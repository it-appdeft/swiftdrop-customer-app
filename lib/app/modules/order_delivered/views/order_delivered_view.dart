import 'package:swiftdrop_customer_app/export.dart';
import '../controllers/order_delivered_controller.dart';
import '../widgets/cancelled_order_body.dart';
import '../widgets/delivered_order_body.dart';

class OrderDeliveredView extends GetView<OrderDeliveredController> {
  const OrderDeliveredView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        controller.handleBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Obx(() {
            if (controller.isSubmitted.value) {
              return const SizedBox.shrink();
            }

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
          if (controller.isSubmitted.value) {
            return _FeedbackThankYouBody(controller: controller);
          }

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
      ),
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

class _FeedbackThankYouBody extends StatelessWidget {
  final OrderDeliveredController controller;
  const _FeedbackThankYouBody({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const Spacer(flex: 2),
            Center(
              child: _FeedbackSuccessIllustration(),
            ),
            const SizedBox(height: 32),
            Text(
              'Thank You For Your Feedback!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0B243A),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your rating helps us improve the delivery experience for everyone.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF868AA5),
                height: 1.45,
              ),
            ),
            const Spacer(flex: 3),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: controller.backToHome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Done',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _FeedbackSuccessIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 180,
      child: CustomPaint(
        painter: _DeliveryHandoffPainter(),
      ),
    );
  }
}

class _DeliveryHandoffPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Delivery Courier (Left)
    final backpackPaint = Paint()..color = const Color(0xFF10B981);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.15, h * 0.22, w * 0.18, h * 0.32), const Radius.circular(8)),
      backpackPaint,
    );

    final courierJacket = Paint()..color = const Color(0xFF059669);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.26, h * 0.24, w * 0.16, h * 0.34), const Radius.circular(6)),
      courierJacket,
    );

    final skinPaint = Paint()..color = const Color(0xFFFDBA74);
    canvas.drawCircle(Offset(w * 0.34, h * 0.16), w * 0.065, skinPaint);
    final capPaint = Paint()..color = const Color(0xFF047857);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * 0.34, h * 0.14), radius: w * 0.07),
      3.14,
      3.14,
      true,
      capPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.34, h * 0.13, w * 0.08, h * 0.025), const Radius.circular(2)),
      capPaint,
    );

    final pantsPaint1 = Paint()..color = const Color(0xFF334155);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.27, h * 0.58, w * 0.06, h * 0.32), const Radius.circular(3)),
      pantsPaint1,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.35, h * 0.58, w * 0.06, h * 0.32), const Radius.circular(3)),
      pantsPaint1,
    );

    final shoePaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.25, h * 0.88, w * 0.08, h * 0.04), const Radius.circular(4)),
      shoePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.34, h * 0.88, w * 0.08, h * 0.04), const Radius.circular(4)),
      shoePaint,
    );

    // Customer (Right)
    canvas.drawCircle(Offset(w * 0.68, h * 0.15), w * 0.065, skinPaint);
    final hairPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * 0.68, h * 0.14), radius: w * 0.07),
      3.14,
      3.14,
      true,
      hairPaint,
    );

    final shirtPaint = Paint()..color = const Color(0xFFF59E0B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.60, h * 0.23, w * 0.16, h * 0.35), const Radius.circular(6)),
      shirtPaint,
    );

    final pantsPaint2 = Paint()..color = const Color(0xFF1E3A8A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.61, h * 0.58, w * 0.065, h * 0.32), const Radius.circular(3)),
      pantsPaint2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.69, h * 0.58, w * 0.065, h * 0.32), const Radius.circular(3)),
      pantsPaint2,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.60, h * 0.88, w * 0.08, h * 0.04), const Radius.circular(4)),
      shoePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.68, h * 0.88, w * 0.08, h * 0.04), const Radius.circular(4)),
      shoePaint,
    );

    final phonePaint = Paint()..color = const Color(0xFF0284C7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.53, h * 0.32, w * 0.04, h * 0.07), const Radius.circular(2)),
      phonePaint,
    );

    final bagPaint = Paint()..color = const Color(0xFFD97706).withValues(alpha: 0.85);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.44, h * 0.66, w * 0.12, h * 0.24), const Radius.circular(4)),
      bagPaint,
    );
    final handlePaint = Paint()
      ..color = const Color(0xFFB45309)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.50, h * 0.66), width: w * 0.06, height: h * 0.08),
      3.14,
      3.14,
      false,
      handlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
