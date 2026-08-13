import 'package:swiftdrop_customer_app/export.dart';

class AppOtpScreen extends StatelessWidget {
  final String appBarTitle;
  final Color background;

  final String? heading;
  final String Function() subtitleBuilder;
  final String Function()? secondaryLineBuilder;

  final TextAlign textAlign;
  final CrossAxisAlignment contentAlignment;
  final Alignment resendAlignment;
  final double topGap;
  final double spacingBeforeOtp;

  final RxList<String> otpValues;
  final List<TextEditingController> otpControllers;
  final List<FocusNode> otpFocusNodes;

  final RxBool canResend;
  final RxInt resendTimer;
  final RxBool isLoading;

  final void Function(int index, String value) onDigitChanged;
  final VoidCallback onResend;
  final VoidCallback onSubmit;
  final String buttonLabel;

  final VoidCallback? beforeLeave;

  const AppOtpScreen({
    super.key,
    required this.appBarTitle,
    required this.background,
    this.heading,
    required this.subtitleBuilder,
    this.secondaryLineBuilder,
    this.textAlign = TextAlign.center,
    this.contentAlignment = CrossAxisAlignment.center,
    this.resendAlignment = Alignment.center,
    this.topGap = AppDimensions.gapXl,
    this.spacingBeforeOtp = AppDimensions.gapLg,
    required this.otpValues,
    required this.otpControllers,
    required this.otpFocusNodes,
    required this.canResend,
    required this.resendTimer,
    required this.isLoading,
    required this.onDigitChanged,
    required this.onResend,
    required this.onSubmit,
    required this.buttonLabel,
    this.beforeLeave,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final scaffold = Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
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
            beforeLeave?.call();
            Get.back();
          },
        ),
        title: Text(
          appBarTitle,
          style: AppTextStyles.h6.copyWith(color: AppColors.lightSurfaceHeading),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMd,
                ),
                child: Column(
                  crossAxisAlignment: contentAlignment,
                  children: [
                    SizedBox(height: topGap),
                    if (heading != null) ...[
                      Text(
                        heading!,
                        style: AppTextStyles.h5.copyWith(
                          color: AppColors.lightSurfaceDarkText,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.gapSm),
                    ],
                    Text(
                      subtitleBuilder(),
                      textAlign: textAlign,
                      style: AppTextStyles.pSmall.copyWith(
                        color: AppColors.lightSurfaceSubtitle,
                        height: 1.5,
                      ),
                    ),
                    if (secondaryLineBuilder != null) ...[
                      const SizedBox(height: AppDimensions.gapMd),
                      Text(
                        secondaryLineBuilder!(),
                        textAlign: textAlign,
                        style: AppTextStyles.pSmallMedium.copyWith(
                          color: AppColors.lightSurfaceLabel,
                        ),
                      ),
                    ],
                    SizedBox(height: spacingBeforeOtp),
                    _OtpRow(
                      values: otpValues,
                      controllers: otpControllers,
                      focusNodes: otpFocusNodes,
                      onDigitChanged: onDigitChanged,
                    ),
                    const SizedBox(height: AppDimensions.gapLg),
                    Align(
                      alignment: resendAlignment,
                      child: _ResendBlock(
                        canResend: canResend,
                        timer: resendTimer,
                        onResend: onResend,
                      ),
                    ),
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
                    label: buttonLabel,
                    onTap: otpValues.every((v) => v.isNotEmpty)
                        ? () {
                            FocusScope.of(context).unfocus();
                            onSubmit();
                          }
                        : null,
                    isLoading: isLoading.value,
                    borderRadius: AppRadius.sm,
                  )),
            ),
          ],
        ),
      ),
    );

    if (beforeLeave == null) return scaffold;
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) beforeLeave!();
      },
      child: scaffold,
    );
  }
}

class _OtpRow extends StatelessWidget {
  final RxList<String> values;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final void Function(int, String) onDigitChanged;

  const _OtpRow({
    required this.values,
    required this.controllers,
    required this.focusNodes,
    required this.onDigitChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final fi = values.indexWhere((v) => v.isEmpty);
      final target = fi == -1 ? AppConstants.otpLength - 1 : fi;
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int index = 0; index < AppConstants.otpLength; index++) ...[
            GestureDetector(
              onTap: () => focusNodes[target].requestFocus(),
              child: AbsorbPointer(
                absorbing: index != target,
                child: AppOtpBox(
                  controller: controllers[index],
                  focusNode: focusNodes[index],
                  onChanged: (value) {
                    onDigitChanged(index, value);
                    if (value.isNotEmpty &&
                        index < AppConstants.otpLength - 1) {
                      focusNodes[index + 1].requestFocus();
                    }
                  },
                  onBackspaceOnEmpty: () {
                    if (index > 0) {
                      focusNodes[index - 1].requestFocus();
                    }
                  },
                ),
              ),
            ),
            if (index < AppConstants.otpLength - 1)
              const SizedBox(width: AppDimensions.gapLg),
          ],
        ],
      );
    });
  }
}

class _ResendBlock extends StatelessWidget {
  final RxBool canResend;
  final RxInt timer;
  final VoidCallback onResend;

  const _ResendBlock({
    required this.canResend,
    required this.timer,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!canResend.value) {
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
                text: '(${timer.value})',
                style: AppTextStyles.pSmallMedium.copyWith(
                  color: AppColors.lightSurfaceLabel,
                ),
              ),
            ],
          ),
        );
      }
      return GestureDetector(
        onTap: () {
          AppUtils.haptic();
          FocusScope.of(context).unfocus();
          onResend();
        },
        child: Text(
          'Resend OTP',
          style: AppTextStyles.pSmallMedium.copyWith(
            color: AppColors.lightSurfaceLabel,
            decoration: TextDecoration.underline,
            decorationColor: AppColors.lightSurfaceLabel,
          ),
        ),
      );
    });
  }
}
