import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swiftdrop_customer_app/export.dart';
import '../controllers/edit_profile_controller.dart';

class DeleteAccountConfirmationView extends GetView<EditProfileController> {
  const DeleteAccountConfirmationView({super.key});

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
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: AppDimensions.iconSm,
            color: AppColors.lightSurfaceDarkText,
          ),
          onPressed: () {
            AppUtils.haptic();
            Get.back();
          },
        ),
        title: Text(
          AppStrings.deleteConfirmation,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.lightSurfaceDarkText,
          ),
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
                padding: const EdgeInsets.all(AppDimensions.paddingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                          controller.selectedReason.value?.reason ?? '',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.lightSurfaceDarkText,
                            height: 1.3,
                          ),
                        )),
                    const SizedBox(height: AppDimensions.gapLg),
                    const _FeedbackField(),
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
                    label: AppStrings.deleteAccount,
                    onTap: controller.isLoading.value
                        ? null
                        : () {
                            FocusScope.of(context).unfocus();
                            controller.confirmDeletionReason();
                          },
                    isLoading: controller.isLoading.value,
                    backgroundColor: AppColors.primary,
                    borderRadius: AppRadius.md,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackField extends GetView<EditProfileController> {
  const _FeedbackField();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.lightSurfaceBorder),
      ),
      child: TextField(
        controller: controller.deletionFeedbackController,
        autocorrect: false,
        enableSuggestions: false,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.black,
          decoration: TextDecoration.none,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.white,
          hintText: AppStrings.deleteAccountFeedbackHint,
          hintStyle: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.lightSurfaceSubtitle.withOpacity(0.6),
            decoration: TextDecoration.none,
          ),
          contentPadding: const EdgeInsets.all(14),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
        ),
      ),
    );
  }
}
