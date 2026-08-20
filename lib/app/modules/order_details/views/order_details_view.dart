import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';
import '../../../../data/models/order_model.dart';
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
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.order.value == null) {
          return const Center(child: AppLoader());
        }

        final order = controller.order.value;
        if (order == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.errorMessage.value.isNotEmpty
                      ? controller.errorMessage.value
                      : 'Order details not found',
                  style: GoogleFonts.inter(fontSize: 14, color: AppColors.navyMuted200),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          );
        }

        final isCancelledOrFailed = order.isCancelled || order.status == 'failed' || order.status == 'payment_failed';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isCancelledOrFailed) ...[
                _buildCancellationBanner(order),
                const SizedBox(height: AppDimensions.gapMd),
              ],
              _buildOrderIdCard(order),
              const SizedBox(height: AppDimensions.gapMd),
              _buildAddressAndPartnerCard(order),
              const SizedBox(height: AppDimensions.gapLg),
              _buildSectionHeader('Order Items'),
              const SizedBox(height: AppDimensions.gapMd),
              _buildOrderItemsCard(order),
              if (!isCancelledOrFailed && order.items.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.gapLg),
                _buildSectionHeader('Rate your ordered dishes'),
                const SizedBox(height: AppDimensions.gapMd),
                _buildDishesRatingCard(order),
                const SizedBox(height: AppDimensions.gapLg),
                _buildPartnerRatingCard(),
              ],
              const SizedBox(height: AppDimensions.gapLg),
              _buildSectionHeader('Payment Details'),
              const SizedBox(height: AppDimensions.gapMd),
              _buildPaymentDetailsCard(order),
              const SizedBox(height: AppDimensions.gapMd),
              _buildPaymentMethodCard(order),
              const SizedBox(height: AppDimensions.gapXl),
              AppButton(
                label: 'Reorder',
                onTap: controller.onReorder,
              ),
              const SizedBox(height: AppDimensions.gapXl),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCancellationBanner(OrderModel order) {
    final reasonText = order.effectiveCancellationReason;
    final isFailed = order.status == 'failed' || order.status == 'payment_failed';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cancel_outlined,
            color: AppColors.error,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isFailed ? 'Order Failed' : 'Order Cancelled',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  reasonText,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.error.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderIdCard(OrderModel order) {
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
              Text(
                '#${order.orderNumber.isNotEmpty ? order.orderNumber : order.id}',
                style: const TextStyle(
                  fontFamily: 'Fonts/Paragraph',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightSurfaceDarkText,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                order.isCancelled ? 'Cancelled On' : (order.isDelivered ? 'Delivered On' : 'Placed On'),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.navyMuted200,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                order.displayPlacedAt,
                style: const TextStyle(
                  fontFamily: 'Fonts/Paragraph',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightSurfaceDarkText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressAndPartnerCard(OrderModel order) {
    final driverText = order.driverName?.isNotEmpty == true
        ? order.driverName!
        : (order.isCancelled ? 'Not assigned' : 'Assigned upon pickup');

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
                    const Text(
                      'Delivery Address',
                      style: TextStyle(
                        fontFamily: 'Fonts/Paragraph',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.lightSurfaceDarkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.deliveryAddress,
                      style: const TextStyle(
                        fontFamily: 'Fonts/Paragraph',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.navyMuted200,
                      ),
                    ),
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
                    const Text(
                      'Delivery Partner',
                      style: TextStyle(
                        fontFamily: 'Fonts/Paragraph',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.lightSurfaceDarkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      driverText,
                      style: const TextStyle(
                        fontFamily: 'Fonts/Paragraph',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.navyMuted200,
                      ),
                    ),
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

  Widget _buildOrderItemsCard(OrderModel order) {
    final restaurantName = order.displayRestaurantName;
    final restaurantAddress = order.restaurantAddressLine.isNotEmpty
        ? order.restaurantAddressLine
        : order.pickupAddress;

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
                    Text(
                      restaurantName,
                      style: const TextStyle(
                        fontFamily: 'Fonts/Paragraph',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.lightSurfaceDarkText,
                      ),
                    ),
                    if (restaurantAddress.isNotEmpty)
                      Text(
                        restaurantAddress,
                        style: const TextStyle(
                          fontFamily: 'Fonts/Paragraph',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.navyMuted200,
                        ),
                      ),
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
          ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = order.items[index];
              return Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${item.quantity}x',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(
                        fontFamily: 'Fonts/Paragraph',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.lightSurfaceDarkText,
                      ),
                    ),
                  ),
                  Text(
                    '£${(item.subtotal > 0 ? item.subtotal : (item.price * item.quantity)).toStringAsFixed(2)}',
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
          ),
        ],
      ),
    );
  }

  Widget _buildDishesRatingCard(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: order.items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = order.items[index];
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(
                    fontFamily: 'Fonts/Paragraph',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.lightSurfaceSubtitle,
                  ),
                ),
              ),
              RatingStars(
                value: 0,
                onValueChanged: (v) {
                  AppUtils.showSuccess('Rating recorded!');
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
      ),
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

  Widget _buildPaymentDetailsCard(OrderModel order) {
    final subtotal = order.subtotalAmount > 0
        ? order.subtotalAmount
        : (order.totalAmount - order.deliveryFee - order.vatAmount).clamp(0.0, double.infinity);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildPaymentRow('Item Total', '£${subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          _buildPaymentRow('Delivery Fee', '£${order.deliveryFee.toStringAsFixed(2)}'),
          if (order.vatAmount > 0) ...[
            const SizedBox(height: 12),
            _buildPaymentRow('Taxes & Charges (VAT)', '£${order.vatAmount.toStringAsFixed(2)}'),
          ],
          if (order.discountAmount > 0) ...[
            const SizedBox(height: 12),
            _buildPaymentRow('Discount', '-£${order.discountAmount.toStringAsFixed(2)}'),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: AppColors.lightSurfaceBorder, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'To Pay',
                style: TextStyle(
                  fontFamily: 'Fonts/Paragraph',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightSurfaceDarkText,
                ),
              ),
              Text(
                '£${order.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontFamily: 'Fonts/Paragraph',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
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

  Widget _buildPaymentMethodCard(OrderModel order) {
    final method = order.paymentMethod?.isNotEmpty == true
        ? order.paymentMethod!
        : 'Online Payment';
    final statusText = order.status.toUpperCase();

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
            child: Text(
              method,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.lightSurfaceDarkText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            statusText,
            style: TextStyle(
              fontFamily: 'Fonts/Paragraph',
              fontSize: 14,
              color: order.isCancelled ? AppColors.error : AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
