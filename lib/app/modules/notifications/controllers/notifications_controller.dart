import 'package:get/get.dart';
import '../../../../data/models/notification_model.dart';
import '../../../../data/repositories/notification_repository.dart';
import '../../../base/base_controller.dart';
import '../../../utils/app_utils.dart';

class NotificationsController extends BaseController {
  final NotificationRepository _repo;
  NotificationsController(this._repo);

  final notifications = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    await runAsync(() async {
      final result = await _repo.getNotifications();
      if (result.success && result.data != null) {
        notifications.value = result.data!;
        _updateUnreadCount();
      }
    });
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  Future<void> markAsRead(String id) async {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index == -1 || notifications[index].isRead) return;

    notifications[index] = notifications[index].copyWith(isRead: true);
    _updateUnreadCount();
    await _repo.markAsRead(id);
  }

  Future<void> markAllAsRead() async {
    for (int i = 0; i < notifications.length; i++) {
      if (!notifications[i].isRead) {
        notifications[i] = notifications[i].copyWith(isRead: true);
      }
    }
    _updateUnreadCount();
    await _repo.markAllAsRead();
    AppUtils.showSuccess('All notifications marked as read.');
  }
}
