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
    NotificationService.to.syncFcmTokenWithServer();
    _setupRealtimeListeners();
  }

  void _setupRealtimeListeners() {
    if (!Get.isRegistered<RealtimeService>() || !Get.isRegistered<AuthService>()) return;
    final userId = AuthService.to.currentUser.value?.id;
    if (userId == null || userId.toString().isEmpty) return;

    final customerChannel = 'private-customer.$userId';
    RealtimeService.to.subscribeToChannel(customerChannel);

    RealtimeService.to.onEvent(customerChannel, 'order.created', (data) {
      AppLogger.i('Realtime event: order.created received on $customerChannel');
      fetchActiveOrders(forceRefresh: true);
      final payload = Map<String, dynamic>.from(data);
      payload['status'] = payload['status'] ?? 'placed';
      AppUtils.showOrderStatusNotification(payload);
    });
    RealtimeService.to.onEvent(customerChannel, 'order.status.updated', (data) {
      AppLogger.i('Realtime event: order.status.updated received on $customerChannel: $data');
      fetchActiveOrders(forceRefresh: true);
      AppUtils.showOrderStatusNotification(data);
    });
    RealtimeService.to.onEvent(customerChannel, 'order.cancelled', (data) {
      AppLogger.i('Realtime event: order.cancelled received on $customerChannel');
      fetchActiveOrders(forceRefresh: true);
      final payload = Map<String, dynamic>.from(data);
      payload['status'] = 'cancelled';
      AppUtils.showOrderStatusNotification(payload);
    });
    RealtimeService.to.onEvent(customerChannel, 'order.delivered', (data) {
      AppLogger.i('Realtime event: order.delivered received on $customerChannel');
      fetchActiveOrders(forceRefresh: true);
      final payload = Map<String, dynamic>.from(data);
      payload['status'] = 'delivered';
      AppUtils.showOrderStatusNotification(payload);
    });
    RealtimeService.to.onEvent(customerChannel, 'delivery.cancelled', (data) {
      AppLogger.i('Realtime event: delivery.cancelled received on $customerChannel');
      fetchActiveOrders(forceRefresh: true);
      final payload = Map<String, dynamic>.from(data);
      payload['status'] = 'cancelled';
      AppUtils.showOrderStatusNotification(payload);
    });
    RealtimeService.to.onEvent(customerChannel, 'dashboard.updated', (_) {
      AppLogger.i('Realtime event: dashboard.updated received on $customerChannel');
      fetchActiveOrders(forceRefresh: true);
    });
  }

  void _removeRealtimeListeners() {
    if (!Get.isRegistered<RealtimeService>() || !Get.isRegistered<AuthService>()) return;
    final userId = AuthService.to.currentUser.value?.id;
    if (userId == null || userId.toString().isEmpty) return;

    final customerChannel = 'private-customer.$userId';
    RealtimeService.to.removeEventHandler(customerChannel, 'order.created');
    RealtimeService.to.removeEventHandler(customerChannel, 'order.status.updated');
    RealtimeService.to.removeEventHandler(customerChannel, 'order.cancelled');
    RealtimeService.to.removeEventHandler(customerChannel, 'order.delivered');
    RealtimeService.to.removeEventHandler(customerChannel, 'delivery.cancelled');
    RealtimeService.to.removeEventHandler(customerChannel, 'dashboard.updated');
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
      NotificationService.to.syncFcmTokenWithServer();
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
    _removeRealtimeListeners();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  void changePage(int index) {
    currentIndex.value = index;
    if (index == 0) {
      fetchActiveOrders();
      NotificationService.to.syncFcmTokenWithServer();
    } else if (index == 2) {
      if (Get.isRegistered<OrderHistoryController>()) {
        Get.find<OrderHistoryController>().loadOrders(force: true);
      }
    }
  }

  void handleBackPress() {
    if (currentIndex.value != 0) {
      changePage(0);
    } else {
      AppUtils.showExitConfirmationDialog();
    }
  }
}