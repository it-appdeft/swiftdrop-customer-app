import 'package:get/get.dart';
import '../../../base/base_controller.dart';

class DashboardController extends BaseController {
  final RxInt currentIndex = 0.obs;

  void changePage(int index) => currentIndex.value = index;
}
