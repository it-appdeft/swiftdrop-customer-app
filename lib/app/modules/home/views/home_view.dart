import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_dimensions.dart';
import '../../../themes/app_text_styles.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/section_header.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _Header()),
            SliverToBoxAdapter(child: _SearchBar()),
            SliverToBoxAdapter(child: _CategoriesRow()),
            SliverToBoxAdapter(child: _ActiveOrderBanner()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.paddingMd,
                  AppDimensions.gapXl,
                  AppDimensions.paddingMd,
                  AppDimensions.gapMd,
                ),
                child: SectionHeader(title: 'Featured near you'),
              ),
            ),
            _RestaurantList(),
          ],
        ),
      ),
    );
  }
}

class _Header extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    final user = AuthService.to.currentUser.value;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingMd,
        AppDimensions.paddingMd,
        AppDimensions.paddingMd,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${user?.name.split(' ').first ?? 'there'}!',
                  style: AppTextStyles.h5,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      'London, UK',
                      style: AppTextStyles.pSmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: AppDimensions.avatarMd,
            height: AppDimensions.avatarMd,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user?.name.substring(0, 1).toUpperCase() ?? 'U',
                style: AppTextStyles.pMediumBold.copyWith(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      child: TextField(
        controller: controller.searchController,
        style: AppTextStyles.pMedium,
        decoration: InputDecoration(
          hintText: 'Search restaurants, food...',
          prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
          suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textHint),
                  onPressed: controller.clearSearch,
                )
              : const SizedBox.shrink()),
        ),
      ),
    );
  }
}

class _CategoriesRow extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: Obx(() => ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMd),
            itemCount: controller.categories.length,
            itemBuilder: (_, index) {
              final cat = controller.categories[index];
              return _CategoryChip(icon: cat['icon'], name: cat['name']);
            },
          )),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String icon;
  final String name;

  const _CategoryChip({required this.icon, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: AppDimensions.gapSm),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(color: AppColors.darkBorder, width: 0.5),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(height: 6),
          Text(name, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _ActiveOrderBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMd),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Row(
          children: [
            const Icon(Icons.delivery_dining, color: AppColors.white, size: 28),
            const SizedBox(width: AppDimensions.gapMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order on the way!', style: AppTextStyles.pSmallSemiBold.copyWith(color: AppColors.white)),
                  const SizedBox(height: 2),
                  Text('Tap to track your delivery', style: AppTextStyles.caption.copyWith(color: AppColors.white.withOpacity(0.8))),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppColors.white, size: 14),
          ],
        ),
      ),
    );
  }
}

class _RestaurantList extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.filteredRestaurants.isEmpty) {
        return SliverToBoxAdapter(
          child: EmptyStateWidget(
            message: 'No restaurants found',
            subtitle: 'Try searching for something else',
            icon: Icons.search_off,
          ),
        );
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, index) {
            final r = controller.filteredRestaurants[index];
            return _RestaurantCard(restaurant: r);
          },
          childCount: controller.filteredRestaurants.length,
        ),
      );
    });
  }
}

class _RestaurantCard extends StatelessWidget {
  final Map<String, dynamic> restaurant;

  const _RestaurantCard({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final isOpen = restaurant['isOpen'] as bool;
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppDimensions.paddingMd,
        0,
        AppDimensions.paddingMd,
        AppDimensions.gapMd,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.darkBorder, width: 0.5),
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          onTap: isOpen ? () {} : null,
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMd),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.darkSurfaceElevated,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: const Icon(Icons.storefront, color: AppColors.textHint, size: 28),
                ),
                const SizedBox(width: AppDimensions.gapMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant['name'],
                        style: AppTextStyles.pMediumSemiBold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        restaurant['category'],
                        style: AppTextStyles.pSmall.copyWith(color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: AppDimensions.gapSm,
                        runSpacing: 2,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, size: 12, color: AppColors.warning),
                              const SizedBox(width: 2),
                              Text(
                                '${restaurant['rating']}',
                                style: AppTextStyles.pXSmall.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.schedule, size: 12, color: AppColors.textHint),
                              const SizedBox(width: 2),
                              Text(
                                restaurant['deliveryTime'],
                                style: AppTextStyles.pXSmall.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                          Text(
                            '£${(restaurant['deliveryFee'] as double).toStringAsFixed(2)} delivery',
                            style: AppTextStyles.pXSmall.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!isOpen)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurfaceElevated,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                    child: Text(
                      'Closed',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
