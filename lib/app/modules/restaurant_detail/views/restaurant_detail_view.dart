import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';
import '../controllers/restaurant_detail_controller.dart';
import 'product_detail_bottom_sheet.dart';
import 'store_info_bottom_sheet.dart';

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

                _buildItemList(),
                _buildViewAllButton(),
                // _buildRecommendedSection(),
                Obx(() => SizedBox(height: controller.showCartFloatingBar.value ? 160 : 40)),
              ],
            ),
          ),
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
                child: controller.isLoading.value
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
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            info?.cuisines ?? '',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.lightSurfaceSubtitle,
                            ),
                            maxLines: 1,
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
                                  text: '${info!.deliveryMinutesMin}-${info.deliveryMinutesMax}',
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
          // Nav buttons drawn last — in front of both image and card
          Positioned(
            top: 48,
            left: 16,
            right: 16,
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
            //const SizedBox(width: 12),
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
      final items = controller.menuItems;
      if (items.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: items
              .map((item) => ItemCard(
                    item: item.toMap(),
                    isHorizontal: false,
                    showFavorite: true,
                    onTap: () => showProductDetailBottomSheet(item.toMap()),
                    onFavoriteTap: () => controller.toggleItemFavorite(item.id),
                  ))
              .toList(),
        ),
      );
    });
  }

  Widget _buildViewAllButton() {
    return Obx(() {
      if (!controller.hasMoreMenu.value) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: GestureDetector(
          onTap: controller.loadMoreMenu,
          child: Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: controller.isLoadingMore.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : Text(
                    'View more',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
          ),
        ),
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
