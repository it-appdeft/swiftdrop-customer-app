import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:swiftdrop_customer_app/app/modules/order_history/controllers/order_history_controller.dart';


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

  CameraPosition get initialCamera {
    if (_initialCamera != null) return _initialCamera!;
    final o = order.value;
    if (o?.pickupLat != null && o?.pickupLng != null) {
      return CameraPosition(target: LatLng(o!.pickupLat!, o.pickupLng!), zoom: 14.0);
    }
    if (o?.deliveryLat != null && o?.deliveryLng != null) {
      return CameraPosition(target: LatLng(o!.deliveryLat!, o.deliveryLng!), zoom: 14.0);
    }
    return const CameraPosition(target: LatLng(30.7046, 76.7179), zoom: 14.0);
  }

  String get orderId =>
      (order.value?.id.isNotEmpty == true ? order.value!.id : null) ??
      Get.parameters['orderId'] ??
      Get.parameters['id'] ??
      Get.arguments?['orderId'] ??
      Get.arguments?['id'] ??
      (Get.arguments is OrderModel && (Get.arguments as OrderModel).id.isNotEmpty
          ? (Get.arguments as OrderModel).id
          : null) ??
      (Get.arguments is Map && Get.arguments['order'] is OrderModel && (Get.arguments['order'] as OrderModel).id.isNotEmpty
          ? (Get.arguments['order'] as OrderModel).id
          : null) ??
      (order.value?.uuid != null && order.value!.uuid!.isNotEmpty ? order.value!.uuid : null) ??
      Get.parameters['orderUuid'] ??
      Get.parameters['uuid'] ??
      Get.arguments?['uuid'] ??
      Get.arguments?['orderUuid'] ??
      '';

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is OrderModel) {
      order.value = Get.arguments as OrderModel;
    } else if (Get.arguments is Map && Get.arguments['order'] is OrderModel) {
      order.value = Get.arguments['order'] as OrderModel;
    }

    if (order.value != null && order.value!.isDelivered) {
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().fetchActiveOrders(forceRefresh: true);
      }
      Get.offNamed(
        AppRoutes.orderDelivered,
        arguments: {
          'id': order.value!.id,
          'orderId': order.value!.id,
          'orderUuid': order.value!.uuid ?? order.value!.targetId,
          'order': order.value,
          'fromOrderTracking': true,
        },
      );
      return;
    }

    final rawId = (order.value?.id.isNotEmpty == true ? order.value!.id : null) ??
        Get.parameters['orderId'] ??
        Get.parameters['id'] ??
        Get.arguments?['orderId'] ??
        Get.arguments?['id'] ??
        (order.value?.uuid != null && order.value!.uuid!.isNotEmpty ? order.value!.uuid : null) ??
        Get.parameters['orderUuid'] ??
        Get.parameters['uuid'] ??
        Get.arguments?['uuid'] ??
        Get.arguments?['orderUuid'] ??
        order.value?.targetId;

    if (rawId != null && rawId.toString().isNotEmpty) {
      final id = rawId.toString();
      if (order.value != null) {
        _buildTrackingMap(order.value!);
        loadOrder(id, isBackgroundRefresh: true);
      } else {
        loadOrder(id, isBackgroundRefresh: false);
      }
      _setupRealtimeListeners(id);
    }
  }

  void _setupRealtimeListeners(String currentOrderId) {
    if (!Get.isRegistered<RealtimeService>() || currentOrderId.isEmpty) return;

    final channelsToSubscribe = <String>{};
    channelsToSubscribe.add('private-order.$currentOrderId');

    final currentUuid = order.value?.uuid ??
        (Get.arguments is Map ? Get.arguments['uuid']?.toString() : null) ??
        (Get.arguments is OrderModel ? (Get.arguments as OrderModel).uuid : null);
    if (currentUuid != null && currentUuid.isNotEmpty && currentUuid != currentOrderId) {
      channelsToSubscribe.add('private-order.$currentUuid');
    }

    // Helper handler for status update
    void handleStatusUpdate(Map<String, dynamic> data) {
      AppLogger.i('⚡ [OrderTracking] Realtime event: order.status.updated received: $data');
      final eventUuid = (data['order_uuid'] ?? data['uuid'])?.toString();
      final eventId = (data['order_id'] ?? data['id'])?.toString();
      final ordUuid = order.value?.uuid ?? (currentOrderId.contains('-') ? currentOrderId : null);
      final ordId = order.value?.id ?? currentOrderId;

      // If event matches this order or no order loaded yet
      final isMatching = (eventUuid != null && ordUuid != null && eventUuid == ordUuid) ||
          (eventId != null && eventId == ordId) ||
          (eventUuid == currentOrderId || eventId == currentOrderId) ||
          order.value == null;

      if (!isMatching) return;

      final newStatus = (data['status'] ?? data['order_status'] ?? '').toString();
      final newOrdStatus = (data['order_status'] ?? '').toString();
      final newDelStatus = (data['delivery_status'] ?? '').toString();

      if (order.value != null) {
        order.value = order.value!.copyWith(
          status: newStatus.isNotEmpty ? newStatus : null,
          orderStatus: newOrdStatus.isNotEmpty ? newOrdStatus : null,
          deliveryStatus: newDelStatus.isNotEmpty ? newDelStatus : null,
        );
        _buildTrackingMap(order.value!);
      }
      loadOrder(currentOrderId, isBackgroundRefresh: true);
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().fetchActiveOrders(forceRefresh: true);
      }
      if (newDelStatus.isNotEmpty || newStatus.isNotEmpty) {
        AppUtils.showOrderStatusNotification(data);
      }
    }

    for (final orderChannel in channelsToSubscribe) {
      RealtimeService.to.subscribeToChannel(orderChannel);
      RealtimeService.to.onEvent(orderChannel, 'order.status.updated', handleStatusUpdate);

      // Driver Live Location Updated
      RealtimeService.to.onEvent(orderChannel, 'driver.location.updated', (data) {
        AppLogger.d('Realtime event: driver.location.updated received: $data');
        double? lat = (data['latitude'] as num?)?.toDouble() ?? (data['lat'] as num?)?.toDouble();
        double? lng = (data['longitude'] as num?)?.toDouble() ?? (data['lng'] as num?)?.toDouble();
        if (lat == null && data['driver'] is Map) {
          lat = (data['driver']['latitude'] as num?)?.toDouble() ?? (data['driver']['lat'] as num?)?.toDouble();
          lng = (data['driver']['longitude'] as num?)?.toDouble() ?? (data['driver']['lng'] as num?)?.toDouble();
        }
        if (lat != null && lng != null && order.value != null) {
          order.value = order.value!.copyWith(driverLat: lat, driverLng: lng);
          _buildTrackingMap(order.value!);
        } else {
          loadOrder(currentOrderId, isBackgroundRefresh: true);
        }
      });

      // Order Cancelled
      RealtimeService.to.onEvent(orderChannel, 'order.cancelled', (_) {
        AppLogger.i('Realtime event: order.cancelled received');
        loadOrder(currentOrderId, isBackgroundRefresh: true);
      });

      // Order Delivered
      RealtimeService.to.onEvent(orderChannel, 'order.delivered', (_) {
        AppLogger.i('Realtime event: order.delivered received');
        loadOrder(currentOrderId, isBackgroundRefresh: true);
      });
    }

    // Customer Channels
    final customerId = Get.isRegistered<AuthService>() ? AuthService.to.currentUser.value?.id : null;
    if (customerId != null && customerId.toString().isNotEmpty) {
      final customerChannel = 'private-customer.$customerId';
      RealtimeService.to.subscribeToChannel(customerChannel);
      RealtimeService.to.onEvent(customerChannel, 'order.status.updated', handleStatusUpdate);
    }
  }

  void _removeRealtimeListeners(String currentOrderId) {
    if (!Get.isRegistered<RealtimeService>() || currentOrderId.isEmpty) return;

    final channelsToUnsubscribe = <String>{};
    channelsToUnsubscribe.add('private-order.$currentOrderId');

    final currentUuid = order.value?.uuid;
    if (currentUuid != null && currentUuid.isNotEmpty && currentUuid != currentOrderId) {
      channelsToUnsubscribe.add('private-order.$currentUuid');
    }

    for (final orderChannel in channelsToUnsubscribe) {
      RealtimeService.to.removeEventHandler(orderChannel, 'order.status.updated');
      RealtimeService.to.removeEventHandler(orderChannel, 'driver.location.updated');
      RealtimeService.to.removeEventHandler(orderChannel, 'order.cancelled');
      RealtimeService.to.removeEventHandler(orderChannel, 'order.delivered');
      RealtimeService.to.unsubscribeFromChannel(orderChannel);
    }

    final customerId = Get.isRegistered<AuthService>() ? AuthService.to.currentUser.value?.id : null;
    if (customerId != null && customerId.toString().isNotEmpty) {
      RealtimeService.to.removeEventHandler('private-customer.$customerId', 'order.status.updated');
    }
  }

  @override
  void onClose() {
    _removeRealtimeListeners(orderId);
    // GoogleMap disposes the controller it handed us; only drop the reference.
    _mapController = null;
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().fetchActiveOrders(forceRefresh: true);
    }
    super.onClose();
  }

  Future<void> loadOrder(String orderId, {bool isBackgroundRefresh = false}) async {
    final showLoader = !isBackgroundRefresh && order.value == null;
    await runAsync(() async {
      final result = await _repo.getOrderTracking(orderId);
      if (result.success && result.data != null) {
        order.value = result.data;
        if (result.data!.isDelivered) {
          if (Get.isRegistered<DashboardController>()) {
            Get.find<DashboardController>().fetchActiveOrders(forceRefresh: true);
          }
          Get.offNamed(
            AppRoutes.orderDelivered,
            arguments: {
              'id': result.data!.id,
              'orderId': result.data!.id,
              'orderUuid': result.data!.uuid ?? result.data!.targetId,
              'order': result.data,
              'fromOrderTracking': true,
            },
          );
          return;
        }
        await _buildTrackingMap(result.data!);
      }
    }, showLoadingIndicator: showLoader, handleErrors: showLoader);
  }

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _fitBounds(animate: false);
  }

  /// Re-frames the map on the full route.
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

    // Delivery destination comes from the order; fallback to current position
    final delivery = order.hasDeliveryCoordinates
        ? LatLng(order.deliveryLat!, order.deliveryLng!)
        : current;

    final driver =
        order.hasDriverCoordinates ? LatLng(order.driverLat!, order.driverLng!) : null;

    final effectiveDriver = driver ?? (order.isPickedUp || order.isDriverAssigned ? restaurant : null);

    if (restaurant == null && delivery == null && effectiveDriver == null) {
      hasMapData.value = false;
      markers.value = <Marker>{};
      polylines.value = <Polyline>{};
      AppLogger.w('[TRACKING] order ${order.id} has no coordinates to plot');
      return;
    }

    // Delivery route: when order is picked up, route starts from driver (or restaurant fallback) to delivery address
    final routeStart = order.isPickedUp ? (effectiveDriver ?? restaurant) : (restaurant ?? effectiveDriver);

    final waypoints = <LatLng>[
      if (routeStart != null) routeStart,
      if (delivery != null) delivery,
    ];

    final stops = waypoints.map((p) => '${p.latitude.toStringAsFixed(5)},${p.longitude.toStringAsFixed(5)}').join('|');
    final driverKey = effectiveDriver != null
        ? '|d:${effectiveDriver.latitude.toStringAsFixed(5)},${effectiveDriver.longitude.toStringAsFixed(5)}'
        : '';
    final geometryKey = '$stops$driverKey|${order.status}';

    hasMapData.value = true;
    _initialCamera ??= CameraPosition(
      target: waypoints.isNotEmpty
          ? waypoints.first
          : (restaurant ?? const LatLng(30.7046, 76.7179)),
      zoom: 13.5,
    );

    await _buildMarkers(
      order: order,
      restaurant: restaurant,
      delivery: delivery,
      current: current,
      driver: effectiveDriver,
    );

    if (geometryKey != _lastGeometryKey) {
      _lastGeometryKey = geometryKey;
      await _buildRoute(order: order, waypoints: waypoints);
    }

    final framePoints = <LatLng>[
      ...waypoints,
      if (effectiveDriver != null) effectiveDriver,
      if (restaurant != null) restaurant,
      if (delivery != null) delivery,
    ];
    if (framePoints.isNotEmpty) {
      _bounds = MapRouteService.boundsOf(framePoints);
      _fitBounds();
    }
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
          title: order.driverName?.trim().isNotEmpty == true ? order.driverName! : 'Delivery partner',
          snippet: order.isPickedUp ? 'On the way with your order' : 'Delivery partner',
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
    if (bounds == null || map == null || isClosed) return;
    if (order.value?.status.toString().toLowerCase() == 'cancelled') return;

    final center = LatLng(
      (bounds.southwest.latitude + bounds.northeast.latitude) / 2,
      (bounds.southwest.longitude + bounds.northeast.longitude) / 2,
    );

    // Immediately position camera on target center
    try {
      await map.moveCamera(CameraUpdate.newLatLngZoom(center, 13.5));
    } catch (_) {}

    final update = CameraUpdate.newLatLngBounds(bounds, 60);
    // The platform view reports a null size until it has been laid out, which
    // makes the first bounds update throw; retries cover that window.
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        if (isClosed) return;
        await Future.delayed(Duration(milliseconds: 200 * (attempt + 1)));
        if (isClosed || _mapController == null) return;
        await (animate ? map.animateCamera(update) : map.moveCamera(update));
        return;
      } catch (e) {
        if (isClosed) return;
        AppLogger.w('[TRACKING] camera fit retry | $e');
      }
    }
  }

  Future<void> refreshTracking() async {
    final id = orderId;
    if (id.isEmpty) return;
    _lastGeometryKey = '';
    await loadOrder(id, isBackgroundRefresh: true);
  }

  final RxList<String> cancellationReasons = <String>[].obs;
  final RxBool isFetchingReasons = false.obs;

  Future<List<String>> fetchCancellationReasons() async {
    if (cancellationReasons.isNotEmpty) return cancellationReasons;
    isFetchingReasons.value = true;
    try {
      final result = await _repo.getCancellationReasons();
      if (result.success && result.data != null && result.data!.isNotEmpty) {
        cancellationReasons.value = result.data!;
      }
    } finally {
      isFetchingReasons.value = false;
    }
    return cancellationReasons;
  }

  Future<bool> cancelOrder(String orderId, {String? reason}) async {
    isLoading.value = true;
    try {
      final effectiveIdentifier = (order.value?.id.isNotEmpty == true ? order.value!.id : null) ??
          (order.value?.uuid != null && order.value!.uuid!.isNotEmpty ? order.value!.uuid! : orderId);

      final result = await _repo.cancelOrder(effectiveIdentifier, reason: reason);
      if (result.success) {
        AppUtils.showSuccess(
          result.message.isNotEmpty ? result.message : 'Order cancelled successfully',
        );
        _lastGeometryKey = '';
        await loadOrder(effectiveIdentifier, isBackgroundRefresh: true);
        if (Get.isRegistered<DashboardController>()) {
          final dash = Get.find<DashboardController>();
          dash.activeOrders.removeWhere((o) =>
              o.id == orderId ||
              o.uuid == orderId ||
              o.id == effectiveIdentifier ||
              o.uuid == effectiveIdentifier ||
              o.orderNumber == orderId);
          dash.fetchActiveOrders(forceRefresh: true);
        }
        if (Get.isRegistered<OrderHistoryController>()) {
          Get.find<OrderHistoryController>().loadOrders(force: true);
        }
        return true;
      } else {
        AppUtils.showError(
          result.message.isNotEmpty ? result.message : 'Failed to cancel order',
        );
        return false;
      }
    } finally {
      isLoading.value = false;
    }
  }
}
