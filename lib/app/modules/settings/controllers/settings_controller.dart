import 'package:get/get.dart';
import '../../../base/base_controller.dart';

class SettingsController extends BaseController {
  final RxBool pushNotifications = true.obs;
  final RxBool orderUpdates = true.obs;
  final RxBool promotions = false.obs;
}
