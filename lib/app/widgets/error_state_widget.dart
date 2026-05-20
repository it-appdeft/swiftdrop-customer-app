import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_dimensions.dart';
import '../themes/app_text_styles.dart';
import 'app_button.dart';

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: AppDimensions.gapLg),
            Text(
              'Something went wrong',
              style: AppTextStyles.pMediumSemiBold,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.gapSm),
            Text(
              message,
              style: AppTextStyles.pSmall.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.gapXl),
              AppButton(
                label: 'Try Again',
                onTap: onRetry,
                width: 160,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
