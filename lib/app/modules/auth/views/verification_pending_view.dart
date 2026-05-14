import 'package:swiftdrop_customer_app/export.dart';

class VerificationPendingView extends StatelessWidget {
  const VerificationPendingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingXl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.hourglass_bottom, size: 48, color: AppColors.warning),
              ),
              const SizedBox(height: AppDimensions.gapXl),
              Text('Verification pending', style: AppTextStyles.h5, textAlign: TextAlign.center),
              const SizedBox(height: AppDimensions.gapMd),
              Text(
                'Your account is being verified. This usually takes a few minutes. You\'ll receive a notification once it\'s done.',
                style: AppTextStyles.pMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.sp40),
              AppButton(
                label: 'Back to Login',
                onTap: () => Get.offAllNamed(AppRoutes.login),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
