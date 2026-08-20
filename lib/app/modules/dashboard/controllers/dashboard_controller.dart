
import 'package:geolocator/geolocator.dart';
import 'package:swiftdrop_customer_app/app/modules/order_history/controllers/order_history_controller.dart';
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

  Future<void> fetchActiveOrders({bool forceRefresh = false}) async {
    final result = await _orderRepo.getActiveOrders(forceRefresh: forceRefresh);
    if (result.success && result.data != null) {
      activeOrders.assignAll(result.data!);
    } else {
      activeOrders.clear();
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

  void changePage(int index) {
    currentIndex.value = index;
    if (index == 0) {
      fetchActiveOrders();
    } else if (index == 2) {
      if (Get.isRegistered<OrderHistoryController>()) {
        Get.find<OrderHistoryController>().loadOrders(force: true);
      }
    }
  }
}
