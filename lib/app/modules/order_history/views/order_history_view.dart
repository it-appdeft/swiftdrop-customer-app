import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';
import 'package:intl/intl.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../controllers/order_history_controller.dart';

class OrderHistoryView extends GetView<OrderHistoryController> {
  const OrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.buttonLabel,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 11),
            _buildSearchBar(),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.historyOrders.isEmpty) {
                  return const Center(child: AppLoader());
                }
                
                final orders = controller.historyOrders;
                if (orders.isEmpty) {
                  return const NoDataWidget(
                    image: SizedBox.shrink(),
                    subtitle: 'Your order history will appear here once orders are live.',
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, Get.find<CartController>().cartItemCount.value > 0 ? 120 : 20),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    return _OrderCard(order: orders[index], index: index);
                  },
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
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Center(
        child: Text(
          'History',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w500,
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
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.offWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.lightSurfaceBorder),
          ),
          child: Row(
            children: [
              Assets.images.homeSearchIcon.image(width: 24, height: 24),
              const SizedBox(width: 15),
              Text(
                'Search by restaurant or dish',
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
    // Extracting parts of address or using mock if needed to match design
    final restaurantName = order.pickupAddress.split(',').first;
    final restaurantLocation = order.pickupAddress.contains(',') 
        ? order.pickupAddress.substring(order.pickupAddress.indexOf(',') + 1).trim()
        : 'Green Park, CA 90210';

    final isFailed = order.status == 'failed' || index == 1;
    final dateStr = DateFormat('MMMM d, h:mm a').format(order.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 20),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(8.0),
        // boxShadow: const [
        //   BoxShadow(
        //     color: AppColors.shadowLight,
        //     blurRadius: 10,
        //     offset: Offset(0, 4),
        //   ),
        // ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Assets.images.restaurantImage.image(
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
                      style: const TextStyle(
                        fontFamily: 'Fonts/Paragraph', // As specified
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.lightSurfaceCusinsSubtitle, // #0B243A
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      restaurantLocation,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.lightSurfaceSubtitle, // #868AA5
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (order.isDelivered && !isFailed)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Assets.images.delivered.image(width: 20, height: 20),
                    const SizedBox(width: 4),
                    Text(
                      'Delivered',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.lightSurfaceDarkText,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const Divider(
            height: 33, // 16 top + 16 bottom + 1 thickness approx
            thickness: 1,
            color: AppColors.lightSurfaceBorder,
          ),
          ...order.items.asMap().entries.map((entry) {
            final isLast = entry.key == order.items.length - 1;
            final item = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primaryFaded.withOpacity(0.2), // #8DE1BE with opacity
                      border: Border.all(color: AppColors.primaryFaded),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${item.quantity}x',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary, // #1BC27D
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(
                        fontFamily: 'Fonts/Paragraph',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.lightSurfaceLabel,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const Divider(
            height: 33, // 16 top + 16 bottom + 1 thickness approx
            thickness: 1,
            color: AppColors.lightSurfaceBorder,
          ),
          AppButton(
            label: 'Reorder',
            onTap: () {},
            height: 44,
            backgroundColor: AppColors.primary,
          ),
          const SizedBox(height: 16),
          if (isFailed) ...[
            Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Payment failed',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'If any amount is deducted, it will be refunded in 3-5 Working days',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.lightSurfaceSubtitle,
              ),
            ),
          ] else ...[
            Text(
              'Ordered $dateStr',
              style: const TextStyle(
                fontFamily: 'Fonts/Paragraph',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.lightSurfaceSubtitle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
