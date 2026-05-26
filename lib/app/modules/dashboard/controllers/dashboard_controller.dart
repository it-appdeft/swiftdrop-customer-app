import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import '../../../base/base_controller.dart';
import '../../../services/location_service.dart';

class DashboardController extends BaseController {
  final RxInt currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 200));
      LocationService.to.checkLocationPermission();
    });
  }

  void changePage(int index) => currentIndex.value = index;
}
