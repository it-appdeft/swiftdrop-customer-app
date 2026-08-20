import 'package:flutter/material.dart';
import 'package:get/get.dart';


class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    // if (!AuthService.to.isAuthenticated) {
    //   return const RouteSettings(name: AppRoutes.login);
    // }



    return null;
  }
}
