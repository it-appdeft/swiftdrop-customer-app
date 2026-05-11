import 'package:get/get.dart';
import '../services/connectivity_service.dart';
import '../utils/app_logger.dart';

abstract class BaseController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;

  bool get isConnected => ConnectivityService.to.isConnected.value;

  Future<T?> runAsync<T>(
    Future<T> Function() operation, {
    bool showLoadingIndicator = true,
    bool handleErrors = true,
  }) async {
    if (showLoadingIndicator) isLoading.value = true;
    errorMessage.value = '';
    hasError.value = false;

    try {
      final result = await operation();
      return result;
    } catch (e, stackTrace) {
      if (handleErrors) {
        hasError.value = true;
        errorMessage.value = e.toString();
        AppLogger.e('BaseController error', e, stackTrace);
      }
      return null;
    } finally {
      if (showLoadingIndicator) isLoading.value = false;
    }
  }

  void clearError() {
    hasError.value = false;
    errorMessage.value = '';
  }
}
