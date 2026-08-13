
import '../../../../export.dart';

import '../controllers/notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text(AppStrings.notifications, style: AppTextStyles.h6),
        automaticallyImplyLeading: false,
        actions: [
          Obx(() {
            if (controller.unreadCount.value == 0) return const SizedBox.shrink();
            return TextButton(
              onPressed: () {
                AppUtils.haptic();
                controller.markAllAsRead();
              },
              child: Text(
                'Mark all read',
                style: AppTextStyles.pXSmall.copyWith(color: AppColors.primary),
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const ShimmerList();
        if (controller.hasError.value) {
          return ErrorStateWidget(
            message: controller.errorMessage.value,
            onRetry: controller.loadNotifications,
          );
        }
        if (controller.notifications.isEmpty) {
          return const EmptyStateWidget(
            message: 'No notifications',
            subtitle: 'You\'re all caught up!',
            icon: Icons.notifications_off_outlined,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.paddingMd),
          itemCount: controller.notifications.length,
          itemBuilder: (_, index) {
            final notif = controller.notifications[index];
            return _NotifTile(
              notification: notif,
              onTap: () {
                AppUtils.haptic();
                controller.markAsRead(notif.id);
              },
            );
          },
        );
      }),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotifTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.gapSm),
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        decoration: BoxDecoration(
          color: notification.isRead ? AppColors.darkSurface : AppColors.darkSurfaceElevated,
          borderRadius: AppRadius.md,
          border: Border.all(
            color: notification.isRead ? AppColors.darkBorder : AppColors.primary.withOpacity(0.4),
            width: notification.isRead ? 0.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _iconColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(_iconData, color: _iconColor, size: 18),
            ),
            const SizedBox(width: AppDimensions.gapMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(notification.title, style: AppTextStyles.pSmallSemiBold),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: AppTextStyles.pXSmall.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppUtils.timeAgo(notification.createdAt),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color get _iconColor {
    switch (notification.type) {
      case 'order_update':
        return AppColors.primary;
      case 'wallet':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData get _iconData {
    switch (notification.type) {
      case 'order_update':
        return Icons.delivery_dining;
      case 'wallet':
        return Icons.account_balance_wallet_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }
}
