import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_dimensions.dart';
import '../../../themes/app_text_styles.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text('Create account', style: AppTextStyles.h6),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingXl),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppDimensions.gapXl),
            Text(
              'Your details',
              style: AppTextStyles.pMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppDimensions.gapXl),
            AppTextField(
              controller: controller.nameController,
              label: 'Full name',
              hint: 'James Hartley',
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              prefixIcon: const Icon(Icons.person_outline, color: AppColors.textHint),
            ),
            const SizedBox(height: AppDimensions.gapLg),
            AppPhoneField(controller: controller.phoneController),
            const SizedBox(height: AppDimensions.gapLg),
            AppTextField(
              controller: controller.emailController,
              label: 'Email address (optional)',
              hint: 'james@email.co.uk',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textHint),
            ),
            const SizedBox(height: AppDimensions.sp32),
            Obx(() => AppButton(
                  label: 'Create account',
                  onTap: controller.register,
                  isLoading: controller.isLoading.value,
                )),
            const SizedBox(height: AppDimensions.gapXl),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: AppTextStyles.pSmall.copyWith(color: AppColors.textSecondary),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Text(
                    'Sign in',
                    style: AppTextStyles.pSmallSemiBold.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingXl),
          ],
        ),
      ),
    );
  }
}
