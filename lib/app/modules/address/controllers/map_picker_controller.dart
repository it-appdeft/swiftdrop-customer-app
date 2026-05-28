import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:swiftdrop_customer_app/export.dart';

class MapPickerController extends GetxController {
  final _mapCompleter = Completer<GoogleMapController>();

  final RxString locationName = ''.obs;
  final RxString locationAddress = ''.obs;
  final RxString locationCity = ''.obs;
  final RxString locationCounty = ''.obs;
  final RxString locationPostcode = ''.obs;
  final RxBool isGeocoding = false.obs;

  double get currentLat => _lastCamera.target.latitude;
  double get currentLng => _lastCamera.target.longitude;

  late final CameraPosition initialCameraPosition;

  CameraPosition _lastCamera = const CameraPosition(
    target: LatLng(51.5074, -0.1278),
    zoom: 15.0,
  );
  bool _skipNextGeocode = false;
  bool _useCurrentLocation = false;

  final _http = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    _useCurrentLocation = args is Map && args['useCurrentLocation'] == true;

    if (args is Map && args['lat'] != null && args['lng'] != null) {
      final lat = (args['lat'] as num).toDouble();
      final lng = (args['lng'] as num).toDouble();
      locationName.value = args['name'] as String? ?? '';
      locationAddress.value = args['address'] as String? ?? '';
      locationCity.value = args['city'] as String? ?? '';
      locationCounty.value = args['county'] as String? ?? '';
      locationPostcode.value = args['postcode'] as String? ?? '';
      _lastCamera = CameraPosition(target: LatLng(lat, lng), zoom: 16.0);
      _skipNextGeocode = true;
    }

    initialCameraPosition = _lastCamera;
  }

  @override
  void onReady() {
    super.onReady();
    if (_useCurrentLocation) _goToCurrentLocation();
  }

  void onMapCreated(GoogleMapController controller) {
    if (!_mapCompleter.isCompleted) _mapCompleter.complete(controller);
  }

  void onCameraMove(CameraPosition position) {
    _lastCamera = position;
  }

  void onCameraIdle() {
    if (_skipNextGeocode) {
      _skipNextGeocode = false;
      return;
    }
    _reverseGeocode(_lastCamera.target.latitude, _lastCamera.target.longitude);
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    isGeocoding.value = true;
    try {
      final response = await _http.get(
        'https://maps.googleapis.com/maps/api/geocode/json',
        queryParameters: {
          'latlng': '$lat,$lng',
          'key': AppConfig.googleMapsApiKey,
          'language': 'en',
        },
      );
      final results = response.data['results'] as List?;
      if (results == null || results.isEmpty) return;

      final first = results.first as Map;
      final components = first['address_components'] as List;
      final formatted = first['formatted_address'] as String? ?? '';

      String name = '';
      for (final c in components) {
        final types = c['types'] as List;
        if (types.contains('premise') ||
            types.contains('establishment') ||
            types.contains('point_of_interest')) {
          name = c['long_name'] as String;
          break;
        }
      }
      if (name.isEmpty) {
        String num = '', route = '';
        for (final c in components) {
          final types = c['types'] as List;
          if (types.contains('street_number')) num = c['long_name'] as String;
          if (types.contains('route')) route = c['long_name'] as String;
        }
        name = [num, route].where((s) => s.isNotEmpty).join(' ');
      }
      if (name.isEmpty) name = formatted.split(',').first;

      String city = '';
      String county = '';
      String postcode = '';
      for (final c in components) {
        final types = c['types'] as List;
        if (city.isEmpty &&
            (types.contains('locality') || types.contains('postal_town'))) {
          city = c['long_name'] as String;
        }
        if (county.isEmpty &&
            types.contains('administrative_area_level_2')) {
          county = c['long_name'] as String;
        }
        if (postcode.isEmpty && types.contains('postal_code')) {
          postcode = c['long_name'] as String;
        }
      }

      locationName.value = name;
      locationAddress.value = formatted;
      locationCity.value = city;
      locationCounty.value = county;
      locationPostcode.value = postcode;
    } catch (_) {
    } finally {
      isGeocoding.value = false;
    }
  }

  void setLocationFromSearch(Map<String, dynamic> result) {
    final lat = (result['lat'] as num).toDouble();
    final lng = (result['lng'] as num).toDouble();
    locationName.value = result['name'] as String? ?? '';
    locationAddress.value = result['address'] as String? ?? '';
    locationCity.value = '';
    locationCounty.value = '';
    locationPostcode.value = '';
    _animateTo(lat, lng);
  }

  Future<void> _goToCurrentLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _skipNextGeocode = false;
      await _animateTo(pos.latitude, pos.longitude);
    } catch (_) {}
  }

  Future<void> _animateTo(double lat, double lng) async {
    final map = await _mapCompleter.future;
    map.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 16.0),
      ),
    );
  }
}
