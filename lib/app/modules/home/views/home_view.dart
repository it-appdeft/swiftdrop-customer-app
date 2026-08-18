import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.buttonLabel,
      body: SafeArea(
        child: Column(
          children: [
            _LocationBar(),
            _SearchBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.refresh(),
                color: AppColors.primary,
                child: CustomScrollView(
                  controller: controller.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: _CategoriesSection(),
                      ),
                    ),
                    SliverToBoxAdapter(child: _TopPicksSection()),
                    //const SliverToBoxAdapter(child: SizedBox(height: 12)),
                    // SliverToBoxAdapter(child: _DiscoverCuisinesSection()),
                    SliverToBoxAdapter(child: _PromoBannerSection()),
                    SliverToBoxAdapter(
                      child: Obx(() {
                        if (!controller.isLoading.value &&
                            controller.restaurants.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 0, 10),
                          child: SectionHeader(
                            title: AppStrings.allRestaurants,
                            style: const TextStyle(
                              fontFamily: 'Helvetica Neue',
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: AppColors.lightSurfaceDarkText,
                            ),
                          ),
                        );
                      }),
                    ),
                    _AllRestaurantsList(),
                    SliverToBoxAdapter(
                      child: Obx(() {
                        final hasCart =
                            Get.find<CartController>().cartItemCount.value > 0;
                        return SizedBox(height: hasCart ? 80 : 40);
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Location Bar ─────────────────────────────────────────────────────────────

class _LocationBar extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: InkWell(
        onTap: () {
          AppUtils.haptic();
          Get.toNamed(AppRoutes.address);
        },
        child: Row(
          children: [
            Assets.images.locationIcon.image(width: 24, height: 24),
            const SizedBox(width: 8),
            SizedBox(
              width: 260,
              child: Obx(
                () => Text(
                  controller.currentAddress.value,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.lightSurfaceNavy,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            //const SizedBox(width: 4),
            Assets.images.locationdropIcon.image(width: 24, height: 24),
          ],
        ),
      ),
    );
  }
}

// ─── Search Bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () {
          AppUtils.haptic();
          Get.find<DashboardController>().changePage(1);
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.offWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.lightSurfaceBorder),
          ),
          child: Row(
            children: [
              Assets.images.homeSearchIcon.image(width: 24, height: 24),
              const SizedBox(width: 15),
              Text(
                'Search',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.lightSurfaceSubtitle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Categories (Food Items) ───────────────────────────────────────────────────

class _CategoriesSection extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.foodItems;
      if (controller.isLoading.value && items.isEmpty) {
        return SizedBox(
          height: 108,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 5,
            itemBuilder: (_, __) => const CategoryShimmer(),
          ),
        );
      }
      if (items.isEmpty) return const SizedBox(height: 108);
      return SizedBox(
        height: 108,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: items.length,
          itemBuilder: (_, i) => Obx(
            () => _CategoryItem(
              item: items[i],
              isSelected: controller.selectedCategoryIndex.value == i,
              onTap: () => controller.selectCategory(i, items[i].id),
            ),
          ),
        ),
      );
    });
  }
}

class _CategoryItem extends StatelessWidget {
  final FoodItemModel item;
  final bool isSelected;
  final VoidCallback onTap;
  const _CategoryItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppUtils.haptic();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 74,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.lightSurfaceBorder,
                  width: isSelected ? 2.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: isSelected ? 10 : 6,
                    spreadRadius: isSelected ? 1 : 0,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: ClipOval(child: _buildImage(item.imageUrl)),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.name,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.lightSurfaceSubtitle,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              width: 52,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String? path) {
    return AppImage(path: path, fit: BoxFit.contain);
  }
}

// ─── Top Picks ────────────────────────────────────────────────────────────────

class _TopPicksSection extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final picks = controller.topPickRestaurants;
      if (controller.isLoading.value && picks.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 1, 16, 12),
              child: Shimmer.fromColors(
                baseColor: AppShimmer.baseColor,
                highlightColor: AppShimmer.highlightColor,
                child: Container(
                  width: 120,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppShimmer.baseColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 188,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 3,
                itemBuilder: (_, __) => const TopPickShimmer(),
              ),
            ),
          ],
        );
      }
      if (picks.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 0, 10),
            child: SectionHeader(
              title: AppStrings.topPicks,
              onAction: () => AppUtils.haptic(),
              style: const TextStyle(
                fontFamily: 'Helvetica Neue',
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: AppColors.lightSurfaceDarkText,
              ),
            ),
          ),
          SizedBox(
            height: 188,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: picks.length,
              itemBuilder: (_, i) => _TopPickCard(restaurant: picks[i]),
            ),
          ),
        ],
      );
    });
  }
}


class _TopPickCard extends StatelessWidget {
  final RestaurantModel restaurant;
  const _TopPickCard({required this.restaurant});

  String _formatTimeString(String timeStr) {
    if (timeStr.isEmpty) return '';
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        final minute = parts[1];
        final ampm = hour >= 12 ? 'PM' : 'AM';
        if (hour == 0) {
          hour = 12;
        } else if (hour > 12) {
          hour -= 12;
        }
        return '$hour:$minute $ampm';
      }
    } catch (_) {}
    return timeStr;
  }

  @override
  Widget build(BuildContext context) {
    final bool isClosed = !restaurant.isOpenNow || !restaurant.isAcceptingOrders;
    String openAtText = '';
    if (restaurant.todayHours != null && restaurant.todayHours!.openFrom.isNotEmpty) {
      final formatted = _formatTimeString(restaurant.todayHours!.openFrom);
      if (formatted.isNotEmpty) openAtText = 'Opens at $formatted';
    }

    return GestureDetector(
      onTap: () {
        AppUtils.haptic();
        Get.toNamed(
          AppRoutes.restaurantDetail,
          arguments: {'id': restaurant.id, 'q': ''},
        );
      },
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                _buildImage(restaurant.coverUrl),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      AppUtils.haptic();
                      Get.find<HomeController>().toggleRestaurantFavorite(restaurant.id);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: (restaurant.isFavorited
                              ? Assets.images.favouriteAdded
                              : Assets.images.favourite)
                          .image(width: 18, height: 18),
                    ),
                  ),
                ),
                if (isClosed)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'CLOSED',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          if (openAtText.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              openAtText,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      restaurant.name,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isClosed
                            ? AppColors.lightSurfaceSubtitle
                            : AppColors.lightSurfaceDarkText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Row(
                    children: [
                      Assets.images.ratingStar.image(width: 14, height: 14),
                      const SizedBox(width: 3),
                      Text(
                        '${restaurant.rating} (${restaurant.totalReviews})',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.lightSurfaceSubtitle,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
              child: Row(
                children: [
                  Assets.images.timeIcon.image(width: 14, height: 14),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${restaurant.distanceMiles.toStringAsFixed(1)} mi',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.lightSurfaceSubtitle,
                        height: 16 / 12,
                        letterSpacing: 0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String? path) {
    return AppImage(path: path, width: 220, height: 130, fit: BoxFit.cover);
  }
}

// ─── Promo Banners (carousel) ─────────────────────────────────────────────────

class _PromoBannerSection extends GetView<HomeController> {
  static final _banners = [
    {
      'bg': AppColors.bannerPink,
      'nameColor': AppColors.darkNavy,
      'offerColor': AppColors.navyMedium,
      'image': 'assets/images/onbording1.png',
    },
    {
      'bg': AppColors.bannerYellow,
      'nameColor': AppColors.lightSurfaceDarkText,
      'offerColor': AppColors.navyMuted400,
      'image': 'assets/images/onbording2.png',
    },
    {
      'bg': AppColors.bannerOrange,
      'nameColor': AppColors.darkNavy,
      'offerColor': AppColors.navyMedium,
      'image': 'assets/images/onbording3.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value || controller.restaurants.isEmpty) {
        return const SizedBox.shrink();
      }
      return _buildBanners();
    });
  }

  Widget _buildBanners() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: SizedBox(
            height: 174,
            child: PageView.builder(
              controller: controller.bannerPageController,
              onPageChanged: (i) => controller.currentBannerPage.value = i,
              itemCount: _banners.length,
              itemBuilder: (_, i) => _BannerCard(data: _banners[i]),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_banners.length, (i) {
              final isActive = controller.currentBannerPage.value == i;
              return Container(
                width: 6,
                height: 6,
                margin: EdgeInsets.only(left: i == 0 ? 0 : 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary
                      : AppColors.lightSurfaceDisabled,
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _BannerCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AppUtils.haptic(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
        height: 174,
        color: data['bg'] as Color,
        child: Stack(
          children: [
            Positioned(
              left: 180,
              top: -33,
              child: Container(
                width: 240,
                height: 240,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(data['image'] as String, fit: BoxFit.cover),
              ),
            ),
            Positioned(
              left: 23,
              top: 35,
              width: 131,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kooker',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: data['nameColor'] as Color,
                    ),
                  ),
                  Text(
                    'Special birthday\noffer up to -25%',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: data['offerColor'] as Color,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Up to 3 delivery promo',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.navyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
    );
  }
}

// ─── All Restaurants ──────────────────────────────────────────────────────────

class _AllRestaurantsList extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.restaurants.isEmpty) {
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => const RestaurantCardShimmer(),
              childCount: 3,
            ),
          ),
        );
      }

      final list = controller.restaurants;

      if (list.isEmpty) {
        if (controller.topPickRestaurants.isNotEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
        return const SliverToBoxAdapter(child: _EmptyHomeState());
      }

      final showLoader =
          controller.isLoadingMore.value || controller.hasMoreRestaurants.value;

      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((_, i) {
            if (i == list.length) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: controller.isLoadingMore.value
                    ? const AppLoader()
                    : const SizedBox.shrink(),
              );
            }
            return RestaurantCard(
              restaurant: list[i].toMap(),
              onFavoriteTap: () =>
                  controller.toggleRestaurantFavorite(list[i].id),
            );
          }, childCount: list.length + (showLoader ? 1 : 0)),
        ),
      );
    });
  }
}

// ─── Empty Home State ─────────────────────────────────────────────────────────

class _EmptyHomeState extends StatelessWidget {
  const _EmptyHomeState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.images.emptyHome.image(width: 96, height: 96),
          const SizedBox(height: 16),
          Text(
            'We\'re Still Growing',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.lightSurfaceDarkText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'No restaurant available in this area yet. We\'re working hard to bring your favorite flavor to you doorstep.',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.lightSurfaceSubtitle,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Try a Different Location',
            onTap: () => Get.toNamed(AppRoutes.address),
            backgroundColor: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
            height: 52,
          ),
        ],
      ),
    );
  }
}
