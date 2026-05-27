import 'package:swiftdrop_customer_app/export.dart';
import '../../cart/controllers/cart_controller.dart';
import '../controllers/restaurant_detail_controller.dart';

class RestaurantDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CartController>(() => CartController(), fenix: true);
    Get.lazyPut<RestaurantDetailRepository>(() => RestaurantDetailRepository());
    Get.lazyPut<RestaurantDetailController>(
        () => RestaurantDetailController(Get.find()));
  }
}
