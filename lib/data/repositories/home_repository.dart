import 'package:dio/dio.dart';
import '../../app/network/api_endpoints.dart';
import '../../app/network/dio_client.dart';
import '../models/api_response.dart';
import '../models/dashboard_model.dart';

class HomeRepository {
  final Dio _dio = DioClient.instance;

  Future<ApiResponse<List<FoodItemModel>>> getFoodItems() async {
    try {
      final response = await _dio.get(ApiEndpoints.customerFoodItems);
      final list = (response.data['data'] as List)
          .map((e) => FoodItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResponse<List<FoodItemModel>>(success: true, message: '', data: list);
    } catch (_) {
      return ApiResponse<List<FoodItemModel>>(success: false, message: '', data: null);
    }
  }

  Future<ApiResponse<List<RestaurantModel>>> getTopPicks({int? foodItemId}) async {
    try {
      final params = <String, dynamic>{};
      if (foodItemId != null) params['food_item_id'] = foodItemId;
      final response = await _dio.get(
        ApiEndpoints.customerTopPicks,
        queryParameters: params.isEmpty ? null : params,
      );
      final list = (response.data['data'] as List)
          .map((e) => RestaurantModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResponse<List<RestaurantModel>>(success: true, message: '', data: list);
    } catch (_) {
      return ApiResponse<List<RestaurantModel>>(success: false, message: '', data: null);
    }
  }

  Future<ApiResponse<RestaurantsPageModel>> getRestaurants({
    int page = 1,
    int? foodItemId,
  }) async {
    try {
      final params = <String, dynamic>{'page': page};
      if (foodItemId != null) params['search'] = foodItemId;
      final response = await _dio.get(
        ApiEndpoints.customerRestaurants,
        queryParameters: params,
      );
      final model = RestaurantsPageModel.fromJson(
          response.data['data'] as Map<String, dynamic>);
      return ApiResponse<RestaurantsPageModel>(success: true, message: '', data: model);
    } catch (_) {
      return ApiResponse<RestaurantsPageModel>(success: false, message: '', data: null);
    }
  }

  Future<ApiResponse<SearchResultModel>> search(
    String q, {
    bool offers = false,
    bool highestRated = false,
    int page = 1,
    bool isItems = false,
  }) async {
    try {
      final params = <String, dynamic>{'search': q, 'page': page};
      if (offers) params['offers'] = 1;
      if (highestRated) params['highest_rated'] = 1;

      final endpoint = isItems
          ? ApiEndpoints.customerSearchItems
          : ApiEndpoints.customerSearchRestaurants;

      final response = await _dio.get(
        endpoint,
        queryParameters: params,
      );
      final model = SearchResultModel.fromJson(response.data);
      return ApiResponse<SearchResultModel>(success: true, message: '', data: model);
    } catch (_) {
      return ApiResponse<SearchResultModel>(success: false, message: '', data: null);
    }
  }

  Future<ApiResponse<SearchResultModel>> getRecent() async {
    try {
      final response = await _dio.get(ApiEndpoints.customerSearchHistory);
      final model = SearchResultModel.fromJson(response.data);
      return ApiResponse<SearchResultModel>(success: true, message: '', data: model);
    } catch (_) {
      return ApiResponse<SearchResultModel>(success: false, message: '', data: null);
    }
  }
}
