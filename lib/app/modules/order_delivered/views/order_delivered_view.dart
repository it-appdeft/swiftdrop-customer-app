import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import '../../../../generated/assets.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_dimensions.dart';
import '../../../widgets/app_button.dart';
import '../controllers/order_delivered_controller.dart';

class OrderDeliveredView extends GetView<OrderDeliveredController> {
  const OrderDeliveredView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildDeliveredAtCard(),
                  const SizedBox(height: 16),
                  _buildRateRestaurantCard(),
                  const SizedBox(height: 16),
                  _buildRateFoodCard(),
                  const SizedBox(height: 16),
                  _buildRateDeliveryCard(),
                  const SizedBox(height: 24),
                  _buildSupportButton(),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Submit',
                    onTap: controller.submitFeedback,
                    backgroundColor: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: controller.backToHome,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Back To Home',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 32,
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              onPressed: () => Get.back(),
            ),
          ),
          Assets.images.orderDelivered.image(width: 88, height: 88),
          const SizedBox(height: 16),
          Text(
            'Order Delivered',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Hope you enjoy your meal.',
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

  Widget _buildDeliveredAtCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Assets.images.locationIcon.image(width: 24, height: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivered At',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF0B243A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '4521 Emerald Valley, Block B, Suite 104, Green Park, CA 90210',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF868AA5),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateRestaurantCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rate the Restaurant',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF0B243A),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Assets.images.restaurantImage.image(width: 48, height: 48, fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'The Marble Grill',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF0B243A),
                      ),
                    ),
                    Text(
                      'Italian & Pizza',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF64748B),
                      ),
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

  Widget _buildRateFoodCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rate the Food',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF0B243A),
            ),
          ),
          const SizedBox(height: 16),
          _buildFoodItemRow('Margherita Pizza', 'Giant Slice x1'),
          const SizedBox(height: 16),
          _buildFoodItemRow('Sweet Corn Pizza', 'Regular x1'),
        ],
      ),
    );
  }

  Widget _buildFoodItemRow(String name, String subtitle) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Assets.images.restaurantImage.image(width: 48, height: 48, fit: BoxFit.cover),
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
                  color: const Color(0xFF0B243A),
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF64748B),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF2F2E9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rate your delivery',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF0B243A),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=james'),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: _StarRating(size: 28, spacing: 8),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 108,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.offWhite,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF0B243A),
              ),
              decoration: InputDecoration(
                hintText: 'Any feedback for your courier?',
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF868AA5),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Assets.images.goToSupport.image(width: 24, height: 24),
          const SizedBox(width: 12),
          Text(
            'Go to Support',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF0B243A),
            ),
          ),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
        ],
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  final double size;
  final double spacing;
  const _StarRating({required this.size, this.spacing = 2});

  @override
  Widget build(BuildContext context) {
    return RatingStars(
      value: 1,
      onValueChanged: (v) {},
      starBuilder: (index, color) => (color == AppColors.warning
              ? Assets.images.filledStart
              : Assets.images.emptyStar)
          .image(
        width: size,
        height: size,
      ),
      starCount: 5,
      starSize: size,
      valueLabelVisibility: false,
      starSpacing: spacing,
      starOffColor: const Color(0xffe4e8ef),
      starColor: AppColors.warning,
    );
  }
}
