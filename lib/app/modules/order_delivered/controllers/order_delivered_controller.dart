import 'package:get/get.dart';
import 'package:swiftdrop_customer_app/app/modules/dashboard/controllers/dashboard_controller.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/repositories/order_repository.dart';

class OrderDeliveredController extends GetxController {
  final order = Rxn<OrderModel>();
  final isLoadingDetail = true.obs;
  final _repo = OrderRepository();

  @override
  void onInit() {
    super.onInit();
    String? targetOrderId;
    if (Get.arguments is OrderModel) {
      final passedOrder = Get.arguments as OrderModel;
      order.value = passedOrder;
      targetOrderId = passedOrder.id;
    } else if (Get.arguments is Map) {
      final map = Get.arguments as Map;
      if (map['order'] is OrderModel) {
        order.value = map['order'] as OrderModel;
      }
      targetOrderId = (map['orderId'] ?? map['id'] ?? order.value?.id)?.toString();
    }

    if (targetOrderId != null && targetOrderId.isNotEmpty) {
      fetchOrderDetail(targetOrderId);
    } else {
      isLoadingDetail.value = false;
    }
  }

  Future<void> fetchOrderDetail(String orderId) async {
    isLoadingDetail.value = true;
    try {
      final res = await _repo.getOrderDetail(orderId);
      if (res.success && res.data != null) {
        final existing = order.value;
        final fetched = res.data!;
        var finalOrder = fetched;
        if (fetched.items.isEmpty && existing != null && existing.items.isNotEmpty) {
          finalOrder = finalOrder.copyWith(items: existing.items);
        }
        if ((fetched.deliveryAddress.isEmpty || fetched.deliveryAddress == 'Customer Location') &&
            existing != null &&
            existing.deliveryAddress.isNotEmpty &&
            existing.deliveryAddress != 'Customer Location') {
          finalOrder = finalOrder.copyWith(deliveryAddress: existing.deliveryAddress);
        }
        order.value = finalOrder;
      }
    } finally {
      isLoadingDetail.value = false;
    }
  }

  void submitFeedback() {
    Get.back();
  }

  void backToHome() {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().fetchActiveOrders(forceRefresh: true);
    }
    Get.offAllNamed('/dashboard');
  }
}
