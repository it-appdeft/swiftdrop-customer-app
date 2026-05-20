import 'package:swiftdrop_customer_app/export.dart';
import '../controllers/home_controller.dart';

// gradient pairs indexed by AppData.categories order
const List<List<Color>> _catGradients = [
  [Color(0xFFFF6B35), Color(0xFFCC3300)],
  [Color(0xFF2563EB), Color(0xFF1741B0)],
  [Color(0xFF06B6D4), Color(0xFF0369A1)],
  [Color(0xFF9333EA), Color(0xFF6B21A8)],
  [Color(0xFFF59E0B), Color(0xFFB45309)],
  [Color(0xFF22C55E), Color(0xFF15803D)],
  [Color(0xFFEC4899), Color(0xFFBE185D)],
  [Color(0xFF92400E), Color(0xFF57300A)],
];

// gradient pairs indexed by AppData.featuredRestaurants order
const List<List<Color>> _restGradients = [
  [Color(0xFF7A3F15), Color(0xFF3D1F0A)],
  [Color(0xFF153F7A), Color(0xFF0A1F3D)],
  [Color(0xFF154D2C), Color(0xFF0A2A1A)],
  [Color(0xFF3F154D), Color(0xFF1F0A2A)],
  [Color(0xFF4D1519), Color(0xFF2A0A0D)],
];

const List<List<Color>> _cuisineGradients = [
  [Color(0xFF3A803E), Color(0xFF1F4A22)],
  [Color(0xFF1C6B7A), Color(0xFF0E3A42)],
  [Color(0xFF8B3A3A), Color(0xFF4A1F1F)],
  [Color(0xFF7A3A1C), Color(0xFF421F0E)],
  [Color(0xFF7A1C4D), Color(0xFF420E2A)],
  [Color(0xFF6B3A7A), Color(0xFF3A1F42)],
];

const List<Map<String, String>> _cuisines = [
  {'name': 'Italian', 'emoji': '🍝'},
  {'name': 'Asian', 'emoji': '🍜'},
  {'name': 'Mexican', 'emoji': '🌮'},
  {'name': 'Chinese', 'emoji': '🥡'},
  {'name': 'Indian', 'emoji': '🍛'},
  {'name': 'Thai', 'emoji': '🥘'},
];

String _emojiForCategory(String category) {
  switch (category.toLowerCase()) {
    case 'burgers':
      return '🍔';
    case 'asian':
      return '🍜';
    case 'sandwiches & coffee':
      return '☕';
    case 'indian':
      return '🍛';
    case 'chicken':
      return '🍗';
    case 'pizza':
      return '🍕';
    case 'sushi':
      return '🍣';
    default:
      return '🍽️';
  }
}

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _LocationBar()),
            SliverToBoxAdapter(child: _SearchBar()),
            SliverToBoxAdapter(child: _CategoriesSection()),
            SliverToBoxAdapter(child: _TopPicksSection()),
            SliverToBoxAdapter(child: _DiscoverCuisinesSection()),
            SliverToBoxAdapter(child: _PromoBannerSection()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.paddingMd,
                  AppDimensions.gapXl,
                  AppDimensions.paddingMd,
                  AppDimensions.gapMd,
                ),
                child: SectionHeader(title: 'All Restaurants', titleColor: AppColors.lightSurfaceDarkText),
              ),
            ),
            _AllRestaurantsList(),
          ],
        ),
      ),
    );
  }
}

// ─── Location Bar ─────────────────────────────────────────────────────────────

class _LocationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingMd,
        AppDimensions.paddingMd,
        AppDimensions.paddingMd,
        AppDimensions.gapSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on_rounded, color: AppColors.primary, size: AppDimensions.iconSm),
          const SizedBox(width: AppDimensions.gapXs),
          Text('London, UK', style: AppTextStyles.pSmallSemiBold.copyWith(color: AppColors.lightSurfaceDarkText)),
          const SizedBox(width: 2),
          const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.lightSurfaceSubtitle, size: 20),
        ],
      ),
    );
  }
}

// ─── Search Bar ───────────────────────────────────────────────────────────────

class _SearchBar extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingMd,
        0,
        AppDimensions.paddingMd,
        AppDimensions.gapLg,
      ),
      child: SizedBox(
        height: AppDimensions.inputHeight,
        child: TextField(
          controller: controller.searchController,
          textAlignVertical: TextAlignVertical.center,
          style: AppTextStyles.pSmall.copyWith(color: AppColors.lightSurfaceText),
          decoration: InputDecoration(
            fillColor: AppColors.white,
            filled: true,
            hintText: 'Search restaurants, cuisines...',
            hintStyle: AppTextStyles.pSmall.copyWith(color: AppColors.lightSurfaceHint),
            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.lightSurfaceHint, size: AppDimensions.iconMd),
            border: OutlineInputBorder(
              borderRadius: AppRadius.sm,
              borderSide: const BorderSide(color: AppColors.lightSurfaceBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.sm,
              borderSide: const BorderSide(color: AppColors.lightSurfaceBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.sm,
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            suffixIcon: Obx(
              () => controller.searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.lightSurfaceHint, size: AppDimensions.iconMd),
                      onPressed: controller.clearSearch,
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Categories ───────────────────────────────────────────────────────────────

class _CategoriesSection extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: Obx(() {
        if (controller.isLoading.value && controller.categories.isEmpty) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMd),
            itemCount: 6,
            itemBuilder: (_, _) => Padding(
              padding: const EdgeInsets.only(right: AppDimensions.gapSm),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ShimmerCircle(size: 58),
                  const SizedBox(height: AppDimensions.gapXs),
                  ShimmerBox(width: 50, height: 10),
                ],
              ),
            ),
          );
        }
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMd),
          itemCount: controller.categories.length,
          itemBuilder: (_, i) {
            final cat = controller.categories[i];
            final colors = _catGradients[i % _catGradients.length];
            return _CategoryItem(
              name: cat['name'] as String,
              emoji: cat['icon'] as String,
              startColor: colors[0],
              endColor: colors[1],
            );
          },
        );
      }),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String name;
  final String emoji;
  final Color startColor;
  final Color endColor;

  const _CategoryItem({
    required this.name,
    required this.emoji,
    required this.startColor,
    required this.endColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      margin: const EdgeInsets.only(right: AppDimensions.gapSm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [startColor, endColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(height: AppDimensions.gapXs),
          Text(
            name,
            style: AppTextStyles.caption.copyWith(color: AppColors.lightSurfaceLabel),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Top Pick's ───────────────────────────────────────────────────────────────

class _TopPicksSection extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    // show 2 full cards with a peek of the 3rd
    final cardWidth = (screenWidth - AppDimensions.paddingMd * 2 - AppDimensions.gapMd) / 2;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.paddingMd,
            AppDimensions.gapXl,
            AppDimensions.paddingMd,
            AppDimensions.gapMd,
          ),
          child: SectionHeader(title: "Top Pick's", titleColor: AppColors.lightSurfaceDarkText, actionLabel: 'See all', onAction: () => AppUtils.showInfo('Feature coming soon.')),
        ),
        SizedBox(
          height: 200,
          child: Obx(() {
            if (controller.isLoading.value && controller.restaurants.isEmpty) {
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMd),
                itemCount: 3,
                itemBuilder: (_, _) => Padding(
                  padding: const EdgeInsets.only(right: AppDimensions.gapMd),
                  child: ShimmerBox(
                    width: cardWidth,
                    height: 200,
                    borderRadius: AppDimensions.radiusMd,
                  ),
                ),
              );
            }
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMd),
              itemCount: controller.restaurants.length,
              itemBuilder: (_, i) {
                final r = controller.restaurants[i];
                final colors = _restGradients[i % _restGradients.length];
                return _TopPickCard(
                  restaurant: r,
                  width: cardWidth,
                  startColor: colors[0],
                  endColor: colors[1],
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

class _TopPickCard extends StatelessWidget {
  final Map<String, dynamic> restaurant;
  final double width;
  final Color startColor;
  final Color endColor;

  const _TopPickCard({
    required this.restaurant,
    required this.width,
    required this.startColor,
    required this.endColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: const EdgeInsets.only(right: AppDimensions.gapMd),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.lightSurfaceBorder, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 116,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [startColor, endColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                _emojiForCategory(restaurant['category'] as String),
                style: const TextStyle(fontSize: 44),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    restaurant['name'] as String,
                    style: AppTextStyles.pXSmallSemiBold.copyWith(color: AppColors.lightSurfaceText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 11, color: AppColors.warning),
                      const SizedBox(width: 3),
                      Text(
                        '${restaurant['rating']} (${restaurant['reviewCount'] ?? 0})',
                        style: AppTextStyles.pXSmall.copyWith(color: AppColors.lightSurfaceLabel),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 11, color: AppColors.lightSurfaceHint),
                      const SizedBox(width: 3),
                      Text(
                        restaurant['deliveryTime'] as String,
                        style: AppTextStyles.pXSmall.copyWith(color: AppColors.lightSurfaceLabel),
                      ),
                    ],
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

// ─── Discover Cuisines ────────────────────────────────────────────────────────

class _DiscoverCuisinesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.paddingMd,
            AppDimensions.gapXl,
            AppDimensions.paddingMd,
            AppDimensions.gapMd,
          ),
          child: SectionHeader(title: 'Discover Cuisines', titleColor: AppColors.lightSurfaceDarkText),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMd),
            itemCount: _cuisines.length,
            itemBuilder: (_, i) {
              final colors = _cuisineGradients[i % _cuisineGradients.length];
              return _CuisineItem(
                name: _cuisines[i]['name']!,
                emoji: _cuisines[i]['emoji']!,
                startColor: colors[0],
                endColor: colors[1],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CuisineItem extends StatelessWidget {
  final String name;
  final String emoji;
  final Color startColor;
  final Color endColor;

  const _CuisineItem({
    required this.name,
    required this.emoji,
    required this.startColor,
    required this.endColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      margin: const EdgeInsets.only(right: AppDimensions.gapSm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [startColor, endColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 30))),
          ),
          const SizedBox(height: AppDimensions.gapXs),
          Text(
            name,
            style: AppTextStyles.caption.copyWith(color: AppColors.lightSurfaceLabel),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Promo Banner ─────────────────────────────────────────────────────────────

class _PromoBannerSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingMd,
        AppDimensions.gapXl,
        AppDimensions.paddingMd,
        0,
      ),
      child: Container(
        height: 112,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4A5E20), Color(0xFF7A9432)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: AppRadius.lg,
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.paddingMd,
                  AppDimensions.paddingSm,
                  0,
                  AppDimensions.paddingSm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'SwiftDrop Pass',
                      style: AppTextStyles.pMediumBold.copyWith(color: AppColors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Special offer up to -25%',
                      style: AppTextStyles.pXSmall.copyWith(
                        color: AppColors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Up to 5 free deliveries/month',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: AppDimensions.paddingMd),
              child: Text('🎂', style: TextStyle(fontSize: 52)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── All Restaurants ──────────────────────────────────────────────────────────

class _AllRestaurantsList extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.filteredRestaurants.isEmpty) {
        return SliverPadding(
          padding: const EdgeInsets.only(bottom: AppDimensions.paddingMd),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, _) => Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.paddingMd,
                  0,
                  AppDimensions.paddingMd,
                  AppDimensions.paddingMd,
                ),
                child: ShimmerBox(
                  width: double.infinity,
                  height: 220,
                  borderRadius: AppDimensions.radiusLg,
                ),
              ),
              childCount: 3,
            ),
          ),
        );
      }
      if (controller.filteredRestaurants.isEmpty) {
        return SliverToBoxAdapter(
          child: EmptyStateWidget(
            message: 'No restaurants found',
            subtitle: 'Try a different search term',
            icon: Icons.search_off_rounded,
          ),
        );
      }
      return SliverPadding(
        padding: const EdgeInsets.only(bottom: AppDimensions.paddingMd),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) {
              final r = controller.filteredRestaurants[i];
              final colors = _restGradients[i % _restGradients.length];
              return _RestaurantCard(
                restaurant: r,
                startColor: colors[0],
                endColor: colors[1],
              );
            },
            childCount: controller.filteredRestaurants.length,
          ),
        ),
      );
    });
  }
}

class _RestaurantCard extends StatelessWidget {
  final Map<String, dynamic> restaurant;
  final Color startColor;
  final Color endColor;

  const _RestaurantCard({
    required this.restaurant,
    required this.startColor,
    required this.endColor,
  });

  @override
  Widget build(BuildContext context) {
    final isOpen = restaurant['isOpen'] as bool;
    final badge = restaurant['badge'] as String?;
    final distance = (restaurant['distance'] as String?) ?? '';

    return GestureDetector(
      onTap: isOpen ? () => AppUtils.showInfo('Feature coming soon.') : null,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppDimensions.paddingMd,
          0,
          AppDimensions.paddingMd,
          AppDimensions.paddingMd,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.lg,
          border: Border.all(color: AppColors.lightSurfaceBorder, width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 176,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [startColor, endColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _emojiForCategory(restaurant['category'] as String),
                        style: const TextStyle(fontSize: 64),
                      ),
                    ),
                  ),
                  if (!isOpen)
                    Container(
                      color: Colors.black.withValues(alpha:0.55),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: AppRadius.full,
                          ),
                          child: Text(
                            'Closed',
                            style: AppTextStyles.pSmallSemiBold.copyWith(color: AppColors.lightSurfaceSubtitle),
                          ),
                        ),
                      ),
                    ),
                  // rating badge — top right
                  Positioned(
                    top: AppDimensions.gapMd,
                    right: AppDimensions.gapMd,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: AppRadius.full,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 12, color: AppColors.warning),
                          const SizedBox(width: 3),
                          Text(
                            '${restaurant['rating']}',
                            style: AppTextStyles.pXSmallSemiBold.copyWith(color: AppColors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  if (badge != null)
                    Positioned(
                      bottom: AppDimensions.gapMd,
                      left: AppDimensions.gapMd,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          borderRadius: AppRadius.full,
                        ),
                        child: Text(
                          badge,
                          style: AppTextStyles.pXSmall.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
  padding: const EdgeInsets.fromLTRB(
    AppDimensions.paddingMd,
    AppDimensions.paddingSm,
    AppDimensions.paddingMd,
    AppDimensions.paddingSm,
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              restaurant['name'] as String,
              style: AppTextStyles.pMediumSemiBold.copyWith(
                  color: AppColors.lightSurfaceText),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () => AppUtils.showInfo('Feature coming soon.'),
            child: const Icon(
              Icons.favorite_border_rounded,
              color: AppColors.lightSurfaceHint,
              size: 20,
            ),
          ),
        ],
      ),
      const SizedBox(height: AppDimensions.gapXs),
      Row(
        children: [
          const Icon(Icons.schedule_rounded,
              size: 13, color: AppColors.lightSurfaceHint),
          const SizedBox(width: 4),
          Text(
            restaurant['deliveryTime'] as String,
            style: AppTextStyles.pXSmall
                .copyWith(color: AppColors.lightSurfaceLabel),
          ),
          if (distance.isNotEmpty) ...[
            Text(' · ',
                style: AppTextStyles.pXSmall
                    .copyWith(color: AppColors.lightSurfaceHint)),
            Text(distance,
                style: AppTextStyles.pXSmall
                    .copyWith(color: AppColors.lightSurfaceLabel)),
          ],
        ],
      ),
    ],
  ),
),
          ],
        ),
      ),
    );
  }
}
