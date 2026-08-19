import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../controllers/order_history_controller.dart';

class OrderHistoryView extends GetView<OrderHistoryController> {
  const OrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildSearchBar(),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.historyOrders.isEmpty) {
                  return const Center(child: AppLoader());
                }
                
                final orders = controller.historyOrders;
                if (orders.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () => controller.loadOrders(),
                    color: AppColors.primary,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: const NoDataWidget(
                          image: SizedBox.shrink(),
                          subtitle: 'Your order history will appear here once orders are live.',
                        ),
                      ),
                    ),
                  );
                }

                final dashboardController = Get.isRegistered<DashboardController>()
                    ? Get.find<DashboardController>()
                    : null;
                final hasCart = Get.find<CartController>().cartItemCount.value > 0;
                final hasActiveOrders = dashboardController != null &&
                    dashboardController.activeOrders.isNotEmpty;

                final double bottomPadding;
                if (hasCart && hasActiveOrders) {
                  bottomPadding = 270.0;
                } else if (hasActiveOrders) {
                  bottomPadding = 210.0;
                } else if (hasCart) {
                  bottomPadding = 180.0;
                } else {
                  bottomPadding = 140.0;
                }

                return RefreshIndicator(
                  onRefresh: () => controller.loadOrders(),
                  color: AppColors.primary,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      16,
                      0,
                      16,
                      bottomPadding,
                    ),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      return _OrderCard(order: orders[index], index: index);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Center(
        child: Text(
          AppStrings.orderHistory,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.lightSurfaceDarkText,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => Get.find<DashboardController>().changePage(1),
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.offWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightSurfaceBorder),
          ),
          child: Row(
            children: [
              Assets.images.homeSearchIcon.image(width: 20, height: 20),
              const SizedBox(width: 12),
              Text(
                'Search by restaurant or dish...',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.lightSurfaceSubtitle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final int index;
  const _OrderCard({required this.order, required this.index});

  @override
  Widget build(BuildContext context) {
    final restaurantName = order.displayRestaurantName;
    final restaurantLocation = order.restaurantAddressLine.isNotEmpty
        ? order.restaurantAddressLine
        : (order.pickupAddress.contains(',')
            ? order.pickupAddress.substring(order.pickupAddress.indexOf(',') + 1).trim()
            : '');

    final isFailed = order.status == 'failed' || order.status == 'payment_failed';
    final isCancelled = order.isCancelled;
    final effectiveOrder = order;

    final dateStr = order.displayPlacedAt;
    final imgUrl = order.fullRestaurantImage;

    return GestureDetector(
      onTap: () {
        AppUtils.haptic();
        if (effectiveOrder.isActive) {
          Get.toNamed(AppRoutes.orderTracking, arguments: {'orderId': effectiveOrder.id, 'order': effectiveOrder});
        } else {
          Get.toNamed(AppRoutes.orderDelivered, arguments: {'orderId': effectiveOrder.id, 'order': effectiveOrder});
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.p),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imgUrl != null && imgUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imgUrl,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Assets.images.restaurantImage.image(
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                          errorWidget: (context, url, error) => Assets.images.restaurantImage.image(
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Assets.images.restaurantImage.image(
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
                        restaurantName,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.lightSurfaceDarkText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        restaurantLocation,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.lightSurfaceSubtitle,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (order.isDelivered && !isFailed && !isCancelled)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Assets.images.delivered.image(width: 16, height: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Delivered',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (isFailed || isCancelled)
                  Container(
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
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.warning.withOpacity(0.4)),
                    ),
                    child: Text(
                      order.status.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.divider,
              ),
            ),
            ...order.items.asMap().entries.map((entry) {
              final isLast = entry.key == order.items.length - 1;
              final item = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
                child: Row(
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
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.lightSurfaceDarkText,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.divider,
              ),
            ),
            if (isFailed) ...[
              Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Payment failed',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'If any amount was deducted, it will be refunded in 3-5 working days.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.lightSurfaceSubtitle,
                ),
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ordered $dateStr',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.lightSurfaceSubtitle,
                    ),
                  ),
                  Text(
                    '₹${order.totalAmount.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.lightSurfaceDarkText,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
