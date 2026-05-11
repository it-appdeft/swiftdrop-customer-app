import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/connectivity_service.dart';
import '../themes/app_colors.dart';
import '../themes/app_dimensions.dart';
import '../themes/app_text_styles.dart';

class ConnectivityWidget extends StatelessWidget {
  final Widget child;

  const ConnectivityWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isConnected = ConnectivityService.to.isConnected.value;
      return Column(
        children: [
          if (!isConnected)
            Container(
              width: double.infinity,
              color: AppColors.error,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMd,
                vertical: AppDimensions.gapSm,
              ),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off, size: AppDimensions.iconSm, color: AppColors.white),
                  const SizedBox(width: AppDimensions.gapSm),
                  Text(
                    'No internet connection',
                    style: AppTextStyles.pSmall.copyWith(color: AppColors.white),
                  ),
                ],
              ),
            ),
          Expanded(child: child),
        ],
      );
    });
  }
}
