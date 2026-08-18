import 'package:swiftdrop_customer_app/export.dart';

class TermsConditionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TermsConditionsController>(
      () => TermsConditionsController(),
    );
  }
}
