import 'package:get/get.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/repositories/order_repository.dart';

class OrderDeliveredController extends GetxController {
  final order = Rxn<OrderModel>();
  final isLoadingDetail = false.obs;
  final _repo = OrderRepository();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is OrderModel) {
      order.value = Get.arguments as OrderModel;
      _loadFullDetailIfNeeded();
    } else if (Get.arguments is Map) {
      final map = Get.arguments as Map;
      if (map['order'] is OrderModel) {
        order.value = map['order'] as OrderModel;
        _loadFullDetailIfNeeded();
      } else if (map['orderId'] != null) {
        fetchOrderDetail(map['orderId'].toString());
      }
    }
  }

  Future<void> _loadFullDetailIfNeeded() async {
    final current = order.value;
    if (current != null && current.id.isNotEmpty) {
      fetchOrderDetail(current.id);
    }
  }

  Future<void> fetchOrderDetail(String orderId) async {
    isLoadingDetail.value = true;
    try {
      final res = await _repo.getOrderDetail(orderId);
      if (res.success && res.data != null) {
        order.value = res.data!;
      }
    } finally {
      isLoadingDetail.value = false;
    }
  }

  void submitFeedback() {
    Get.back();
  }

  void backToHome() {
    Get.offAllNamed('/dashboard');
  }
}
