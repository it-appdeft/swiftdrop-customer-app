import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import '../../constants/storage_keys.dart';
import '../../routes/app_routes.dart';
import '../../services/storage_service.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = StorageService.to.read<String>(StorageKeys.authToken);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      const _authRoutes = {
        AppRoutes.splash,
        AppRoutes.onboarding,
        AppRoutes.login,
        AppRoutes.otp,
        AppRoutes.register,
        AppRoutes.registerSteps,
        AppRoutes.verificationPending,
      };
      if (!_authRoutes.contains(Get.currentRoute)) {
        Get.offAllNamed(AppRoutes.login);
      }
    }
    handler.next(err);
  }
}
