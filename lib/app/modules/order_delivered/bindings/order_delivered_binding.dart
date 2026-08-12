import 'package:get/get.dart';
import '../controllers/order_delivered_controller.dart';

class OrderDeliveredBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderDeliveredController>(
      () => OrderDeliveredController(),
    );
  }
}
