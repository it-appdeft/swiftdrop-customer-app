import 'package:dio/dio.dart';
import '../../app/network/api_endpoints.dart';
import '../../app/network/dio_client.dart';
import '../local/app_data.dart';
import '../models/api_response.dart';

class HomeRepository {
  final Dio _dio = DioClient.instance;

  Future<ApiResponse<List<Map<String, dynamic>>>> getCategories() async {
    try {
      final response = await _dio.get(ApiEndpoints.categories);
      final list = (response.data['data'] as List).cast<Map<String, dynamic>>();
      return ApiResponse<List<Map<String, dynamic>>>(success: true, message: '', data: list);
    } catch (_) {
      return ApiResponse<List<Map<String, dynamic>>>(
        success: true,
        message: '',
        data: AppData.categories,
      );
    }
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getFeaturedRestaurants() async {
    try {
      final response = await _dio.get(ApiEndpoints.restaurants);
      final list = (response.data['data'] as List).cast<Map<String, dynamic>>();
      return ApiResponse<List<Map<String, dynamic>>>(success: true, message: '', data: list);
    } catch (_) {
      return ApiResponse<List<Map<String, dynamic>>>(
        success: true,
        message: '',
        data: AppData.featuredRestaurants,
      );
    }
  }
}
