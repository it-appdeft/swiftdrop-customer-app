import 'package:get/get.dart';
import '../controllers/favorites_controller.dart';
import '../../../../data/repositories/favorites_repository.dart';

class FavoritesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FavoritesController>(
      () => FavoritesController(FavoritesRepository()),
    );
  }
}
