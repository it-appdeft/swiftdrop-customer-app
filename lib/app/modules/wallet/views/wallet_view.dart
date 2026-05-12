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
import '../../../widgets/error_state_widget.dart';
import '../../../widgets/shimmer_widgets.dart';
import '../../../widgets/status_badge.dart';
import '../../../../data/models/transaction_model.dart';
import '../controllers/wallet_controller.dart';

class WalletView extends GetView<WalletController> {
  const WalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text('Wallet', style: AppTextStyles.h6),
        automaticallyImplyLeading: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const ShimmerList();
        if (controller.hasError.value) {
          return ErrorStateWidget(
            message: controller.errorMessage.value,
            onRetry: controller.loadTransactions,
          );
        }

        return Column(
          children: [
            _BalanceCard(),
            Expanded(child: _TransactionList()),
          ],
        );
      }),
    );
  }
}

class _BalanceCard extends GetView<WalletController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingMd),
      padding: const EdgeInsets.all(AppDimensions.paddingXl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wallet Balance',
            style: AppTextStyles.pSmall.copyWith(color: AppColors.white.withOpacity(0.8)),
          ),
          const SizedBox(height: AppDimensions.gapSm),
          Obx(() => Text(
                AppUtils.formatCurrency(controller.balance.value),
                style: AppTextStyles.amountLg.copyWith(color: AppColors.white),
              )),
          const SizedBox(height: AppDimensions.gapXl),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Add Money',
                  onTap: () => _showAddFundsSheet(),
                  backgroundColor: AppColors.white,
                  textColor: AppColors.primary,
                  height: 44,
                  prefixIcon: const Icon(Icons.add, color: AppColors.primary, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddFundsSheet() {
    final amounts = [5.0, 10.0, 20.0, 50.0];
    AppUtils.showBottomSheet(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add money to wallet', style: AppTextStyles.h6),
            const SizedBox(height: AppDimensions.gapXl),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: AppDimensions.gapMd,
                mainAxisSpacing: AppDimensions.gapMd,
              ),
              itemCount: amounts.length,
              itemBuilder: (_, index) => OutlinedButton(
                onPressed: () {
                  Get.back();
                  controller.addFunds(amounts[index]);
                },
                child: Text(AppUtils.formatCurrency(amounts[index])),
              ),
            ),
            const SizedBox(height: AppDimensions.gapXl),
          ],
        ),
      ),
    );
  }
}

class _TransactionList extends GetView<WalletController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.transactions.isEmpty) {
        return const EmptyStateWidget(
          message: 'No transactions yet',
          subtitle: 'Your transaction history will appear here',
          icon: Icons.receipt_outlined,
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMd),
        itemCount: controller.transactions.length + (controller.isLoadingMore.value ? 1 : 0),
        itemBuilder: (_, index) {
          if (index == controller.transactions.length) {
            return const Padding(
              padding: EdgeInsets.all(AppDimensions.paddingMd),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
              ),
            );
          }
          return _TransactionTile(transaction: controller.transactions[index]);
        },
      );
    });
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionModel transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.gapSm),
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: AppDecorations.card,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (transaction.isCredit ? AppColors.success : AppColors.error).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              transaction.isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color: transaction.isCredit ? AppColors.success : AppColors.error,
              size: 18,
            ),
          ),
          const SizedBox(width: AppDimensions.gapMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.description, style: AppTextStyles.pSmallSemiBold),
                const SizedBox(height: 2),
                Text(
                  AppUtils.timeAgo(transaction.createdAt),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${transaction.isCredit ? '+' : '-'}${AppUtils.formatCurrency(transaction.amount)}',
                style: AppTextStyles.pSmallSemiBold.copyWith(
                  color: transaction.isCredit ? AppColors.success : AppColors.error,
                ),
              ),
              const SizedBox(height: 2),
              StatusBadge(status: transaction.status),
            ],
          ),
        ],
      ),
    );
  }
}
