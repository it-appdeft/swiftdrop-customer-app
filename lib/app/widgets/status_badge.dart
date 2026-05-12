import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_decorations.dart';
import '../themes/app_dimensions.dart';
import '../themes/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSm,
        vertical: AppDimensions.gapXs,
      ),
      decoration: AppDecorations.badge(color: config.color),
      child: Text(
        config.label,
        style: AppTextStyles.pXSmallMedium.copyWith(color: config.color),
      ),
    );
  }

  _StatusConfig _getConfig(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return _StatusConfig(AppColors.warning, 'Pending');
      case 'accepted':
        return _StatusConfig(AppColors.primary, 'Accepted');
      case 'picked_up':
        return _StatusConfig(AppColors.primary, 'On the way');
      case 'delivered':
        return _StatusConfig(AppColors.success, 'Delivered');
      case 'cancelled':
        return _StatusConfig(AppColors.error, 'Cancelled');
      case 'completed':
        return _StatusConfig(AppColors.success, 'Completed');
      case 'credit':
        return _StatusConfig(AppColors.success, 'Credit');
      case 'debit':
        return _StatusConfig(AppColors.error, 'Debit');
      default:
        return _StatusConfig(AppColors.textSecondary, status);
    }
  }
}

class _StatusConfig {
  final Color color;
  final String label;
  const _StatusConfig(this.color, this.label);
}
