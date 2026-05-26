import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../controllers/search_controller.dart';

class SearchView extends GetView<SearchTabController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.buttonLabel,
      body: SafeArea(
        child: Column(
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
                      _RecentChipsRow(),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _FilterRow(),
                    const SizedBox(height: 16),
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
          Obx(() => controller.recentSearches.isNotEmpty
              ? GestureDetector(
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
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}

class _RecentChipsRow extends GetView<SearchTabController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.recentSearches.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'No recent search yet',
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
            _TabItem(
              label: 'Restaurants',
              isSelected: controller.selectedTabIndex.value == 0,
              onTap: () => controller.selectedTabIndex.value = 0,
            ),
            const SizedBox(width: 16),
            _TabItem(
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

class _TabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _TabItem({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: IntrinsicWidth(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  color: isSelected ? AppColors.lightSurfaceDarkText : AppColors.navyMedium,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 2,
              width: double.infinity,
              color: isSelected ? AppColors.lightSurfaceDarkText : Colors.transparent,
            ),
          ],
        ),
      ),
    );
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
      if (controller.selectedTabIndex.value == 0) {
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          itemCount: controller.restaurantResults.length,
          itemBuilder: (context, index) {
            return RestaurantCard(restaurant: controller.restaurantResults[index]);
          },
        );
      } else {
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 150),
          itemCount: controller.itemResults.length,
          itemBuilder: (context, index) {
            return RestaurantWithItems(data: controller.itemResults[index]);
          },
        );
      }
    });
  }
}
