import 'package:dio/dio.dart';
import '../../app/network/api_endpoints.dart';
import '../../app/network/dio_client.dart';
import '../models/api_response.dart';
import '../models/restaurant_detail_model.dart';

class RestaurantDetailRepository {
  final Dio _dio = DioClient.instance;

  Future<ApiResponse<RestaurantDetailModel>> getRestaurantDetail(
    int id, {
    String? search,
    String? diet,
    bool minRating4 = false,
    int page = 1,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (diet != null) params['diet'] = diet;
      if (minRating4) params['min_rating'] = 4;
      if (page > 1) params['page'] = page;

      final response = await _dio.get(
        ApiEndpoints.customerRestaurantDetail(id),
        queryParameters: params.isNotEmpty ? params : null,
      );
      final model = RestaurantDetailModel.fromJson(
          response.data['data'] as Map<String, dynamic>);
      return ApiResponse<RestaurantDetailModel>(
          success: true, message: '', data: model);
    } catch (_) {
      return ApiResponse<RestaurantDetailModel>(
          success: false, message: '', data: null);
    }
  }
}
