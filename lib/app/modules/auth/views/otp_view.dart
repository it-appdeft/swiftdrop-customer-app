import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_dimensions.dart';
import '../../../themes/app_text_styles.dart';
import '../../../widgets/app_button.dart';
import '../../../utils/app_utils.dart';
import '../controllers/auth_controller.dart';

class OtpView extends GetView<AuthController> {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());
    final List<TextEditingController> otpControllers =
        List.generate(4, (_) => TextEditingController());

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingXl),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppDimensions.gapXl),
            Text('Verify your number', style: AppTextStyles.h4),
            const SizedBox(height: AppDimensions.gapSm),
            Obx(() => Text(
                  'Enter the 4-digit code sent to ${AppUtils.formatPhoneDisplay(controller.phoneNumber.value)}',
                  style: AppTextStyles.pMedium.copyWith(color: AppColors.textSecondary),
                )),
            const SizedBox(height: AppDimensions.sp32),
            // OTP boxes scale fluidly to available width
            LayoutBuilder(
              builder: (context, constraints) {
                // (available width − 3 gaps of 12px each) ÷ 4 boxes, clamped 52–72px
                final boxSize = ((constraints.maxWidth - 36) / 4).clamp(52.0, 72.0);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(4, (index) {
                    return _OtpBox(
                      size: boxSize,
                      controller: otpControllers[index],
                      focusNode: focusNodes[index],
                      onChanged: (value) {
                        controller.onOtpDigitChanged(index, value);
                        if (value.isNotEmpty && index < 3) {
                          focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          focusNodes[index - 1].requestFocus();
                        }
                      },
                    );
                  }),
                );
              },
            ),
            const SizedBox(height: AppDimensions.sp32),
            Obx(() => AppButton(
                  label: 'Verify',
                  onTap: controller.verifyOtp,
                  isLoading: controller.isLoading.value,
                )),
            const SizedBox(height: AppDimensions.gapXl),
            Center(
              child: Obx(() {
                if (!controller.canResend.value) {
                  return Text(
                    'Resend code in ${controller.resendTimer.value}s',
                    style: AppTextStyles.pSmall.copyWith(color: AppColors.textSecondary),
                  );
                }
                return GestureDetector(
                  onTap: controller.resendOtp,
                  child: Text(
                    'Resend code',
                    style: AppTextStyles.pSmallSemiBold.copyWith(color: AppColors.primary),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppDimensions.paddingXl),
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
    return SizedBox(
      width: size,
      height: size,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: AppTextStyles.h5,
        onChanged: onChanged,
        decoration: const InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
