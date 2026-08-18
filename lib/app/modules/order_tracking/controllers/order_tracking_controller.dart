import 'dart:ui' show Offset;

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../data/models/order_model.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../base/base_controller.dart';
import '../../../services/location_service.dart';
import '../../../services/map_route_service.dart';
import '../../../themes/app_colors.dart';
import '../../../utils/app_logger.dart';
import '../../../utils/app_utils.dart';
import '../../../utils/map_marker_factory.dart';

class OrderTrackingController extends BaseController {
  final OrderRepository _repo;
  final MapRouteService _routeService;

  OrderTrackingController(this._repo, {MapRouteService? routeService})
      : _routeService = routeService ?? MapRouteService();

  final Rx<OrderModel?> order = Rx<OrderModel?>(null);

  final Rx<Set<Marker>> markers = Rx<Set<Marker>>(<Marker>{});
  final Rx<Set<Polyline>> polylines = Rx<Set<Polyline>>(<Polyline>{});
  final RxBool hasMapData = false.obs;
  final RxBool isRouteLoading = false.obs;

  GoogleMapController? _mapController;
  LatLngBounds? _bounds;
  CameraPosition? _initialCamera;
  String _lastGeometryKey = '';

  CameraPosition get initialCamera =>
      _initialCamera ?? const CameraPosition(target: LatLng(51.5074, -0.1278), zoom: 12);

  String get orderId =>
      order.value?.id ??
      (Get.parameters['orderId'] ?? Get.arguments?['orderId'] ?? '').toString();

  @override
  void onInit() {
    super.onInit();
    final rawId = Get.parameters['orderId'] ?? Get.arguments?['orderId'];
    if (rawId != null) loadOrder(rawId.toString());
  }

  @override
  void onClose() {
    // GoogleMap disposes the controller it handed us; only drop the reference.
    _mapController = null;
    super.onClose();
  }

  Future<void> loadOrder(String orderId) async {
    await runAsync(() async {
      final result = await _repo.getOrderTracking(orderId);
      if (result.success && result.data != null) {
        order.value = result.data;
        await _buildTrackingMap(result.data!);
      }
    });
  }

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _fitBounds(animate: false);
  }

  /// Re-frames the map on the full pickup → restaurant → delivery route.
  void recenter() => _fitBounds();

  Future<void> _buildTrackingMap(OrderModel order) async {
    final restaurant = order.hasPickupCoordinates
        ? LatLng(order.pickupLat!, order.pickupLng!)
        : null;

    final locationService = Get.isRegistered<LocationService>()
        ? LocationService.to
        : null;
    final current = (locationService?.lat != null && locationService?.lng != null)
        ? LatLng(locationService!.lat!, locationService.lng!)
        : null;

    // Delivery destination comes from the order; the device position is only a
    // stand-in when the payload carries no address coordinates.
    final delivery = order.hasDeliveryCoordinates
        ? LatLng(order.deliveryLat!, order.deliveryLng!)
        : current;

    final driver =
        order.hasDriverCoordinates ? LatLng(order.driverLat!, order.driverLng!) : null;

    if (restaurant == null && delivery == null) {
      hasMapData.value = false;
      markers.value = <Marker>{};
      polylines.value = <Polyline>{};
      AppLogger.w('[TRACKING] order ${order.id} has no coordinates to plot');
      return;
    }

    final showCurrent = current != null &&
        delivery != null &&
        Geolocator.distanceBetween(
              current.latitude,
              current.longitude,
              delivery.latitude,
              delivery.longitude,
            ) >
            120;

    final waypoints = <LatLng>[
      if (showCurrent) current,
      ?restaurant,
      ?delivery,
    ];

    final stops = waypoints.map((p) => '${p.latitude},${p.longitude}').join('|');
    final driverKey =
        driver != null ? '|d:${driver.latitude},${driver.longitude}' : '';
    final geometryKey = '$stops$driverKey|${order.status}';
    if (geometryKey == _lastGeometryKey) return;
    _lastGeometryKey = geometryKey;

    hasMapData.value = true;
    _initialCamera ??= CameraPosition(
      target: waypoints.first,
      zoom: 13.5,
    );

    await _buildMarkers(
      order: order,
      restaurant: restaurant,
      delivery: delivery,
      current: showCurrent ? current : null,
      driver: driver,
    );

    await _buildRoute(order: order, waypoints: waypoints);

    final framePoints = <LatLng>[
      ...waypoints,
      ?driver,
    ];
    _bounds = MapRouteService.boundsOf(framePoints);
    _fitBounds();
  }

  Future<void> _buildMarkers({
    required OrderModel order,
    LatLng? restaurant,
    LatLng? delivery,
    LatLng? current,
    LatLng? driver,
  }) async {
    final next = <Marker>{};

    if (restaurant != null) {
      next.add(Marker(
        markerId: const MarkerId('restaurant'),
        position: restaurant,
        anchor: const Offset(0.5, 1.0),
        zIndexInt: 2,
        icon: await MapMarkerFactory.restaurantPin(order.restaurantImage),
        infoWindow: InfoWindow(
          title: order.displayRestaurantName,
          snippet: order.restaurantAddressLine,
        ),
      ));
    }

    if (delivery != null) {
      next.add(Marker(
        markerId: const MarkerId('delivery'),
        position: delivery,
        anchor: const Offset(0.5, 1.0),
        zIndexInt: 2,
        icon: await MapMarkerFactory.homePin(),
        infoWindow: InfoWindow(
          title: 'Delivery address',
          snippet: order.deliveryAddress,
        ),
      ));
    }

    if (current != null) {
      next.add(Marker(
        markerId: const MarkerId('current_location'),
        position: current,
        anchor: const Offset(0.5, 0.5),
        zIndexInt: 1,
        icon: await MapMarkerFactory.currentLocationPin(),
        infoWindow: const InfoWindow(title: 'Your location'),
      ));
    }

    if (driver != null && order.isActive) {
      next.add(Marker(
        markerId: const MarkerId('driver'),
        position: driver,
        anchor: const Offset(0.5, 1.0),
        zIndexInt: 3,
        icon: await MapMarkerFactory.driverPin(order.driverImage),
        infoWindow: InfoWindow(
          title: order.driverName ?? 'Delivery partner',
          snippet: 'On the way',
        ),
      ));
    }

    markers.value = next;
  }

  Future<void> _buildRoute({
    required OrderModel order,
    required List<LatLng> waypoints,
  }) async {
    if (waypoints.length < 2) {
      polylines.value = <Polyline>{};
      return;
    }

    isRouteLoading.value = true;
    try {
      List<LatLng> points;
      final encoded = order.routePolyline;
      if (encoded != null && encoded.trim().isNotEmpty) {
        points = PolylineCodec.decode(encoded.trim());
      } else {
        points = await _routeService.buildRoute(waypoints);
      }
      if (points.length < 2) {
        polylines.value = <Polyline>{};
        return;
      }

      polylines.value = {
        Polyline(
          polylineId: const PolylineId('route_casing'),
          points: points,
          color: AppColors.primaryDark.withValues(alpha: 0.35),
          width: 5,
          jointType: JointType.round,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          zIndex: 0,
        ),
        Polyline(
          polylineId: const PolylineId('route'),
          points: points,
          color: AppColors.primary,
          width: 3,
          jointType: JointType.round,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          zIndex: 1,
        ),
      };
    } finally {
      isRouteLoading.value = false;
    }
  }

  Future<void> _fitBounds({bool animate = true}) async {
    final bounds = _bounds;
    final map = _mapController;
    if (bounds == null || map == null) return;

    final update = CameraUpdate.newLatLngBounds(bounds, 60);
    // The platform view reports a null size until it has been laid out, which
    // makes the first bounds update throw; one retry covers that window.
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        await (animate ? map.animateCamera(update) : map.moveCamera(update));
        return;
      } catch (e) {
        AppLogger.w('[TRACKING] camera fit retry | $e');
        await Future.delayed(const Duration(milliseconds: 350));
      }
    }
  }

  Future<void> refreshTracking() async {
    final id = orderId;
    if (id.isEmpty) return;
    _lastGeometryKey = '';
    await loadOrder(id);
  }

  Future<void> cancelOrder(String orderId) async {
    await Future.delayed(const Duration(seconds: 1));

    final result = await _repo.cancelOrder(orderId);
    if (result.success) {
      Get.back();
      AppUtils.showSuccess('order cancelled successfully');
      _lastGeometryKey = '';
      loadOrder(orderId);
    } else {
      Get.back();
      AppUtils.showError(
        result.message.isNotEmpty ? result.message : 'Failed to cancel order',
      );
    }
  }
}
