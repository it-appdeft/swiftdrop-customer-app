import 'package:geolocator/geolocator.dart';
import 'package:swiftdrop_customer_app/export.dart';

class LocationService extends GetxService {
  static LocationService get to => Get.find();

  // ==========================================
  // TEMPORARY STATIC LOCATION FOR TESTING
  // TODO: Uncomment original code when done testing
  // ==========================================
  static const double testLat = 30.7046486;
  static const double testLng = 76.7178726;

  Position? _gpsPosition;

  // --- TESTING STATIC COORDINATES ---
  double? _sessionLat = testLat;
  double? _sessionLng = testLng;

  // --- ORIGINAL (UNCOMMENT FOR PRODUCTION) ---
  // double? _sessionLat;
  // double? _sessionLng;

  // Display label for the location bar — updated by reverse geocode
  final RxString displayAddress = 'Select Location'.obs;

  // Changes ONLY when lat/lng coordinates change.
  // HomeController watches this to trigger reloads, NOT displayAddress,
  // so reverse-geocode label updates don't cause unnecessary dashboard reloads.
  final RxString locationKey = '$testLat,$testLng'.obs;
  // final RxString locationKey = ''.obs; // ORIGINAL

  bool get hasLocation => true;
  // bool get hasLocation => _sessionLat != null && _sessionLng != null; // ORIGINAL
  double? get lat => _sessionLat ?? testLat;
  // double? get lat => _sessionLat; // ORIGINAL
  double? get lng => _sessionLng ?? testLng;
  // double? get lng => _sessionLng; // ORIGINAL

  /// Called once per session from HomeController._initFlow.
  /// Always fetches fresh GPS — never restores from storage.
  Future<bool> initLocation() async {
    // --- ORIGINAL GPS PERMISSION CHECK (UNCOMMENT FOR PRODUCTION) ---
    // LocationPermission permission = await Geolocator.checkPermission();
    // if (permission == LocationPermission.denied) {
    //   permission = await Geolocator.requestPermission();
    // }
    // if (permission != LocationPermission.whileInUse &&
    //     permission != LocationPermission.always) {
    //   return false;
    // }
    // return _fetchGps();

    return _fetchGps();
  }

  Future<bool> _fetchGps() async {
    try {
      // --- TESTING STATIC COORDINATES ---
      _sessionLat = testLat;
      _sessionLng = testLng;
      locationKey.value = '$testLat,$testLng';
      displayAddress.value = 'Sahibzada Ajit Singh Nagar';
      // Background reverse geocode
      _reverseGeocode(testLat, testLng);
      return true;

      // --- ORIGINAL GPS FETCH (UNCOMMENT FOR PRODUCTION) ---
      // _gpsPosition = await Geolocator.getCurrentPosition(
      //   desiredAccuracy: LocationAccuracy.high,
      // );
      // _sessionLat = _gpsPosition!.latitude;
      // _sessionLng = _gpsPosition!.longitude;
      // locationKey.value = '${_gpsPosition!.latitude},${_gpsPosition!.longitude}';
      // displayAddress.value = 'Current Location';
      // _reverseGeocode(_gpsPosition!.latitude, _gpsPosition!.longitude);
      // return true;
    } catch (e) {
      _sessionLat = testLat;
      _sessionLng = testLng;
      locationKey.value = '$testLat,$testLng';
      return true;
      // AppLogger.e('[Location] GPS fetch failed', e);
      // return false;
    }
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    try {
      final response = await Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      )).get(
        'https://maps.googleapis.com/maps/api/geocode/json',
        queryParameters: {
          'latlng': '$lat,$lng',
          'key': AppConfig.googleMapsApiKey,
          'language': 'en',
        },
      );
      if (response.data['status'] != 'OK') return;
      final results = response.data['results'] as List;
      if (results.isEmpty) return;
      final components = (results[0]['address_components'] as List? ?? []);
      String streetNumber = '';
      String route = '';
      String city = '';
      for (final comp in components) {
        final types = (comp['types'] as List).cast<String>();
        final name = comp['long_name'] as String? ?? '';
        if (streetNumber.isEmpty && types.contains('street_number')) streetNumber = name;
        if (route.isEmpty && types.contains('route')) route = name;
        if (city.isEmpty &&
            (types.contains('postal_town') || types.contains('locality'))) {
          city = name;
        }
      }
      final street = [streetNumber, route].where((s) => s.isNotEmpty).join(' ');
      final label = [street, city].where((s) => s.isNotEmpty).join(', ');
      if (label.isNotEmpty) displayAddress.value = label;
    } catch (e) {
      AppLogger.e('[Location] Reverse geocode failed', e);
    }
  }

  /// Scenario 3 & 4: User selects a saved address or confirms a searched place.
  /// Returns false if the user rejected the far-location alert.
  Future<bool> selectLocation({
    required double lat,
    required double lng,
    required String label,
  }) async {
    if (_gpsPosition != null) {
      final distKm = Geolocator.distanceBetween(
            _gpsPosition!.latitude,
            _gpsPosition!.longitude,
            lat,
            lng,
          ) /
          1000;
      if (distKm > 50) {
        final confirmed = await _showFarLocationAlert();
        if (confirmed != true) return false;
      }
    }
    _sessionLat = lat;
    _sessionLng = lng;
    displayAddress.value = label;
    locationKey.value = '$lat,$lng';
    return true;
  }

  Future<bool?> _showFarLocationAlert() {
    return Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        title: Text(
          'Location is Far',
          style: AppTextStyles.pLargeSemiBold.copyWith(
            color: AppColors.lightSurfaceDarkText,
          ),
        ),
        content: Text(
          'This location is far from your current position. Restaurants may not deliver here. Continue?',
          style: AppTextStyles.pSmall.copyWith(
            color: AppColors.lightSurfaceSubtitle,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'No',
              style: AppTextStyles.pSmallMedium.copyWith(
                color: AppColors.lightSurfaceSubtitle,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'Yes',
              style: AppTextStyles.pSmallMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
