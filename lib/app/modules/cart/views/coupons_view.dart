import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';
import '../controllers/cart_controller.dart';

class CouponsView extends StatefulWidget {
  const CouponsView({super.key});

  @override
  State<CouponsView> createState() => _CouponsViewState();
}

class _CouponsViewState extends State<CouponsView> {
  final TextEditingController _promoCodeController = TextEditingController();
  final CartController controller = Get.find<CartController>();

  @override
  void dispose() {
    _promoCodeController.dispose();
    super.dispose();
  }

  void _onApplyPromoCode() {
    AppUtils.haptic();
    final codeText = _promoCodeController.text.trim();
    if (codeText.isEmpty) {
      AppUtils.showError('Please enter a promo code');
      return;
    }

    final coupons = controller.checkoutData.value?.availableCoupons ?? [];
    final matched = coupons.firstWhereOrNull(
      (c) => c.code.toLowerCase() == codeText.toLowerCase(),
    );

    if (matched != null) {
      if (!matched.eligible) {
        final req = matched.minOrderValue != null ? ' (Min. order £${matched.minOrderValue})' : '';
        AppUtils.showError('Coupon "${matched.code}" is not eligible for your current cart amount$req.');
        return;
      }
      controller.applyCouponApi(matched.id);
    } else {
      AppUtils.showError('Invalid promo code. Please select from available offers below.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(),
      body: Obx(() {
        final coupons = controller.checkoutData.value?.availableCoupons ?? [];

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            _buildPromoCodeInput(),
            const SizedBox(height: 24),
            Text(
              AppStrings.moreOffers,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.lightSurfaceDarkText,
              ),
            ),
            const SizedBox(height: 16),
            if (coupons.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    AppStrings.noCouponsAvailable,
                    style: TextStyle(color: AppColors.lightSurfaceSubtitle),
                  ),
                ),
              )
            else
              ...coupons.asMap().entries.map((entry) {
                final coupon = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: coupon.type == 'exclusive'
                      ? _buildExclusiveCoupon(context, coupon)
                      : _buildStandardCoupon(context, coupon),
                );
              }),
          ],
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.iconDark, size: 20),
        onPressed: () {
          AppUtils.haptic();
          Get.back();
        },
      ),
      title: Text(
        AppStrings.applyCoupons,
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.lightSurfaceDarkText,
        ),
      ),
    );
  }

  Widget _buildPromoCodeInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightSurfaceBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Assets.images.couponIcon.image(width: 22, height: 22, fit: BoxFit.contain),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _promoCodeController,
              textCapitalization: TextCapitalization.characters,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.lightSurfaceDarkText,
                letterSpacing: 0.5,
              ),
              decoration: InputDecoration(
                hintText: AppStrings.enterPromoCode,
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFADB5BD),
                  letterSpacing: 0,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isCollapsed: true,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _onApplyPromoCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              elevation: 0,
              minimumSize: const Size(76, 38),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: Text(
              'Apply',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExclusiveCoupon(BuildContext context, CheckoutCoupon coupon) {
    final bool isApplied = controller.checkoutData.value?.appliedCoupon?.id == coupon.id;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE53915),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE53915).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        image: DecorationImage(
          image: Assets.images.onbording1.provider(),
          fit: BoxFit.cover,
          opacity: 0.15,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars_rounded, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        coupon.title ?? AppStrings.exclusiveOffer,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    coupon.code,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              coupon.headline,
              style: GoogleFonts.inter(
                fontSize: 38,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.0,
              ),
            ),
            if (coupon.description != null && coupon.description!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                coupon.description!,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.2,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    coupon.validUntil != null
                        ? 'Valid until ${coupon.validUntil}'
                        : 'Valid for limited time',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isApplied
                      ? () {
                          AppUtils.haptic();
                          controller.removeCouponApi();
                        }
                      : (coupon.eligible
                          ? () {
                              AppUtils.haptic();
                              controller.applyCouponApi(coupon.id);
                            }
                          : null),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isApplied
                        ? Colors.white.withValues(alpha: 0.9)
                        : Colors.white,
                    foregroundColor: isApplied
                        ? const Color(0xFFE53915)
                        : const Color(0xFFE53915),
                    elevation: 0,
                    minimumSize: const Size(100, 38),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: Text(
                    isApplied ? 'Remove' : AppStrings.applyNow,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardCoupon(BuildContext context, CheckoutCoupon coupon) {
    final bool isApplied = controller.checkoutData.value?.appliedCoupon?.id == coupon.id;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightSurfaceBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F9F1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Assets.images.offers.image(
                  width: 20,
                  height: 20,
                  fit: BoxFit.contain,
                  color: AppColors.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  coupon.code,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            coupon.headline,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.lightSurfaceDarkText,
            ),
          ),
          if (coupon.description != null && coupon.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              coupon.description!,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.lightSurfaceSubtitle,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.lightSurfaceBorder, thickness: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: coupon.minOrderValue != null
                    ? Text(
                        'Min. order £${coupon.minOrderValue}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: coupon.eligible ? AppColors.lightSurfaceSubtitle : AppColors.error,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),              ElevatedButton(
                onPressed: isApplied
                    ? () {
                        AppUtils.haptic();
                        controller.removeCouponApi();
                      }
                    : (coupon.eligible
                        ? () {
                            AppUtils.haptic();
                            controller.applyCouponApi(coupon.id);
                          }
                        : null),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isApplied
                      ? const Color(0xFFFDE8E8)
                      : (coupon.eligible ? AppColors.primary : AppColors.greyButton),
                  foregroundColor: isApplied
                      ? AppColors.error
                      : (coupon.eligible ? AppColors.white : AppColors.lightSurfaceSubtitle),
                  elevation: 0,
                  minimumSize: const Size(84, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: Text(
                  isApplied ? 'Remove' : 'Apply',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
