import 'package:swiftdrop_customer_app/export.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeRepository>(() => HomeRepository());
    Get.lazyPut<FavoritesRepository>(() => FavoritesRepository());
    Get.lazyPut<HomeController>(() => HomeController(Get.find(), Get.find()));
  }
}
