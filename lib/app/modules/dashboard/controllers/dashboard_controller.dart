import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../../../base/base_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/app_logger.dart';

class DashboardController extends BaseController with WidgetsBindingObserver {
  final RxInt currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissionOnResume();
    }
  }

  Future<void> _checkPermissionOnResume() async {
    final currentRoute = Get.currentRoute;
    if (currentRoute == AppRoutes.address ||
        currentRoute == AppRoutes.deliveryAddress ||
        currentRoute == AppRoutes.mapPicker ||
        currentRoute == AppRoutes.addressDetails) {
      return;
    }

    try {
      final permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        AppLogger.i('Permission revoked — redirecting to address screen');
        Get.toNamed(AppRoutes.address, arguments: {'permissionDenied': true});
      }
    } catch (e) {
      AppLogger.e('Error checking location on resume', e);
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  void changePage(int index) => currentIndex.value = index;
}
