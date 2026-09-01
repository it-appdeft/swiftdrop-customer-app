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
                  return const OrderHistoryShimmer();
                }
                
                final orders = controller.filteredOrders;
                if (orders.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () => controller.loadOrders(),
                    color: AppColors.primary,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: NoDataWidget(
                          image: const SizedBox.shrink(),
                          subtitle: controller.searchQuery.value.isNotEmpty
                              ? 'No orders found matching "${controller.searchQuery.value}"'
                              : 'Your order history will appear here once orders are live.',
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
            Expanded(
              child: TextField(
                onChanged: (val) => controller.searchQuery.value = val,
                cursorColor: AppColors.primary,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.lightSurfaceDarkText,
                ),
                decoration: InputDecoration(
                  isCollapsed: true,
                  filled: false,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  hintText: 'Search by restaurant or dish',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.lightSurfaceSubtitle,
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            Obx(() {
              if (controller.searchQuery.value.isNotEmpty) {
                return GestureDetector(
                  onTap: () {
                    AppUtils.haptic();
                    controller.searchQuery.value = '';
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.lightSurfaceBorder,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: AppColors.lightSurfaceDarkText,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
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
            : (order.pickupAddress != 'Restaurant' ? order.pickupAddress : ''));

    final isFailed = order.status == 'failed' || order.status == 'payment_failed';
    final isCancelled = order.isCancelled;
    final effectiveOrder = order;

    final dateStr = order.displayPlacedAt;
    final imgUrl = order.fullRestaurantImage;

    return GestureDetector(
      onTap: () {
        AppUtils.haptic();
        if (effectiveOrder.isActive) {
          Get.toNamed(AppRoutes.orderTracking, arguments: {
            'id': effectiveOrder.id,
            'orderId': effectiveOrder.id,
            'orderUuid': effectiveOrder.uuid ?? effectiveOrder.targetId,
            'order': effectiveOrder,
          });
        } else {
          Get.toNamed(AppRoutes.orderDetails, arguments: {
            'id': effectiveOrder.id,
            'orderId': effectiveOrder.id,
            'orderUuid': effectiveOrder.uuid,
            'order': effectiveOrder,
          });
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.p),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFF0F0F5)),
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
            // Restaurant Header Row
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
                          color: const Color(0xFF0B243A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (restaurantLocation.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          restaurantLocation,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF868AA5),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (order.isDelivered && !isFailed && !isCancelled)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, size: 18, color: Color(0xFF00B36F)),
                      const SizedBox(width: 4),
                      Text(
                        'Delivered',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF0B243A),
                        ),
                      ),
                    ],
                  )
                else if (isFailed || isCancelled)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cancel, size: 18, color: Color(0xFFD94D52)),
                      const SizedBox(width: 4),
                      Text(
                        isFailed ? 'Failed' : 'Cancelled',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFD94D52),
                        ),
                      ),
                    ],
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.status.replaceAll('_', ' ').capitalizeFirst ?? order.status,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
            
            if (order.items.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFF3F3F7),
                ),
              ),
              // Items List
              ...order.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
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
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF70748E),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.subtotal > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          AppUtils.formatCurrency(item.subtotal),
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF0B243A),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ],
            // Reorder button on history card is commented out; reordering is accessible via Order Details
            /*
            if (order.isDelivered && !isCancelled && !isFailed) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  AppUtils.haptic();
                  if (Get.isRegistered<CartController>()) {
                    Get.find<CartController>().reorderFromOrder(effectiveOrder);
                  } else {
                    final cart = Get.put(CartController());
                    cart.reorderFromOrder(effectiveOrder);
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Reorder',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ] else */
            if (effectiveOrder.isActive) ...[
              const SizedBox(height: 12),
              // Track Order Button (For active orders)
              GestureDetector(
                onTap: () {
                  AppUtils.haptic();
                  Get.toNamed(
                    AppRoutes.orderTracking,
                    arguments: {
                      'orderId': effectiveOrder.id.isNotEmpty ? effectiveOrder.id : effectiveOrder.targetId,
                      'id': effectiveOrder.id.isNotEmpty ? effectiveOrder.id : effectiveOrder.targetId,
                      'orderUuid': effectiveOrder.uuid,
                      'order': effectiveOrder,
                    },
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Track Order',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],

            // Footer note / Date
            const SizedBox(height: 12),
            if (isFailed) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.error_outline, color: Color(0xFFD94D52), size: 16),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment failed',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFD94D52),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'If any amount is deducted, it will be refunded in 3-5 Working days',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF868AA5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (order.totalAmount > 0)
                    Text(
                      AppUtils.formatCurrency(order.totalAmount),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0B243A),
                      ),
                    ),
                ],
              ),
            ] else if (isCancelled) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      order.cancellationReason != null && order.cancellationReason!.trim().isNotEmpty
                          ? 'Cancelled • ${order.cancellationReason!.trim()}'
                          : 'Cancelled on $dateStr',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF868AA5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (order.totalAmount > 0)
                    Text(
                      AppUtils.formatCurrency(order.totalAmount),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0B243A),
                      ),
                    ),
                ],
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
                      color: const Color(0xFF868AA5),
                    ),
                  ),
                  if (order.totalAmount > 0)
                    Text(
                      AppUtils.formatCurrency(order.totalAmount),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0B243A),
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
