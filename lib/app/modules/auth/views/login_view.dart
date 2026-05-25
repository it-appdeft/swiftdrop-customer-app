import 'package:country_picker/country_picker.dart';
import 'package:swiftdrop_customer_app/export.dart';
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
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
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
            physics: const ClampingScrollPhysics(),
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
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'Craving Something',
              maxLines: 1,
              style: AppTextStyles.h3.copyWith(
                color: AppColors.lightSurfaceText,
              ),
            ),
          ),
          Text(
            'Delicious?',
            maxLines: 1,
            style: AppTextStyles.h3.copyWith(color: AppColors.primary),
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
          Obx(() => AppPhoneField(
                controller: controller.phoneController,
                countryFlag: controller.countryFlag.value,
                countryCode: controller.countryCode.value,
                onCountryTap: () => _openCountryPicker(context),
                isLightSurface: true,
                textInputAction: TextInputAction.done,
              )),
          Obx(() {
            final showError = controller.phoneNumber.value.isNotEmpty &&
                !controller.isPhoneValid.value;
            if (!showError) return const SizedBox(height: AppDimensions.gapMd);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: AppDimensions.gapSm),
                Text(
                  'Phone number invalid',
                  style: AppTextStyles.pXSmall.copyWith(color: AppColors.error),
                ),
                const SizedBox(height: AppDimensions.gapMd),
              ],
            );
          }),
          Obx(() => AppButton(
                label: 'Get OTP',
                onTap: controller.isPhoneValid.value
                    ? () {
                        FocusScope.of(context).unfocus();
                        controller.sendOtp();
                      }
                    : null,
                isLoading: controller.isLoading.value,
                borderRadius: AppRadius.sm,
              )),
        ],
      ),
    );
  }

  void _openCountryPicker(BuildContext context) {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country country) {
        controller.selectCountry(country.flagEmoji, '+${country.phoneCode}', country.countryCode);
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
