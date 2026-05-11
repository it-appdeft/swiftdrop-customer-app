import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_dimensions.dart';
import '../../../themes/app_text_styles.dart';
import '../../../utils/responsive.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: Responsive.hpc(context, 40),
                ),
                child: Image.asset(
                  'assets/images/login.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingXl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppDimensions.gapXl),
                    Text('Welcome back', style: AppTextStyles.h4),
                    const SizedBox(height: AppDimensions.gapSm),
                    Text(
                      'Enter your UK mobile number to continue',
                      style: AppTextStyles.pMedium.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppDimensions.sp32),
                    AppPhoneField(
                      controller: controller.phoneController,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: AppDimensions.sp32),
                    Obx(() => AppButton(
                          label: 'Continue',
                          onTap: controller.isPhoneValid.value ? controller.sendOtp : null,
                          isLoading: controller.isLoading.value,
                        )),
                    const SizedBox(height: AppDimensions.gapXl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: AppTextStyles.pSmall.copyWith(color: AppColors.textSecondary),
                        ),
                        GestureDetector(
                          onTap: () => Get.toNamed(AppRoutes.register),
                          child: Text(
                            'Sign up',
                            style: AppTextStyles.pSmallSemiBold.copyWith(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.sp40),
                    Center(
                      child: Text(
                        'By continuing, you agree to our Terms of Service\nand Privacy Policy.',
                        style: AppTextStyles.caption,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingXl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
