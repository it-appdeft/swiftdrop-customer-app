import 'package:swiftdrop_customer_app/export.dart';

import '../controllers/edit_profile_controller.dart';

class DeleteAccountReasonView extends GetView<EditProfileController> {
  const DeleteAccountReasonView({super.key});

  @override
  Widget build(BuildContext context) {
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
          'Delete Account',
          style: AppTextStyles.h6.copyWith(color: AppColors.lightSurfaceHeading),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMd,
          vertical: AppDimensions.paddingLg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Reason',
              style: AppTextStyles.h6.copyWith(
                color: AppColors.lightSurfaceDarkText,
              ),
            ),
            const SizedBox(height: AppDimensions.gapXs),
            Text(
              'Why would you like to delete your account?',
              style: AppTextStyles.pSmall.copyWith(
                color: AppColors.lightSurfaceSubtitle,
              ),
            ),
            const SizedBox(height: AppDimensions.gapLg),
            Obx(() => Column(
                  children: controller.deletionReasons
                      .map((r) => _ReasonCard(reason: r))
                      .toList(),
                )),
          ],
        ),
      ),
    );
  }
}

class _ReasonCard extends GetView<EditProfileController> {
  final DeletionReason reason;
  const _ReasonCard({required this.reason});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.gapSm),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.lightSurfaceBorder),
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: AppRadius.md,
        child: InkWell(
          onTap: () => controller.pickDeletionReason(reason),
          borderRadius: AppRadius.md,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMd,
              vertical: AppDimensions.paddingMd,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    reason.reason,
                    style: AppTextStyles.pSmall.copyWith(
                      color: AppColors.lightSurfaceDarkText,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.gapSm),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: AppDimensions.iconXs,
                  color: AppColors.lightSurfaceHint,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
