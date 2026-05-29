import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';
import '../controllers/restaurant_detail_controller.dart';

void showStoreInfoBottomSheet() {
  Get.bottomSheet(
    const StoreInfoContent(),
    backgroundColor: AppColors.transparent,
    isScrollControlled: true,
  );
}

class StoreInfoContent extends StatelessWidget {
  const StoreInfoContent({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RestaurantDetailController>();
    return Obx(() {
      final info = controller.restaurantInfo.value;
      final deliveryTime = (info?.deliveryMinutesMin != null && info?.deliveryMinutesMax != null)
          ? '${info!.deliveryMinutesMin}-${info.deliveryMinutesMax} min'
          : '--';
      final distance = info?.distanceMiles != null
          ? '${info!.distanceMiles!.toStringAsFixed(1)} mi'
          : '--';
      final openLabel = info?.todayOpenTo != null
          ? 'Open until ${info!.todayOpenTo}'
          : '--';
      final hoursSummary = info?.hoursSummary ?? '--';

      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Store Info',
                      style: TextStyle(
                        fontFamily: 'Helvetica Neue',
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: AppColors.lightSurfaceDarkText,
                        height: 1.2,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const Icon(Icons.close, color: AppColors.iconDark, size: 24),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: info != null
                                ? Text(
                                    info.name,
                                    style: const TextStyle(
                                      fontFamily: 'Helvetica Neue',
                                      fontSize: 28,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.lightSurfaceDarkText,
                                    ),
                                  )
                                : AppShimmer.text(height: 28),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.offWhite,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Assets.images.ratingStar.image(width: 14, height: 14),
                                const SizedBox(width: 4),
                                info != null
                                    ? Text(
                                        info.rating.toStringAsFixed(1),
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.lightSurfaceDarkText,
                                        ),
                                      )
                                    : AppShimmer.text(width: 24, height: 14),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          info != null
                              ? Text(
                                  info.cuisines ?? '',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.lightSurfaceSubtitle,
                                  ),
                                )
                              : AppShimmer.text(width: 100, height: 14),
                          info != null
                              ? Text(
                                  '(${info.totalReviews})',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: AppColors.lightSurfaceSubtitle,
                                  ),
                                )
                              : AppShimmer.text(width: 40, height: 14),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _InfoCard(
                              icon: Assets.images.timeIcon,
                              label: 'Delivery',
                              value: deliveryTime,
                              isLoading: info == null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoCard(
                              icon: Assets.images.locationIcon,
                              label: 'Distance',
                              value: distance,
                              isLoading: info == null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.offWhite,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            info != null
                                ? Text(
                                    openLabel,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.lightSurfaceDarkText,
                                    ),
                                  )
                                : AppShimmer.text(width: 120, height: 14),
                            info != null
                                ? Text(
                                    hoursSummary,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.navyMuted300,
                                    ),
                                  )
                                : AppShimmer.text(width: 60, height: 12),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.offWhite,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              child: Assets.images.alertIcon.image(
                                width: 28,
                                height: 28,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Allergy requests unavailable',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.lightSurfaceDarkText,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'This shop can\'t accommodate in-app food allergy requests',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: AppColors.lightSurfaceSubtitle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'SwiftDrop cannot guarantee that any unpackaged products served in shops are allergen-free because shops may use shared equipment to store, prepare and serve them.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.lightSurfaceSubtitle,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildAllergenInfo(Icons.restaurant, 'Share',
                          'Tools may come into contact with multiple ingredients.'),
                      const SizedBox(height: 12),
                      _buildAllergenInfo(Icons.inventory_2_outlined, 'Storage',
                          'Ingredients are stored in proximity to allergens.'),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAllergenInfo(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: AppColors.lightSurfaceDarkText),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.lightSurfaceDarkText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.lightSurfaceSubtitle,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final AssetGenImage icon;
  final String label;
  final String value;
  final bool isLoading;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          icon.image(width: 20, height: 20, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.lightSurfaceSubtitle,
            ),
          ),
          const SizedBox(height: 4),
          isLoading
              ? AppShimmer.text(width: 60, height: 14)
              : Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.lightSurfaceDarkText,
                  ),
                ),
        ],
      ),
    );
  }
}
