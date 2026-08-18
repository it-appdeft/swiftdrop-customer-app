import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';


class SearchView extends GetView<SearchTabController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            _SearchRow(),
            Obx(() {
              if (controller.searchQuery.value.isEmpty) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _ResultTabs(),
                  ],
                ),
              );
            }),
            Expanded(
              child: Obx(() {
                if (controller.searchQuery.value.isEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _RecentHeader(),
                      const SizedBox(height: 14),
                      Expanded(child: _RecentChipsRow()),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 14),
                    _FilterRow(),
                    const SizedBox(height: 14),
                    Expanded(child: _SearchResultsList()),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchRow extends GetView<SearchTabController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.find<DashboardController>().changePage(0),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.lightSurfaceBorder),
              ),
              child: Center(
                child: Assets.images.back.image(width: 20, height: 20),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.lightSurfaceBorder),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Assets.images.homeSearchIcon.image(width: 20, height: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: controller.queryController,
                      onChanged: controller.onQueryChanged,
                      onSubmitted: controller.onSubmit,
                      textInputAction: TextInputAction.search,
                      cursorColor: AppColors.primary,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.lightSurfaceDarkText,
                      ),
                      decoration: const InputDecoration(
                        isCollapsed: true,
                        filled: false,
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        hintText: 'Search restaurants or dishes...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.lightSurfaceSubtitle,
                        ),
                      ),
                    ),
                  ),
                  Obx(
                    () => controller.inputText.value.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              AppUtils.haptic();
                              controller.clearQuery();
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.lightSurfaceBorder,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 14,
                                color: AppColors.lightSurfaceSubtitle,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentHeader extends GetView<SearchTabController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.recentSearches.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Searches',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.lightSurfaceDarkText,
              ),
            ),
            GestureDetector(
              onTap: () {
                AppUtils.haptic();
                controller.clearRecent();
              },
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
                  const SizedBox(width: 4),
                  Text(
                    'Clear all',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _RecentChipsRow extends GetView<SearchTabController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingRecent.value) {
        return const _ShimmerRecentChips();
      }
      if (controller.recentSearches.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: AppColors.offWhite,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Assets.images.recentSearch.image(
                      width: 68,
                      height: 68,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Search Foods & Restaurants',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightSurfaceDarkText,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Find your favorite dishes, cuisines, or top-rated restaurants near you.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.lightSurfaceSubtitle,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Wrap(
          spacing: 8,
          runSpacing: 10,
          children: controller.recentSearches
              .map((q) => _RecentChip(label: q, onTap: () => controller.tapRecent(q)))
              .toList(),
        ),
      );
    });
  }
}

class _RecentChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _RecentChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppUtils.haptic();
        onTap();
      },
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.offWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.lightSurfaceBorder),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history_rounded, size: 16, color: AppColors.lightSurfaceSubtitle),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.lightSurfaceDarkText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultTabs extends GetView<SearchTabController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            AppTabItem(
              label: AppStrings.popularRestaurants,
              isSelected: controller.selectedTabIndex.value == 0,
              onTap: () {
                AppUtils.haptic();
                controller.selectedTabIndex.value = 0;
              },
            ),
            const SizedBox(width: 16),
            AppTabItem(
              label: AppStrings.categories,
              isSelected: controller.selectedTabIndex.value == 1,
              onTap: () {
                AppUtils.haptic();
                controller.selectedTabIndex.value = 1;
              },
            ),
          ],
        ),
      );
    });
  }
}

class _FilterRow extends GetView<SearchTabController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _FilterChip(
              label: 'Offers',
              assetImage: Assets.images.offers,
              isSelected: controller.activeFilters.contains('Offers'),
              onTap: () {
                AppUtils.haptic();
                controller.toggleFilter('Offers');
              },
            ),
            const SizedBox(width: 10),
            _FilterChip(
              label: 'Highest rated',
              assetImage: Assets.images.highestRated,
              isSelected: controller.activeFilters.contains('Highest rated'),
              onTap: () {
                AppUtils.haptic();
                controller.toggleFilter('Highest rated');
              },
            ),
          ],
        ),
      );
    });
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final AssetGenImage assetImage;
  final bool isSelected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.assetImage, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppUtils.haptic();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.offWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.lightSurfaceBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            assetImage.image(width: 18, height: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.lightSurfaceDarkText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultsList extends GetView<SearchTabController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isSearching.value) {
        return controller.selectedTabIndex.value == 0
            ? const _ShimmerRestaurantList()
            : const _ShimmerItemGroupList();
      }

      final isRestaurantsTab = controller.selectedTabIndex.value == 0;
      final isEmpty = isRestaurantsTab
          ? controller.restaurantResults.isEmpty
          : controller.itemResults.isEmpty;

      if (isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: AppColors.offWhite,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Assets.images.noResultofSearch.image(
                      width: 72,
                      height: 72,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  AppStrings.noResultFound,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightSurfaceDarkText,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  isRestaurantsTab
                      ? AppStrings.noResultRestaurantsSubtitle
                      : AppStrings.noResultItemsSubtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.lightSurfaceSubtitle,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      if (isRestaurantsTab) {
        final list = controller.restaurantResults;
        final showLoader = controller.isLoadingMore.value || controller.hasMoreRestaurants.value;
        return Obx(() {
          final hasCart = Get.find<CartController>().cartItemCount.value > 0;
          return ListView.builder(
            controller: controller.scrollController,
            padding: EdgeInsets.fromLTRB(16, 0, 16, hasCart ? 120 : 20),
            itemCount: list.length + (showLoader ? 1 : 0),
            itemBuilder: (_, i) {
              if (i == list.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: controller.isLoadingMore.value
                      ? const AppLoader()
                      : const SizedBox.shrink(),
                );
              }
              return RestaurantCard(
                restaurant: list[i],
                searchQuery: controller.searchQuery.value,
                onFavoriteTap: () => controller.toggleRestaurantFavorite(list[i]['id']),
              );
            },
          );
        });
      }

      final list = controller.itemResults;
      final showLoader = controller.isLoadingMore.value || controller.hasMoreItems.value;
      return Obx(() {
        final hasCart = Get.find<CartController>().cartItemCount.value > 0;
        return ListView.builder(
          controller: controller.scrollController,
          padding: EdgeInsets.only(bottom: hasCart ? 150 : 40),
          itemCount: list.length + (showLoader ? 1 : 0),
          itemBuilder: (_, i) {
            if (i == list.length) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: controller.isLoadingMore.value
                    ? const AppLoader()
                    : const SizedBox.shrink(),
              );
            }
            return RestaurantWithItems(
              data: list[i],
              searchQuery: controller.searchQuery.value,
              showFavorite: false,
              onFavoriteTap: () => controller.toggleRestaurantFavorite(list[i]['id']),
            );
          },
        );
      });
    });
  }
}

class _ShimmerRestaurantList extends StatelessWidget {
  const _ShimmerRestaurantList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      itemCount: 3,
      itemBuilder: (_, __) => const RestaurantCardShimmer(),
    );
  }
}

class _ShimmerItemGroupList extends StatelessWidget {
  const _ShimmerItemGroupList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 2,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        color: AppColors.offWhite,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 12, 28, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppShimmer.text(width: 140, height: 18),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            AppShimmer.circle(size: 16),
                            const SizedBox(width: 4),
                            AppShimmer.text(width: 60, height: 12),
                            const SizedBox(width: 16),
                            AppShimmer.text(width: 40, height: 12),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  AppShimmer.circle(size: 24),
                ],
              ),
            ),
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 36),
                itemCount: 3,
                itemBuilder: (_, __) => Container(
                  width: 330,
                  height: 160,
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppShimmer.rect(width: 128, height: 119, radius: 10),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppShimmer.rect(width: 16, height: 16),
                            const SizedBox(height: 4),
                            AppShimmer.text(height: 16),
                            const SizedBox(height: 4),
                            AppShimmer.text(width: 60, height: 14),
                            const SizedBox(height: 4),
                            AppShimmer.rect(width: 52, height: 22, radius: 11),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _ShimmerRecentChips extends StatelessWidget {
  const _ShimmerRecentChips();

  static const _widths = [80.0, 120.0, 60.0, 100.0, 90.0, 70.0];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 12,
        children: _widths.map((w) => Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.offWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.lightSurfaceBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppShimmer.circle(size: 16),
              const SizedBox(width: 8),
              AppShimmer.text(width: w, height: 12),
            ],
          ),
        )).toList(),
      ),
    );
  }
}
