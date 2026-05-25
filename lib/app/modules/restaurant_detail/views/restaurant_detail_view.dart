import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';
import '../controllers/restaurant_detail_controller.dart';
import 'product_detail_bottom_sheet.dart';
import 'store_info_bottom_sheet.dart';

class RestaurantDetailView extends GetView<RestaurantDetailController> {
  const RestaurantDetailView({super.key});

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
                const SizedBox(height: 88), // 60 (overflow) + 28 (gap) = 88
                _buildSearchBar(),
                const SizedBox(height: 28),
                _buildFilters(),
                const SizedBox(height: 24),
                _buildDishList(),
                _buildViewAllButton(),
                // _buildRecommendedSection(),
                Obx(() => SizedBox(height: controller.showCartFloatingBar.value ? 160 : 40)),
              ],
            ),
          ),
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
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Assets.images.onbording3.image(
          width: double.infinity,
          height: 330,
          fit: BoxFit.cover,
        ),
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
        Positioned(
          bottom: -74,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
            // 20px from bottom label
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'The Marble Grill',
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
                            '4.8',
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
                        'Steakhouse • Premium Pizza',
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
                      '(200K+)',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.lightSurfaceSubtitle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Assets.images.timeIcon.image(width: 16, height: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: '25-35',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.lightSurfaceDarkText,
                          ),
                          children: [
                            TextSpan(
                              text: ' Delivery Time',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.lightSurfaceSubtitle,
                              ),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
                  hintText: 'Search for pizza',
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
      child: Obx(() =>
          Row(
            children: [
              _buildCircleFilter(
                'Veg',
                Assets.images.veg3x,
                controller.isVegSelected.value,
                onTap: () => controller.isVegSelected.toggle(),
              ),
              const SizedBox(width: 12),
              _buildCircleFilter(
                'Non-Veg',
                Assets.images.nonVeg3x,
                controller.isNonVegSelected.value,
                onTap: () => controller.isNonVegSelected.toggle(),
              ),
              const SizedBox(width: 12),
              _buildPillFilter(
                  'Ratings 4.0+', controller.isRatingsSelected.value,
                  onTap: () => controller.isRatingsSelected.toggle()),
              const SizedBox(width: 8),
              _buildPillFilter(
                  'Bestseller', controller.isBestsellerSelected.value,
                  onTap: () => controller.isBestsellerSelected.toggle()),
            ],
          )),
    );
  }

  Widget _buildCircleFilter(String label, AssetGenImage icon, bool isSelected,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          isSelected
              ? icon.image(width: 18, height: 18)
              : Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.lightSurfaceSubtitle),
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

  Widget _buildDishList() {
    final dishes = [
      {
        'id': '1',
        'name': 'Margherita Ultimate Cheese Pizza',
        'price': '8.23',
        'rating': '4.8'
      },
      {
        'id': '2',
        'name': 'Margherita Pizza Giant Slice',
        'price': '8.23',
        'rating': '4.0'
      },
      {'id': '3', 'name': 'Sweet Corn Pizza Regular', 'price': '8.23', 'rating': '4.8'},
      {'id': '4', 'name': 'Onions Thin Crust Pizza', 'price': '8.23', 'rating': '4.2'},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: dishes
            .map((dish) =>
            DishCard(
              dish: dish,
              isHorizontal: false,
              showFavorite: true,
              onTap: () => showProductDetailBottomSheet(dish),
            ))
            .toList(),
      ),
    );
  }

  Widget _buildViewAllButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          'View more',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
        ),
      ),
    );
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
                .map((dish) =>
                DishCard(
                  dish: dish,
                  isHorizontal: false,
                  showFavorite: true,
                  onTap: () => showProductDetailBottomSheet(dish),
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
                  label: 'Add To Favorites',
                  onTap: () => Get.back(),
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
