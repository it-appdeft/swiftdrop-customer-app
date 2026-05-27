import 'package:dio/dio.dart';
import '../../app/network/api_endpoints.dart';
import '../../app/network/dio_client.dart';
import '../models/api_response.dart';
import '../models/dashboard_model.dart';

class HomeRepository {
  final Dio _dio = DioClient.instance;

  Future<ApiResponse<DashboardModel>> getDashboard() async {
    try {
      final response = await _dio.get(ApiEndpoints.customerDashboard);
      final model = DashboardModel.fromJson(response.data['data'] as Map<String, dynamic>);
      return ApiResponse<DashboardModel>(success: true, message: '', data: model);
    } catch (_) {
      return ApiResponse<DashboardModel>(success: false, message: '', data: null);
    }
  }

  Future<ApiResponse<SearchResultModel>> search(String q) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.customerSearch,
        queryParameters: {'q': q},
      );
      final model = SearchResultModel.fromJson(response.data['data'] as Map<String, dynamic>);
      return ApiResponse<SearchResultModel>(success: true, message: '', data: model);
    } catch (_) {
      return ApiResponse<SearchResultModel>(success: false, message: '', data: null);
    }
  }

  Future<ApiResponse<SearchResultModel>> getRecent() async {
    try {
      final response = await _dio.get(ApiEndpoints.customerSearch);
      final model = SearchResultModel.fromJson(response.data['data'] as Map<String, dynamic>);
      return ApiResponse<SearchResultModel>(success: true, message: '', data: model);
    } catch (_) {
      return ApiResponse<SearchResultModel>(success: false, message: '', data: null);
    }
  }
}
