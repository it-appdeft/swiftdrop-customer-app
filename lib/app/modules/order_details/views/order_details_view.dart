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
        actions: [
          IconButton(
            icon: const Icon(
              Icons.download_rounded,
              color: AppColors.lightSurfaceDarkText,
              size: 22,
            ),
            onPressed: () {
              AppUtils.showSuccess('Invoice downloaded successfully');
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const OrderDetailsShimmer();
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
              if (order.specialInstructions != null && order.specialInstructions!.trim().isNotEmpty) ...[
                const SizedBox(height: AppDimensions.gapMd),
                _buildSpecialInstructionsCard(order.specialInstructions!),
              ],
              if (!isCancelledOrFailed && order.items.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.gapLg),
                _buildSectionHeader('Rate your ordered dishes'),
                const SizedBox(height: AppDimensions.gapMd),
                _buildDishesRatingCard(order),
                const SizedBox(height: AppDimensions.gapLg),
                _buildPartnerRatingCard(order),
              ],
              const SizedBox(height: AppDimensions.gapLg),
              _buildSectionHeader('Payment Details'),
              const SizedBox(height: AppDimensions.gapMd),
              _buildPaymentDetailsCard(order),
              const SizedBox(height: AppDimensions.gapMd),
              _buildPaymentMethodCard(order),
              if (order.isDelivered && !isCancelledOrFailed) ...[
                const SizedBox(height: AppDimensions.gapXl),
                AppButton(
                  label: 'Give Feedback',
                  onTap: () {
                    AppUtils.haptic();
                    Get.toNamed(AppRoutes.orderDelivered, arguments: {
                      'id': order.id,
                      'orderId': order.id,
                      'orderUuid': order.uuid,
                      'order': order,
                    });
                  },
                  backgroundColor: AppColors.primary,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: controller.onReorder,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Reorder',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.gapXl),
              ] else if (order.isActive) ...[
                const SizedBox(height: AppDimensions.gapXl),
                AppButton(
                  label: 'Track Order',
                  onTap: () {
                    AppUtils.haptic();
                    Get.toNamed(AppRoutes.orderTracking, arguments: {
                      'id': order.id,
                      'orderId': order.id,
                      'orderUuid': order.uuid ?? order.targetId,
                      'order': order,
                    });
                  },
                ),
                const SizedBox(height: AppDimensions.gapXl),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCancellationBanner(OrderModel order) {
    final reasonText = order.effectiveCancellationReason;
    final isFailed = order.status == 'failed' || order.status == 'payment_failed';
    final byText = order.cancelledBy != null && order.cancelledBy!.trim().isNotEmpty
        ? (order.cancelledBy!.toLowerCase() == 'customer' || order.cancelledBy!.toLowerCase() == 'user'
            ? 'Cancelled by you'
            : (order.cancelledBy!.toLowerCase() == 'restaurant' || order.cancelledBy!.toLowerCase() == 'vendor'
                ? 'Cancelled by restaurant'
                : (order.cancelledBy!.toLowerCase() == 'driver' || order.cancelledBy!.toLowerCase() == 'rider'
                    ? 'Cancelled by delivery partner'
                    : 'Cancelled by ${order.cancelledBy}')))
        : (isFailed ? 'Order Failed' : 'Order Cancelled');

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
                  byText,
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
    final dateLabel = order.isCancelled
        ? 'Cancelled On'
        : (order.isDelivered ? 'Delivered On' : 'Placed On');
    final dateValue = order.isCancelled
        ? order.displayCancelledAt
        : (order.isDelivered ? order.displayDeliveredAt : order.displayPlacedAt);

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
                dateLabel,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.navyMuted200,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dateValue,
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
            separatorBuilder: (context, index) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final item = order.items[index];
              final itemImg = item.image ?? order.fullRestaurantImage;
              return Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: itemImg != null && itemImg.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: itemImg,
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
                          item.name,
                          style: const TextStyle(
                            fontFamily: 'Fonts/Paragraph',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.lightSurfaceDarkText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.modifiers.isNotEmpty
                              ? '${item.modifiers.join(', ')} x${item.quantity}'
                              : 'Qty x${item.quantity}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.lightSurfaceSubtitle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    AppUtils.formatCurrency(item.subtotal > 0 ? item.subtotal : (item.price * item.quantity)),
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

  Widget _buildSpecialInstructionsCard(String instructions) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.note_alt_outlined, size: 20, color: AppColors.navyMuted200),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Special Instructions',
                  style: TextStyle(
                    fontFamily: 'Fonts/Paragraph',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightSurfaceDarkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  instructions,
                  style: const TextStyle(
                    fontFamily: 'Fonts/Paragraph',
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: AppColors.navyMuted200,
                  ),
                ),
              ],
            ),
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
              const _StaticStars(rating: 0, size: 18),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPartnerRatingCard(OrderModel order) {
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
          const SizedBox(height: 10),
          _StaticStars(
            rating: order.driverRating ?? 0.0,
            size: 26,
            spacing: 6,
          ),
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
          _buildPaymentRow('Item Total', AppUtils.formatCurrency(subtotal)),
          const SizedBox(height: 12),
          _buildPaymentRow('Delivery Fee', AppUtils.formatCurrency(order.deliveryFee)),
          if (order.vatAmount > 0) ...[
            const SizedBox(height: 12),
            _buildPaymentRow('Taxes & Charges (VAT)', AppUtils.formatCurrency(order.vatAmount)),
          ],
          if (order.discountAmount > 0) ...[
            const SizedBox(height: 12),
            _buildPaymentRow('Discount', '-${AppUtils.formatCurrency(order.discountAmount)}'),
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
                AppUtils.formatCurrency(order.totalAmount),
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

class _StaticStars extends StatelessWidget {
  final double rating;
  final double size;
  final double spacing;

  const _StaticStars({
    required this.rating,
    this.size = 18,
    this.spacing = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final isFilled = index < rating;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing / 2),
          child: Icon(
            isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
            size: size,
            color: isFilled ? const Color(0xFFFBBF24) : const Color(0xFFCBD5E1),
          ),
        );
      }),
    );
  }
}

