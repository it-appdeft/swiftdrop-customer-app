import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_constants.dart';
import '../themes/app_colors.dart';
import '../themes/app_dimensions.dart';
import '../themes/app_text_styles.dart';

class AppUtils {
  AppUtils._();

  static String formatCurrency(double amount, {String symbol = '£'}) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  static bool isValidPhone(String phone) => phone.length >= 5;

  static bool isValidEmail(String email) =>
      RegExp(r'^[\w.+\-]+@[a-zA-Z\d\-]+\.[a-zA-Z]{2,}$').hasMatch(email);

  static String formatPhoneDisplay(String raw) {
    if (raw.startsWith('0')) return '+44 ${raw.substring(1)}';
    return raw;
  }

  static void showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: AppColors.error.withOpacity(0.9),
      colorText: AppColors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: AppConstants.snackbarDuration),
      margin: const EdgeInsets.all(AppDimensions.paddingMd),
      borderRadius: AppDimensions.radiusMd,
      icon: const Icon(Icons.error_outline, color: AppColors.white),
    );
  }

  static void showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: AppColors.success.withOpacity(0.9),
      colorText: AppColors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: AppConstants.snackbarDuration),
      margin: const EdgeInsets.all(AppDimensions.paddingMd),
      borderRadius: AppDimensions.radiusMd,
      icon: const Icon(Icons.check_circle_outline, color: AppColors.white),
    );
  }

  static void showWarning(String message) {
    Get.snackbar(
      'Notice',
      message,
      backgroundColor: AppColors.warning.withOpacity(0.9),
      colorText: AppColors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: AppConstants.snackbarDuration),
      margin: const EdgeInsets.all(AppDimensions.paddingMd),
      borderRadius: AppDimensions.radiusMd,
      icon: const Icon(Icons.warning_amber_outlined, color: AppColors.white),
    );
  }

  static void showInfo(String message) {
    Get.snackbar(
      'Info',
      message,
      backgroundColor: AppColors.darkSurfaceElevated,
      colorText: AppColors.textPrimary,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: AppConstants.snackbarDuration),
      margin: const EdgeInsets.all(AppDimensions.paddingMd),
      borderRadius: AppDimensions.radiusMd,
    );
  }

  static void showBottomSheet({required Widget child, bool isDismissible = true}) {
    Get.bottomSheet(
      child,
      isDismissible: isDismissible,
      isScrollControlled: true,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXl)),
      ),
    );
  }

  static Future<bool?> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) {
    return Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: Text(title, style: AppTextStyles.h6),
        content: Text(message, style: AppTextStyles.pMedium),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelText, style: AppTextStyles.pMediumSemiBold.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(confirmText, style: AppTextStyles.pMediumSemiBold.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  static String timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}
