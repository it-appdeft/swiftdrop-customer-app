import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.buttonLabel,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _LocationBar()),
            SliverToBoxAdapter(child: _SearchBar()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: _CategoriesSection(),
              ),
            ),
            SliverToBoxAdapter(child: _TopPicksSection()),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(child: _DiscoverCuisinesSection()),
            SliverToBoxAdapter(child: _PromoBannerSection()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SectionHeader(
                  title: 'All Restaurants',
                  style: const TextStyle(
                    fontFamily: 'Helvetica Neue',
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: AppColors.lightSurfaceDarkText,
                  ),
                ),
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

class _LocationBar extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.address),
        child: Row(
          children: [
            Assets.images.locationIcon.image(width: 24, height: 24),
            const SizedBox(width: 8),
            Obx(() => Text(
                  controller.currentAddress.value,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.lightSurfaceNavy,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )),
            const SizedBox(width: 4),
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
        onTap: () => Get.find<DashboardController>().changePage(1),
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
                  color: const Color(0xFF868AA5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Categories ───────────────────────────────────────────────────────────────

class _CategoriesSection extends StatelessWidget {
  static const _items = [
    {'name': 'Pizza',    'image': 'assets/images/onbording1.png'},
    {'name': 'Momo',     'image': 'assets/images/onbording2.png'},
    {'name': 'Drinks',   'image': 'assets/images/onbording3.png'},
    {'name': 'Sandwich', 'image': 'assets/images/onbording1.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _items.length,
        itemBuilder: (_, i) => _CategoryItem(
          name: _items[i]['name']!,
          imageUrl: _items[i]['image']!,
        ),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String name;
  final String imageUrl;
  const _CategoryItem({required this.name, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 75,
      margin: const EdgeInsets.only(right: 14),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
            clipBehavior: Clip.antiAlias,
            child: _buildImage(imageUrl),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.lightSurfaceSubtitle,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String url) {
    if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, __) => const ShimmerCircle(size: 64),
      );
    } else {
      return Image.asset(url, fit: BoxFit.cover);
    }
  }
}

// ─── Top Pick's ───────────────────────────────────────────────────────────────

class _TopPicksSection extends StatelessWidget {
  static const _picks = [
    {
      'name': "McDonald's",
      'image': 'assets/images/onbording1.png',
      'rating': '4.5',
      'reviews': '120',
      'time': '20-30 min',
    },
    {
      'name': 'Handmade B..',
      'image': 'assets/images/onbording2.png',
      'rating': '4.8',
      'reviews': '210',
      'time': '25-35 min',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: SectionHeader(
            title: "Top Pick's",
            actionLabel: 'See All',
            onAction: () {},
            style: const TextStyle(
              fontFamily: 'Helvetica Neue',
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: AppColors.lightSurfaceDarkText,
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _picks.length,
            itemBuilder: (_, i) => _TopPickCard(data: _picks[i]),
          ),
        ),
      ],
    );
  }
}

class _TopPickCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _TopPickCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildImage(data['image']),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  data['name'],
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.lightSurfaceDarkText,
            ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  Assets.images.ratingStar.image(width: 16, height: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${data['rating']} (${data['reviews']})',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.lightSurfaceSubtitle,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Assets.images.timeIcon.image(width: 15, height: 15),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  data['time'],
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.lightSurfaceSubtitle,
                    height: 16 / 12, // 16px line height
                    letterSpacing: 0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String url) {
    return Assets.images.restaurantImage.image(
      height: 130,
      width: 220,
      fit: BoxFit.cover,
    );
  }
}

// ─── Discover Cuisines ────────────────────────────────────────────────────────

class _DiscoverCuisinesSection extends StatelessWidget {
  static const _cuisines = [
    {'name': 'Italian', 'image': 'assets/images/onbording1.png'},
    {'name': 'Asian',   'image': 'assets/images/onbording2.png'},
    {'name': 'Mexican', 'image': 'assets/images/onbording3.png'},
    {'name': 'Chinese', 'image': 'assets/images/onbording1.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 214,
      color: AppColors.offWhite,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SectionHeader(
              title: 'Discover Cuisines',
              style: const TextStyle(
                fontFamily: 'Helvetica Neue',
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: AppColors.lightSurfaceDarkText,
              ),
            ),
          ),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _cuisines.length,
              itemBuilder: (_, i) => _CuisineItem(
                name: _cuisines[i]['name']!,
                imageUrl: _cuisines[i]['image']!,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CuisineItem extends StatelessWidget {
  final String name;
  final String imageUrl;
  const _CuisineItem({required this.name, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      margin: const EdgeInsets.only(right: 14),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(color: AppColors.offWhite, shape: BoxShape.circle),
            clipBehavior: Clip.antiAlias,
            child: _buildImage(imageUrl),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.lightSurfaceCusinsSubtitle,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String url) {
    if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, __) => const ShimmerCircle(size: 88),
      );
    } else {
      return Image.asset(url, fit: BoxFit.cover);
    }
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
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
        Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (i) {
            final isActive = controller.currentBannerPage.value == i;
            return Container(
              width: 6,
              height: 6,
              margin: EdgeInsets.only(left: i == 0 ? 0 : 4),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.lightSurfaceDisabled,
                shape: BoxShape.circle,
              ),
            );
          }),
        )),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _BannerCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
     // borderRadius: BorderRadius.circular(0),
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
                child: _buildImage(data['image']),
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
    );
  }

  Widget _buildImage(String url) {
    if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, __) => const ShimmerCircle(size: 240),
      );
    } else {
      return Image.asset(url, fit: BoxFit.cover);
    }
  }
}

// ─── All Restaurants ──────────────────────────────────────────────────────────

class _AllRestaurantsList extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.filteredRestaurants;
      if (controller.isLoading.value && list.isEmpty) {
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, __) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ShimmerBox(width: double.infinity, height: 276, borderRadius: 16),
              ),
              childCount: 3,
            ),
          ),
        );
      }

      final List displayList = list.isNotEmpty
          ? list
          : [
              {
                'name': 'The Marble Grill',
                'image': 'assets/images/onbording1.png',
                'rating': 4.5,
                'time': '20-30 min',
                'distance': '4.9 mi',
                'offer': '60% OFF select items',
              },
              {
                'name': 'Grand Chinese',
                'image': 'assets/images/onbording2.png',
                'rating': 4.6,
                'time': '20-30 min',
                'distance': '4.9 mi',
                'offer': 'Buy 1 Get 1 Free',
              },
            ];

      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => RestaurantCard(restaurant: displayList[i]),
            childCount: displayList.length,
          ),
        ),
      );
    });
  }
}
