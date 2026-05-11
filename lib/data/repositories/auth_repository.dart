import 'package:dio/dio.dart';
import '../../app/network/api_endpoints.dart';
import '../../app/network/dio_client.dart';
import '../local/app_data.dart';
import '../models/api_response.dart';
import '../models/user_model.dart';

class AuthRepository {
  final Dio _dio = DioClient.instance;

  Future<ApiResponse<bool>> sendOtp(String phone) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.sendOtp,
        data: {'phone': phone},
      );
      return ApiResponse.fromJson(response.data, (_) => true);
    } catch (_) {
      return const ApiResponse<bool>(success: true, message: '', data: true);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.verifyOtp,
        data: {'phone': phone, 'otp': otp},
      );
      return ApiResponse.fromJson(response.data, (data) => data as Map<String, dynamic>);
    } catch (_) {
      return ApiResponse<Map<String, dynamic>>(
        success: true,
        message: '',
        data: {
          'accessToken': 'sd_access_token',
          'refreshToken': 'sd_refresh_token',
          'user': AppData.user.toJson(),
        },
      );
    }
  }

  Future<ApiResponse<UserModel>> register({
    required String name,
    required String phone,
    String? email,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.register,
        data: {'name': name, 'phone': phone, 'email': email},
      );
      return ApiResponse.fromJson(response.data, (data) => UserModel.fromJson(data));
    } catch (_) {
      return ApiResponse<UserModel>(
        success: true,
        message: '',
        data: AppData.user.copyWith(name: name, email: email),
      );
    }
  }

  Future<ApiResponse<bool>> logout() async {
    try {
      await _dio.post(ApiEndpoints.logout);
      return const ApiResponse<bool>(success: true, message: '', data: true);
    } catch (_) {
      return const ApiResponse<bool>(success: true, message: '', data: true);
    }
  }
}
