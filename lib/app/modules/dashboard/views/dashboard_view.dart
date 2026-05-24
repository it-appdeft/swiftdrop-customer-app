import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_dimensions.dart';
import '../../../themes/app_radius.dart';
import '../../../themes/app_text_styles.dart';
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
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.darkBackground,
      body: Obx(() => IndexedStack(
            index: controller.currentIndex.value,
            children: _pages,
          )),
      bottomNavigationBar: Obx(() => _BottomNav(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changePage,
          )),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppDimensions.paddingMd,
          AppDimensions.gapSm,
          AppDimensions.paddingMd,
          bottom + AppDimensions.gapMd,
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
                  label: 'Home',
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
                  label: 'Search',
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
                  label: 'History',
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
                  label: 'Account',
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
      onTap: () => onTap(index),
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

