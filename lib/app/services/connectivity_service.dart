import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import '../utils/app_logger.dart';

class ConnectivityService extends GetxService {
  static ConnectivityService get to => Get.find();

  final RxBool isConnected = true.obs;
  StreamSubscription<List<ConnectivityResult>>? _sub;

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnectivity();
    _listenToConnectivity();
  }

  Future<void> _checkInitialConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    isConnected.value = _hasConnection(result);
  }

  void _listenToConnectivity() {
    _sub = Connectivity().onConnectivityChanged.listen((results) {
      isConnected.value = _hasConnection(results);
      AppLogger.d('Connectivity changed: ${isConnected.value}');
    });
  }

  bool _hasConnection(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
