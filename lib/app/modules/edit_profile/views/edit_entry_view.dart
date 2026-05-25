import 'package:country_picker/country_picker.dart';
import 'package:swiftdrop_customer_app/export.dart';

import '../controllers/edit_profile_controller.dart';

enum EditEntryFlow { phone, email }

class EditEntryView extends GetView<EditProfileController> {
  final EditEntryFlow flow;
  const EditEntryView({super.key, required this.flow});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isPhone = flow == EditEntryFlow.phone;

    return Scaffold(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppDimensions.gapMd),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: isPhone
                                ? 'Change Phone\n'
                                : 'Add Your New\n',
                            style: AppTextStyles.h3.copyWith(
                              color: AppColors.lightSurfaceDarkText,
                            ),
                          ),
                          TextSpan(
                            text: isPhone ? 'Number' : 'Email',
                            style: AppTextStyles.h3.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.gapXs),
                    Text(
                      isPhone
                          ? 'Enter your new Mobile number to receive a verification code'
                          : 'Enter your new email address to receive a verification code',
                      style: AppTextStyles.pSmall.copyWith(
                        color: AppColors.lightSurfaceSubtitle,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.gapXl),
                    Row(
                      children: [
                        Text(
                          isPhone ? 'Mobile Number ' : 'Email Address ',
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
                    if (isPhone) _PhoneInput(onCountryTap: () => _openCountryPicker(context)) else _EmailInput(),
                    Obx(() {
                      final showError = isPhone
                          ? controller.newPhoneNumber.value.isNotEmpty &&
                              !controller.isNewPhoneValid.value
                          : controller.newEmail.value.isNotEmpty &&
                              !controller.isNewEmailValid.value;
                      if (!showError) {
                        return const SizedBox(height: AppDimensions.gapMd);
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: AppDimensions.gapSm),
                          Text(
                            isPhone
                                ? 'Phone number invalid'
                                : 'Email address invalid',
                            style: AppTextStyles.pXSmall.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.gapMd),
                        ],
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
              child: Obx(() {
                final valid = isPhone
                    ? controller.isNewPhoneValid.value
                    : controller.isNewEmailValid.value;
                return AppButton(
                  label: 'Get OTP',
                  onTap: valid
                      ? () {
                          FocusScope.of(context).unfocus();
                          if (isPhone) {
                            controller.sendNewPhoneOtp();
                          } else {
                            controller.sendEmailOtp();
                          }
                        }
                      : null,
                  isLoading: controller.isLoading.value,
                  borderRadius: AppRadius.sm,
                );
              }),
            ),
          ],
        ),
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

class _PhoneInput extends GetView<EditProfileController> {
  final VoidCallback onCountryTap;
  const _PhoneInput({required this.onCountryTap});

  @override
  Widget build(BuildContext context) {
    return Obx(() => AppPhoneField(
          controller: controller.newPhoneController,
          countryFlag: controller.countryFlag.value,
          countryCode: controller.countryCode.value,
          onCountryTap: onCountryTap,
          isLightSurface: true,
          textInputAction: TextInputAction.done,
        ));
  }
}

class _EmailInput extends GetView<EditProfileController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.inputHeight,
      decoration: AppDecorations.lightInput,
      child: TextField(
        controller: controller.newEmailController,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        textAlignVertical: TextAlignVertical.center,
        style: AppTextStyles.pSmall.copyWith(
          color: AppColors.lightSurfaceText,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.transparent,
          hintText: 'alexandra.arnold123@example.com',
          hintStyle: AppTextStyles.pSmall.copyWith(
            color: AppColors.lightSurfaceSubtitle,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          isCollapsed: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingSm,
          ),
        ),
      ),
    );
  }
}
