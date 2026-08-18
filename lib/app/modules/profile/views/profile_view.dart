import '../../../../export.dart';
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
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
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
            hasCart ? 200 : 150,
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
      final name = user?.name ?? '';
      final initial = name.isNotEmpty
          ? name.substring(0, 1).toUpperCase()
          : 'U';
      final email = user?.email ?? '';
      final phone = user?.phone ?? '';
      final subtitle = email.isNotEmpty
          ? email
          : AppUtils.formatPhoneDisplay(phone);

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
              decoration: const BoxDecoration(
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
                    name.isNotEmpty ? name : 'User',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.lightSurfaceDarkText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.lightSurfaceSubtitle,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Edit icon
            GestureDetector(
              onTap: controller.navigateToEditProfile,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.edit_outlined,
                  color: AppColors.primary,
                  size: AppDimensions.iconSm,
                ),
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
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.lightSurfaceText,
        ),
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
      _MenuItemData(
          icon: Icons.location_on_outlined,
          label: AppStrings.savedAddresses,
          onTap: controller.navigateToAddress),
      _MenuItemData(
          icon: Icons.favorite_border_rounded,
          label: 'Favorites',
          onTap: controller.navigateToFavorites),
      _MenuItemData(
          icon: Icons.credit_card_outlined,
          label: 'Payments',
          onTap: comingSoon),
      _MenuItemData(
          icon: Icons.settings_outlined,
          label: AppStrings.settings,
          onTap: controller.navigateToSettings),
      _MenuItemData(
          icon: Icons.privacy_tip_outlined,
          label: AppStrings.privacyPolicy,
          onTap: () => Get.toNamed(AppRoutes.privacyPolicy)),
      _MenuItemData(
          icon: Icons.article_outlined,
          label: AppStrings.termsConditions,
          onTap: () => Get.toNamed(AppRoutes.termsConditions)),
      _MenuItemData(
          icon: Icons.help_outline_rounded,
          label: AppStrings.helpCenter,
          onTap: () => Get.toNamed(AppRoutes.helpCenter)),
      _MenuItemData(
          icon: Icons.delete_outline_rounded,
          label: 'Delete Account',
          isDestructive: true,
          onTap: () => Get.toNamed(AppRoutes.deleteAccountReason)),
      _MenuItemData(
          icon: Icons.logout_rounded,
          label: AppStrings.logout,
          onTap: controller.logout),
    ];

    return Column(
      children: items.map((item) => _MenuItemCard(data: item)).toList(),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuItemData({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });
}

class _MenuItemCard extends StatelessWidget {
  final _MenuItemData data;

  const _MenuItemCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final color = data.isDestructive
        ? AppColors.error
        : AppColors.lightSurfaceDarkText;
    final iconColor = data.isDestructive
        ? AppColors.error
        : AppColors.lightSurfaceSubtitle;

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
          onTap: () {
            AppUtils.haptic();
            data.onTap.call();
          },
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
                  color: iconColor,
                ),
                const SizedBox(width: AppDimensions.gapMd),
                Expanded(
                  child: Text(
                    data.label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: data.isDestructive
                          ? FontWeight.w500
                          : FontWeight.w400,
                      color: color,
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