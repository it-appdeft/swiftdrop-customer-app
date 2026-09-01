import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swiftdrop_customer_app/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:swiftdrop_customer_app/app/routes/app_routes.dart';
import 'package:swiftdrop_customer_app/app/utils/app_utils.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/repositories/order_repository.dart';

class OrderDeliveredController extends GetxController {
  final order = Rxn<OrderModel>();
  final isLoadingDetail = true.obs;
  final isSubmitted = false.obs;
  final fromOrderTracking = false.obs;

  final RxDouble restaurantRating = 4.0.obs;
  final RxMap<int, double> foodRatings = <int, double>{}.obs;
  final RxDouble driverRating = 4.0.obs;
  final TextEditingController driverFeedbackController = TextEditingController();

  final _repo = OrderRepository();

  @override
  void onInit() {
    super.onInit();
    String? targetOrderId;
    if (Get.arguments is OrderModel) {
      final passedOrder = Get.arguments as OrderModel;
      order.value = passedOrder;
      targetOrderId = (passedOrder.id.isNotEmpty && int.tryParse(passedOrder.id) != null)
          ? passedOrder.id
          : (passedOrder.uuid ?? passedOrder.targetId);
    } else if (Get.arguments is Map) {
      final map = Get.arguments as Map;
      fromOrderTracking.value = map['fromOrderTracking'] == true;
      if (map['order'] is OrderModel) {
        order.value = map['order'] as OrderModel;
      }
      targetOrderId = (map['id'] ??
          map['orderId'] ??
          (order.value?.id.isNotEmpty == true && int.tryParse(order.value!.id) != null ? order.value!.id : null) ??
          map['orderUuid'] ??
          map['uuid'] ??
          order.value?.uuid ??
          order.value?.targetId)?.toString();
    }

    if (order.value != null && order.value!.items.isNotEmpty) {
      isLoadingDetail.value = false;
    }

    if (targetOrderId != null && targetOrderId.isNotEmpty) {
      fetchOrderDetail(targetOrderId);
    } else {
      isLoadingDetail.value = false;
    }
  }

  Future<void> fetchOrderDetail(String orderId) async {
    if (order.value == null || order.value!.items.isEmpty) {
      isLoadingDetail.value = true;
    }
    try {
      final res = await _repo.getOrderDetail(orderId);
      if (res.success && res.data != null) {
        final existing = order.value;
        final fetched = res.data!;
        var finalOrder = fetched;
        if (fetched.items.isEmpty && existing != null && existing.items.isNotEmpty) {
          finalOrder = finalOrder.copyWith(items: existing.items);
        }
        if ((fetched.deliveryAddress.isEmpty || fetched.deliveryAddress == 'Customer Location') &&
            existing != null &&
            existing.deliveryAddress.isNotEmpty &&
            existing.deliveryAddress != 'Customer Location') {
          finalOrder = finalOrder.copyWith(deliveryAddress: existing.deliveryAddress);
        }
        order.value = finalOrder;
      }
    } finally {
      isLoadingDetail.value = false;
    }
  }

  void submitFeedback() {
    AppUtils.haptic();
    isSubmitted.value = true;
  }

  void handleBack() {
    AppUtils.haptic();
    if (fromOrderTracking.value) {
      backToHome();
    } else {
      Get.back();
    }
  }

  void backToHome() {
    AppUtils.haptic();
    if (fromOrderTracking.value) {
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().fetchActiveOrders(forceRefresh: true);
      }
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      Get.back();
    }
  }

  @override
  void onClose() {
    driverFeedbackController.dispose();
    super.onClose();
  }
}
