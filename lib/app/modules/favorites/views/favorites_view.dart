import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';
import '../controllers/favorites_controller.dart';
import '../../../widgets/app_tabs.dart';

class FavoritesView extends GetView<FavoritesController> {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.buttonLabel,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Favorites',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.lightSurfaceDarkText,
          ),
        ),
        centerTitle: true,
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
      color: AppColors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Obx(() => Row(
                  children: [
                    Expanded(
                      child: AppTabItem(
                        label: AppStrings.categories,
                        isSelected: controller.selectedTabIndex.value == 0,
                        onTap: () {
                          AppUtils.haptic();
                          controller.onTabChanged(0);
                        },
                        expand: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTabItem(
                        label: AppStrings.popularRestaurants,
                        isSelected: controller.selectedTabIndex.value == 1,
                        onTap: () {
                          AppUtils.haptic();
                          controller.onTabChanged(1);
                        },
                        expand: true,
                      ),
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
        return NoDataWidget(
          image: Assets.images.noResultofSearch.image(width: 96, height: 96),
          subtitle: 'No favorite items yet',
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.only(top: 16, bottom: 20),
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
        return NoDataWidget(
          image: Assets.images.noResultofSearch.image(width: 96, height: 96),
          subtitle: 'No favorite restaurants yet',
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: controller.favoriteRestaurants.length,
        itemBuilder: (context, index) {
          final restaurant = controller.favoriteRestaurants[index];
          return RestaurantCard(
            restaurant: restaurant,
            onFavoriteTap: () => controller.toggleRestaurantFavorite(restaurant['id']),
          );
        },
      );
    });
  }
}
