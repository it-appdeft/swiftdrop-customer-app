import 'package:get/get.dart';
import '../../../../data/repositories/earnings_repository.dart';
import '../../../../data/repositories/notification_repository.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../../data/repositories/profile_repository.dart';
import '../../home/bindings/home_binding.dart';
import '../../notifications/controllers/notifications_controller.dart';
import '../../order_history/controllers/order_history_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../wallet/controllers/wallet_controller.dart';
import '../controllers/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    HomeBinding().dependencies();
    Get.lazyPut<OrderRepository>(() => OrderRepository());
    Get.lazyPut<EarningsRepository>(() => EarningsRepository());
    Get.lazyPut<NotificationRepository>(() => NotificationRepository());
    Get.lazyPut<ProfileRepository>(() => ProfileRepository(), fenix: true);
    Get.lazyPut<OrderHistoryController>(() => OrderHistoryController(Get.find()));
    Get.lazyPut<WalletController>(() => WalletController(Get.find()));
    Get.lazyPut<NotificationsController>(() => NotificationsController(Get.find()));
    Get.lazyPut<ProfileController>(() => ProfileController(Get.find()));
  }
}
