import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swiftdrop_customer_app/export.dart';
import '../../../../data/repositories/auth_repository.dart';

class HelpCenterController extends GetxController {
  final AuthRepository _repo = AuthRepository();

  late final TextEditingController issueTitleController;
  late final TextEditingController issueDetailsController;
  late final TextEditingController orderReferenceController;

  final RxBool isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    issueTitleController = TextEditingController();
    issueDetailsController = TextEditingController();
    orderReferenceController = TextEditingController();
  }

  @override
  void onClose() {
    issueTitleController.dispose();
    issueDetailsController.dispose();
    orderReferenceController.dispose();
    super.onClose();
  }

  Future<void> submitReport() async {
    final title = issueTitleController.text.trim();
    final details = issueDetailsController.text.trim();
    final orderRef = orderReferenceController.text.trim();

    if (title.isEmpty) {
      AppUtils.showError('Please enter a title for the issue');
      return;
    }

    if (details.isEmpty) {
      AppUtils.showError('Please describe the issue in details');
      return;
    }

    isSubmitting.value = true;
    try {
      final res = await _repo.createSupportTicket(
        subject: title,
        description: details,
        orderReference: orderRef.isNotEmpty ? orderRef : null,
      );
      if (res.success) {
        final reference = res.data?['reference']?.toString() ?? '';
        final msg = res.message.isNotEmpty ? res.message : 'Support ticket submitted.';
        issueTitleController.clear();
        issueDetailsController.clear();
        orderReferenceController.clear();
        _showSuccessDialog(reference, msg);
      } else {
        AppUtils.showError(
            res.message.isNotEmpty ? res.message : 'Failed to submit report');
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  void _showSuccessDialog(String reference, String message) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Ticket Submitted!',
                style: AppTextStyles.pLargeSemiBold.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightSurfaceDarkText,
                ),
              ),
              if (reference.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Text(
                    'Ticket #$reference',
                    style: AppTextStyles.pSmallSemiBold.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                message.isNotEmpty
                    ? message
                    : 'Your support ticket has been submitted. Our support team will review your inquiry and get back to you shortly.',
                textAlign: TextAlign.center,
                style: AppTextStyles.pSmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Done',
                onTap: () {
                  Get.back(); // Close dialog
                  Get.back(); // Close help center screen
                },
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
