import 'package:get/get.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../base/base_controller.dart';
import '../../../utils/app_utils.dart';

class OrderTrackingController extends BaseController {
  final OrderRepository _repo;
  OrderTrackingController(this._repo);

  final Rx<OrderModel?> order = Rx<OrderModel?>(null);

  @override
  void onInit() {
    super.onInit();
    final orderId = Get.parameters['orderId'] ?? Get.arguments?['orderId'];
    if (orderId != null) loadOrder(orderId as String);
  }

  Future<void> loadOrder(String orderId) async {
    await runAsync(() async {
      final result = await _repo.getOrderDetail(orderId);
      if (result.success && result.data != null) {
        order.value = result.data;
      }
    });
  }

  Future<void> cancelOrder(String orderId) async {
    // Dialog will be shown from the view
    // Adding a small delay to ensure the bottom sheet is visible to the user
    await Future.delayed(const Duration(seconds: 1));
    
    final result = await _repo.cancelOrder(orderId);
    if (result.success) {
      Get.back(); // Close cancellation bottom sheet
      AppUtils.showSuccess('order cancelled successfully');
      loadOrder(orderId); // Refresh order status
    } else {
      Get.back();
      AppUtils.showError(result.message ?? 'Failed to cancel order');
    }
  }
}
