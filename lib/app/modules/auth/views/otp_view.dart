import 'package:swiftdrop_customer_app/export.dart';

import '../controllers/auth_controller.dart';

class OtpView extends GetView<AuthController> {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppOtpScreen(
      appBarTitle: 'OTP Verification',
      background: AppColors.white,
      subtitleBuilder: () =>
          'We have sent a verification code\nto ${controller.displayPhone}',
      otpValues: controller.otpValues,
      otpControllers: controller.otpBoxControllers,
      otpFocusNodes: controller.otpFocusNodes,
      canResend: controller.canResend,
      resendTimer: controller.resendTimer,
      isLoading: controller.isLoading,
      onDigitChanged: controller.onOtpDigitChanged,
      onResend: controller.resendOtp,
      onSubmit: controller.verifyOtp,
      buttonLabel: 'Verify',
      beforeLeave: controller.cancelTimer,
    );
  }
}
