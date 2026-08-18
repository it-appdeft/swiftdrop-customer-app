import 'package:swiftdrop_customer_app/export.dart';
import 'package:swiftdrop_customer_app/generated/assets.dart';
import '../modules/dashboard/controllers/dashboard_controller.dart';

class ActiveOrdersFloatingBar extends StatefulWidget {
  const ActiveOrdersFloatingBar({super.key});

  @override
  State<ActiveOrdersFloatingBar> createState() => _ActiveOrdersFloatingBarState();
}

class _ActiveOrdersFloatingBarState extends State<ActiveOrdersFloatingBar> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return Obx(() {
      final orders = controller.activeOrders;
      if (orders.isEmpty) return const SizedBox.shrink();

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 76,
            child: PageView.builder(
              controller: _pageController,
              itemCount: orders.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildOrderCard(orders[index]),
                );
              },
            ),
          ),
          if (orders.length > 1) ...[
            const SizedBox(height: 8),
            _buildPageIndicator(orders.length),
          ],
        ],
      );
    });
  }

  int _calculateRemainingMinutes(OrderModel order) {
    final totalEst = order.estimatedTime > 0 ? order.estimatedTime : 25;
    final elapsedMinutes = DateTime.now().difference(order.createdAt).inMinutes;
    final remaining = totalEst - elapsedMinutes;
    return remaining.clamp(1, totalEst);
  }

  Widget _buildOrderCard(OrderModel order) {
    final restaurantName = order.displayRestaurantName;
    final remainingMinutes = _calculateRemainingMinutes(order);

    return GestureDetector(
      onTap: () {
        AppUtils.haptic();
        Get.toNamed(AppRoutes.orderTracking, arguments: {'orderId': order.id});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Delivery Bike Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delivery_dining_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // Order Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    restaurantName,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getStatusText(order.status),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Time Indicator Button
            Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$remainingMinutes min',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightOtpBoxBg, // Light grey background
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) {
          return Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentPage == index
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.2),
            ),
          );
        }),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'placed':
      case 'pending':
        return 'Order Placed';
      case 'accepted':
      case 'confirmed':
      case 'preparing':
        return 'Preparing your order';
      case 'picked_up':
      case 'out_for_delivery':
      case 'on_the_way':
        return 'Order on the way';
      default:
        return 'Order in progress';
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
