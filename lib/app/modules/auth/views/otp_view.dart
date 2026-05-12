import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_decorations.dart';
import '../../../themes/app_dimensions.dart';
import '../../../themes/app_radius.dart';
import '../../../themes/app_text_styles.dart';
import '../../../widgets/app_button.dart';
import '../controllers/auth_controller.dart';

class OtpView extends GetView<AuthController> {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
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
          onPressed: () => Get.back(),
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
                horizontal: AppDimensions.paddingXl,
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
                  const SizedBox(height: AppDimensions.sp32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int index = 0; index < 4; index++) ...[
                        _OtpBox(
                          size: AppDimensions.otpBoxSize,
                          controller: controller.otpBoxControllers[index],
                          focusNode: controller.otpFocusNodes[index],
                          onChanged: (value) {
                            controller.onOtpDigitChanged(index, value);
                            if (value.isNotEmpty && index < 3) {
                              controller.otpFocusNodes[index + 1].requestFocus();
                            } else if (value.isEmpty && index > 0) {
                              controller.otpFocusNodes[index - 1].requestFocus();
                            }
                          },
                        ),
                        if (index < 3) const SizedBox(width: AppDimensions.gapLg),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppDimensions.gapXl),
                  Obx(() {
                    if (!controller.canResend.value) {
                      return Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Resend OTP ',
                              style: AppTextStyles.pSmall.copyWith(
                                color: AppColors.lightSurfaceDisabled,
                              ),
                            ),
                            TextSpan(
                              text: '(${controller.resendTimer.value})',
                              style: AppTextStyles.pSmall.copyWith(
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
                        style: AppTextStyles.pSmallSemiBold.copyWith(
                          color: AppColors.lightSurfaceLabel,
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
              left: AppDimensions.paddingXl,
              right: AppDimensions.paddingXl,
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
    );
  }
}

class _OtpBox extends StatefulWidget {
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
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  bool _isFocused = false;
  bool _hasContent = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChange);
    _hasContent = widget.controller.text.isNotEmpty;
  }

  void _onFocusChange() {
    setState(() => _isFocused = widget.focusNode.hasFocus);
  }

  void _onTextChange() {
    setState(() => _hasContent = widget.controller.text.isNotEmpty);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onTextChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: (_isFocused || _hasContent)
          ? AppDecorations.lightOtpBoxFocused
          : AppDecorations.lightOtpBox,
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: AppTextStyles.pMedium.copyWith(color: AppColors.lightInputText),
        onChanged: widget.onChanged,
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
  }
}
