import 'package:swiftdrop_customer_app/export.dart';
import '../controllers/address_controller.dart';

class AddressBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddressRepository>(() => AddressRepository());
    Get.lazyPut<AddressController>(() => AddressController(Get.find()));
  }
}
