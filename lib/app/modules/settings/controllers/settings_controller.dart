import 'package:get/get.dart';
import '../../../base/base_controller.dart';
import '../../../constants/storage_keys.dart';
import '../../../services/storage_service.dart';

class SettingsController extends BaseController {
  final RxBool pushNotifications = true.obs;
  final RxBool orderUpdates = true.obs;
  final RxBool promotions = false.obs;

  @override
  void onInit() {
    super.onInit();
    pushNotifications.value =
        StorageService.to.read<bool>(StorageKeys.settingPushNotifications) ?? true;
    orderUpdates.value =
        StorageService.to.read<bool>(StorageKeys.settingOrderUpdates) ?? true;
    promotions.value =
        StorageService.to.read<bool>(StorageKeys.settingPromotions) ?? false;

    ever(pushNotifications, (v) =>
        StorageService.to.write(StorageKeys.settingPushNotifications, v));
    ever(orderUpdates, (v) =>
        StorageService.to.write(StorageKeys.settingOrderUpdates, v));
    ever(promotions, (v) =>
        StorageService.to.write(StorageKeys.settingPromotions, v));
  }
}
