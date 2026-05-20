import 'package:get/get.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../base/base_controller.dart';

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
}
