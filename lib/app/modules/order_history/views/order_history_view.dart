import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_decorations.dart';
import '../../../themes/app_dimensions.dart';
import '../../../themes/app_text_styles.dart';
import '../../../utils/app_utils.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/error_state_widget.dart';
import '../../../widgets/shimmer_widgets.dart';
import '../../../widgets/status_badge.dart';
import '../../../../data/models/order_model.dart';
import '../controllers/order_history_controller.dart';

class OrderHistoryView extends GetView<OrderHistoryController> {
  const OrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text('My Orders', style: AppTextStyles.h6),
        automaticallyImplyLeading: false,
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              tabs: [
                Obx(() => Tab(text: 'Active (${controller.activeOrders.length})')),
                const Tab(text: 'History'),
              ],
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) return const ShimmerList();
                if (controller.hasError.value) {
                  return ErrorStateWidget(
                    message: controller.errorMessage.value,
                    onRetry: controller.loadOrders,
                  );
                }
                return TabBarView(
                  children: [
                    _OrderList(orders: controller.activeOrders),
                    _OrderList(orders: controller.historyOrders),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final RxList<OrderModel> orders;

  const _OrderList({required this.orders});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (orders.isEmpty) {
        return const EmptyStateWidget(
          message: 'No orders yet',
          subtitle: 'Your orders will appear here',
          icon: Icons.receipt_long_outlined,
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        itemCount: orders.length,
        itemBuilder: (_, index) => _OrderCard(order: orders[index]),
      );
    });
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.gapMd),
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('#${order.orderNumber}', style: AppTextStyles.pSmallSemiBold),
              StatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: AppDimensions.gapSm),
          Text(
            order.pickupAddress,
            style: AppTextStyles.pXSmall.copyWith(color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimensions.gapXs),
          Row(
            children: [
              const Icon(Icons.arrow_downward, size: 12, color: AppColors.primary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  order.deliveryAddress,
                  style: AppTextStyles.pXSmall.copyWith(color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Divider(height: AppDimensions.gapLg, color: AppColors.darkBorder),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${order.items.length} item${order.items.length != 1 ? 's' : ''}',
                style: AppTextStyles.pXSmall.copyWith(color: AppColors.textSecondary),
              ),
              Text(
                AppUtils.formatCurrency(order.totalAmount),
                style: AppTextStyles.pSmallSemiBold.copyWith(color: AppColors.success),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
