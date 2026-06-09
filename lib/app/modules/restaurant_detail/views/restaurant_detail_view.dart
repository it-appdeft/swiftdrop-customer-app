import 'dart:ui';
import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';
import '../../cart/controllers/cart_controller.dart';
import '../controllers/restaurant_detail_controller.dart';
import 'product_detail_bottom_sheet.dart';
import 'store_info_bottom_sheet.dart';
import 'your_customizations_sheet.dart';

class RestaurantDetailView extends GetView<RestaurantDetailController> {
  final bool isSheet;
  const RestaurantDetailView({super.key, this.isSheet = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: controller.scrollController,
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildSearchBar(),
                const SizedBox(height: 28),
                _buildFilters(),
                const SizedBox(height: 24),

                Obx(() {
                  final isSearching = controller.searchQuery.value.isNotEmpty;
                  if (controller.isLoading.value) {
                    return _buildItemList();
                  }
                  if (!isSearching) {
                    return _buildItemList();
                  }

                  final matchingIds = controller.recommended.map((e) => e.id).toSet();
                  final resultCount = matchingIds.length;

                  if (resultCount == 0 && !controller.isLoading.value) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: NoDataWidget(
                        image: Assets.images.noResultofSearch.image(width: 96, height: 96),
                        subtitle: 'No items found matching "${controller.searchQuery.value}"',
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(
                          'Results for "${controller.searchQuery.value}" ($resultCount)',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.lightSurfaceDarkText,
                          ),
                        ),
                      ),
                      if (controller.recommended.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: controller.recommended
                                .map((item) {
                                  final itemMap = item.toMap();
                                  itemMap['restaurant_id'] = controller.restaurantId;
                                  return ItemCard(
                                      item: itemMap,
                                      isHorizontal: false,
                                      showFavorite: true,
                                      onTap: () {
                                        final cart = Get.find<CartController>();
                                        if (item.modifierGroups.isNotEmpty && (cart.quantities[item.id] ?? 0) > 0) {
                                          showYourCustomizationsSheet(itemMap);
                                        } else {
                                          showProductDetailBottomSheet(itemMap);
                                        }
                                      },
                                      onFavoriteTap: () => controller.toggleItemFavorite(item.id),
                                    );
                                })
                                .toList(),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: Divider(color: AppColors.lightSurfaceBorder, thickness: 1),
                        ),
                      ],
                      _buildItemList(),
                    ],
                  );
                }),
                // _buildRecommendedSection(),
                Obx(() => SizedBox(height: controller.showCartFloatingBar.value ? 160 : 40)),
              ],
            ),
          ),
          _buildStickyHeader(context),
          _buildClosedOverlay(),
          if (!isSheet)
            Obx(() => controller.showCartFloatingBar.value
                ? const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: CartFloatingBar(),
                  )
                : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildClosedOverlay() {
    return Obx(() {
      final info = controller.restaurantInfo.value;
      if (info == null) return const SizedBox.shrink();

      final bool isOpenNow = info.isOpenNow;
      final bool isAcceptingOrders = info.isAcceptingOrders;
      final bool isClosed = !isOpenNow || !isAcceptingOrders;

      if (!isClosed) return const SizedBox.shrink();

      String openAt = '1:00 PM';
      if (info.todayHours != null) {
        openAt = info.todayHours!.openFrom;
      }

      return Positioned.fill(
        child: Container(
          color: Colors.black.withValues(alpha: 0.4),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                  child: const Text(
                    'CLOSED',
                    style: TextStyle(
                      fontFamily: 'Fonts/Paragraph',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Opens at $openAt',
                  style: const TextStyle(
                    fontFamily: 'Fonts/Paragraph',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildStickyHeader(BuildContext context) {
    return Obx(() {
      final isScrolled = controller.isScrolled.value;
      final showName = controller.showStickyName.value;
      final info = controller.restaurantInfo.value;

      return Container(
        height: MediaQuery.of(context).padding.top + 60,
        decoration: BoxDecoration(
          color: isScrolled ? AppColors.white : Colors.transparent,
          boxShadow: isScrolled
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: SafeArea(
          bottom: false,
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Assets.images.back.image(
                        width: 16, height: 16, color: AppColors.white),
                  ),
                ),
                if (showName)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        info?.name ?? '',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.lightSurfaceDarkText,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                else
                  const Spacer(),
                GestureDetector(
                  onTap: () => _showMoreOptions(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                        Icons.more_vert, color: AppColors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHeader(BuildContext context) {
    return Obx(() {
      final info = controller.restaurantInfo.value;
      return Stack(
        children: [
          // Image is Positioned so it doesn't drive Stack height
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppImage(
              path: info?.coverUrl,
              width: double.infinity,
              height: 330,
              fit: BoxFit.cover,
            ),
          ),
          // Column drives Stack height: 256px transparent gap + card grows downward
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 256),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: (controller.isLoading.value && info == null)
                    ? _buildHeaderCardShimmer()
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            info?.name ?? '',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: AppColors.lightSurfaceDarkText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.offWhite,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Assets.images.ratingStar.image(width: 14, height: 14),
                              const SizedBox(width: 4),
                              Text(
                                info?.rating.toStringAsFixed(1) ?? '0.0',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.lightSurfaceDarkText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            (info?.description ?? info?.cuisines ?? ''),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.lightSurfaceSubtitle,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${info?.totalReviews ?? 0})',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.lightSurfaceSubtitle,
                          ),
                        ),
                      ],
                    ),
                    if ((info?.description ?? '').isNotEmpty && (info?.cuisines ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        info?.cuisines ?? '',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.lightSurfaceSubtitle,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (info?.deliveryMinutesMin != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Assets.images.timeIcon.image(width: 16, height: 16),
                          const SizedBox(width: 8),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${info!.deliveryMinutesMin}-${info.deliveryMinutesMax} min',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.lightSurfaceDarkText,
                                  ),
                                ),
                                TextSpan(
                                  text: ' Delivery time',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.lightSurfaceSubtitle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                    if ((info?.fullAddress ?? info?.city ?? '').isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Assets.images.locationIcon.image(width: 16, height: 16),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              info?.fullAddress ?? info?.city ?? '',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.lightSurfaceSubtitle,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildHeaderCardShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: AppShimmer.text(height: 24)),
            const SizedBox(width: 8),
            AppShimmer.rect(width: 60, height: 26, radius: 12),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppShimmer.text(width: 120, height: 14),
            AppShimmer.text(width: 40, height: 14),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            AppShimmer.rect(width: 16, height: 16),
            const SizedBox(width: 8),
            AppShimmer.text(width: 140, height: 14),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            AppShimmer.rect(width: 16, height: 16),
            const SizedBox(width: 8),
            Expanded(child: AppShimmer.text(height: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                controller: controller.searchController,
                onChanged: (v) => controller.searchQuery.value = v.trim(),
                onSubmitted: (v) {
                  controller.searchQuery.value = v.trim();
                  controller.searchNow();
                },
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
                  hintText: 'Search for items',
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
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() => Row(
            children: [
              _FoodToggle(
                isSelected: controller.isVegSelected.value,
                activeTrackColor: AppColors.lightSurfaceVerified,
                icon: Assets.images.vegToggle,
                label: 'Veg',
                onTap: controller.toggleVeg,
              ),
              const SizedBox(width: 12),
              _FoodToggle(
                isSelected: controller.isNonVegSelected.value,
                activeTrackColor: AppColors.error,
                icon: Assets.images.nonVegToggle,
                label: 'Non-Veg',
                onTap: controller.toggleNonVeg,
              ),
              const SizedBox(width: 12),
              _buildPillFilter('Ratings 4.0+', controller.isRatingsSelected.value,
                  onTap: controller.toggleRatings),
            ],
          )),
    );
  }

  Widget _buildPillFilter(String label, bool isSelected,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 28,
        padding: const EdgeInsets.only(left: 10, right: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isSelected ? AppColors.transparent : AppColors.lightSurfaceBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.lightSurfaceDarkText,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 2),
              Assets.images.crossIcon.image(width: 16, height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItemList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: List.generate(3, (_) => const MenuItemCardShimmer()),
          ),
        );
      }
      final categories = controller.categories;

      if (categories.isEmpty) {
        // If not searching, show empty state for the whole menu
        if (controller.searchQuery.value.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: NoDataWidget(
              image: Assets.images.noResultofSearch.image(width: 96, height: 96),
              subtitle: 'No items available in this restaurant yet.',
            ),
          );
        }
        return const SizedBox.shrink();
      }

      return Column(
        children: categories.map((category) {
          final isCollapsed = controller.collapsedCategories.contains(category.id);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => controller.toggleCategory(category.id),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          category.name,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.lightSurfaceDarkText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        isCollapsed
                            ? Icons.keyboard_arrow_down_rounded
                            : Icons.keyboard_arrow_up_rounded,
                        color: AppColors.lightSurfaceDarkText,
                      ),
                    ],
                  ),
                ),
              ),
              if (!isCollapsed)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: category.items
                        .map((item) {
                              final itemMap = item.toMap();
                              itemMap['restaurant_id'] = controller.restaurantId;
                              return ItemCard(
                                item: itemMap,
                                isHorizontal: false,
                                showFavorite: true,
                                onTap: () {
                                  final cart = Get.find<CartController>();
                                  if (item.modifierGroups.isNotEmpty && (cart.quantities[item.id] ?? 0) > 0) {
                                    showYourCustomizationsSheet(itemMap);
                                  } else {
                                    showProductDetailBottomSheet(itemMap);
                                  }
                                },
                                onFavoriteTap: () => controller.toggleItemFavorite(item.id),
                              );
                            })
                        .toList(),
                  ),
                ),
            ],
          );
        }).toList(),
      );
    });
  }

  Widget _buildRecommendedSection() {
    final recommended = [
      {'id': '5', 'name': 'Sweet Corn Pizza Regular', 'price': '8.00', 'rating': '4.5'},
      {'id': '6', 'name': 'Onions Thin Crust Pizza', 'price': '4.23', 'rating': '4.6'},
      {
        'id': '7',
        'name': 'Margherita Pizza Giant Slice',
        'price': '4.01',
        'rating': '4.5'
      },
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Text(
            'Recommended (12)',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.lightSurfaceDarkText,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: recommended
                .map((item) =>
                ItemCard(
                  item: item,
                  isHorizontal: false,
                  showFavorite: true,
                  onTap: () => showProductDetailBottomSheet(item),
                ))
                .toList(),
          ),
        ),
      ],
    );
  }

  void _showMoreOptions(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildOptionItem(
                  icon: Assets.images.heartUnfilled,
                  label: controller.isFavorited.value
                      ? 'Remove from Favourites'
                      : 'Add to Favourites',
                  onTap: () {
                    controller.toggleRestaurantFavorite();
                    Get.back();
                  },
                ),
                const Divider(color: AppColors.lightSurfaceBorder, height: 32),
                _buildOptionItem(
                  icon: Assets.images.info,
                  label: 'Store Info',
                  onTap: () {
                    Get.back();
                    showStoreInfoBottomSheet();
                  },
                ),
                const Divider(color: AppColors.lightSurfaceBorder, height: 32),
                _buildOptionItem(
                  icon: Assets.images.share,
                  label: 'Share',
                  onTap: () => Get.back(),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  Widget _buildOptionItem({
    required AssetGenImage icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          icon.image(width: 24, height: 24),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Helvetica Neue',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.lightSurfaceDarkText,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Food Toggle (Veg / Non-Veg) ─────────────────────────────────────────────

class _FoodToggle extends StatelessWidget {
  final bool isSelected;
  final Color activeTrackColor;
  final AssetGenImage icon;
  final String label;
  final VoidCallback onTap;

  const _FoodToggle({
    required this.isSelected,
    required this.activeTrackColor,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 36,
            height: 18,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  width: 36,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? activeTrackColor
                        : AppColors.lightSurfaceDisabled,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                AnimatedAlign(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  alignment:
                      isSelected ? Alignment.centerRight : Alignment.centerLeft,
                  child: icon.image(width: 18, height: 18),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.lightSurfaceDarkText,
            ),
          ),
        ],
      ),
    );
  }
}
