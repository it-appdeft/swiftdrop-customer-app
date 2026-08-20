import 'package:swiftdrop_customer_app/export.dart';
import '../controllers/order_delivered_controller.dart';
import '../widgets/cancelled_order_body.dart';
import '../widgets/delivered_order_body.dart';

class OrderDeliveredView extends GetView<OrderDeliveredController> {
  const OrderDeliveredView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(() {
          final order = controller.order.value;
          final isCancelledOrFailed = order != null &&
              (order.isCancelled || order.status == 'failed' || order.status == 'payment_failed');

          if (isCancelledOrFailed) {
            return const _CancelledStatusAppBar();
          }
          return const SizedBox.shrink();
        }),
      ),
      body: Obx(() {
        if (controller.isLoadingDetail.value) {
          return _buildOrderDeliveredShimmer();
        }

        final order = controller.order.value;
        if (order == null) {
          return _buildOrderDeliveredShimmer();
        }

        final isCancelledOrFailed =
            (order.isCancelled || order.status == 'failed' || order.status == 'payment_failed');

        if (isCancelledOrFailed) {
          return CancelledOrFailedOrderBody(
            order: order,
            onBackToHome: controller.backToHome,
          );
        }

        return DeliveredOrderBody(
          order: order,
          controller: controller,
        );
      }),
    );
  }

  Widget _buildOrderDeliveredShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Banner Shimmer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.offWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.lightSurfaceBorder),
            ),
            child: Row(
              children: [
                AppShimmer.circle(size: 38),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppShimmer.text(width: 140, height: 16),
                      const SizedBox(height: 6),
                      AppShimmer.text(width: 200, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Address Card Shimmer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.offWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.lightSurfaceBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppShimmer.circle(size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppShimmer.text(width: 120, height: 14),
                      const SizedBox(height: 6),
                      AppShimmer.text(width: double.infinity, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Restaurant & Items Card Shimmer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.offWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.lightSurfaceBorder),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    AppShimmer.rect(width: 44, height: 44, radius: 8),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppShimmer.text(width: 150, height: 15),
                          const SizedBox(height: 6),
                          AppShimmer.text(width: 100, height: 12),
                        ],
                      ),
                    ),
                    AppShimmer.rect(width: 70, height: 24, radius: 12),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: AppColors.lightSurfaceBorder),
                ),
                ...List.generate(
                  2,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        AppShimmer.rect(width: 24, height: 24, radius: 6),
                        const SizedBox(width: 10),
                        Expanded(child: AppShimmer.text(width: double.infinity, height: 14)),
                        const SizedBox(width: 16),
                        AppShimmer.text(width: 50, height: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Payment Details Shimmer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.offWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.lightSurfaceBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppShimmer.text(width: 130, height: 15),
                const SizedBox(height: 14),
                AppShimmer.text(width: double.infinity, height: 13),
                const SizedBox(height: 8),
                AppShimmer.text(width: double.infinity, height: 13),
                const SizedBox(height: 8),
                AppShimmer.text(width: double.infinity, height: 13),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: AppColors.lightSurfaceBorder),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppShimmer.text(width: 80, height: 16),
                    AppShimmer.text(width: 70, height: 16),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppShimmer.rect(width: double.infinity, height: 52, radius: 12),
        ],
      ),
    );
  }
}

class _CancelledStatusAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _CancelledStatusAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.black, size: 20),
        onPressed: () => Get.back(),
      ),
      title: Text(
        AppStrings.orderStatus,
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.lightSurfaceDarkText,
        ),
      ),
    );
  }
}
