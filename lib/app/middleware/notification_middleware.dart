import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationMiddleware extends GetMiddleware {
  @override
  int? get priority => 3;

  @override
  RouteSettings? redirect(String? route) => null;
}
