import 'package:swiftdrop_customer_app/export.dart';

class HelpCenterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HelpCenterController>(
      () => HelpCenterController(),
    );
  }
}
