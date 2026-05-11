import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/connectivity_service.dart';
import '../utils/app_utils.dart';

class ConnectivityMiddleware extends GetMiddleware {
  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    if (!ConnectivityService.to.isConnected.value) {
      AppUtils.showWarning('You are offline. Some features may be unavailable.');
    }
    return null;
  }
}
