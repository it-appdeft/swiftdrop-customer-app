import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';
import '../controllers/favorites_controller.dart';


class FavoritesView extends GetView<FavoritesController> {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: AppDimensions.iconSm,
            color: AppColors.lightSurfaceDarkText,
          ),
          onPressed: () {
            AppUtils.haptic();
            Get.back();
          },
        ),
        title: Text(
          'Favorites',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.lightSurfaceDarkText,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildTabs(),
          Expanded(
            child: Obx(() {
              if (controller.selectedTabIndex.value == 0) {
                return _buildItemsList();
              } else {
                return _buildRestaurantsList();
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      width: double.infinity,
      color: AppColors.white,
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(() => Row(
                  children: [
                    AppTabItem(
                      label: AppStrings.categories,
                      isSelected: controller.selectedTabIndex.value == 0,
                      onTap: () {
                        AppUtils.haptic();
                        controller.onTabChanged(0);
                      },
                      expand: false,
                    ),
                    const SizedBox(width: 24),
                    AppTabItem(
                      label: AppStrings.popularRestaurants,
                      isSelected: controller.selectedTabIndex.value == 1,
                      onTap: () {
                        AppUtils.haptic();
                        controller.onTabChanged(1);
                      },
                      expand: false,
                    ),
                  ],
                )),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.lightSurfaceBorder),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return Obx(() {
      if (controller.isFetchingItems.value && controller.favoriteItems.isEmpty) {
        return ListView.builder(
          padding: const EdgeInsets.only(top: 16),
          itemCount: 3,
          itemBuilder: (_, __) => const FavoriteItemCardShimmer(),
        );
      }

      if (controller.favoriteItems.isEmpty) {
        return _buildEmptyState(
          image: Assets.images.noResultofSearch.image(fit: BoxFit.contain),
          title: 'No Favorite Items',
          subtitle: 'Items you mark as favorite will appear here for quick access.',
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        itemCount: controller.favoriteItems.length,
        itemBuilder: (context, index) {
          final item = controller.favoriteItems[index];
          return FavoriteItemCard(
            item: item,
            onFavoriteTap: () {
              AppUtils.haptic();
              controller.toggleItemFavorite(item['id']);
            },
            onTap: () {
              AppUtils.haptic();
              final restaurantId = (item['restaurant'] as Map?)?['id'];
              if (restaurantId != null) {
                Get.toNamed(AppRoutes.restaurantDetail, arguments: {'id': restaurantId});
              }
            },
          );
        },
      );
    });
  }

  Widget _buildRestaurantsList() {
    return Obx(() {
      if (controller.isFetchingRestaurants.value && controller.favoriteRestaurants.isEmpty) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 3,
          itemBuilder: (_, __) => const RestaurantCardShimmer(),
        );
      }

      if (controller.favoriteRestaurants.isEmpty) {
        return _buildEmptyState(
          image: Assets.images.noResultofSearch.image(fit: BoxFit.contain),
          title: 'No Favorite Restaurants',
          subtitle: 'Restaurants you mark as favorite will appear here for easy ordering.',
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: controller.favoriteRestaurants.length,
        itemBuilder: (context, index) {
          final restaurant = controller.favoriteRestaurants[index];
          return RestaurantCard(
            restaurant: restaurant,
            onFavoriteTap: () {
              AppUtils.haptic();
              controller.toggleRestaurantFavorite(restaurant['id']);
            },
          );
        },
      );
    });
  }

  Widget _buildEmptyState({
    required Widget image,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.lightSurfaceBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: image,
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.lightSurfaceDarkText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.lightSurfaceSubtitle,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
