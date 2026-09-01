import '../../../../export.dart';
import '../../cart/controllers/cart_controller.dart';

class OrderDetailsController extends GetxController {
  final order = Rxn<OrderModel>();
  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final partnerRating = 0.0.obs;
  final _repo = OrderRepository();

  @override
  void onInit() {
    super.onInit();
    String? targetId;
    if (Get.arguments is OrderModel) {
      final passedOrder = Get.arguments as OrderModel;
      targetId = (passedOrder.id.isNotEmpty && int.tryParse(passedOrder.id) != null)
          ? passedOrder.id
          : (passedOrder.uuid ?? passedOrder.targetId);
    } else if (Get.arguments is Map) {
      final map = Get.arguments as Map;
      final id = map['id'] ??
          map['orderId'] ??
          map['orderUuid'] ??
          map['uuid'] ??
          (map['order'] is OrderModel ? (map['order'] as OrderModel).targetId : null);
      if (id != null && id.toString().isNotEmpty) {
        targetId = id.toString();
      }
    } else if (Get.parameters.containsKey('id')) {
      targetId = Get.parameters['id'];
    }

    isLoading.value = true;
    if (targetId != null && targetId.isNotEmpty) {
      fetchOrderDetail(targetId);
    } else {
      isLoading.value = false;
      errorMessage.value = 'Order details not found';
    }
  }

  Future<void> fetchOrderDetail(String orderId) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final res = await _repo.getOrderDetail(orderId);
      if (res.success && res.data != null) {
        order.value = res.data!;
      } else {
        errorMessage.value = res.message.isNotEmpty ? res.message : 'Failed to load order details';
      }
    } catch (e) {
      AppLogger.w('[ORDER_DETAILS] fetchOrderDetail error: $e');
      errorMessage.value = 'Failed to load order details';
    } finally {
      isLoading.value = false;
    }
  }

  void onReorder() {
    AppUtils.haptic();
    final o = order.value;
    if (o == null) return;
    if (Get.isRegistered<CartController>()) {
      Get.find<CartController>().reorderFromOrder(o);
    } else {
      final cart = Get.put(CartController());
      cart.reorderFromOrder(o);
    }
  }
}
