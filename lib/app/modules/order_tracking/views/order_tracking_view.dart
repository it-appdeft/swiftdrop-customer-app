import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_dimensions.dart';
import '../../../themes/app_radius.dart';
import '../../../themes/app_text_styles.dart';
import '../../../utils/app_utils.dart';
import '../../../widgets/app_loader.dart';
import '../../../widgets/error_state_widget.dart';
import '../controllers/order_tracking_controller.dart';

class OrderTrackingView extends GetView<OrderTrackingController> {
  const OrderTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value) return const AppLoader();
        if (controller.hasError.value) {
          return ErrorStateWidget(
            message: controller.errorMessage.value,
            onRetry: () => controller.loadOrder(
              Get.parameters['orderId'] ?? Get.arguments?['orderId'] ?? '',
            ),
          );
        }

        final order = controller.order.value;
        if (order == null) return const AppLoader();

        // Extract restaurant name/address from pickupAddress
        final parts = order.pickupAddress.split(',');
        final restaurantName = parts.first.trim();
        final restaurantAddress = parts.length > 1 ? parts.sublist(1).join(',').trim() : '';

        return Column(
          children: [
            _Header(order: order, restaurantName: restaurantName, forceStatus: 'picked_up'),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _MapSection(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _DeliveryCodeSection(code: '5236'),
                          const SizedBox(height: 16),
                          _DeliveryPartnerSection(
                            isAssigning: false,
                            partnerName: 'James Bride',
                            partnerStats: '230 Order delivered',
                            rating: 4.8,
                          ),
                          const SizedBox(height: 16),
                          _DeliveryAddressCard(address: order.deliveryAddress),
                          const SizedBox(height: 16),
                          _OrderDetailsCard(
                            restaurantName: restaurantName,
                            restaurantAddress: restaurantAddress,
                            orderNumber: order.orderNumber,
                            items: order.items,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _SummaryCard(
                                  label: 'Total Paid',
                                  value: AppUtils.formatCurrency(order.totalAmount),
                                  valueColor: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: _SummaryCard(
                                  label: 'Payment',
                                  value: '•••• 4412',
                                  icon: Icons.credit_card,
                                  isPayment: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _SupportButton(),
                          const SizedBox(height: 24),
                          _CancelButton(order: order),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _Header extends StatelessWidget {
  final dynamic order;
  final String restaurantName;
  final String? forceStatus;

  const _Header({required this.order, required this.restaurantName, this.forceStatus});

  @override
  Widget build(BuildContext context) {
    String statusTitle = 'Order Placed';
    String statusSubtitle = 'Food preparation will begin shortly';
    double progress = 0.2;

    switch (forceStatus?.toLowerCase() ?? order.status.toLowerCase()) {
      case 'pending':
        statusTitle = 'Awaiting Confirmation';
        statusSubtitle = '';
        progress = 0.1;
        break;
      case 'accepted':
        statusTitle = 'Order placed';
        statusSubtitle = 'Food preparation will begin shortly';
        progress = 0.2;
        break;
      case 'preparing':
        statusTitle = 'Order placed';
        statusSubtitle = 'Arriving in ${order.estimatedTime} mins';
        progress = 0.4;
        break;
      case 'picked_up':
        statusTitle = 'Out For Delivery';
        statusSubtitle = 'Arriving in ${order.estimatedTime} mins';
        progress = 0.8;
        break;
      case 'delivered':
        statusTitle = 'Order Delivered';
        statusSubtitle = 'Enjoy your meal!';
        progress = 1.0;
        break;
      case 'cancelled':
        statusTitle = 'Order Cancelled';
        statusSubtitle = 'Your request has been processed';
        progress = 1.0;
        break;
    }

    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 10,
        16,
        20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                behavior: HitTestBehavior.opaque,
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              ),
              Expanded(
                child: Text(
                  restaurantName,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 20), // To balance the back button
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusTitle,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (statusSubtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        statusSubtitle,
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Get.find<OrderTrackingController>().loadOrder(order.id),
                child: Assets.images.reloadButton.image(width: 36, height: 36),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Stack(
            children: [
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
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

class _MapSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      width: double.infinity,
      color: Colors.grey[200],
      child: Assets.images.dummyMapImage.image(
        fit: BoxFit.cover,
        width: double.infinity,
      ),
    );
  }
}

class _DeliveryCodeSection extends StatelessWidget {
  final String code;

  const _DeliveryCodeSection({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Delivery Code',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF0B243A),
            ),
          ),
          Row(
            children: code.split('').map((digit) {
              return Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFE1E2E3)),
                ),
                child: Text(
                  digit,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF868AA5),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _DeliveryPartnerSection extends StatelessWidget {
  final bool isAssigning;
  final String? partnerName;
  final String? partnerStats;
  final double? rating;

  const _DeliveryPartnerSection({
    this.isAssigning = true,
    this.partnerName,
    this.partnerStats,
    this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: isAssigning
          ? Row(
              children: [
                Assets.images.assigningPartner.image(width: 48, height: 48),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Assigning a delivery partner...',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF0B243A),
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=james'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        partnerName ?? '',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0B243A),
                        ),
                      ),
                      Text(
                        partnerStats ?? '',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF868AA5),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        rating?.toString() ?? '0.0',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF0B243A),
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

class _DeliveryAddressCard extends StatelessWidget {
  final String address;

  const _DeliveryAddressCard({required this.address});

  @override
  Widget build(BuildContext context) {
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
                  'Delivery Address',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF0B243A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address,
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
}

class _OrderDetailsCard extends StatelessWidget {
  final String restaurantName;
  final String restaurantAddress;
  final String orderNumber;
  final List<dynamic> items;

  const _OrderDetailsCard({
    required this.restaurantName,
    required this.restaurantAddress,
    required this.orderNumber,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Assets.images.storeImage.image(width: 24, height: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurantName,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF0B243A),
                      ),
                    ),
                    Text(
                      restaurantAddress,
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
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: Color(0xFFE1E2E3)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order ID',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              Text(
                '#$orderNumber',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0B243A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == items.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '${item.quantity}x',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.name,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF868AA5),
                      ),
                    ),
                  ),
                  Text(
                    AppUtils.formatCurrency(item.price),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF0B243A),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final IconData? icon;
  final bool isPayment;

  const _SummaryCard({
    required this.label,
    required this.value,
    this.valueColor,
    this.icon,
    this.isPayment = false,
  });

  @override
  Widget build(BuildContext context) {
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
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF868AA5),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: isPayment ? 16 : 20,
                  color: const Color(0xFF0B243A),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: isPayment ? 14 : 18,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? const Color(0xFF0B243A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SupportButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
              fontWeight: FontWeight.w500,
              color: const Color(0xFF0B243A),
                ),
          ),
          const Spacer(),
          Assets.images.rightArrow.image(width: 24, height: 24),
        ],
      ),
    );
  }
}

class _CancelButton extends GetView<OrderTrackingController> {
  final dynamic order;

  const _CancelButton({required this.order});

  @override
  Widget build(BuildContext context) {
    // Show cancel button only if order is pending
    if (order.status.toLowerCase() != 'pending') {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showCancellationDialog(context, order.id),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFDC3545),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          'Cancel Order',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showCancellationDialog(BuildContext context, String orderId) {
    String selectedReason = 'Ordered by mistake';
    final reasons = [
      'Ordered by mistake',
      'Want to change items',
      'Delivery time too long',
      'Found a better option',
      'Other',
    ];

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Cancel This Order?',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0B243A),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  "You'll receive a full refund because the restaurant has not started preparing your food yet.",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF868AA5),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ...reasons.map((reason) {
                  final isSelected = selectedReason == reason;
                  return GestureDetector(
                    onTap: () => setSheetState(() => selectedReason = reason),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              reason,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF0B243A),
                              ),
                            ),
                          ),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? AppColors.primary : const Color(0xFFE1E2E3),
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? Center(
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back(); // Close reason sheet
                     // _showProcessingSheet(context, orderId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD94D52),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Cancel Order',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    'Keep order',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  void _showProcessingSheet(BuildContext context, String orderId) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: const Icon(
                Icons.close,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Cancelling Your Order...',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0B243A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Please wait while we process your request. We are notifying the kitchen to stop your preparation.',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF868AA5),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      isDismissible: false,
      enableDrag: false,
    );
    controller.cancelOrder(orderId);
  }
}
