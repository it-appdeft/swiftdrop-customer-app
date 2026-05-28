import 'package:geolocator/geolocator.dart';
import 'package:swiftdrop_customer_app/export.dart';

class LocationService extends GetxService {
  static LocationService get to => Get.find();

  Future<void> checkLocationPermission() async {
    final currentRoute = Get.currentRoute;
    AppLogger.d('LocationService - Checking permission on route: $currentRoute');

    // If we're already on these screens, we don't need to force redirect
    if (currentRoute == AppRoutes.deliveryAddress ||
        currentRoute == AppRoutes.address ||
        currentRoute == AppRoutes.mapPicker ||
        currentRoute == AppRoutes.addressDetails ||
        currentRoute == AppRoutes.splash ||
        currentRoute == AppRoutes.onboarding ||
        currentRoute == AppRoutes.login ||
        currentRoute == AppRoutes.otp ||
        currentRoute == AppRoutes.register) {
      return;
    }

    try {
      LocationPermission permission = await Geolocator.checkPermission();

      AppLogger.d('LocationService - Permission: $permission');

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _redirectToAddress();
      }
    } catch (e) {
      AppLogger.e('Error checking location permission', e);
    }
  }

  void _redirectToAddress() {
    if (Get.currentRoute == AppRoutes.address) return;

    AppLogger.i('Redirecting to Address screen due to missing location permission');

    const args = {'permissionDenied': true};

    if (Get.currentRoute == AppRoutes.dashboard) {
      Get.toNamed(AppRoutes.address, arguments: args);
    } else {
      Get.offAllNamed(AppRoutes.dashboard);
      Future.delayed(const Duration(milliseconds: 300), () {
        if (Get.currentRoute != AppRoutes.address) {
          Get.toNamed(AppRoutes.address, arguments: args);
        }
      });
    }
  }
}
