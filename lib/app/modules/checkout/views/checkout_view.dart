import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_dimensions.dart';
import '../../../themes/app_radius.dart';
import '../../../themes/app_text_styles.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../controllers/checkout_controller.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text('Checkout', style: AppTextStyles.h6),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingXl),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Delivery address', style: AppTextStyles.pMediumSemiBold),
            const SizedBox(height: AppDimensions.gapMd),
            AppTextField(
              controller: controller.addressController,
              hint: 'Enter delivery address',
              prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.textHint),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: AppDimensions.gapXl),
            Text('Payment method', style: AppTextStyles.pMediumSemiBold),
            const SizedBox(height: AppDimensions.gapMd),
            _PaymentOption(
              value: 'wallet',
              icon: Icons.account_balance_wallet_outlined,
              label: 'SwiftDrop Wallet',
              subtitle: 'Balance: £24.50',
            ),
            const SizedBox(height: AppDimensions.gapSm),
            _PaymentOption(
              value: 'card',
              icon: Icons.credit_card,
              label: 'Credit / Debit Card',
              subtitle: 'Visa, Mastercard, Amex',
            ),
            const SizedBox(height: AppDimensions.sp40),
            Obx(() => AppButton(
                  label: 'Place Order',
                  onTap: controller.placeOrder,
                  isLoading: controller.isLoading.value,
                )),
            const SizedBox(height: AppDimensions.paddingXl),
          ],
        ),
      ),
    );
  }
}

class _PaymentOption extends GetView<CheckoutController> {
  final String value;
  final IconData icon;
  final String label;
  final String subtitle;

  const _PaymentOption({
    required this.value,
    required this.icon,
    required this.label,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.selectedPayment.value == value;
      return GestureDetector(
        onTap: () => controller.selectPayment(value),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingMd),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: AppRadius.md,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.darkBorder,
              width: isSelected ? 1.5 : 0.5,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: AppDimensions.iconSm, color: isSelected ? AppColors.primary : AppColors.textSecondary),
              const SizedBox(width: AppDimensions.gapMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTextStyles.pSmallSemiBold),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.caption),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
            ],
          ),
        ),
      );
    });
  }
}
