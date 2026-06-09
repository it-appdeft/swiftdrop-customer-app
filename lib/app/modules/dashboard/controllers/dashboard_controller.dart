import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:swiftdrop_customer_app/export.dart';

class DashboardController extends BaseController with WidgetsBindingObserver {
  final RxInt currentIndex = 0.obs;
  final RxList<OrderModel> activeOrders = <OrderModel>[].obs;
  final _orderRepo = OrderRepository();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    fetchActiveOrders();
  }

  Future<void> fetchActiveOrders() async {
    final result = await _orderRepo.getActiveOrders();
    if (result.success && result.data != null) {
      activeOrders.assignAll(result.data!);
    }

    // For testing: ensuring we have exactly ONE mock order to see how it looks
    if (activeOrders.isEmpty) {
      activeOrders.add(
        OrderModel(
          id: 'mock_1',
          orderNumber: 'SD-999001',
          status: 'picked_up',
          pickupAddress: 'The Marble Grill, High Street',
          deliveryAddress: 'Your Home',
          items: [],
          totalAmount: 15.0,
          deliveryFee: 2.0,
          distance: 1.5,
          estimatedTime: 12,
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissionOnResume();
      fetchActiveOrders();
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
