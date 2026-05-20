import 'package:swiftdrop_customer_app/export.dart';

import '../controllers/edit_profile_controller.dart';

enum EditOtpFlow { existing, newPhone, email, account, deleteAccount }

class EditOtpView extends GetView<EditProfileController> {
  final EditOtpFlow flow;
  const EditOtpView({super.key, required this.flow});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    switch (flow) {
      case EditOtpFlow.existing:
        return AppOtpScreen(
          appBarTitle: 'Verify Existing Account',
          background: AppColors.offWhite,
          subtitleBuilder: () =>
              'For Security, please verify your existing\naccount information',
          secondaryLineBuilder: () => 'OTP sent to ${c.verifyExistingTarget}',
          otpValues: c.existingOtpValues,
          otpControllers: c.existingOtpControllers,
          otpFocusNodes: c.existingOtpFocusNodes,
          canResend: c.canResendExisting,
          resendTimer: c.existingResendTimer,
          isLoading: c.isLoading,
          onDigitChanged: c.onExistingOtpChanged,
          onResend: c.resendExistingOtp,
          onSubmit: c.verifyExistingOtp,
          buttonLabel: 'Verify',
        );
      case EditOtpFlow.newPhone:
        return AppOtpScreen(
          appBarTitle: 'OTP Verification',
          background: AppColors.white,
          subtitleBuilder: () =>
              'We have sent a verification code\nto ${c.newPhoneDisplay}',
          otpValues: c.newPhoneOtpValues,
          otpControllers: c.newPhoneOtpControllers,
          otpFocusNodes: c.newPhoneOtpFocusNodes,
          canResend: c.canResendNewPhone,
          resendTimer: c.newPhoneResendTimer,
          isLoading: c.isLoading,
          onDigitChanged: c.onNewPhoneOtpChanged,
          onResend: c.resendNewPhoneOtp,
          onSubmit: c.verifyNewOtp,
          buttonLabel: 'Verify',
        );
      case EditOtpFlow.email:
        return AppOtpScreen(
          appBarTitle: 'Email Verification',
          background: AppColors.white,
          subtitleBuilder: () =>
              'We have sent a verification code\nto ${c.newEmailDisplay}',
          otpValues: c.emailOtpValues,
          otpControllers: c.emailOtpControllers,
          otpFocusNodes: c.emailOtpFocusNodes,
          canResend: c.canResendEmail,
          resendTimer: c.emailResendTimer,
          isLoading: c.isLoading,
          onDigitChanged: c.onEmailOtpChanged,
          onResend: c.resendEmailOtp,
          onSubmit: c.verifyEmailOtp,
          buttonLabel: 'Verify',
        );
      case EditOtpFlow.account:
        return AppOtpScreen(
          appBarTitle: 'Verify Account',
          background: AppColors.white,
          heading: 'For your security, Please verify\nyour account information',
          subtitleBuilder: () =>
              'Enter OTP send on ${c.currentPhoneDisplay}. Do not share OTP with Anyone.',
          textAlign: TextAlign.start,
          contentAlignment: CrossAxisAlignment.start,
          topGap: AppDimensions.gapMd,
          spacingBeforeOtp: AppDimensions.gapXl,
          otpValues: c.existingOtpValues,
          otpControllers: c.existingOtpControllers,
          otpFocusNodes: c.existingOtpFocusNodes,
          canResend: c.canResendExisting,
          resendTimer: c.existingResendTimer,
          isLoading: c.isLoading,
          onDigitChanged: c.onExistingOtpChanged,
          onResend: c.resendExistingOtp,
          onSubmit: c.submitAccountVerification,
          buttonLabel: 'Submit',
        );
      case EditOtpFlow.deleteAccount:
        return AppOtpScreen(
          appBarTitle: 'Verify Account',
          background: AppColors.white,
          heading: 'For your security, Please verify\nyour account information',
          subtitleBuilder: () {
            final target = c.deletionTarget.value;
            final dest = target.isEmpty ? c.currentPhoneDisplay : target;
            return 'Enter OTP send on $dest. Do not share OTP with Anyone.';
          },
          textAlign: TextAlign.start,
          contentAlignment: CrossAxisAlignment.start,
          topGap: AppDimensions.gapMd,
          spacingBeforeOtp: AppDimensions.gapXl,
          otpValues: c.existingOtpValues,
          otpControllers: c.existingOtpControllers,
          otpFocusNodes: c.existingOtpFocusNodes,
          canResend: c.canResendExisting,
          resendTimer: c.existingResendTimer,
          isLoading: c.isLoading,
          onDigitChanged: c.onExistingOtpChanged,
          onResend: c.resendDeletionOtp,
          onSubmit: c.verifyDeletionOtp,
          buttonLabel: 'Submit',
        );
    }
  }
}
