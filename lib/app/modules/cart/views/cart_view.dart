import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_decorations.dart';
import '../../../themes/app_dimensions.dart';
import '../../../themes/app_radius.dart';
import '../../../themes/app_text_styles.dart';
import '../../../utils/app_utils.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/empty_state_widget.dart';
import '../controllers/cart_controller.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text('Cart', style: AppTextStyles.h6),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.items.isEmpty) {
          return const EmptyStateWidget(
            message: 'Your cart is empty',
            subtitle: 'Add items from a restaurant to get started',
            icon: Icons.shopping_cart_outlined,
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppDimensions.paddingMd),
                itemCount: controller.items.length,
                itemBuilder: (_, index) {
                  final item = controller.items[index];
                  return _CartItemTile(item: item);
                },
              ),
            ),
            _OrderSummary(),
          ],
        );
      }),
    );
  }
}

class _CartItemTile extends GetView<CartController> {
  final CartItem item;

  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.gapSm),
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: AppDecorations.card,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: AppTextStyles.pSmallSemiBold),
                const SizedBox(height: 4),
                Text(
                  AppUtils.formatCurrency(item.price),
                  style: AppTextStyles.pXSmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Obx(() => Row(
                children: [
                  _QuantityButton(
                    icon: Icons.remove,
                    onTap: () => controller.decrementItem(item.id),
                  ),
                  SizedBox(
                    width: 32,
                    child: Text(
                      '${item.quantity.value}',
                      style: AppTextStyles.pSmallSemiBold,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  _QuantityButton(
                    icon: Icons.add,
                    onTap: () => controller.addItem(item.id, item.name, item.price),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.darkSurfaceElevated,
          borderRadius: AppRadius.sm,
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Icon(icon, size: 16, color: AppColors.textPrimary),
      ),
    );
  }
}

class _OrderSummary extends GetView<CartController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXl),
      decoration: const BoxDecoration(
        color: AppColors.darkSurface,
        border: Border(top: BorderSide(color: AppColors.darkBorder, width: 0.5)),
      ),
      child: Obx(() => Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Subtotal', style: AppTextStyles.pSmall.copyWith(color: AppColors.textSecondary)),
                  Text(AppUtils.formatCurrency(controller.subtotal), style: AppTextStyles.pSmallSemiBold),
                ],
              ),
              const SizedBox(height: AppDimensions.gapSm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Delivery fee', style: AppTextStyles.pSmall.copyWith(color: AppColors.textSecondary)),
                  Text(AppUtils.formatCurrency(controller.deliveryFee.value), style: AppTextStyles.pSmallSemiBold),
                ],
              ),
              const Divider(height: AppDimensions.gapXl, color: AppColors.darkBorder),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: AppTextStyles.pMediumBold),
                  Text(
                    AppUtils.formatCurrency(controller.total),
                    style: AppTextStyles.amount,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.gapLg),
              AppButton(
                label: 'Proceed to Checkout',
                onTap: controller.proceedToCheckout,
              ),
            ],
          )),
    );
  }
}
