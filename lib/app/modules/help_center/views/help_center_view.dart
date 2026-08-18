import 'package:swiftdrop_customer_app/export.dart';


class HelpCenterView extends GetView<HelpCenterController> {
  const HelpCenterView({super.key});

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
            color: AppColors.black,
          ),
          onPressed: () {
            AppUtils.haptic();
            Get.back();
          },
        ),
        title: Text(
          'Help',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Report an Issue',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'If you are experiencing any issue. please let us know. we will try to solve as soon as possible.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.lightSurfaceSubtitle,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: AppDimensions.gapLg),
              const _RequiredLabel(label: 'Issue'),
              const SizedBox(height: AppDimensions.gapSm),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.lightSurfaceBorder),
                ),
                child: TextField(
                  controller: controller.issueTitleController,
                  autocorrect: false,
                  enableSuggestions: false,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.black,
                    decoration: TextDecoration.none,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.white,
                    hintText: 'Enter title for the Issue',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.lightSurfaceSubtitle,
                      decoration: TextDecoration.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.gapMd),
              const _RequiredLabel(label: 'Details'),
              const SizedBox(height: AppDimensions.gapSm),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.lightSurfaceBorder),
                ),
                child: TextField(
                  controller: controller.issueDetailsController,
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
                    hintText: 'Describe the issue in details....',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.lightSurfaceSubtitle,
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
              ),
              const SizedBox(height: AppDimensions.gapXl * 1.5),
              Obx(() => AppButton(
                    label: 'Submit Report',
                    onTap: controller.isSubmitting.value
                        ? null
                        : () {
                            FocusScope.of(context).unfocus();
                            controller.submitReport();
                          },
                    isLoading: controller.isSubmitting.value,
                    backgroundColor: AppColors.primary,
                    borderRadius: AppRadius.md,
                  )),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequiredLabel extends StatelessWidget {
  final String label;
  const _RequiredLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.black,
          ),
        ),
        Text(
          ' *',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.error,
          ),
        ),
      ],
    );
  }
}
