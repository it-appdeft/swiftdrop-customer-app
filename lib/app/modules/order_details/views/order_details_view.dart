import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';

import '../controllers/order_details_controller.dart';

class OrderDetailsView extends GetView<OrderDetailsController> {
  const OrderDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Assets.images.back.image(width: 24, height: 24),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Order Details',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.lightSurfaceDarkText,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: AppColors.lightSurfaceDarkText),
            onPressed: () {
              // Download invoice
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderIdCard(),
            const SizedBox(height: AppDimensions.gapMd),
            _buildAddressAndPartnerCard(),
            const SizedBox(height: AppDimensions.gapLg),
            _buildSectionHeader('Order Items'),
            const SizedBox(height: AppDimensions.gapMd),
            _buildOrderItemsCard(),
            const SizedBox(height: AppDimensions.gapLg),
            _buildSectionHeader('Rate your ordered dishes'),
            const SizedBox(height: AppDimensions.gapMd),
            _buildDishesRatingCard(),
            const SizedBox(height: AppDimensions.gapLg),
            _buildPartnerRatingCard(),
            const SizedBox(height: AppDimensions.gapLg),
            _buildSectionHeader('Payment Details'),
            const SizedBox(height: AppDimensions.gapMd),
            _buildPaymentDetailsCard(),
            const SizedBox(height: AppDimensions.gapMd),
            _buildPaymentMethodCard(),
            const SizedBox(height: AppDimensions.gapXl),
            AppButton(
              label: 'Reorder',
              onTap: controller.onReorder,
            ),
            const SizedBox(height: AppDimensions.gapXl),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderIdCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order ID',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.navyMuted200,
                ),
              ),
              const SizedBox(height: 4),
              Obx(() => Text(
                    controller.orderId.value,
                    style: const TextStyle(
                      fontFamily: 'Fonts/Paragraph',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.lightSurfaceDarkText,
                    ),
                  )),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Delivered On',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.navyMuted200,
                ),
              ),
              const SizedBox(height: 4),
              Obx(() => Text(
                    controller.deliveredOn.value,
                    style: const TextStyle(
                      fontFamily: 'Fonts/Paragraph',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.lightSurfaceDarkText,
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressAndPartnerCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Assets.images.locationIcon.image(width: 20, height: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Address',
                      style: const TextStyle(
                        fontFamily: 'Fonts/Paragraph',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.lightSurfaceDarkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                          controller.deliveryAddress.value,
                          style: const TextStyle(
                            fontFamily: 'Fonts/Paragraph',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.navyMuted200,
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.lightSurfaceBorder, height: 1),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Assets.images.deliveryPartner.image(width: 20, height: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Partner',
                      style: const TextStyle(
                        fontFamily: 'Fonts/Paragraph',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.lightSurfaceDarkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                          controller.deliveryPartner.value,
                          style: const TextStyle(
                            fontFamily: 'Fonts/Paragraph',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.navyMuted200,
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Fonts/Paragraph',
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.lightSurfaceDarkText,
      ),
    );
  }

  Widget _buildOrderItemsCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Assets.images.storeImage.image(width: 22, height: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                          controller.restaurantName.value,
                          style: const TextStyle(
                            fontFamily: 'Fonts/Paragraph',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: AppColors.lightSurfaceDarkText,
                          ),
                        )),
                    Obx(() => Text(
                          controller.restaurantAddress.value,
                          style: const TextStyle(
                            fontFamily: 'Fonts/Paragraph',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.navyMuted200,
                          ),
                        )),
                  ],
                ),
              ),
              Assets.images.rightArrow.image(width: 20, height: 20),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.lightSurfaceBorder, height: 1),
          ),
          Obx(() => ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final item = controller.items[index];
                  return Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: AppImage(
                          path: item['image'],
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: const TextStyle(
                                fontFamily: 'Fonts/Paragraph',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.lightSurfaceDarkText,
                              ),
                            ),
                            Text(
                              item['subtitle'],
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.navyMuted200,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        item['price'],
                        style: const TextStyle(
                          fontFamily: 'Fonts/Paragraph',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.lightSurfaceDarkText,
                        ),
                      ),
                    ],
                  );
                },
              )),
        ],
      ),
    );
  }

  Widget _buildDishesRatingCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Obx(() => ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = controller.items[index];
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item['name']} ${item['subtitle'] ?? ''}',
                      style: const TextStyle(
                        fontFamily: 'Fonts/Paragraph',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.lightSurfaceSubtitle,
                      ),
                    ),
                  ),
                  RatingStars(
                    value: item['rating'] ?? 0,
                    onValueChanged: (v) {
                      // Update rating
                    },
                    starBuilder: (index, color) => (color == AppColors.warning
                            ? Assets.images.filledStart
                            : Assets.images.emptyStar)
                        .image(
                      width: 18,
                      height: 18,
                    ),
                    starCount: 5,
                    starSize: 18,
                    valueLabelVisibility: false,
                    starSpacing: 2,
                    starOffColor: const Color(0xffe4e8ef),
                    starColor: AppColors.warning,
                  ),
                ],
              );
            },
          )),
    );
  }

  Widget _buildPartnerRatingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Rate Delivery Partner'),
          const SizedBox(height: 8),
          Obx(() => RatingStars(
                value: controller.partnerRating.value,
                onValueChanged: (v) {
                  controller.partnerRating.value = v;
                },
                starBuilder: (index, color) => (color == AppColors.warning
                        ? Assets.images.filledStart
                        : Assets.images.emptyStar)
                    .image(
                  width: 28,
                  height: 28,
                ),
                starCount: 5,
                starSize: 28,
                valueLabelVisibility: false,
                starSpacing: 8,
                starOffColor: const Color(0xffe4e8ef),
                starColor: AppColors.warning,
              )),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildPaymentRow('Item Total', controller.itemTotal.value),
          const SizedBox(height: 12),
          _buildPaymentRow('Delivery Fee', controller.deliveryFee.value),
          const SizedBox(height: 12),
          _buildPaymentRow('Taxes & Charges', controller.taxesAndCharges.value),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: AppColors.lightSurfaceBorder, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'To Pay',
                style: const TextStyle(
                  fontFamily: 'Fonts/Paragraph',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightSurfaceDarkText,
                ),
              ),
              Obx(() => Text(
                    controller.toPay.value,
                    style: const TextStyle(
                      fontFamily: 'Fonts/Paragraph',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Fonts/Paragraph',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.black,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Fonts/Paragraph',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.credit_card, color: AppColors.lightSurfaceDarkText, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(() => Text(
                  controller.paymentMethod.value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.lightSurfaceDarkText,
                    fontWeight: FontWeight.w500,
                  ),
                )),
          ),
          Obx(() => Text(
                controller.paymentStatus.value,
                style: const TextStyle(
                  fontFamily: 'Fonts/Paragraph',
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              )),
        ],
      ),
    );
  }
}
