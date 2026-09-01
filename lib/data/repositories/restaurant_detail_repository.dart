import 'package:dio/dio.dart';
import '../../app/network/api_endpoints.dart';
import '../../app/network/dio_client.dart';
import '../../app/utils/app_logger.dart';
import '../../app/utils/app_utils.dart';
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

      final rawData = response.data['data'];
      if (rawData == null || rawData is! Map) {
        AppLogger.w('Restaurant detail data is null or not a Map for id $id: ${response.data}');
        return const ApiResponse<RestaurantDetailModel>(
          success: false,
          message: 'Invalid data returned from server',
          data: null,
        );
      }

      final mapData = rawData is Map<String, dynamic>
          ? rawData
          : Map<String, dynamic>.from(rawData);

      final model = RestaurantDetailModel.fromJson(mapData);
      return ApiResponse<RestaurantDetailModel>(
        success: true,
        message: response.data['message']?.toString() ?? '',
        data: model,
      );
    } catch (e, stack) {
      AppLogger.e('RestaurantDetailRepository error for restaurant $id: $e\n$stack');
      return ApiResponse<RestaurantDetailModel>(
        success: false,
        message: AppUtils.extractErrorMessage(e),
        data: null,
      );
    }
  }
}

