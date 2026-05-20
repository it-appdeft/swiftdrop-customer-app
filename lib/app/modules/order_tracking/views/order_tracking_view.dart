import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_decorations.dart';
import '../../../themes/app_dimensions.dart';
import '../../../themes/app_radius.dart';
import '../../../themes/app_text_styles.dart';
import '../../../utils/app_utils.dart';
import '../../../utils/responsive.dart';
import '../../../widgets/app_loader.dart';
import '../../../widgets/error_state_widget.dart';
import '../../../widgets/info_row.dart';
import '../../../widgets/status_badge.dart';
import '../controllers/order_tracking_controller.dart';

class OrderTrackingView extends GetView<OrderTrackingController> {
  const OrderTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text('Track Order', style: AppTextStyles.h6),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
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

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatusBanner(status: order.status),
              const SizedBox(height: AppDimensions.gapLg),
              _MapPlaceholder(),
              const SizedBox(height: AppDimensions.gapLg),
              _OrderDetails(order: order),
            ],
          ),
        );
      }),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String status;

  const _StatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: AppDecorations.card,
      child: Row(
        children: [
          const Icon(Icons.delivery_dining, size: 32, color: AppColors.primary),
          const SizedBox(width: AppDimensions.gapMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order Status', style: AppTextStyles.pSmall.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                StatusBadge(status: status),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: Responsive.hpc(context, 28),
      decoration: AppDecorations.card,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map_outlined, size: 40, color: AppColors.textHint),
            const SizedBox(height: AppDimensions.gapSm),
            Text(
              'Live tracking map',
              style: AppTextStyles.pSmall.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderDetails extends StatelessWidget {
  final dynamic order;

  const _OrderDetails({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Details', style: AppTextStyles.pMediumSemiBold),
          const SizedBox(height: AppDimensions.gapMd),
          InfoRow(label: 'Order #', value: order.orderNumber),
          InfoRow(label: 'Pickup', value: order.pickupAddress, isLast: false),
          InfoRow(label: 'Delivery', value: order.deliveryAddress, isLast: false),
          InfoRow(
            label: 'Total',
            value: AppUtils.formatCurrency(order.totalAmount),
            valueColor: AppColors.success,
            isLast: true,
          ),
        ],
      ),
    );
  }
}
