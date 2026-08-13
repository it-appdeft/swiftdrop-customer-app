import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import '../../../../export.dart';
import '../../../../generated/assets.dart';
import '../../../../data/models/order_model.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_dimensions.dart';
import '../../../widgets/app_button.dart';
import '../controllers/order_delivered_controller.dart';

class OrderDeliveredView extends GetView<OrderDeliveredController> {
  const OrderDeliveredView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Obx(() {
        final order = controller.order.value;
        return SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDeliveredAtCard(order),
                    const SizedBox(height: 16),
                    _buildRateRestaurantCard(order),
                    const SizedBox(height: 16),
                    _buildRateFoodCard(order),
                    const SizedBox(height: 16),
                    _buildRateDeliveryCard(),
                    const SizedBox(height: 20),
                    _buildSupportButton(),
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Submit Feedback',
                      onTap: controller.submitFeedback,
                      backgroundColor: AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () {
                          AppUtils.haptic();
                          controller.backToHome();
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
                          'Back To Home',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 42),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
            'Hope you enjoyed your meal.',
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

  Widget _buildDeliveredAtCard(OrderModel? order) {
    final addressText = order?.deliveryAddress.isNotEmpty == true
        ? order!.deliveryAddress
        : '4521 Emerald Valley, Block B, Suite 104, Green Park, CA 90210';

    return Container(
      padding: EdgeInsets.all(16),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
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
                  addressText,
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

  Widget _buildRateRestaurantCard(OrderModel? order) {
    final restaurantName =
        order?.pickupAddress.split(',').first ?? 'The Marble Grill';
    final restaurantCategory = order?.pickupAddress.contains(',') == true
        ? order!.pickupAddress
              .substring(order.pickupAddress.indexOf(',') + 1)
              .trim()
        : 'Italian & Pizza';

    return Container(
      padding: EdgeInsets.all(16),
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
                child: Assets.images.restaurantImage.image(
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
                    const SizedBox(height: 2),
                    Text(
                      restaurantCategory,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.lightSurfaceSubtitle,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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

  Widget _buildRateFoodCard(OrderModel? order) {
    final items = order?.items ?? [];

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
            'Rate the Food',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.lightSurfaceDarkText,
            ),
          ),
          const SizedBox(height: 14),
          if (items.isEmpty) ...[
            _buildFoodItemRow('Margherita Pizza', 'Giant Slice x1'),
            const SizedBox(height: 14),
            _buildFoodItemRow('Sweet Corn Pizza', 'Regular x1'),
          ] else ...[
            ...items.asMap().entries.map((entry) {
              final item = entry.value;
              final isLast = entry.key == items.length - 1;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
                child: _buildFoodItemRow(item.name, 'Qty: x${item.quantity}'),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildFoodItemRow(String name, String subtitle) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Assets.images.restaurantImage.image(
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

  Widget _buildRateDeliveryCard() {
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
            'Rate your delivery partner',
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
                hintText: 'Any feedback for your courier?',
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

  Widget _buildSupportButton() {
    return Container(
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
            'Go to Support',
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
