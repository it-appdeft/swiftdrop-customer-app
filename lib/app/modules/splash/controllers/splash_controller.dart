import 'dart:async';

import 'package:swiftdrop_customer_app/export.dart';

class SplashController extends BaseController {
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer(
      const Duration(milliseconds: AppConstants.splashDuration),
      _navigate,
    );
  }

  void _navigate() {
    if (isClosed) return;

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

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
