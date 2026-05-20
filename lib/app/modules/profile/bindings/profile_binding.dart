import 'package:get/get.dart';
import '../../../../data/repositories/profile_repository.dart';
import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileRepository>(() => ProfileRepository(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(Get.find()));
  }
}
