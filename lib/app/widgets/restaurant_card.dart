import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';

class RestaurantCard extends StatefulWidget {
  final Map<String, dynamic> restaurant;
  final String? searchQuery;
  final VoidCallback? onFavoriteTap;
  const RestaurantCard({super.key, required this.restaurant, this.searchQuery, this.onFavoriteTap});

  @override
  State<RestaurantCard> createState() => _RestaurantCardState();
}

class _RestaurantCardState extends State<RestaurantCard> {
  late bool _isFavourited;

  @override
  void initState() {
    super.initState();
    _isFavourited = widget.restaurant['is_favorited'] ?? false;
  }

  @override
  void didUpdateWidget(covariant RestaurantCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.restaurant['is_favorited'] != oldWidget.restaurant['is_favorited']) {
      setState(() {
        _isFavourited = widget.restaurant['is_favorited'] ?? false;
      });
    }
  }

  Widget _buildImage(String? path) {
    return AppImage(
      path: path,
      height: 210,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.restaurantDetail, arguments: {
            'id': widget.restaurant['id'],
            'q': widget.searchQuery ?? '',
          }),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildImage(
                    widget.restaurant['coverUrl'] as String? ??
                        widget.restaurant['image'] as String?,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 60,
                    height: 26,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.offWhite,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Assets.images.ratingStar.image(width: 14, height: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.restaurant['rating']}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF081929),
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (widget.restaurant['offer'] != null || widget.restaurant['badge'] != null)
                  Positioned(
                    bottom: 16,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        (widget.restaurant['offer'] ?? widget.restaurant['badge']).toString(),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.restaurant['name'],
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF081929),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() => _isFavourited = !_isFavourited);
                    widget.onFavoriteTap?.call();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: (_isFavourited ? Assets.images.favouriteAdded : Assets.images.favourite)
                      .image(width: 24, height: 24),
                ),
              ],
            ),

            const SizedBox(height: 4),
            Row(
              children: [
                Assets.images.timeIcon.image(width: 20, height: 20),
                const SizedBox(width: 5),
                Text( widget.restaurant['time'] ?? "20-30 min",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.lightSurfaceSubtitle,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: 9),
                Container(width: 0.5, height: 19.5, color: const Color(0xFFCFD1DC)),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    widget.restaurant['distance'] ?? '',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.lightSurfaceSubtitle,
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
    );
  }
}
