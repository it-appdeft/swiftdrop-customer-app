import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';
import '../../../../export.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_dimensions.dart';
import '../../../themes/app_radius.dart';
import '../../../widgets/cart_floating_bar.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../home/views/home_view.dart';
import '../../order_history/views/order_history_view.dart';
import '../../profile/views/profile_view.dart';
import '../../search/views/search_view.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  static const List<Widget> _pages = [
    HomeView(),
    SearchView(),
    OrderHistoryView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();

    // Mirror _BottomNav height so the floating bar sits exactly 12 px above
    // the rounded nav container.
    final systemBottom = MediaQuery.of(context).padding.bottom;
    final double navBottomPad;
    if (GetPlatform.isIOS && systemBottom > 0) {
      navBottomPad = (systemBottom - 8).clamp(0.0, double.infinity);
    } else {
      navBottomPad = systemBottom > 0 ? systemBottom + 12.0 : AppDimensions.gapMd;
    }
    // gapSm (top pad) + bottomNavHeight + navBottomPad = full widget height
    final navTotalHeight = AppDimensions.gapSm + AppDimensions.bottomNavHeight + navBottomPad;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        controller.handleBackPress();
      },
      child: Scaffold(
        extendBody: true,
        backgroundColor: AppColors.darkBackground,
        body: Stack(
          children: [
            Obx(() => IndexedStack(
                  index: controller.currentIndex.value,
                  children: _pages,
                )),
            
            // Order floating bar (lower priority or stacked below cart if both exist?)
            // Usually Active Order is more critical.
            Obx(() {
              final hasCart = cartController.cartItemCount.value > 0;
              final hasActiveOrders = controller.activeOrders.isNotEmpty;
              
              if (!hasCart && !hasActiveOrders) return const SizedBox.shrink();

              return Positioned(
                left: 0,
                right: 0,
                bottom: navTotalHeight - 4,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasActiveOrders) ...[
                      const ActiveOrdersFloatingBar(),
                      if (hasCart) const SizedBox(height: 12),
                    ],
                    if (hasCart) const CartFloatingBar(addSafeArea: false),
                  ],
                ),
              );
            }),
          ],
        ),
        bottomNavigationBar: Obx(() => _BottomNav(
              currentIndex: controller.currentIndex.value,
              onTap: controller.changePage,
            )),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom ;
    
    double finalBottomPadding;
    if (GetPlatform.isIOS && bottomPadding > 0) {
      finalBottomPadding = (bottomPadding - 8).clamp(0.0, double.infinity);
    } else {
      finalBottomPadding = bottomPadding > 0 ? bottomPadding + 12 : AppDimensions.gapMd;
    }

    return Container(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppDimensions.paddingMd,
          AppDimensions.gapSm,
          AppDimensions.paddingMd,
          finalBottomPadding,
        ),
        child: Container(
          height: AppDimensions.bottomNavHeight,
          decoration: BoxDecoration(
            color: const Color(0xFF0F1520),
            borderRadius: AppRadius.xl,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 24),
              Expanded(
                child: _NavItem(
                  icon: Assets.images.homeUnselected,
                  activeIcon: Assets.images.homeSelected,
                  label: AppStrings.navHome,
                  index: 0,
                  currentIndex: currentIndex,
                  onTap: onTap,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _NavItem(
                  icon: Assets.images.searchUnselected,
                  activeIcon: Assets.images.searchSelected,
                  label: AppStrings.navSearch,
                  index: 1,
                  currentIndex: currentIndex,
                  onTap: onTap,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _NavItem(
                  icon: Assets.images.historyUnselected,
                  activeIcon: Assets.images.historySelcted,
                  label: AppStrings.navHistory,
                  index: 2,
                  currentIndex: currentIndex,
                  onTap: onTap,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _NavItem(
                  icon: Assets.images.profileUnselcetd,
                  activeIcon: Assets.images.profileSelected,
                  label: AppStrings.navAccount,
                  index: 3,
                  currentIndex: currentIndex,
                  onTap: onTap,
                ),
              ),
              const SizedBox(width: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final AssetGenImage icon;
  final AssetGenImage activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentIndex == index;
    final color = isActive ? AppColors.primary : AppColors.white;

    return GestureDetector(
      onTap: () {
        AppUtils.haptic();
        onTap(index);
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            (isActive ? activeIcon : icon).image(
              width: 22,
              height: 22,
              color: color,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

