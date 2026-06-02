import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../controllers/search_controller.dart';

class SearchView extends GetView<SearchTabController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();

    return Scaffold(
      backgroundColor: AppColors.buttonLabel,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // _SearchRow is a direct, static child of this Column — never
            // inside any Obx — so its TextField element is never touched
            // by reactive rebuilds, keeping focus and keystrokes intact.
            const SizedBox(height: 11),
            _SearchRow(),
            // Tabs row: appears with shadow only in results mode.
            Obx(() {
              if (controller.searchQuery.value.isEmpty) return const SizedBox.shrink();
              return Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFEFEFD),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowLight,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _ResultTabs(),
                  ],
                ),
              );
            }),
            // Body: recent searches or filter chips + results list.
            Expanded(
              child: Obx(() {
                if (controller.searchQuery.value.isEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _RecentHeader(),
                      const SizedBox(height: 16),
                      Expanded(child: _RecentChipsRow()),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _FilterRow(),
                        const SizedBox(height: 16),
                      ],
                    ),
                    Expanded(child: _SearchResultsList()),
                  ],
                );
              }),
            ),
          ],
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
            child: SizedBox(
              width: 24,
              height: 24,
              child: Assets.images.back.image(width: 24, height: 24),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.lightSurfaceBorder),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Assets.images.homeSearchIcon.image(width: 24, height: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: controller.queryController,
                      onChanged: controller.onQueryChanged,
                      onSubmitted: controller.onSubmit,
                      textInputAction: TextInputAction.search,
                      cursorColor: AppColors.iconDark,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.lightSurfaceDarkText,
                      ),
                      decoration: const InputDecoration(
                        isCollapsed: true,
                        filled: false,
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        hintText: 'Search restaurant or items',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.lightSurfaceSubtitle,
                        ),
                      ),
                    ),
                  ),
                  Obx(
                    () => controller.searchQuery.value.isNotEmpty
                        ? GestureDetector(
                            onTap: controller.clearQuery,
                            behavior: HitTestBehavior.opaque,
                            child: const Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: AppColors.lightSurfaceSubtitle,
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
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.navyMedium,
              ),
            ),
            GestureDetector(
              onTap: controller.clearRecent,
              behavior: HitTestBehavior.opaque,
              child: Text(
                'Clear',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.error,
                ),
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Type something to search!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.lightSurfaceSubtitle,
              ),
            ),
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Wrap(
          spacing: 8,
          runSpacing: 12,
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
      onTap: onTap,
      child: Container(
        height: 41,
        decoration: BoxDecoration(
          color: AppColors.offWhite,
          borderRadius: BorderRadius.circular(44),
          border: Border.all(color: AppColors.lightSurfaceBorder),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Assets.images.recentSearch.image(width: 20, height: 20),
            const SizedBox(width: 9),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
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
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Row(
          children: [
            AppTabItem(
              label: 'Restaurants',
              isSelected: controller.selectedTabIndex.value == 0,
              onTap: () => controller.selectedTabIndex.value = 0,
            ),
            const SizedBox(width: 16),
            AppTabItem(
              label: 'Items',
              isSelected: controller.selectedTabIndex.value == 1,
              onTap: () => controller.selectedTabIndex.value = 1,
            ),
          ],
        ),
      );
    });
  }
}

// Remove _TabItem class since we now use AppTabItem


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
              onTap: () => controller.toggleFilter('Offers'),
            ),
            const SizedBox(width: 12),
            _FilterChip(
              label: 'Highest rated',
              assetImage: Assets.images.highestRated,
              isSelected: controller.activeFilters.contains('Highest rated'),
              onTap: () => controller.toggleFilter('Highest rated'),
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
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.offWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.lightSurfaceBorder,
          ),
        ),
        child: Row(
          children: [
            assetImage.image(width: 22, height: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.lightSurfaceDarkText,
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
        return NoDataWidget(
          image: Assets.images.noResultofSearch.image(width: 96, height: 96),
          subtitle: isRestaurantsTab
              ? AppStrings.noResultRestaurantsSubtitle
              : AppStrings.noResultItemsSubtitle,
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
          height: 41,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.offWhite,
            borderRadius: BorderRadius.circular(44),
            border: Border.all(color: AppColors.lightSurfaceBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppShimmer.circle(size: 20),
              const SizedBox(width: 9),
              AppShimmer.text(width: w, height: 14),
            ],
          ),
        )).toList(),
      ),
    );
  }
}
