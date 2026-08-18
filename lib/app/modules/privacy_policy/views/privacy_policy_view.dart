import 'package:swiftdrop_customer_app/export.dart';
import '../controllers/privacy_policy_controller.dart';

class PrivacyPolicyView extends GetView<PrivacyPolicyController> {
  const PrivacyPolicyView({super.key});

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
          AppStrings.privacyPolicy,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.lightSurfaceDarkText,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingMd),
          child: Column(
            children: controller.paragraphs
                .map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppDimensions.paddingMd),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: AppRadius.lg,
                        border: Border.all(color: AppColors.lightSurfaceBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        p,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.lightSurfaceDarkText,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        );
      }),
    );
  }
}
