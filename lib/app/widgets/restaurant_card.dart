import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';

class RestaurantCard extends StatefulWidget {
  final Map<String, dynamic> restaurant;
  final String? searchQuery;
  final VoidCallback? onFavoriteTap;
  const RestaurantCard({
    super.key,
    required this.restaurant,
    this.searchQuery,
    this.onFavoriteTap,
  });

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
    if (widget.restaurant['is_favorited'] !=
        oldWidget.restaurant['is_favorited']) {
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
    final bool isOpenNow = widget.restaurant['is_open_now'] ?? true;
    final bool isAcceptingOrders =
        widget.restaurant['is_accepting_orders'] ?? true;
    final bool isClosed = !isOpenNow || !isAcceptingOrders;

    String formatTime(String timeStr) {
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

    String openAtText = '';
    final todayHours = widget.restaurant['today_hours'];
    if (todayHours != null &&
        todayHours['open_from'] != null &&
        todayHours['open_from'].toString().isNotEmpty) {
      final formatted = formatTime(todayHours['open_from'].toString());
      if (formatted.isNotEmpty) openAtText = 'Opens at $formatted';
    } else if (widget.restaurant['opens_at'] != null) {
      final formatted = formatTime(widget.restaurant['opens_at'].toString());
      if (formatted.isNotEmpty) openAtText = 'Opens at $formatted';
    }

    return GestureDetector(
      onTap: () {
        AppUtils.haptic();
        Get.toNamed(
          AppRoutes.restaurantDetail,
          arguments: {
            'id': widget.restaurant['id'],
            'q': widget.searchQuery ?? '',
          },
        );
      },
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
                        widget.restaurant['cover_url'] as String? ??
                        widget.restaurant['logo_url'] as String? ??
                        widget.restaurant['image'] as String?,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 60,
                    height: 26,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
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
                          '${widget.restaurant['rating'] ?? '0.0'}',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.darkNavy,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (widget.restaurant['offer'] != null ||
                    widget.restaurant['badge'] != null)
                  Positioned(
                    bottom: 16.h,
                    left: 10.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      child: Text(
                        (widget.restaurant['offer'] ??
                                widget.restaurant['badge'])
                            .toString(),
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                if (isClosed)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 40.h,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: AppColors.white.withOpacity(0.2),
                                width: 2,
                              ),
                            ),
                            child: Text(
                              'CLOSED',
                              style: TextStyle(
                                fontFamily: 'Fonts/Paragraph',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                          if (openAtText.isNotEmpty) ...[
                            SizedBox(height: 4.h),
                            Text(
                              openAtText,
                              style: TextStyle(
                                fontFamily: 'Fonts/Paragraph',
                                fontSize: 14.sp,
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
            SizedBox(height: 12.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.restaurant['name'],
                    style: GoogleFonts.inter(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkNavy,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    AppUtils.haptic();
                    setState(() => _isFavourited = !_isFavourited);
                    widget.onFavoriteTap?.call();
                  },
                  behavior: HitTestBehavior.opaque,
                  child:
                      (_isFavourited
                              ? Assets.images.favouriteAdded
                              : Assets.images.favourite)
                          .image(width: 24.w, height: 24.h),
                ),
              ],
            ),

            SizedBox(height: 4.h),
            Row(
              children: [
                Assets.images.timeIcon.image(width: 20.w, height: 20.h),
                SizedBox(width: 5.w),
                Text(
                  widget.restaurant['time'] ?? "20-30 min",
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.lightSurfaceSubtitle,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(width: 9.w),
                Container(
                  width: 0.5,
                  height: 19.5.h,
                  color: AppColors.lightSurfaceBorder,
                ),
                SizedBox(width: 9.w),
                Expanded(
                  child: Text(
                    widget.restaurant['distance'] ?? '',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
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
