import 'package:geolocator/geolocator.dart';
import 'package:swiftdrop_customer_app/export.dart';

class LocationService extends GetxService with WidgetsBindingObserver {
  static LocationService get to => Get.find();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    // Use a short delay to allow the app to initialize before first check
    Future.delayed(const Duration(seconds: 1), checkLocationPermission);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    AppLogger.d('LocationService - AppLifecycleState: $state');
    if (state == AppLifecycleState.resumed) {
      // Increased delay to allow the OS to update permission status internally
      Future.delayed(const Duration(milliseconds: 500), checkLocationPermission);
    }
  }

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
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();

      AppLogger.d('Location Status - Enabled: $serviceEnabled, Permission: $permission');

      if (!serviceEnabled || 
          permission == LocationPermission.denied || 
          permission == LocationPermission.deniedForever) {
        _redirectToDelivery();
      }
    } catch (e) {
      AppLogger.e('Error checking location permission', e);
    }
  }

  void _redirectToDelivery() {
    if (Get.currentRoute == AppRoutes.deliveryAddress) return;

    AppLogger.i('Redirecting to Delivery Address screen due to missing permissions');

    const args = {'forceRedirect': true};

    if (Get.currentRoute == AppRoutes.dashboard) {
      Get.toNamed(AppRoutes.deliveryAddress, arguments: args);
    } else {
      Get.offAllNamed(AppRoutes.dashboard);
      Future.delayed(const Duration(milliseconds: 300), () {
        if (Get.currentRoute != AppRoutes.deliveryAddress) {
          Get.toNamed(AppRoutes.deliveryAddress, arguments: args);
        }
      });
    }
  }
}
