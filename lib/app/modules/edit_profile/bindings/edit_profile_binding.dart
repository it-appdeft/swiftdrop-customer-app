import 'package:swiftdrop_customer_app/export.dart';

import '../controllers/edit_profile_controller.dart';

class EditProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(() => AuthRepository(), fenix: true);
    Get.lazyPut<ProfileRepository>(() => ProfileRepository(), fenix: true);
    Get.lazyPut<EditProfileController>(
      () => EditProfileController(Get.find(), Get.find()),
    );
  }
}
