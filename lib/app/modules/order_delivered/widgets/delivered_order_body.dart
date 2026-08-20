import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';
import 'package:swiftdrop_customer_app/data/models/order_model.dart';
import '../controllers/order_delivered_controller.dart';

class DeliveredOrderBody extends StatelessWidget {
  final OrderModel? order;
  final OrderDeliveredController controller;

  const DeliveredOrderBody({
    super.key,
    required this.order,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _DeliveredHeader(context: context),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _DeliveredAtCard(order: order),
                const SizedBox(height: 16),
                _RateRestaurantCard(order: order),
                const SizedBox(height: 16),
                _RateFoodCard(order: order),
                const SizedBox(height: 16),
                const _RateDeliveryCard(),
                const SizedBox(height: 20),
                const _GoToSupportCard(),
                const SizedBox(height: 24),
                AppButton(
                  label: AppStrings.submitFeedback,
                  onTap: controller.submitFeedback,
                  backgroundColor: AppColors.primary,
                ),
                const SizedBox(height: 12),
                _BackToHomeButton(onPressed: controller.backToHome),
                const SizedBox(height: 42),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SUB-COMPONENTS ──────────────────────────────────────────────────────────

class _DeliveredHeader extends StatelessWidget {
  final BuildContext context;
  const _DeliveredHeader({required this.context});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 28,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Get.back(),
              ),
            ),
          ),
          Assets.images.orderDelivered.image(width: 84, height: 84),
          const SizedBox(height: 14),
          Text(
            AppStrings.orderDelivered,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.hopeYouEnjoyedMeal,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveredAtCard extends StatelessWidget {
  final OrderModel? order;
  const _DeliveredAtCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final deliveryAddress = order?.deliveryAddress ?? '';
    if (deliveryAddress.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Assets.images.locationIcon.image(width: 20, height: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.deliveredAt,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightSurfaceDarkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  deliveryAddress,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.lightSurfaceSubtitle,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RateRestaurantCard extends StatelessWidget {
  final OrderModel? order;
  const _RateRestaurantCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final restaurantName = order?.displayRestaurantName ?? 'Restaurant';
    final restaurantAddress = order?.restaurantAddressLine ?? '';
    final imgUrl = order?.fullRestaurantImage;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.rateRestaurant,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.lightSurfaceDarkText,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imgUrl != null && imgUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imgUrl,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorWidget: (c, u, e) => Assets.images.restaurantImage.image(
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Assets.images.restaurantImage.image(
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurantName,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightSurfaceDarkText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (restaurantAddress.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        restaurantAddress,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.lightSurfaceSubtitle,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const _StarRating(size: 18),
            ],
          ),
        ],
      ),
    );
  }
}

class _RateFoodCard extends StatelessWidget {
  final OrderModel? order;
  const _RateFoodCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final items = order?.items ?? [];
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.rateFood,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.lightSurfaceDarkText,
            ),
          ),
          const SizedBox(height: 14),
          ...items.asMap().entries.map((entry) {
            final item = entry.value;
            final isLast = entry.key == items.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: _RateFoodItemRow(
                name: item.name,
                subtitle: 'Qty: x${item.quantity}',
                image: order?.fullRestaurantImage,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _RateFoodItemRow extends StatelessWidget {
  final String name;
  final String subtitle;
  final String? image;

  const _RateFoodItemRow({
    required this.name,
    required this.subtitle,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: image != null && image!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: image!,
                  width: 42,
                  height: 42,
                  fit: BoxFit.cover,
                  errorWidget: (c, u, e) => Assets.images.restaurantImage.image(
                    width: 42,
                    height: 42,
                    fit: BoxFit.cover,
                  ),
                )
              : Assets.images.restaurantImage.image(
                  width: 42,
                  height: 42,
                  fit: BoxFit.cover,
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.lightSurfaceDarkText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
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
        ),
        const _StarRating(size: 18),
      ],
    );
  }
}

class _RateDeliveryCard extends StatelessWidget {
  const _RateDeliveryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.rateDeliveryPartner,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.lightSurfaceDarkText,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?u=james',
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(child: _StarRating(size: 26, spacing: 6)),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 96,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.offWhite,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.lightSurfaceBorder),
            ),
            child: TextField(
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.lightSurfaceDarkText,
              ),
              decoration: InputDecoration(
                hintText: AppStrings.feedbackCourierHint,
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.lightSurfaceSubtitle,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                isDense: true,
              ),
              maxLines: null,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoToSupportCard extends StatelessWidget {
  const _GoToSupportCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppUtils.haptic();
        Get.toNamed(AppRoutes.helpCenter);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.offWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lightSurfaceBorder),
        ),
        child: Row(
          children: [
            Assets.images.goToSupport.image(width: 22, height: 22),
            const SizedBox(width: 12),
            Text(
              AppStrings.goToSupport,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.lightSurfaceDarkText,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.lightSurfaceSubtitle,
            ),
          ],
        ),
      ),
    );
  }
}

class _BackToHomeButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _BackToHomeButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () {
          AppUtils.haptic();
          onPressed();
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          AppStrings.backToHome,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _StarRating extends StatefulWidget {
  final double size;
  final double spacing;
  const _StarRating({required this.size, this.spacing = 2});

  @override
  State<_StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<_StarRating> {
  double _rating = 4.0;

  @override
  Widget build(BuildContext context) {
    return RatingStars(
      value: _rating,
      onValueChanged: (v) => setState(() => _rating = v),
      starBuilder: (index, color) =>
          (color == AppColors.warning
                  ? Assets.images.filledStart
                  : Assets.images.emptyStar)
              .image(width: widget.size, height: widget.size),
      starCount: 5,
      starSize: widget.size,
      valueLabelVisibility: false,
      starSpacing: widget.spacing,
      starOffColor: AppColors.lightSurfaceBorder,
      starColor: AppColors.warning,
    );
  }
}
