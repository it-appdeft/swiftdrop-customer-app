import 'package:swiftdrop_customer_app/export.dart';

import '../controllers/edit_profile_controller.dart';

class DeleteAccountConfirmationView extends GetView<EditProfileController> {
  const DeleteAccountConfirmationView({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.offWhite,
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
          'Delete Confirmation',
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
                  vertical: AppDimensions.paddingLg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                          controller.selectedReason.value?.reason ?? '',
                          style: AppTextStyles.h6.copyWith(
                            color: AppColors.lightSurfaceDarkText,
                            height: 1.3,
                          ),
                        )),
                    const SizedBox(height: AppDimensions.gapLg),
                    _FeedbackField(),
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
                    label: 'Delete Account',
                    onTap: controller.isLoading.value
                        ? null
                        : () {
                            FocusScope.of(context).unfocus();
                            controller.confirmDeletionReason();
                          },
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

class _FeedbackField extends GetView<EditProfileController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.lightInput,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSm,
        vertical: AppDimensions.gapSm,
      ),
      child: TextField(
        controller: controller.deletionFeedbackController,
        maxLines: 6,
        minLines: 6,
        keyboardType: TextInputType.multiline,
        textCapitalization: TextCapitalization.sentences,
        style: AppTextStyles.pSmall.copyWith(color: AppColors.lightSurfaceText),
        decoration: InputDecoration(
          isCollapsed: true,
          filled: true,
          fillColor: AppColors.transparent,
          hintText:
              'Do you have any feedback for us? We would love to hear from you! (optional)',
          hintStyle: AppTextStyles.pSmall.copyWith(
            color: AppColors.lightSurfaceSubtitle,
            height: 1.4,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
