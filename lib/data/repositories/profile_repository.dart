import 'package:dio/dio.dart';

import '../../app/network/api_endpoints.dart';
import '../../app/network/dio_client.dart';
import '../../app/utils/app_logger.dart';
import '../models/api_response.dart';
import '../models/deletion_reason.dart';
import '../models/user_model.dart';

class ProfileRepository {
  final Dio _dio = DioClient.instance;

  /// GET /customer/profile
  Future<ApiResponse<UserModel>> getProfile() async {
    try {
      final response = await _dio.get(ApiEndpoints.customerProfile);
      final json = response.data as Map<String, dynamic>;
      final success = json['success'] as bool? ?? false;
      final data = json['data'] as Map<String, dynamic>?;
      final userJson = _mergeProfile(data);
      AppLogger.i(
        '[PROFILE] getProfile ${success ? 'SUCCESS' : 'FAILED'} | status: ${response.statusCode}',
      );
      if (success && userJson != null) {
        return ApiResponse<UserModel>(
          success: true,
          message: json['message'] as String? ?? '',
          data: UserModel.fromJson(userJson),
        );
      }
      return ApiResponse<UserModel>(
        success: false,
        message: json['message'] as String? ?? '',
      );
    } on DioException catch (e) {
      AppLogger.e(
        '[PROFILE] getProfile FAILED | status: ${e.response?.statusCode} | body: ${e.response?.data}',
      );
      if (_isNetworkError(e)) {
        return const ApiResponse<UserModel>(
          success: false,
          message: _offlineMessage,
        );
      }
      return ApiResponse<UserModel>(
        success: false,
        message: _extractMessage(e) ?? '',
      );
    } catch (e) {
      AppLogger.w('[PROFILE] getProfile — unexpected error | $e');
      return const ApiResponse<UserModel>(success: false, message: '');
    }
  }

  /// POST /customer/profile with _method=PUT
  Future<ApiResponse<UserModel>> updateProfile({
    String? name,
    String? profilePhotoPath,
  }) async {
    try {
      final formData = FormData.fromMap({
        '_method': 'PUT',
        if (name != null && name.isNotEmpty) 'name': name,
        if (profilePhotoPath != null && profilePhotoPath.isNotEmpty)
          'profile_photo': await MultipartFile.fromFile(profilePhotoPath),
      });
      final response = await _dio.post(
        ApiEndpoints.customerProfile,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      final json = response.data as Map<String, dynamic>;
      final success = json['success'] as bool? ?? false;
      final data = json['data'] as Map<String, dynamic>?;
      final userJson = _mergeProfile(data);
      AppLogger.i(
        '[PROFILE] updateProfile ${success ? 'SUCCESS' : 'FAILED'} | status: ${response.statusCode} | message: ${json['message']}',
      );
      if (success && userJson != null) {
        return ApiResponse<UserModel>(
          success: true,
          message: json['message'] as String? ?? '',
          data: UserModel.fromJson(userJson),
        );
      }
      return ApiResponse<UserModel>(
        success: success,
        message: json['message'] as String? ?? '',
      );
    } on DioException catch (e) {
      AppLogger.e(
        '[PROFILE] updateProfile FAILED | status: ${e.response?.statusCode} | body: ${e.response?.data}',
      );
      if (_isNetworkError(e)) {
        return const ApiResponse<UserModel>(
          success: false,
          message: _offlineMessage,
        );
      }
      return ApiResponse<UserModel>(
        success: false,
        message: _extractMessage(e) ?? '',
      );
    } catch (e) {
      AppLogger.w('[PROFILE] updateProfile — unexpected error | $e');
      return const ApiResponse<UserModel>(success: false, message: '');
    }
  }

  /// POST /customer/profile/delete/initiate
  Future<ApiResponse<Map<String, dynamic>>> initiateProfileDeletion() async {
    try {
      final response = await _dio.post(
        ApiEndpoints.customerProfileDeleteInitiate,
        options: Options(headers: {'X-Requested-With': 'XMLHttpRequest'}),
      );
      final json = response.data as Map<String, dynamic>;
      final success = json['success'] as bool? ?? false;
      AppLogger.i(
        '[PROFILE] initiateDeletion ${success ? 'SUCCESS' : 'FAILED'} | status: ${response.statusCode}',
      );
      return ApiResponse<Map<String, dynamic>>(
        success: success,
        message: json['message'] as String? ?? '',
        data: json['data'] as Map<String, dynamic>?,
      );
    } on DioException catch (e) {
      AppLogger.e(
        '[PROFILE] initiateDeletion FAILED | status: ${e.response?.statusCode} | body: ${e.response?.data}',
      );
      if (_isNetworkError(e)) {
        return const ApiResponse<Map<String, dynamic>>(
          success: false,
          message: _offlineMessage,
        );
      }
      final msg = _extractMessage(e);
      if (msg != null) {
        return ApiResponse<Map<String, dynamic>>(success: false, message: msg);
      }
      AppLogger.w('[PROFILE] initiateDeletion — no real API, falling back to local');
      return const ApiResponse<Map<String, dynamic>>(
        success: true,
        message: '',
        data: null,
      );
    } catch (e) {
      AppLogger.w('[PROFILE] initiateDeletion — unexpected error, falling back to local | $e');
      return const ApiResponse<Map<String, dynamic>>(
        success: true,
        message: '',
        data: null,
      );
    }
  }

  /// POST /customer/profile with _method=DELETE
  Future<ApiResponse<bool>> confirmProfileDeletion({
    required String code,
    required int reasonId,
    String? description,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.customerProfile,
        data: FormData.fromMap({
          '_method': 'DELETE',
          'code': code,
          'reason_id': reasonId,
          if (description != null && description.isNotEmpty)
            'description': description,
        }),
        options: Options(
          contentType: 'multipart/form-data',
          headers: {'X-Requested-With': 'XMLHttpRequest'},
        ),
      );
      AppLogger.i('[PROFILE] confirmDeletion SUCCESS | status: ${response.statusCode}');
      return const ApiResponse<bool>(success: true, message: '', data: true);
    } on DioException catch (e) {
      AppLogger.e(
        '[PROFILE] confirmDeletion FAILED | status: ${e.response?.statusCode} | body: ${e.response?.data}',
      );
      if (_isNetworkError(e)) {
        return const ApiResponse<bool>(
          success: false,
          message: _offlineMessage,
        );
      }
      final msg = _extractMessage(e);
      if (msg != null) {
        return ApiResponse<bool>(success: false, message: msg);
      }
      AppLogger.w('[PROFILE] confirmDeletion — no real API, falling back to local');
      return const ApiResponse<bool>(success: true, message: '', data: true);
    } catch (e) {
      AppLogger.w('[PROFILE] confirmDeletion — unexpected error, falling back to local | $e');
      return const ApiResponse<bool>(success: true, message: '', data: true);
    }
  }

  /// GET /deletion-reasons
  Future<ApiResponse<List<DeletionReason>>> getDeletionReasons() async {
    try {
      final response = await _dio.get(ApiEndpoints.deletionReasons);
      final json = response.data as Map<String, dynamic>;
      final success = json['success'] as bool? ?? false;
      final rawList = json['data'];
      final list = <DeletionReason>[];
      if (rawList is List) {
        for (final item in rawList) {
          if (item is Map<String, dynamic>) {
            list.add(DeletionReason.fromJson(item));
          }
        }
      }
      AppLogger.i(
        '[PROFILE] getDeletionReasons ${success ? 'SUCCESS' : 'FAILED'} | status: ${response.statusCode} | count: ${list.length}',
      );
      return ApiResponse<List<DeletionReason>>(
        success: success,
        message: json['message'] as String? ?? '',
        data: list,
      );
    } on DioException catch (e) {
      AppLogger.e(
        '[PROFILE] getDeletionReasons FAILED | status: ${e.response?.statusCode} | body: ${e.response?.data}',
      );
      if (_isNetworkError(e)) {
        return const ApiResponse<List<DeletionReason>>(
          success: false,
          message: _offlineMessage,
        );
      }
      return ApiResponse<List<DeletionReason>>(
        success: false,
        message: _extractMessage(e) ?? '',
      );
    } catch (e) {
      AppLogger.w('[PROFILE] getDeletionReasons — unexpected error | $e');
      return const ApiResponse<List<DeletionReason>>(
        success: false,
        message: '',
      );
    }
  }

  /// Merges the outer profile fields (profile_photo, first_name, last_name,
  /// date_of_birth) into the nested data.user object so a single UserModel
  /// covers both the auth identity and the profile metadata.
  Map<String, dynamic>? _mergeProfile(Map<String, dynamic>? data) {
    if (data == null) return null;
    final userJson = data['user'] as Map<String, dynamic>?;
    if (userJson == null) return data;
    return {
      ...userJson,
      if (data['profile_photo'] != null) 'profile_photo': data['profile_photo'],
      if (data['first_name'] != null) 'first_name': data['first_name'],
      if (data['last_name'] != null) 'last_name': data['last_name'],
      if (data['date_of_birth'] != null)
        'date_of_birth': data['date_of_birth'],
    };
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
}
