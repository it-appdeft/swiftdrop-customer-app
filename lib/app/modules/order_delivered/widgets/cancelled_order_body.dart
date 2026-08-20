import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';

class CancelledOrFailedOrderBody extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onBackToHome;

  const CancelledOrFailedOrderBody({
    super.key,
    required this.order,
    required this.onBackToHome,
  });

  @override
  Widget build(BuildContext context) {
    final isFailed = order.status == 'failed' || order.status == 'payment_failed';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Red Status Banner
          _CancelledStatusBanner(order: order, isFailed: isFailed),
          const SizedBox(height: 14),

          // 2. Main Order Status Card (Figma Unified Card)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8E9ED)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Delivery Address Section
                _DeliveryAddressSection(address: order.deliveryAddress),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F5)),
                ),

                // Restaurant & Order ID & Items Section
                _RestaurantAndItemsSection(order: order, isFailed: isFailed),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F5)),
                ),

                // Reason for Cancellation Section
                _CancellationReasonSection(order: order, isFailed: isFailed),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F5)),
                ),

                // Total Paid & Payment Row Section
                _PaymentSummarySection(order: order),
                const SizedBox(height: 14),

                // Refund Information Banner
                _RefundInformationBanner(isFailed: isFailed),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F5)),
                ),

                // Go to Support Row
                const _GoToSupportRow(),
              ],
            ),
          ),

          const SizedBox(height: 20),
          _BackToHomeButton(onPressed: onBackToHome),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── SUB-COMPONENTS ──────────────────────────────────────────────────────────

class _CancelledStatusBanner extends StatelessWidget {
  final OrderModel order;
  final bool isFailed;
  const _CancelledStatusBanner({required this.order, required this.isFailed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFE53935),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isFailed ? AppStrings.orderFailed : AppStrings.orderCancelled,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE53935),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isFailed
                      ? AppStrings.paymentCouldNotBeProcessed
                      : AppStrings.orderCouldNotBeFulfilled,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFE53935).withValues(alpha: 0.85),
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

class _DeliveryAddressSection extends StatelessWidget {
  final String address;
  const _DeliveryAddressSection({required this.address});

  @override
  Widget build(BuildContext context) {
    final displayText = address.isNotEmpty
        ? address
        : 'Customer Location';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Assets.images.locationIcon.image(width: 22, height: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.deliveryAddress,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0B243A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                displayText,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF868AA5),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RestaurantAndItemsSection extends StatelessWidget {
  final OrderModel order;
  final bool isFailed;

  const _RestaurantAndItemsSection({
    required this.order,
    required this.isFailed,
  });

  @override
  Widget build(BuildContext context) {
    final restaurantName = order.displayRestaurantName;
    final restaurantAddress = order.restaurantAddressLine;
    final orderId = order.orderNumber.isNotEmpty ? order.orderNumber : order.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Restaurant Header Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: const Icon(
                Icons.storefront_outlined,
                size: 22,
                color: Color(0xFF0B243A),
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
                      color: const Color(0xFF0B243A),
                    ),
                  ),
                  if (restaurantAddress.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      restaurantAddress,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF868AA5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Red Cancelled Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFCDD2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE53935),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    isFailed ? 'Failed' : 'Cancelled',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFE53935),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Order ID Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.orderIdLabel,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF868AA5),
              ),
            ),
            Text(
              '#$orderId',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0B243A),
              ),
            ),
          ],
        ),

        // Items List
        if (order.items.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${item.quantity}x',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.name,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF70748E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item.subtotal > 0 || (item.price > 0)) ...[
                      const SizedBox(width: 8),
                      Text(
                        '£${(item.subtotal > 0 ? item.subtotal : (item.price * item.quantity)).toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF0B243A),
                        ),
                      ),
                    ],
                  ],
                ),
              )),
        ],
      ],
    );
  }
}

class _CancellationReasonSection extends StatelessWidget {
  final OrderModel order;
  final bool isFailed;
  const _CancellationReasonSection({required this.order, required this.isFailed});

  @override
  Widget build(BuildContext context) {
    final reasonText = order.effectiveCancellationReason.isNotEmpty
        ? order.effectiveCancellationReason
        : (isFailed ? 'Payment could not be processed' : 'Order was cancelled');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isFailed ? 'REASON FOR FAILURE' : 'REASON FOR CANCELLATION',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF868AA5),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFE53935),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                reasonText,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF868AA5),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PaymentSummarySection extends StatelessWidget {
  final OrderModel order;
  const _PaymentSummarySection({required this.order});

  @override
  Widget build(BuildContext context) {
    final amountText = order.totalAmount.toStringAsFixed(2);
    final paymentText = order.paymentMethod?.isNotEmpty == true
        ? order.paymentMethod!
        : '•••• 4412';

    return Row(
      children: [
        // Total Paid Column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.totalPaid,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF868AA5),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '£$amountText',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 1,
          height: 40,
          color: const Color(0xFFF0F0F5),
        ),
        const SizedBox(width: 16),
        // Payment Mode Column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.payment,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF868AA5),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.credit_card_rounded,
                    size: 18,
                    color: Color(0xFF0B243A),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      paymentText,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0B243A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RefundInformationBanner extends StatelessWidget {
  final bool isFailed;
  const _RefundInformationBanner({required this.isFailed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_rounded,
            color: Color(0xFFD97706),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isFailed
                  ? 'Refund will be processed in 3–5 days'
                  : 'Refund will be processed in 3–5 days',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFB45309),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoToSupportRow extends StatelessWidget {
  const _GoToSupportRow();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppUtils.haptic();
        Get.toNamed(AppRoutes.helpCenter);
      },
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Assets.images.goToSupport.image(width: 22, height: 22),
          const SizedBox(width: 12),
          Text(
            AppStrings.goToSupport,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF0B243A),
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: Color(0xFF868AA5),
          ),
        ],
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
      height: 48,
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
            borderRadius: BorderRadius.circular(10),
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
