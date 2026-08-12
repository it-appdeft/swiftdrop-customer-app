import 'package:get/get.dart';
import '../../../../data/models/order_model.dart';

class OrderDeliveredController extends GetxController {
  final order = Rxn<OrderModel>();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is OrderModel) {
      order.value = Get.arguments as OrderModel;
    }
  }

  void submitFeedback() {
    // Implement feedback submission logic
    Get.back();
  }

  void backToHome() {
    Get.offAllNamed('/dashboard');
  }
}
