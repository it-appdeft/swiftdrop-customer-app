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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CancelledStatusBanner(isFailed: isFailed),
          const SizedBox(height: 16),
          _DeliveryAddressCard(address: order.deliveryAddress),
          const SizedBox(height: 16),
          _RestaurantOrderDetailsCard(order: order, isFailed: isFailed),
          const SizedBox(height: 16),
          _CancellationReasonCard(isFailed: isFailed),
          const SizedBox(height: 16),
          _PaymentSummaryRow(totalAmount: order.totalAmount),
          const SizedBox(height: 16),
          _RefundInformationBanner(isFailed: isFailed),
          const SizedBox(height: 16),
          const _GoToSupportCard(),
          const SizedBox(height: 24),
          _BackToHomeButton(onPressed: onBackToHome),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── SUB-COMPONENTS ──────────────────────────────────────────────────────────

class _CancelledStatusBanner extends StatelessWidget {
  final bool isFailed;
  const _CancelledStatusBanner({required this.isFailed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.error,
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
                    color: AppColors.error,
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
}

class _DeliveryAddressCard extends StatelessWidget {
  final String address;
  const _DeliveryAddressCard({required this.address});

  @override
  Widget build(BuildContext context) {
    final displayText = address.isNotEmpty
        ? address
        : '4521 Emerald Valley, Block B, Suite 104, Green Park, CA 90210';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightSurfaceBorder),
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
                  AppStrings.deliveryAddress,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightSurfaceDarkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayText,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.lightSurfaceSubtitle,
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

class _RestaurantOrderDetailsCard extends StatelessWidget {
  final OrderModel order;
  final bool isFailed;

  const _RestaurantOrderDetailsCard({
    required this.order,
    required this.isFailed,
  });

  @override
  Widget build(BuildContext context) {
    final restaurantName = order.pickupAddress.isNotEmpty
        ? order.pickupAddress.split(',').first.trim()
        : 'The Marble Grill';
    final restaurantAddress = order.pickupAddress.contains(',')
        ? order.pickupAddress.substring(order.pickupAddress.indexOf(',') + 1).trim()
        : 'West Coker, Yelovil, UK';
    final orderId = order.orderNumber.isNotEmpty ? order.orderNumber : order.id;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightSurfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.lightSurfaceBorder),
                ),
                child: const Icon(
                  Icons.storefront_outlined,
                  size: 20,
                  color: AppColors.lightSurfaceDarkText,
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
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightSurfaceDarkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      restaurantAddress,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.lightSurfaceSubtitle,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadgePill(isFailed: isFailed),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 1, color: AppColors.divider),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.orderIdLabel,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.lightSurfaceSubtitle,
                ),
              ),
              Text(
                '#$orderId',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.lightSurfaceDarkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (order.items.isEmpty) ...[
            const _OrderItemRow(name: 'Margherita Pizza Giant Slice', quantity: 1, price: 8.23),
            const SizedBox(height: 10),
            const _OrderItemRow(name: 'Sweet Corn Pizza Regular', quantity: 1, price: 8.02),
          ] else ...[
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _OrderItemRow(
                    name: item.name,
                    quantity: item.quantity,
                    price: item.price,
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

class _StatusBadgePill extends StatelessWidget {
  final bool isFailed;
  const _StatusBadgePill({required this.isFailed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            isFailed ? 'Failed' : 'Cancelled',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  final String name;
  final int quantity;
  final double price;

  const _OrderItemRow({
    required this.name,
    required this.quantity,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${quantity}x',
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
            name,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.lightSurfaceDarkText,
            ),
          ),
        ),
        Text(
          '£${price.toStringAsFixed(2)}',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.lightSurfaceDarkText,
          ),
        ),
      ],
    );
  }
}

class _CancellationReasonCard extends StatelessWidget {
  final bool isFailed;
  const _CancellationReasonCard({required this.isFailed});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isFailed ? AppStrings.reasonForFailure : AppStrings.reasonForCancellation,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.lightSurfaceDarkText.withOpacity(0.7),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.offWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightSurfaceBorder),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isFailed
                      ? AppStrings.paymentFailedReason
                      : AppStrings.restaurantUnavailableReason,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.lightSurfaceSubtitle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentSummaryRow extends StatelessWidget {
  final double totalAmount;
  const _PaymentSummaryRow({required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    final amountText = totalAmount > 0 ? totalAmount.toStringAsFixed(2) : '23.90';

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.offWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.lightSurfaceBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.totalPaid,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.lightSurfaceSubtitle,
                  ),
                ),
                const SizedBox(height: 6),
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
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.offWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.lightSurfaceBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.payment,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.lightSurfaceSubtitle,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.credit_card_rounded,
                      size: 18,
                      color: AppColors.lightSurfaceDarkText,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '•••• 4412',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightSurfaceDarkText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_rounded,
            color: Color(0xFFD97706),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isFailed
                  ? AppStrings.refundFailedNotice
                  : AppStrings.refundProcessedNotice,
              style: GoogleFonts.inter(
                fontSize: 13,
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

class _GoToSupportCard extends StatelessWidget {
  const _GoToSupportCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppUtils.haptic();
        AppUtils.showSuccess('Support team connected');
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
