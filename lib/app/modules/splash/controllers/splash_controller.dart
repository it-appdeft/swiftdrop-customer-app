import 'package:get/get.dart';
import '../../../base/base_controller.dart';
import '../../../constants/app_constants.dart';
import '../../../constants/storage_keys.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';

class SplashController extends BaseController {
  @override
  void onInit() {
    super.onInit();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(
      const Duration(milliseconds: AppConstants.splashDuration),
      _navigate,
    );
  }

  void _navigate() {
    final isLoggedIn = AuthService.to.isAuthenticated;
    if (isLoggedIn) {
      Get.offAllNamed(AppRoutes.dashboard);
      return;
    }

    final onboardingDone =
        StorageService.to.read<bool>(StorageKeys.onboardingCompleted) ?? false;
    if (onboardingDone) {
      Get.offAllNamed(AppRoutes.login);
    } else {
      Get.offAllNamed(AppRoutes.onboarding);
    }
  }
}
