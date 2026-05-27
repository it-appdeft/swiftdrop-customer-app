import 'package:dio/dio.dart';
import '../../app/network/api_endpoints.dart';
import '../../app/network/dio_client.dart';
import '../models/api_response.dart';
import '../models/restaurant_detail_model.dart';

class RestaurantDetailRepository {
  final Dio _dio = DioClient.instance;

  Future<ApiResponse<RestaurantDetailModel>> getRestaurantDetail(
    int id, {
    String? q,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.customerRestaurantDetail(id),
        queryParameters: (q != null && q.isNotEmpty) ? {'q': q} : null,
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
