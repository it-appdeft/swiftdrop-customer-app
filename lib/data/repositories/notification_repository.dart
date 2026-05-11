import 'package:dio/dio.dart';
import '../../app/network/api_endpoints.dart';
import '../../app/network/dio_client.dart';
import '../local/app_data.dart';
import '../models/api_response.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final Dio _dio = DioClient.instance;

  Future<ApiResponse<List<NotificationModel>>> getNotifications({int page = 1}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.notifications,
        queryParameters: {'page': page, 'limit': 10},
      );
      return ApiResponse.fromJson(
        response.data,
        (data) => (data as List).map((e) => NotificationModel.fromJson(e)).toList(),
      );
    } catch (_) {
      return ApiResponse<List<NotificationModel>>(
        success: true,
        message: '',
        data: AppData.notifications,
      );
    }
  }

  Future<ApiResponse<bool>> markAsRead(String notificationId) async {
    try {
      await _dio.post('${ApiEndpoints.markNotificationRead}/$notificationId');
      return const ApiResponse<bool>(success: true, message: '', data: true);
    } catch (_) {
      return const ApiResponse<bool>(success: true, message: '', data: true);
    }
  }

  Future<ApiResponse<bool>> markAllAsRead() async {
    try {
      await _dio.post(ApiEndpoints.markNotificationRead);
      return const ApiResponse<bool>(success: true, message: '', data: true);
    } catch (_) {
      return const ApiResponse<bool>(success: true, message: '', data: true);
    }
  }
}
