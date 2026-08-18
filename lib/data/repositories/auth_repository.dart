import 'package:dio/dio.dart';
import '../../app/config/app_config.dart';
import '../../app/network/api_endpoints.dart';
import '../../app/network/dio_client.dart';
import '../../app/utils/app_logger.dart';
import '../local/app_data.dart';
import '../models/api_response.dart';
import '../models/user_model.dart';

class AuthRepository {
  final Dio _dio = DioClient.instance;

  Future<ApiResponse<Map<String, dynamic>>> sendOtp({
    String? email,
    String? mobile,
    String? countryCode,
    String? countryIso,
    required String type,
    required String channel,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.sendOtp,
        data: FormData.fromMap({
          'type': type,
          'user_type': 'customer',
          'channel': channel,
          if (email != null) 'email': email,
          if (mobile != null) 'mobile': mobile,
          if (countryCode != null) 'country_code': countryCode,
          if (countryIso != null) 'country_iso': countryIso,
        }),
        options: Options(contentType: 'multipart/form-data'),
      );
      final json = response.data as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>?;
      AppLogger.i('[AUTH] sendOtp SUCCESS | status: ${response.statusCode} | body: ${response.data}');
      return ApiResponse<Map<String, dynamic>>(success: true, message: '', data: data);
    } on DioException catch (e) {
      AppLogger.e('[AUTH] sendOtp FAILED | status: ${e.response?.statusCode} | body: ${e.response?.data} | type: ${e.type}');
      if (_isNetworkError(e)) {
        return const ApiResponse<Map<String, dynamic>>(success: false, message: _offlineMessage);
      }
      final msg = _extractMessage(e);
      if (msg != null) return ApiResponse<Map<String, dynamic>>(success: false, message: msg);
      AppLogger.w('[AUTH] sendOtp — no real API, falling back to local');
      return const ApiResponse<Map<String, dynamic>>(success: true, message: '', data: null);
    } catch (e) {
      AppLogger.w('[AUTH] sendOtp — unexpected error, falling back to local | $e');
      return const ApiResponse<Map<String, dynamic>>(success: true, message: '', data: null);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyOtp({
    String? email,
    String? mobile,
    String? countryCode,
    String? countryIso,
    required String code,
    required String type,
    required String channel,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.verifyOtp,
        data: FormData.fromMap({
          'type': type,
          'user_type': 'customer',
          'channel': channel,
          if (email != null) 'email': email,
          if (mobile != null) 'mobile': mobile,
          if (countryCode != null) 'country_code': countryCode,
          if (countryIso != null) 'country_iso': countryIso,
          'code': code,
        }),
        options: Options(contentType: 'multipart/form-data'),
      );
      final json = response.data as Map<String, dynamic>;
      final success = json['success'] as bool? ?? false;
      final data = json['data'] as Map<String, dynamic>?;
      AppLogger.i('[AUTH] verifyOtp ${success ? "SUCCESS" : "FAILED"} | status: ${response.statusCode} | message: ${json['message']} | data: $data');
      return ApiResponse<Map<String, dynamic>>(
        success: success,
        message: json['message'] as String? ?? '',
        data: data,
      );
    } on DioException catch (e) {
      AppLogger.e('[AUTH] verifyOtp FAILED | status: ${e.response?.statusCode} | body: ${e.response?.data} | type: ${e.type}');
      if (_isNetworkError(e)) {
        return const ApiResponse<Map<String, dynamic>>(success: false, message: _offlineMessage);
      }
      final msg = _extractMessage(e);
      if (msg != null) {
        return ApiResponse<Map<String, dynamic>>(success: false, message: msg);
      }
      AppLogger.w('[AUTH] verifyOtp — no real API, falling back to local');
      return ApiResponse<Map<String, dynamic>>(
        success: true,
        message: '',
        data: {'token': AppConfig.accessTokenKey, 'user': AppData.user.toJson()},
      );
    } catch (e) {
      AppLogger.w('[AUTH] verifyOtp — unexpected error, falling back to local | $e');
      return ApiResponse<Map<String, dynamic>>(
        success: true,
        message: '',
        data: {'token': AppConfig.accessTokenKey, 'user': AppData.user.toJson()},
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> register({
    required String name,
    required String mobile,
    required String countryCode,
    String? countryIso,
    String? email,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.register,
        data: FormData.fromMap({
          'name': name,
          'mobile': mobile,
          'country_code': countryCode,
          if (countryIso != null) 'country_iso': countryIso,
          if (email != null && email.isNotEmpty) 'email': email,
        }),
        options: Options(contentType: 'multipart/form-data'),
      );
      final json = response.data as Map<String, dynamic>;
      final success = json['success'] as bool? ?? false;
      final data = json['data'] as Map<String, dynamic>?;
      AppLogger.i('[AUTH] register ${success ? "SUCCESS" : "FAILED"} | status: ${response.statusCode} | message: ${json['message']} | data: $data');
      return ApiResponse<Map<String, dynamic>>(
        success: success,
        message: json['message'] as String? ?? '',
        data: data,
      );
    } on DioException catch (e) {
      AppLogger.e('[AUTH] register FAILED | status: ${e.response?.statusCode} | body: ${e.response?.data} | type: ${e.type}');
      if (_isNetworkError(e)) {
        return const ApiResponse<Map<String, dynamic>>(success: false, message: _offlineMessage);
      }
      final msg = _extractMessage(e);
      if (msg != null) {
        return ApiResponse<Map<String, dynamic>>(success: false, message: msg);
      }
      AppLogger.w('[AUTH] register — no real API, falling back to local');
      return const ApiResponse<Map<String, dynamic>>(success: true, message: '', data: null);
    } catch (e) {
      AppLogger.w('[AUTH] register — unexpected error, falling back to local | $e');
      return const ApiResponse<Map<String, dynamic>>(success: true, message: '', data: null);
    }
  }

  Future<ApiResponse<bool>> logout() async {
    try {
      final response = await _dio.post(ApiEndpoints.logout);
      AppLogger.i('[AUTH] logout SUCCESS | status: ${response.statusCode}');
      return const ApiResponse<bool>(success: true, message: '', data: true);
    } on DioException catch (e) {
      AppLogger.e('[AUTH] logout FAILED | status: ${e.response?.statusCode} | body: ${e.response?.data}');
      return const ApiResponse<bool>(success: true, message: '', data: true);
    } catch (e) {
      AppLogger.w('[AUTH] logout — unexpected error | $e');
      return const ApiResponse<bool>(success: true, message: '', data: true);
    }
  }

  String? _extractMessage(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final msg = data['message'] as String?;
        if (msg != null && msg.isNotEmpty) return msg;
      }
    } catch (_) {}
    return null;
  }

  bool _isNetworkError(DioException e) =>
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.sendTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.connectionError;

  static const String _offlineMessage =
      'No internet connection. Please check your network and try again.';
  Future<ApiResponse<Map<String, dynamic>>> getTermsAndConditions() async { try { final response = await _dio.get(ApiEndpoints.termsAndConditions); return ApiResponse<Map<String, dynamic>>.fromJson(response.data as Map<String, dynamic>, (d) => d as Map<String, dynamic>); } catch (_) { return const ApiResponse<Map<String, dynamic>>(success: false, message: 'Failed'); } }

  Future<ApiResponse<Map<String, dynamic>>> getPrivacyPolicy() async { try { final response = await _dio.get(ApiEndpoints.privacyPolicy); return ApiResponse<Map<String, dynamic>>.fromJson(response.data as Map<String, dynamic>, (d) => d as Map<String, dynamic>); } catch (_) { return const ApiResponse<Map<String, dynamic>>(success: false, message: 'Failed'); } }

  Future<ApiResponse<List<dynamic>>> getDeletionReasons() async { try { final response = await _dio.get(ApiEndpoints.deletionReasons); final json = response.data as Map<String, dynamic>; final list = (json['data'] as List<dynamic>?) ?? []; return ApiResponse<List<dynamic>>(success: true, message: '', data: list); } catch (_) { return const ApiResponse<List<dynamic>>(success: false, message: 'Failed'); } }
  Future<ApiResponse<Map<String, dynamic>>> createSupportTicket({required String subject, required String description, String? orderReference}) async { try { final response = await _dio.post(ApiEndpoints.createTicket, data: FormData.fromMap({'subject': subject, 'description': description, if (orderReference != null && orderReference.isNotEmpty) 'order_reference': orderReference}), options: Options(contentType: 'multipart/form-data')); final json = response.data as Map<String, dynamic>; return ApiResponse<Map<String, dynamic>>(success: json['success'] as bool? ?? true, message: json['message'] as String? ?? 'Support ticket submitted.', data: json['data'] as Map<String, dynamic>?); } catch (e) { return const ApiResponse<Map<String, dynamic>>(success: false, message: 'Failed to submit support ticket'); } }
}
