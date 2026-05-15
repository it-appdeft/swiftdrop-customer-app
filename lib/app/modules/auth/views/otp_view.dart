import 'package:swiftdrop_customer_app/export.dart';
import '../controllers/auth_controller.dart';

class OtpView extends GetView<AuthController> {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) controller.cancelTimer();
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
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
            onPressed: () {
              controller.cancelTimer();
              Get.back();
            },
          ),
          title: Text(
            'OTP Verification',
            style: AppTextStyles.h6.copyWith(color: AppColors.lightSurfaceHeading),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMd,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: AppDimensions.gapXl),
                    Obx(() => Text(
                          'We have sent a verification code\nto ${controller.displayPhone}',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.pSmall.copyWith(
                            color: AppColors.lightSurfaceSubtitle,
                          ),
                        )),
                    const SizedBox(height: AppDimensions.gapLg),
                    Obx(() {
                      final fi = controller.otpValues.indexWhere((v) => v.isEmpty);
                      final target = fi == -1 ? AppConstants.otpLength - 1 : fi;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int index = 0; index < AppConstants.otpLength; index++) ...[
                            GestureDetector(
                              onTap: () => controller.otpFocusNodes[target].requestFocus(),
                              child: AbsorbPointer(
                                absorbing: index != target,
                                child: _OtpBox(
                                  size: AppDimensions.otpBoxSize,
                                  controller: controller.otpBoxControllers[index],
                                  focusNode: controller.otpFocusNodes[index],
                                  onChanged: (value) {
                                    controller.onOtpDigitChanged(index, value);
                                    if (value.isNotEmpty && index < AppConstants.otpLength - 1) {
                                      controller.otpFocusNodes[index + 1].requestFocus();
                                    } else if (value.isEmpty && index > 0) {
                                      controller.otpFocusNodes[index - 1].requestFocus();
                                    }
                                  },
                                ),
                              ),
                            ),
                            if (index < AppConstants.otpLength - 1) const SizedBox(width: AppDimensions.gapLg),
                          ],
                        ],
                      );
                    }),
                    const SizedBox(height: AppDimensions.gapLg),
                    Obx(() {
                      if (!controller.canResend.value) {
                        return Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Resend OTP ',
                                style: AppTextStyles.pSmallMedium.copyWith(
                                  color: AppColors.lightSurfaceDisabled,
                                ),
                              ),
                              TextSpan(
                                text: '(${controller.resendTimer.value})',
                                style: AppTextStyles.pSmallMedium.copyWith(
                                  color: AppColors.lightSurfaceLabel,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return GestureDetector(
                        onTap: controller.resendOtp,
                        child: Text(
                          'Resend OTP',
                          style: AppTextStyles.pSmallMedium.copyWith(
                            color: AppColors.lightSurfaceLabel,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.lightSurfaceLabel,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: AppDimensions.paddingMd,
                right: AppDimensions.paddingMd,
                bottom: bottomPadding + AppDimensions.paddingLg,
              ),
              child: Obx(() => AppButton(
                    label: 'Verify',
                    onTap: controller.otpValues.every((v) => v.isNotEmpty)
                        ? controller.verifyOtp
                        : null,
                    isLoading: controller.isLoading.value,
                    borderRadius: AppRadius.sm,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final double size;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.size,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([controller, focusNode]),
      builder: (_, _) {
        final isFocused = focusNode.hasFocus;
        final hasContent = controller.text.isNotEmpty;
        return Container(
          width: size,
          height: size,
          decoration: (isFocused || hasContent)
              ? AppDecorations.lightOtpBoxFocused
              : AppDecorations.lightOtpBox,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: AppTextStyles.pMedium.copyWith(color: AppColors.lightInputText),
            onChanged: onChanged,
            decoration: const InputDecoration(
              counterText: '',
              contentPadding: EdgeInsets.zero,
              filled: true,
              fillColor: AppColors.transparent,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        );
      },
    );
  }
}
