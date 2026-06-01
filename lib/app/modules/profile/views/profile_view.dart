import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_dimensions.dart';
import '../../../themes/app_radius.dart';
import '../../../themes/app_text_styles.dart';
import '../../../utils/app_utils.dart';
import '../../cart/controllers/cart_controller.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: Text(
          'Account',
          style: AppTextStyles.h6.copyWith(color: AppColors.white),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Obx(() {
        final hasCart = cartController.cartItemCount.value > 0;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppDimensions.paddingMd,
            AppDimensions.paddingMd,
            AppDimensions.paddingMd,
            hasCart ? 200 : 150, // Increased bottom padding if cart view is visible
          ),
          child: Column(
            children: [
              const SizedBox(height: AppDimensions.gapSm),
              _ProfileCard(),
              const SizedBox(height: AppDimensions.gapLg),
              _MenuList(),
            ],
          ),
        );
      }),
    );
  }
}

// ─── Profile Card ─────────────────────────────────────────────────────────────

class _ProfileCard extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = controller.user.value;
      final initial = user?.name.isNotEmpty == true
          ? user!.name.substring(0, 1).toUpperCase()
          : 'U';

      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMd,
          vertical: AppDimensions.paddingMd,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.lg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar circle
            Container(
              width: AppDimensions.avatarMd,
              height: AppDimensions.avatarMd,
              decoration: BoxDecoration(
                color: AppColors.lightSurfaceBorder,
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: _AvatarContent(avatar: user?.avatar, initial: initial),
            ),
            const SizedBox(width: AppDimensions.gapMd),
            // Name & email
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? '',
                    style: AppTextStyles.pMediumSemiBold.copyWith(
                      color: AppColors.lightSurfaceDarkText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user?.email ?? AppUtils.formatPhoneDisplay(user?.phone ?? ''),
                    style: AppTextStyles.pXSmall.copyWith(
                      color: AppColors.lightSurfaceSubtitle,
                    ),
                  ),
                ],
              ),
            ),
            // Edit icon
            GestureDetector(
              onTap: controller.navigateToEditProfile,
              child: Icon(
                Icons.edit_outlined,
                color: AppColors.primary,
                size: AppDimensions.iconSm,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _AvatarContent extends StatelessWidget {
  final String? avatar;
  final String initial;

  const _AvatarContent({required this.avatar, required this.initial});

  Widget _fallback() {
    return Center(
      child: Text(
        initial,
        style: AppTextStyles.h6.copyWith(color: AppColors.lightSurfaceText),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (avatar == null || avatar!.isEmpty) return _fallback();
    return Image.network(
      avatar!,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _fallback(),
    );
  }
}

// ─── Menu List ────────────────────────────────────────────────────────────────

class _MenuList extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    void comingSoon() => AppUtils.showInfo('Feature coming soon.');
    final items = [
      _MenuItemData(icon: Icons.location_on_outlined,   label: 'Saved Address',      onTap: controller.navigateToAddress),
      _MenuItemData(icon: Icons.favorite_border_rounded, label: 'Favorites',          onTap: controller.navigateToFavorites),
      _MenuItemData(icon: Icons.credit_card_outlined,    label: 'Payments',           onTap: comingSoon),
      _MenuItemData(icon: Icons.settings_outlined,       label: 'Settings',           onTap: controller.navigateToSettings),
      _MenuItemData(icon: Icons.privacy_tip_outlined,    label: 'Privacy Policy',     onTap: comingSoon),
      _MenuItemData(icon: Icons.article_outlined,        label: 'Terms & Conditions', onTap: comingSoon),
      _MenuItemData(icon: Icons.help_outline_rounded,    label: 'Help',               onTap: comingSoon),
      _MenuItemData(icon: Icons.logout_rounded,          label: 'Logout',             onTap: controller.logout),
    ];

    return Column(
      children: items
          .map((item) => _MenuItemCard(data: item))
          .toList(),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItemData({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _MenuItemCard extends StatelessWidget {
  final _MenuItemData data;

  const _MenuItemCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.gapSm),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.md,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: AppRadius.md,
        child: InkWell(
          onTap: data.onTap,
          borderRadius: AppRadius.md,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMd,
              vertical: AppDimensions.paddingMd,
            ),
            child: Row(
              children: [
                Icon(
                  data.icon,
                  size: AppDimensions.iconSm,
                  color: AppColors.lightSurfaceSubtitle,
                ),
                const SizedBox(width: AppDimensions.gapMd),
                Expanded(
                  child: Text(
                    data.label,
                    style: AppTextStyles.pSmall.copyWith(
                      color: AppColors.lightSurfaceDarkText,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: AppDimensions.iconXs,
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