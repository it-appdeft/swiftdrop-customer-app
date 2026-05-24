import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';

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
                  Text(
                    'Store Info',
                    style: const TextStyle(
                      fontFamily: 'Helvetica Neue',
                      fontSize: 20, // H6 Size
                      fontWeight: FontWeight.w400,
                      color: AppColors.lightSurfaceDarkText,
                      height: 1.2,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(
                        Icons.close, color: AppColors.iconDark, size: 24),
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
                          child: Text(
                            'The Marble Grill',
                            style: const TextStyle(
                              fontFamily: 'Helvetica Neue',
                              fontSize: 28, // H4 Size
                              fontWeight: FontWeight.w500,
                              color: AppColors.lightSurfaceDarkText,
                            ),
                          ),
                        ),
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
                        Text(
                          'Steakhouse • Premium Pizza',
                          style: GoogleFonts.inter(
                            fontSize: 14, // PS Size
                            fontWeight: FontWeight.w400,
                            color: AppColors.lightSurfaceSubtitle,
                          ),
                        ),
                        Text(
                          '(200K+)',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.lightSurfaceSubtitle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 96,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.offWhite,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Assets.images.timeIcon.image(width: 20,
                                    height: 20,
                                    color: AppColors.primary),
                                const SizedBox(height: 8),
                                Text(
                                  'Delivery',
                                  style: GoogleFonts.inter(
                                      fontSize: 14, // PS Size
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.lightSurfaceSubtitle),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '25-35 min',
                                  style: GoogleFonts.inter(fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.lightSurfaceDarkText),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 96,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.offWhite,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Assets.images.locationIcon.image(width: 20,
                                    height: 20,
                                    color: AppColors.primary),
                                const SizedBox(height: 8),
                                Text(
                                  'Distance',
                                  style: GoogleFonts.inter(
                                      fontSize: 14, // PS Size
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.lightSurfaceSubtitle),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '1.2 mi',
                                  style: GoogleFonts.inter(fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.lightSurfaceDarkText),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 49,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.offWhite,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Open until 11:00 PM',
                            style: GoogleFonts.inter(fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.lightSurfaceDarkText),
                          ),
                          Text(
                            'Everyday 09:00-23:00',
                            style: GoogleFonts.inter(
                                fontSize: 12, // Pxs Size
                                fontWeight: FontWeight.w400,
                                color: AppColors.navyMuted300),
                          ),
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
                              //color: Colors.white,
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
                                  style: GoogleFonts.inter(fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.lightSurfaceDarkText),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'This shop can\'t accommodate in-app food allergy requests',
                                  style: GoogleFonts.inter(
                                      fontSize: 14, color: AppColors.lightSurfaceSubtitle),
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
                        fontSize: 14, // PS Size
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
                    fontSize: 14, // PS Size
                    fontWeight: FontWeight.w500, // Medium
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
              fontSize: 12, // Pxs Size
              fontWeight: FontWeight.w400, // Regular
              color: AppColors.lightSurfaceSubtitle,
            ),
          )
        ],
      ),
    );
  }
}
