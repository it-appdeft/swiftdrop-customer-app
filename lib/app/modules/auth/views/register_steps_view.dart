import 'package:swiftdrop_customer_app/export.dart';

class RegisterStepsView extends StatelessWidget {
  const RegisterStepsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text('Complete your profile', style: AppTextStyles.h6),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppDimensions.gapXl),
            _StepItem(
              stepNumber: 1,
              title: 'Verify phone number',
              subtitle: 'We\'ve sent a code to your number',
              isCompleted: true,
            ),
            const SizedBox(height: AppDimensions.gapMd),
            _StepItem(
              stepNumber: 2,
              title: 'Add delivery address',
              subtitle: 'Where should we deliver to?',
              isCompleted: false,
              isActive: true,
            ),
            const SizedBox(height: AppDimensions.gapMd),
            _StepItem(
              stepNumber: 3,
              title: 'Add payment method',
              subtitle: 'Add a card or top up your wallet',
              isCompleted: false,
            ),
            const SizedBox(height: AppDimensions.sp40),
            AppButton(
              label: 'Add delivery address',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final int stepNumber;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isActive;

  const _StepItem({
    required this.stepNumber,
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCompleted
        ? AppColors.success
        : isActive
            ? AppColors.primary
            : AppColors.textHint;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: AppRadius.md,
        border: Border.all(
          color: isActive ? AppColors.primary : AppColors.darkBorder,
          width: isActive ? 1.5 : 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? Icon(Icons.check, size: 18, color: color)
                  : Text('$stepNumber', style: AppTextStyles.pSmallSemiBold.copyWith(color: color)),
            ),
          ),
          const SizedBox(width: AppDimensions.gapMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.pSmallSemiBold),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          if (!isCompleted)
            Icon(Icons.arrow_forward_ios, size: 14, color: color),
        ],
      ),
    );
  }
}
