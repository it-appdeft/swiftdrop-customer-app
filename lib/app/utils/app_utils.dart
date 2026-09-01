import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:swiftdrop_customer_app/app/routes/app_routes.dart';
import '../constants/app_constants.dart';
import '../themes/app_colors.dart';
import '../themes/app_dimensions.dart';
import '../themes/app_text_styles.dart';
import '../widgets/app_button.dart';

class AppUtils {
  AppUtils._();

  static void haptic() {
    HapticFeedback.lightImpact();
  }

  static String formatCurrency(double amount, {String symbol = '£'}) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  static bool isValidPhone(String phone) => phone.length >= 8;

  static bool isValidEmail(String email) =>
      RegExp(r'^[\w.+\-]+@[a-zA-Z\d\-]+\.[a-zA-Z]{2,}$').hasMatch(email);

  static String formatPhoneDisplay(String raw) {
    if (raw.startsWith('0')) return '+44 ${raw.substring(1)}';
    return raw;
  }

  static String extractErrorMessage(dynamic error, [String defaultMessage = 'An unexpected error occurred.']) {
    if (error == null) return defaultMessage;

    if (error is DioException) {
      final res = error.response;
      if (res != null && res.data != null) {
        final data = res.data;
        if (data is Map) {
          if (data['message'] is String && (data['message'] as String).trim().isNotEmpty) {
            return (data['message'] as String).trim();
          }
          if (data['error'] is String && (data['error'] as String).trim().isNotEmpty) {
            return (data['error'] as String).trim();
          }
          if (data['errors'] is Map) {
            final errorsMap = data['errors'] as Map;
            for (final key in errorsMap.keys) {
              final val = errorsMap[key];
              if (val is List && val.isNotEmpty) {
                return val.first.toString();
              } else if (val is String && val.trim().isNotEmpty) {
                return val.trim();
              }
            }
          }
        } else if (data is String && data.trim().isNotEmpty) {
          return data.trim();
        }
      }

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return 'Connection timeout. Please check your internet connection.';
      }
      if (error.type == DioExceptionType.connectionError) {
        return 'Unable to connect to server. Please check your internet connection.';
      }
      if (error.message != null && error.message!.isNotEmpty && !error.message!.contains('DioException')) {
        return error.message!;
      }
      return defaultMessage;
    }

    if (error is Map) {
      if (error['message'] is String && (error['message'] as String).trim().isNotEmpty) {
        return (error['message'] as String).trim();
      }
      if (error['error'] is String && (error['error'] as String).trim().isNotEmpty) {
        return (error['error'] as String).trim();
      }
      if (error['errors'] is Map) {
        final errorsMap = error['errors'] as Map;
        for (final key in errorsMap.keys) {
          final val = errorsMap[key];
          if (val is List && val.isNotEmpty) {
            return val.first.toString();
          } else if (val is String && val.trim().isNotEmpty) {
            return val.trim();
          }
        }
      }
    }

    final str = error.toString();
    if (str.startsWith('Exception: ')) {
      return str.substring(11).trim();
    }
    if (str.contains('DioException') || str.contains('RequestOptions.validateStatus')) {
      return defaultMessage;
    }
    return str.isNotEmpty ? str : defaultMessage;
  }

  static void showError(dynamic message) {
    final cleanMsg = message is String
        ? (message.contains('DioException') || message.contains('RequestOptions.validateStatus')
            ? 'An unexpected error occurred. Please try again.'
            : message)
        : extractErrorMessage(message);

    try {
      if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
      Get.snackbar(
        'Error',
        cleanMsg,
        backgroundColor: AppColors.error.withValues(alpha: 0.95),
        colorText: AppColors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: AppConstants.snackbarDuration),
        margin: const EdgeInsets.all(AppDimensions.paddingMd),
        borderRadius: AppDimensions.radiusMd,
        icon: const Icon(Icons.error_outline, color: AppColors.white),
      );
    } catch (_) {}
  }

  static void showSuccess(String message) {
    try {
      if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
      Get.snackbar(
        'Success',
        message,
        backgroundColor: AppColors.success.withValues(alpha: 0.95),
        colorText: AppColors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: AppConstants.snackbarDuration),
        margin: const EdgeInsets.all(AppDimensions.paddingMd),
        borderRadius: AppDimensions.radiusMd,
        icon: const Icon(Icons.check_circle_outline, color: AppColors.white),
      );
    } catch (_) {}
  }

  static void showWarning(String message) {
    try {
      if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
      Get.snackbar(
        'Notice',
        message,
        backgroundColor: AppColors.warning.withValues(alpha: 0.95),
        colorText: AppColors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: AppConstants.snackbarDuration),
        margin: const EdgeInsets.all(AppDimensions.paddingMd),
        borderRadius: AppDimensions.radiusMd,
        icon: const Icon(Icons.warning_amber_outlined, color: AppColors.white),
      );
    } catch (_) {}
  }

  static void showInfo(String message) {
    try {
      if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
      Get.snackbar(
        'Info',
        message,
        backgroundColor: AppColors.darkSurfaceElevated,
        colorText: AppColors.textPrimary,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: AppConstants.snackbarDuration),
        margin: const EdgeInsets.all(AppDimensions.paddingMd),
        borderRadius: AppDimensions.radiusMd,
      );
    } catch (_) {}
  }

  static String _lastNotificationKey = '';
  static DateTime _lastNotificationTime = DateTime.fromMillisecondsSinceEpoch(0);

  static void showOrderStatusNotification(Map<String, dynamic> data) {
    final rawDelStatus = (data['delivery_status'] ?? '').toString().toLowerCase().trim();
    final delStatus = rawDelStatus.replaceAll('-', '_').replaceAll(' ', '_');

    final rawOrdStatus = (data['order_status'] ?? data['status'] ?? '').toString().toLowerCase().trim();
    final ordStatus = rawOrdStatus.replaceAll('-', '_').replaceAll(' ', '_');

    final status = (delStatus == 'reached_customer' ||
            delStatus == 'driver_reached' ||
            delStatus == 'arrived' ||
            delStatus == 'driver_arrived' ||
            delStatus == 'reached_restaurant' ||
            delStatus == 'reached_resturant')
        ? delStatus
        : (ordStatus.isNotEmpty ? ordStatus : delStatus);

    final orderId = (data['order_id'] ?? data['id'] ?? '')?.toString() ?? '';
    final orderUuid = (data['order_uuid'] ?? data['uuid'] ?? '')?.toString() ?? '';
    final targetId = orderId.isNotEmpty ? orderId : orderUuid;
    final displayId = orderId.isNotEmpty ? orderId : (orderUuid.isNotEmpty ? orderUuid.substring(0, 8) : '');

    // Deduplicate rapid repeat events (within 2 seconds)
    final notificationKey = '$targetId:$status';
    final now = DateTime.now();
    if (_lastNotificationKey == notificationKey && now.difference(_lastNotificationTime).inSeconds < 2) {
      return;
    }
    _lastNotificationKey = notificationKey;
    _lastNotificationTime = now;

    haptic();

    // If the user is currently already on the Order Tracking screen, do not show intrusive snackbar popups
    if (Get.currentRoute == AppRoutes.orderTracking) {
      return;
    }

    String title = 'Order Update';
    String message = 'Your order status has been updated.';
    Color bgColor = AppColors.primary;
    IconData icon = Icons.notifications_active_outlined;

    switch (status) {
      case 'placed':
      case 'pending':
      case 'order_placed':
        title = 'Order Placed';
        message = displayId.isNotEmpty
            ? 'Your order #$displayId has been placed successfully.'
            : 'Your order has been placed successfully.';
        bgColor = AppColors.primary;
        icon = Icons.receipt_long_outlined;
        break;

      case 'accepted':
      case 'confirmed':
      case 'order_accepted':
        title = 'Order Accepted';
        message = displayId.isNotEmpty
            ? 'Restaurant has accepted your order #$displayId.'
            : 'Restaurant has accepted your order.';
        bgColor = AppColors.success;
        icon = Icons.check_circle_outline;
        break;

      case 'preparing':
      case 'kitchen':
      case 'in_kitchen':
      case 'in_progress':
      case 'food_preparing':
        title = 'Food Preparing';
        message = 'Your food is being prepared in the kitchen.';
        bgColor = AppColors.primary;
        icon = Icons.soup_kitchen_outlined;
        break;

      case 'ready':
      case 'ready_for_pickup':
      case 'ready_to_pickup':
      case 'ready_to_pick':
      case 'food_ready':
        title = 'Ready for Pickup';
        message = 'Your order is ready and waiting for delivery partner.';
        bgColor = AppColors.success;
        icon = Icons.inventory_2_outlined;
        break;

      case 'reached_restaurant':
      case 'driver_reached_restaurant':
        title = 'Driver at Restaurant';
        message = 'Delivery partner has reached the restaurant to pick up your order.';
        bgColor = AppColors.primary;
        icon = Icons.storefront_outlined;
        break;

      case 'picked_up':
      case 'pickedup':
      case 'on_the_way':
      case 'ontheway':
      case 'out_for_delivery':
      case 'outfordelivery':
      case 'in_transit':
      case 'intransit':
        title = 'Out for Delivery';
        message = 'Delivery partner has picked up your order and is on the way!';
        bgColor = AppColors.primaryLight;
        icon = Icons.delivery_dining_outlined;
        break;

      case 'reached_customer':
      case 'driver_reached_customer':
      case 'driver_reached':
      case 'arrived':
      case 'driver_arrived':
        title = 'Driver Arrived';
        message = 'Delivery partner has reached your location! Please share your delivery code.';
        bgColor = AppColors.success;
        icon = Icons.location_on_outlined;
        break;

      case 'delivered':
      case 'completed':
      case 'order_delivered':
        title = 'Order Delivered';
        message = displayId.isNotEmpty
            ? 'Your order #$displayId has been delivered. Enjoy your meal!'
            : 'Your order has been delivered. Enjoy your meal!';
        bgColor = AppColors.success;
        icon = Icons.task_alt;
        break;

      case 'rejected':
      case 'order_rejected':
        title = 'Order Rejected';
        message = displayId.isNotEmpty
            ? 'Your order #$displayId was rejected by the restaurant.'
            : 'Your order was rejected by the restaurant.';
        bgColor = AppColors.error;
        icon = Icons.cancel_outlined;
        break;

      case 'cancelled':
      case 'canceled':
      case 'failed':
      case 'order_cancelled':
        title = 'Order Cancelled';
        message = displayId.isNotEmpty
            ? 'Your order #$displayId has been cancelled.'
            : 'Your order has been cancelled.';
        bgColor = AppColors.error;
        icon = Icons.error_outline;
        break;

      default:
        title = 'Order Status Updated';
        message = 'Order status is now ${status.replaceAll('_', ' ')}.';
        bgColor = AppColors.primary;
        icon = Icons.notifications_active_outlined;
        break;
    }

    final isTerminal = status == 'rejected' || status == 'cancelled' || status == 'canceled' || status == 'failed';

    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Get.snackbar(
      title,
      message,
      backgroundColor: bgColor.withValues(alpha: 0.95),
      colorText: AppColors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(AppDimensions.paddingMd),
      borderRadius: AppDimensions.radiusMd,
      icon: Icon(icon, color: AppColors.white, size: 28),
      mainButton: targetId.isNotEmpty
          ? TextButton(
              style: TextButton.styleFrom(
                backgroundColor: AppColors.white.withValues(alpha: 0.2),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
                if (isTerminal) {
                  Get.toNamed(AppRoutes.orderDetails, arguments: {
                    'id': targetId,
                    'orderId': targetId,
                    'uuid': orderUuid,
                  });
                } else {
                  Get.toNamed(AppRoutes.orderTracking, arguments: {
                    'id': targetId,
                    'orderId': targetId,
                    'uuid': orderUuid,
                  });
                }
              },
              child: Text(
                isTerminal ? 'View Details' : 'Track Order',
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            )
          : null,
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
            onPressed: () {
              haptic();
              Get.back(result: false);
            },
            child: Text(cancelText, style: AppTextStyles.pMediumSemiBold.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              haptic();
              Get.back(result: true);
            },
            child: Text(confirmText, style: AppTextStyles.pMediumSemiBold.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  static Future<bool?> showExitConfirmationDialog() {
    return Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.exit_to_app_rounded,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Exit SwiftDrop?',
                style: AppTextStyles.h5.copyWith(color: const Color(0xFF0B243A), fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to exit the app?',
                style: AppTextStyles.pMedium.copyWith(color: const Color(0xFF868AA5), height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        haptic();
                        Get.back(result: false);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFE1E2E3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.pMediumSemiBold.copyWith(color: const Color(0xFF0B243A)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        haptic();
                        Get.back(result: true);
                        SystemNavigator.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Exit',
                        style: AppTextStyles.pMediumSemiBold.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
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

  static void showLocationPermissionDeniedDialog({
    required VoidCallback onEnterManual,
    VoidCallback? onCancel,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Location Permission Denied',
                style: AppTextStyles.h6.copyWith(color: AppColors.lightSurfaceDarkText),
              ),
              const SizedBox(height: 10),
              Text(
                'We cannot load the map without location access. Please enable location permissions or enter your address manually.',
                style: AppTextStyles.pSmall.copyWith(color: AppColors.lightSurfaceSubtitle),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    haptic();
                    Get.back();
                    onEnterManual();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Enter Manual Location',
                    style: AppTextStyles.pSmallSemiBold.copyWith(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () {
                          haptic();
                          Get.back();
                          onCancel?.call();
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.lightSurfaceDisabled),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.pSmallSemiBold.copyWith(
                            color: AppColors.lightSurfaceDarkText,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () {
                          haptic();
                          Get.back();
                          Geolocator.openAppSettings();
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Open Settings',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.pSmallSemiBold.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void showLocationPermissionDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.settings_suggest_outlined, size: 64, color: AppColors.primary),
              const SizedBox(height: 24),
              const Text(
                'Permission Required',
                style: TextStyle(
                  fontFamily: 'Helvetica Neue',
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Location permission is permanently denied. Please enable it in your device settings to use your current location.',
                textAlign: TextAlign.center,
                style: AppTextStyles.pSmall.copyWith(
                  color: AppColors.lightSurfaceSubtitle,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              AppButton(
                label: 'Open Settings',
                onTap: () {
                  haptic();
                  Get.back();
                  Geolocator.openAppSettings();
                },
                backgroundColor: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  haptic();
                  Get.back();
                },
                child: Text(
                  'Cancel',
                  style: AppTextStyles.pSmallMedium.copyWith(
                    color: AppColors.lightSurfaceSubtitle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
