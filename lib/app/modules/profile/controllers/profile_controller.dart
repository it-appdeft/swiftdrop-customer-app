import 'package:get/get.dart';
import '../../../base/base_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';
import '../../../utils/app_utils.dart';
import '../../../../data/models/user_model.dart';

class ProfileController extends BaseController {
  final Rx<UserModel?> user = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    user.value = AuthService.to.currentUser.value;
    ever(AuthService.to.currentUser, (u) => user.value = u);
  }

  Future<void> logout() async {
    final confirmed = await AppUtils.showConfirmDialog(
      title: 'Sign out',
      message: 'Are you sure you want to sign out?',
      confirmText: 'Sign out',
      cancelText: 'Cancel',
    );

    if (confirmed == true) {
      await AuthService.to.logout();
      Get.offAllNamed(AppRoutes.login);
    }
  }

  void navigateToSettings() => Get.toNamed(AppRoutes.settings);
}
