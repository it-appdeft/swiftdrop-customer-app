import 'package:swiftdrop_customer_app/export.dart';

class PrivacyPolicyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PrivacyPolicyController>(
      () => PrivacyPolicyController(),
    );
  }
}
