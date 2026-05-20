import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_decorations.dart';
import '../../../themes/app_dimensions.dart';
import '../../../themes/app_text_styles.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text('Settings', style: AppTextStyles.h6),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        children: [
          _SectionLabel('Notifications'),
          _ToggleTile(
            label: 'Push notifications',
            subtitle: 'Receive push notifications',
            value: controller.pushNotifications,
            onChanged: (v) => controller.pushNotifications.value = v,
          ),
          _ToggleTile(
            label: 'Order updates',
            subtitle: 'Get notified about your orders',
            value: controller.orderUpdates,
            onChanged: (v) => controller.orderUpdates.value = v,
          ),
          _ToggleTile(
            label: 'Promotions',
            subtitle: 'Deals and special offers',
            value: controller.promotions,
            onChanged: (v) => controller.promotions.value = v,
          ),
          const SizedBox(height: AppDimensions.gapLg),
          _SectionLabel('App'),
          _ListTile(label: 'App version', value: '1.0.0'),
          _ListTile(label: 'Region', value: '🇬🇧 United Kingdom'),
          _ListTile(label: 'Currency', value: '£ GBP'),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.gapSm, top: AppDimensions.gapSm),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.label.copyWith(color: AppColors.textHint),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final RxBool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.gapSm),
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: AppDecorations.card,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.pSmallSemiBold),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
          Obx(() => Switch(value: value.value, onChanged: onChanged)),
        ],
      ),
    );
  }
}

class _ListTile extends StatelessWidget {
  final String label;
  final String value;

  const _ListTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.gapSm),
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: AppDecorations.card,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.pSmall),
          Text(value, style: AppTextStyles.pSmall.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
