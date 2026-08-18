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
        final order = controller.order.value;
        final isCancelledOrFailed = order != null &&
            (order.isCancelled || order.status == 'failed' || order.status == 'payment_failed');

        if (isCancelledOrFailed) {
          return CancelledOrFailedOrderBody(
            order: order!,
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
