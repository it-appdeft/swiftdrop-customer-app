import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';

class DishCard extends StatefulWidget {
  final Map<String, dynamic> dish;
  final bool showFavorite;
  final bool isHorizontal;
  final VoidCallback? onTap;
  const DishCard({
    super.key,
    required this.dish,
    this.showFavorite = false,
    this.isHorizontal = true,
    this.onTap,
  });

  @override
  State<DishCard> createState() => _DishCardState();
}

class _DishCardState extends State<DishCard> {
  bool _isFavourited = false;
  int _quantity = 0;

  Widget _buildImage(String? imageUrl) {
    return Assets.images.onbording1.image(
      width: widget.isHorizontal ? 128 : 154,
      height: widget.isHorizontal ? 119 : 144,
      fit: BoxFit.cover,
    );
  }

  AssetGenImage get _vegIcon =>
      widget.dish['isVeg'] == false ? Assets.images.nonVeg3x : Assets.images.vegIcon;

  @override
  Widget build(BuildContext context) {
    final imageStack = Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(widget.isHorizontal ? 10 : 12),
          child: _buildImage(widget.dish['image']),
        ),
        Positioned(
          bottom: -14,
          left: widget.isHorizontal ? 10 : 20,
          right: widget.isHorizontal ? 10 : 20,
          child: Container(
            height: widget.isHorizontal ? 36 : 32,
            width: 112,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withOpacity(0.5)),
            ),
            child: _quantity == 0
                ? GestureDetector(
                    onTap: () => setState(() => _quantity = 1),
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: Text(
                        'ADD',
                        style: GoogleFonts.inter(
                          fontSize: widget.isHorizontal ? 16 : 14,
                          fontWeight: widget.isHorizontal ? FontWeight.w500 : FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  )
                : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _quantity > 1 ? _quantity-- : _quantity = 0),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Assets.images.minus.image(width: 24, height: 24),
                        ),
                      ),
                      SizedBox(width:8),
                      Text(
                        '$_quantity',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,

                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() => _quantity++),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Assets.images.plus.image(width: 24, height: 24),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );

    final textContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            _vegIcon.image(
              width: 16,
              height: 16,
            ),
            if (!widget.isHorizontal && widget.showFavorite)
              GestureDetector(
                onTap: () => setState(() => _isFavourited = !_isFavourited),
                behavior: HitTestBehavior.opaque,
                child: (_isFavourited ? Assets.images.favouriteAdded : Assets.images.favourite)
                    .image(width: 20, height: 20),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          widget.dish['name'] ?? '',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF0B243A),
            height: widget.isHorizontal ? 24 / 16 : null,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          '£${widget.dish['price']}',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF595D70),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 52,
          height: 22,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: AppColors.lightSurfaceBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Assets.images.ratingStar.image(width: 12, height: 12),
              const SizedBox(width: 2),
              Text(
                '${widget.dish['rating']}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkBackground,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: widget.isHorizontal ? 330 : null,
        height: 160,
        margin: widget.isHorizontal
            ? const EdgeInsets.only(right: 16)
            : const EdgeInsets.only(bottom: 24),
        padding: widget.isHorizontal ? const EdgeInsets.all(12) : null,
        decoration: widget.isHorizontal
            ? BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12))
            : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imageStack,
            SizedBox(width: widget.isHorizontal ? 12 : 16),
            Expanded(child: textContent),
          ],
        ),
      ),
    );
  }
}

class RestaurantWithDishes extends StatelessWidget {
  final Map<String, dynamic> data;
  const RestaurantWithDishes({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.restaurantDetail, arguments: data),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: const BoxDecoration(
          color: AppColors.offWhite,
        ),
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
                        Text(
                          data['name'] ?? '',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0B243A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Assets.images.timeIcon.image(width: 16, height: 16),
                            const SizedBox(width: 4),
                            Text(
                              data['time'] ?? '20-30 min',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.lightSurfaceSubtitle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(width: 1, height: 12, color: const Color(0xFFCFD1DC)),
                            const SizedBox(width: 8),
                            Text(
                              data['distance'] ?? '4.9 mi',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.lightSurfaceSubtitle,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Assets.images.rightIcon.image(width: 24, height: 24),
                ],
              ),
            ),
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 36),
                itemCount: (data['dishes'] as List?)?.length ?? 0,
                itemBuilder: (context, index) {
                  final dish = data['dishes'][index];
                  return DishCard(dish: dish);
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
