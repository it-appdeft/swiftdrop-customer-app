import 'package:dio/dio.dart';
import '../../app/network/api_endpoints.dart';
import '../../app/network/dio_client.dart';
import '../models/api_response.dart';
import '../models/dashboard_model.dart';

class HomeRepository {
  final Dio _dio = DioClient.instance;

  Future<ApiResponse<DashboardModel>> getDashboard({
    int restaurantsPage = 1,
    int? foodItemId,
  }) async {
    try {
      final params = <String, dynamic>{'restaurants_page': restaurantsPage};
      if (foodItemId != null) params['food_item_id'] = foodItemId;
      final response = await _dio.get(
        ApiEndpoints.customerDashboard,
        queryParameters: params,
      );
      final model = DashboardModel.fromJson(response.data['data'] as Map<String, dynamic>);
      return ApiResponse<DashboardModel>(success: true, message: '', data: model);
    } catch (_) {
      return ApiResponse<DashboardModel>(success: false, message: '', data: null);
    }
  }

  Future<ApiResponse<SearchResultModel>> search(
    String q, {
    bool offers = false,
    bool highestRated = false,
  }) async {
    try {
      final params = <String, dynamic>{'search': q};
      if (offers) params['offers'] = 1;
      if (highestRated) params['highest_rated'] = 1;
      final response = await _dio.get(
        ApiEndpoints.customerSearch,
        queryParameters: params,
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
