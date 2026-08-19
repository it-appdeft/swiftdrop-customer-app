import '../../../../export.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/repositories/order_repository.dart';

class OrderDetailsController extends GetxController {
  final order = Rxn<OrderModel>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final partnerRating = 0.0.obs;
  final _repo = OrderRepository();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is OrderModel) {
      order.value = Get.arguments as OrderModel;
      if (order.value != null && order.value!.id.isNotEmpty) {
        fetchOrderDetail(order.value!.id);
      }
    } else if (Get.arguments is Map) {
      final map = Get.arguments as Map;
      if (map['order'] is OrderModel) {
        order.value = map['order'] as OrderModel;
      }
      final id = map['orderId'] ?? map['id'] ?? order.value?.id;
      if (id != null && id.toString().isNotEmpty) {
        fetchOrderDetail(id.toString());
      }
    }
  }

  Future<void> fetchOrderDetail(String orderId) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final res = await _repo.getOrderDetail(orderId);
      if (res.success && res.data != null) {
        order.value = res.data!;
      } else if (res.message.isNotEmpty) {
        errorMessage.value = res.message;
      }
    } catch (e) {
      AppLogger.w('[ORDER_DETAILS] fetchOrderDetail error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void onReorder() {
    AppUtils.showSuccess('Reordering order #${order.value?.orderNumber ?? ""}...');
  }
}
