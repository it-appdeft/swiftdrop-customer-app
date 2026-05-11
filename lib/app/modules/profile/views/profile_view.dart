import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_dimensions.dart';
import '../../../themes/app_text_styles.dart';
import '../../../utils/app_utils.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text('Profile', style: AppTextStyles.h6),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: controller.navigateToSettings,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _ProfileHeader(),
            const SizedBox(height: AppDimensions.gapLg),
            _MenuSection(),
            const SizedBox(height: AppDimensions.gapLg),
            _LogoutButton(),
            const SizedBox(height: AppDimensions.sp32),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = controller.user.value;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimensions.paddingXl),
        color: AppColors.darkSurface,
        child: Column(
          children: [
            Container(
              width: AppDimensions.avatarXl,
              height: AppDimensions.avatarXl,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  user?.name.substring(0, 1).toUpperCase() ?? 'U',
                  style: AppTextStyles.h3.copyWith(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.gapMd),
            Text(user?.name ?? '', style: AppTextStyles.h6),
            const SizedBox(height: 4),
            Text(
              AppUtils.formatPhoneDisplay(user?.phone ?? ''),
              style: AppTextStyles.pSmall.copyWith(color: AppColors.textSecondary),
            ),
            if (user?.email != null) ...[
              const SizedBox(height: 4),
              Text(
                user!.email!,
                style: AppTextStyles.pSmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: AppDimensions.gapMd),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.verified, size: 16, color: AppColors.success),
                const SizedBox(width: 4),
                Text(
                  user?.isVerified == true ? 'Verified account' : 'Unverified',
                  style: AppTextStyles.pXSmall.copyWith(
                    color: user?.isVerified == true ? AppColors.success : AppColors.warning,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _MenuSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMd),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: AppColors.darkBorder, width: 0.5),
        ),
        child: Column(
          children: [
            _MenuItem(icon: Icons.location_on_outlined, label: 'Saved addresses', onTap: () {}),
            const Divider(height: 1, color: AppColors.darkBorder),
            _MenuItem(icon: Icons.payment_outlined, label: 'Payment methods', onTap: () {}),
            const Divider(height: 1, color: AppColors.darkBorder),
            _MenuItem(icon: Icons.history, label: 'Order history', onTap: () {}),
            const Divider(height: 1, color: AppColors.darkBorder),
            _MenuItem(icon: Icons.headset_mic_outlined, label: 'Help & support', onTap: () {}),
            const Divider(height: 1, color: AppColors.darkBorder),
            _MenuItem(icon: Icons.privacy_tip_outlined, label: 'Privacy policy', onTap: () {}),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMd,
            vertical: AppDimensions.paddingMd,
          ),
          child: Row(
            children: [
              Icon(icon, size: AppDimensions.iconSm, color: AppColors.textSecondary),
              const SizedBox(width: AppDimensions.gapMd),
              Expanded(child: Text(label, style: AppTextStyles.pSmall)),
              const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMd),
      child: Material(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: InkWell(
          onTap: controller.logout,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.paddingMd),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(color: AppColors.error.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.logout, size: AppDimensions.iconSm, color: AppColors.error),
                const SizedBox(width: AppDimensions.gapSm),
                Text(
                  'Sign out',
                  style: AppTextStyles.pSmallSemiBold.copyWith(color: AppColors.error),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
