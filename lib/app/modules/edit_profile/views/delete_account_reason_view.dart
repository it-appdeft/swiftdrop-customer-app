import 'package:swiftdrop_customer_app/export.dart';
import '../controllers/edit_profile_controller.dart';

class DeleteAccountReasonView extends GetView<EditProfileController> {
  const DeleteAccountReasonView({super.key});

  @override
  Widget build(BuildContext context) {
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
          AppStrings.deleteAccount,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.lightSurfaceDarkText,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.selectReason,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.lightSurfaceDarkText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppStrings.whyDeleteAccount,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w400,
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.lightSurfaceBorder),
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: AppRadius.md,
        child: InkWell(
          onTap: () {
            AppUtils.haptic();
            controller.pickDeletionReason(reason);
          },
          borderRadius: AppRadius.md,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    reason.reason,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.lightSurfaceDarkText,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
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
