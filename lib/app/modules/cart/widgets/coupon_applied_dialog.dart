import 'package:swiftdrop_customer_app/export.dart';
import '../controllers/cart_controller.dart';

class CouponAppliedDialog extends StatelessWidget {
  final CheckoutCoupon coupon;
  final CartController controller;

  const CouponAppliedDialog({
    super.key,
    required this.coupon,
    required this.controller,
  });

  static void show(BuildContext context, CheckoutCoupon coupon, CartController controller) {
    Get.dialog(
      CouponAppliedDialog(coupon: coupon, controller: controller),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 44, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD8FFEF),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 32),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Coupon Applied!',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.lightSurfaceDarkText,
              ),
            ),
            const SizedBox(height: 8),
            if (coupon.type == 'exclusive') ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFD8FFEF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars, color: AppColors.primary, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      coupon.title ?? coupon.headline,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'You saved £${controller.couponDiscount.value.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${coupon.headline} applied',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.lightSurfaceDarkText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'The discount has been added to your cart. Enjoy your meal!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.lightSurfaceSubtitle,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Yah!',
              onTap: () {
                AppUtils.haptic();
                Get.back(); // Close Dialog
                Get.back(); // Go back from CouponsView to CartView
              },
            ),
          ],
        ),
      ),
    );
  }
}
