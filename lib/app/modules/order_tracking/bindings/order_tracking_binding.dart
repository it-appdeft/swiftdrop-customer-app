import 'package:get/get.dart';
import '../../../../data/repositories/order_repository.dart';
import '../controllers/order_tracking_controller.dart';

class OrderTrackingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderRepository>(() => OrderRepository());
    Get.lazyPut<OrderTrackingController>(() => OrderTrackingController(Get.find()));
  }
}
