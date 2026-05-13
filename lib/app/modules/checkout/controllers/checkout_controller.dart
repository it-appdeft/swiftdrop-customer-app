import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../base/base_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/app_utils.dart';
import '../../cart/controllers/cart_controller.dart';

class CheckoutController extends BaseController {
  final addressController = TextEditingController();
  final RxString selectedPayment = 'wallet'.obs;
  final RxString deliveryAddress = ''.obs;

  @override
  void onInit() {
    super.onInit();
    deliveryAddress.value = '27 Clerkenwell Rd, London EC1M 5RN';
    addressController.text = deliveryAddress.value;
    addressController.addListener(_onAddressChanged);
  }

  void _onAddressChanged() => deliveryAddress.value = addressController.text;

  void selectPayment(String method) => selectedPayment.value = method;

  Future<void> placeOrder() async {
    if (isLoading.value) return;
    if (deliveryAddress.value.trim().isEmpty) {
      AppUtils.showError('Please enter a delivery address.');
      return;
    }

    await runAsync(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (Get.isRegistered<CartController>()) {
        Get.find<CartController>().clearCart();
      }
      AppUtils.showSuccess('Order placed successfully!');
      Get.offAllNamed(AppRoutes.dashboard);
    });
  }

  @override
  void onClose() {
    addressController.removeListener(_onAddressChanged);
    addressController.dispose();
    super.onClose();
  }
}
