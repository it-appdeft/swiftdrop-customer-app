import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_text_styles.dart';
import '../../../widgets/empty_state_widget.dart';
import '../controllers/order_history_controller.dart';

class OrderHistoryView extends GetView<OrderHistoryController> {
  const OrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: Text(
          'History',
          style: AppTextStyles.h6.copyWith(color: AppColors.lightSurfaceDarkText),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: const EmptyStateWidget(
        icon: Icons.receipt_long_outlined,
        message: 'Feature coming soon',
        subtitle: 'Your order history will appear here once orders are live.',
      ),
    );
  }
}
