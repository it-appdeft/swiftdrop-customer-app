import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_decorations.dart';
import '../../../themes/app_dimensions.dart';
import '../../../themes/app_radius.dart';
import '../../../themes/app_text_styles.dart';
import '../../../utils/responsive.dart';
import '../../../widgets/app_button.dart';
import '../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: Responsive.hpc(context, 60),
            child: Image.asset(
              'assets/images/login.png',
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: screenHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      SizedBox(height: Responsive.hpc(context, 50)),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingMd,
                        ),
                        child: _LoginCard(),
                      ),
                      const SizedBox(height: AppDimensions.gapXl),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: bottomPadding + AppDimensions.paddingLg,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: AppTextStyles.pSmall.copyWith(
                            color: AppColors.lightSurfaceHeading,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Get.toNamed(AppRoutes.register),
                          child: Text(
                            'Register',
                            style: AppTextStyles.pSmallSemiBold.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginCard extends GetView<AuthController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: AppDecorations.lightCard,
      padding: const EdgeInsets.all(AppDimensions.paddingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Craving Something\n',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.lightSurfaceText,
                  ),
                ),
                TextSpan(
                  text: 'Delicious?',
                  style: AppTextStyles.h3.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.gapLg),
          Row(
            children: [
              Text(
                'Mobile Number ',
                style: AppTextStyles.pSmallMedium.copyWith(
                  color: AppColors.lightSurfaceLabel,
                ),
              ),
              Text(
                '*',
                style: AppTextStyles.pSmallMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.gapSm),
          _PhoneInputRow(),
          Obx(() {
            final showError = controller.phoneNumber.value.isNotEmpty &&
                !controller.isPhoneValid.value;
            if (!showError) return const SizedBox(height: AppDimensions.gapMd);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: AppDimensions.gapSm),
                Padding(
                  padding: const EdgeInsets.only(left: AppDimensions.gapSm),
                  child: Text(
                    'Phone number invalid',
                    style: AppTextStyles.pXSmall.copyWith(color: AppColors.error),
                  ),
                ),
                const SizedBox(height: AppDimensions.gapMd),
              ],
            );
          }),
          Obx(() => AppButton(
                label: 'Get OTP',
                onTap: controller.isPhoneValid.value ? controller.sendOtp : null,
                isLoading: controller.isLoading.value,
                borderRadius: AppRadius.sm,
              )),
        ],
      ),
    );
  }
}

class _PhoneInputRow extends GetView<AuthController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.inputHeight,
      decoration: AppDecorations.lightInput,
      child: Row(
        children: [
          Obx(
            () => GestureDetector(
              onTap: () => _openCountryPicker(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingXs,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      controller.countryFlag.value,
                      style: const TextStyle(fontSize: 22),
                    ),
                    const SizedBox(width: AppDimensions.gapXs),
                    Text(
                      controller.countryCode.value,
                      style: AppTextStyles.pSmall.copyWith(
                        color: AppColors.lightSurfaceSubtitle,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.gapXs),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: AppDimensions.iconSm,
                      color: AppColors.lightSurfaceSubtitle,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: 1,
            height: AppDimensions.inputHeight,
            color: AppColors.lightSurfaceBorder,
          ),
          Expanded(
            child: TextField(
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              style: AppTextStyles.pSmall.copyWith(
                color: AppColors.lightSurfaceText,
              ),
              maxLength: 11,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.transparent,
                hintText: 'Enter Mobile Number',
                hintStyle: AppTextStyles.pSmall.copyWith(
                  color: AppColors.lightSurfaceSubtitle,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                counterText: '',
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingSm,
                  vertical: AppDimensions.gapMd,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openCountryPicker(BuildContext context) {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      favorite: ['GB'],
      onSelect: (Country country) {
        controller.selectCountry(country.flagEmoji, '+${country.phoneCode}');
      },
      countryListTheme: CountryListThemeData(
        backgroundColor: AppColors.white,
        borderRadius: AppRadius.topXl,
        textStyle: AppTextStyles.pSmall.copyWith(
          color: AppColors.lightSurfaceText,
        ),
        searchTextStyle: AppTextStyles.pSmall.copyWith(
          color: AppColors.lightSurfaceText,
        ),
        inputDecoration: InputDecoration(
          filled: true,
          fillColor: AppColors.transparent,
          labelText: 'Search',
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          labelStyle: AppTextStyles.pSmall.copyWith(
            color: AppColors.textSecondary,
          ),
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
