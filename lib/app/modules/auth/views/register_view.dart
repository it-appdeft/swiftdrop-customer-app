import 'package:country_picker/country_picker.dart';
import 'package:swiftdrop_customer_app/export.dart';
import '../controllers/auth_controller.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) controller.resetRegisterState();
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: AppDimensions.iconSm,
              color: AppColors.lightSurfaceText,
            ),
            onPressed: () => Get.back(),
          ),
        ),
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.gapMd),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Get Started With\n',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.lightSurfaceDarkText,
                      ),
                    ),
                    TextSpan(
                      text: 'SwiftDrop',
                      style: AppTextStyles.h3.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.gapXs),
              Text(
                'Create your account to start ordering with precision.',
                style: AppTextStyles.pMedium.copyWith(
                  color: AppColors.lightSurfaceSubtitle,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppDimensions.gapLg),

              const _FieldLabel(label: 'Full Name'),
              const SizedBox(height: AppDimensions.gapSm),
              _NameField(),
              const SizedBox(height: AppDimensions.gapLg),

              const _FieldLabel(label: 'Email Address'),
              const SizedBox(height: AppDimensions.gapSm),
              _EmailFieldRow(),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: Obx(() {
                  if (!controller.emailOtpSent.value) return const SizedBox.shrink();
                  return _InlineOtpPanel(
                    subtitle: 'We\'ve sent a 4-digit code to your email address.',
                    otpBoxControllers: controller.emailOtpBoxControllers,
                    otpFocusNodes: controller.emailOtpFocusNodes,
                    otpValues: controller.emailOtpValues,
                    onDigitChanged: controller.onEmailOtpDigitChanged,
                    onVerify: controller.verifyEmailOtp,
                    isVerifying: controller.isVerifyingEmailOtp,
                  );
                }),
              ),
              const SizedBox(height: AppDimensions.gapLg),

              const _FieldLabel(label: 'Mobile Number'),
              const SizedBox(height: AppDimensions.gapSm),
              Obx(() => AppPhoneField(
                    controller: controller.regPhoneController,
                    countryFlag: controller.countryFlag.value,
                    countryCode: controller.countryCode.value,
                    onCountryTap: () => _openCountryPicker(context),
                    isLightSurface: true,
                    suffixAction: Obx(() {
                      if (controller.isSendingPhoneOtp.value) {
                        return const Padding(
                          padding: EdgeInsets.only(right: AppDimensions.paddingXs),
                          child: AppInlineLoader(),
                        );
                      }
                      if (controller.isPhoneVerified.value) {
                        return Padding(
                          padding: const EdgeInsets.only(right: AppDimensions.paddingXs),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'VERIFIED',
                                style: AppTextStyles.pXSmallMedium.copyWith(
                                  color: AppColors.lightSurfaceVerified,
                                ),
                              ),
                              const SizedBox(width: AppDimensions.gapXs),
                              const Icon(
                                Icons.check_circle,
                                size: AppDimensions.iconSm,
                                color: AppColors.lightSurfaceVerified,
                              ),
                            ],
                          ),
                        );
                      }
                      if (controller.regPhoneOtpSent.value) {
                        return Padding(
                          padding: const EdgeInsets.only(right: AppDimensions.paddingXs),
                          child: GestureDetector(
                            onTap: controller.canResendRegPhone.value
                                ? () {
                                    FocusScope.of(context).unfocus();
                                    controller.resendRegisterPhoneOtp();
                                  }
                                : null,
                            child: controller.canResendRegPhone.value
                                ? Text(
                                    'Resend OTP',
                                    style: AppTextStyles.pXSmallMedium.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  )
                                : Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Resend OTP ',
                                          style: AppTextStyles.pXSmallMedium.copyWith(
                                            color: AppColors.lightSurfaceDisabled,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '(${controller.regPhoneResendTimer.value})',
                                          style: AppTextStyles.pXSmallMedium.copyWith(
                                            color: AppColors.lightSurfaceLabel,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(right: AppDimensions.paddingXs),
                        child: GestureDetector(
                          onTap: controller.regIsPhoneValid.value
                              ? () {
                                  FocusScope.of(context).unfocus();
                                  controller.sendRegisterPhoneOtp();
                                }
                              : null,
                          child: Text(
                            'Get OTP',
                            style: AppTextStyles.pXSmallSemiBold.copyWith(
                              color: controller.regIsPhoneValid.value
                                  ? AppColors.primary
                                  : AppColors.primaryFaded,
                            ),
                          ),
                        ),
                      );
                    }),
                  )),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: Obx(() {
                  if (!controller.regPhoneOtpSent.value) return const SizedBox.shrink();
                  return _InlineOtpPanel(
                    subtitle: 'We\'ve sent a 4-digit code to your phone number.',
                    otpBoxControllers: controller.regPhoneOtpBoxControllers,
                    otpFocusNodes: controller.regPhoneOtpFocusNodes,
                    otpValues: controller.regPhoneOtpValues,
                    onDigitChanged: controller.onRegPhoneOtpDigitChanged,
                    onVerify: controller.verifyRegisterPhoneOtp,
                    isVerifying: controller.isVerifyingPhoneOtp,
                  );
                }),
              ),
              const SizedBox(height: AppDimensions.gapXl),

              Obx(() => AppButton(
                    label: 'Register',
                    onTap: (controller.isEmailVerified.value &&
                            controller.isPhoneVerified.value)
                        ? () {
                            FocusScope.of(context).unfocus();
                            controller.submitRegister();
                          }
                        : null,
                    isLoading: controller.isLoading.value,
                    borderRadius: AppRadius.sm,
                  )),
              const SizedBox(height: AppDimensions.gapXl),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: AppTextStyles.pSmall.copyWith(
                      color: AppColors.lightSurfaceHeading,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      controller.resetRegisterState();
                      Get.back();
                    },
                    child: Text(
                      'Login',
                      style: AppTextStyles.pSmallSemiBold.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: bottomPadding + AppDimensions.paddingXl),
            ],
          ),
        ),
      ),
    );
  }

  void _openCountryPicker(BuildContext context) {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country country) {
        controller.selectCountry(country.flagEmoji, '+${country.phoneCode}');
      },
      countryListTheme: CountryListThemeData(
        backgroundColor: AppColors.white,
        borderRadius: AppRadius.topXl,
        textStyle: AppTextStyles.pSmall.copyWith(color: AppColors.lightSurfaceText),
        searchTextStyle: AppTextStyles.pSmall.copyWith(color: AppColors.lightSurfaceText),
        inputDecoration: InputDecoration(
          filled: true,
          fillColor: AppColors.transparent,
          labelText: 'Search',
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          labelStyle: AppTextStyles.pSmall.copyWith(color: AppColors.textSecondary),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.lightSurfaceBorder),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.pSmallMedium.copyWith(
            color: AppColors.lightSurfaceLabel,
          ),
        ),
        Text(
          ' *',
          style: AppTextStyles.pSmallMedium.copyWith(
            color: AppColors.error,
          ),
        ),
      ],
    );
  }
}

class _NameField extends GetView<AuthController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.inputHeight,
      decoration: AppDecorations.lightInput,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.nameController,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              textAlignVertical: TextAlignVertical.center,
              style: AppTextStyles.pSmall.copyWith(
                color: AppColors.lightSurfaceText,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.transparent,
                hintText: 'Enter Your Full Name',
                hintStyle: AppTextStyles.pSmall.copyWith(
                  color: AppColors.lightSurfaceSubtitle,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingXs,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmailFieldRow extends GetView<AuthController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.inputHeight,
      decoration: AppDecorations.lightInput,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              textAlignVertical: TextAlignVertical.center,
              style: AppTextStyles.pSmall.copyWith(
                color: AppColors.lightSurfaceText,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.transparent,
                hintText: 'Enter Your Email Address',
                hintStyle: AppTextStyles.pSmall.copyWith(
                  color: AppColors.lightSurfaceSubtitle,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingXs,
                ),
              ),
            ),
          ),
          Obx(() {
            if (controller.isEmailVerified.value) {
              return Padding(
                padding: const EdgeInsets.only(right: AppDimensions.paddingXs),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'VERIFIED',
                      style: AppTextStyles.pXSmallMedium.copyWith(
                        color: AppColors.lightSurfaceVerified,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.gapXs),
                    const Icon(
                      Icons.check_circle,
                      size: AppDimensions.iconSm,
                      color: AppColors.lightSurfaceVerified,
                    ),
                  ],
                ),
              );
            }
            if (controller.emailOtpSent.value) {
              return Padding(
                padding: const EdgeInsets.only(right: AppDimensions.paddingXs),
                child: GestureDetector(
                  onTap: controller.canResendEmail.value
                      ? () {
                          FocusScope.of(context).unfocus();
                          controller.resendEmailOtp();
                        }
                      : null,
                  child: controller.canResendEmail.value
                      ? Text(
                          'Resend OTP',
                          style: AppTextStyles.pXSmallMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        )
                      : Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Resend OTP ',
                                style: AppTextStyles.pXSmallMedium.copyWith(
                                  color: AppColors.lightSurfaceDisabled,
                                ),
                              ),
                              TextSpan(
                                text: '(${controller.emailResendTimer.value})',
                                style: AppTextStyles.pXSmallMedium.copyWith(
                                  color: AppColors.lightSurfaceLabel,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              );
            }
            if (controller.isSendingEmailOtp.value) {
              return const Padding(
                padding: EdgeInsets.only(right: AppDimensions.paddingXs),
                child: AppInlineLoader(),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(right: AppDimensions.paddingXs),
              child: GestureDetector(
                onTap: controller.isEmailValid.value
                    ? () {
                        FocusScope.of(context).unfocus();
                        controller.sendEmailOtp();
                      }
                    : null,
                child: Text(
                  'Get OTP',
                  style: AppTextStyles.pXSmallSemiBold.copyWith(
                    color: controller.isEmailValid.value
                        ? AppColors.primary
                        : AppColors.primaryFaded,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _InlineOtpPanel extends StatelessWidget {
  final String subtitle;
  final List<TextEditingController> otpBoxControllers;
  final List<FocusNode> otpFocusNodes;
  final RxList<String> otpValues;
  final Function(int, String) onDigitChanged;
  final VoidCallback onVerify;
  final RxBool isVerifying;

  const _InlineOtpPanel({
    required this.subtitle,
    required this.otpBoxControllers,
    required this.otpFocusNodes,
    required this.otpValues,
    required this.onDigitChanged,
    required this.onVerify,
    required this.isVerifying,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppDimensions.gapMd),
      padding: const EdgeInsets.all(AppDimensions.paddingSm),
      decoration: BoxDecoration(
        borderRadius: AppRadius.sm,
        border: Border.all(color: AppColors.lightSurfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Enter Verification Code',
            style: AppTextStyles.pSmallMedium.copyWith(
              color: AppColors.lightSurfaceLabel,
            ),
          ),
          const SizedBox(height: AppDimensions.gapXs),
          Text(
            subtitle,
            style: AppTextStyles.pXSmall.copyWith(
              color: AppColors.lightSurfaceSubtitle,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppDimensions.gapLg),
          Obx(() {
            final fi = otpValues.indexWhere((v) => v.isEmpty);
            final target = fi == -1 ? AppConstants.otpLength - 1 : fi;
            final allFilled = otpValues.every((v) => v.isNotEmpty);
            return Row(
              children: [
                for (int i = 0; i < AppConstants.otpLength; i++) ...[
                  GestureDetector(
                    onTap: () => otpFocusNodes[target].requestFocus(),
                    child: AbsorbPointer(
                      absorbing: i != target,
                      child: AppOtpBox(
                        controller: otpBoxControllers[i],
                        focusNode: otpFocusNodes[i],
                        onChanged: (value) {
                          onDigitChanged(i, value);
                          if (value.isNotEmpty &&
                              i < AppConstants.otpLength - 1) {
                            otpFocusNodes[i + 1].requestFocus();
                          }
                        },
                        onBackspaceOnEmpty: () {
                          if (i > 0) {
                            otpFocusNodes[i - 1].requestFocus();
                          }
                        },
                      ),
                    ),
                  ),
                  if (i < AppConstants.otpLength - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.gapXs,
                      ),
                      child: Container(
                        width: AppDimensions.gapSm,
                        height: 1,
                        color: AppColors.lightSurfaceDisabled,
                      ),
                    ),
                ],
                const Spacer(),
                if (isVerifying.value)
                  const AppInlineLoader()
                else
                  GestureDetector(
                    onTap: allFilled
                        ? () {
                            FocusScope.of(context).unfocus();
                            onVerify();
                          }
                        : null,
                    child: Text(
                      'VERIFY',
                      style: AppTextStyles.pXSmallSemiBold.copyWith(
                        color: allFilled ? AppColors.primary : AppColors.primaryFaded,
                      ),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}


