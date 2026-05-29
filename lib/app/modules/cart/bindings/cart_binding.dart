import 'package:get/get.dart';
import '../controllers/cart_controller.dart';

class CartBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CartController>(() => CartController());
    Future.microtask(() => Get.find<CartController>().fetchCheckout());
  }
}
