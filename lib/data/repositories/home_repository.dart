import 'package:dio/dio.dart';
import '../../app/network/api_endpoints.dart';
import '../../app/network/dio_client.dart';
import '../models/api_response.dart';
import '../models/banner_model.dart';
import '../models/dashboard_model.dart';

class HomeRepository {
  final Dio _dio = DioClient.instance;

  Future<ApiResponse<List<BannerModel>>> getBanners() async {
    try {
      final response = await _dio.get(ApiEndpoints.customerBanners);
      final rawData = response.data['data'];
      List<BannerModel> list = [];
      if (rawData is List) {
        list = rawData
            .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
            .where((b) => b.status.isEmpty || b.status.toLowerCase() == 'active')
            .toList();
      }
      return ApiResponse<List<BannerModel>>(success: true, message: '', data: list);
    } catch (_) {
      return const ApiResponse<List<BannerModel>>(success: false, message: '', data: []);
    }
  }

 
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

  Future<ApiResponse<List<RestaurantModel>>> getTopPicks({
    int? foodItemId,
    double? lat,
    double? lng,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (foodItemId != null) params['food_item_id'] = foodItemId;
      if (lat != null) params['latitude'] = lat;
      if (lng != null) params['longitude'] = lng;
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
    double? lat,
    double? lng,
  }) async {
    try {
      final params = <String, dynamic>{'page': page};
      if (foodItemId != null) {
        params['search'] = foodItemId;
        params['food_item_id'] = foodItemId;
        params['food_type_id'] = foodItemId;
      }
      if (lat != null) params['latitude'] = lat;
      if (lng != null) params['longitude'] = lng;
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
    double? lat,
    double? lng,
  }) async {
    try {
      final params = <String, dynamic>{'search': q, 'page': page};
      if (offers) params['offers'] = 1;
      if (highestRated) params['highest_rated'] = 1;
      if (lat != null) params['latitude'] = lat;
      if (lng != null) params['longitude'] = lng;

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

  Future<ApiResponse<List<String>>> getSearchHistory() async {
    try {
      final response = await _dio.get(ApiEndpoints.customerSearchHistory);
      final rawData = response.data['data'];
      List<String> list = [];
      if (rawData is List) {
        list = rawData
            .map((e) => e is Map ? (e['query'] ?? e['keyword'] ?? e['name'] ?? '').toString() : e.toString())
            .where((e) => e.isNotEmpty)
            .toList();
      } else if (rawData is Map) {
        final rawQueries = rawData['queries'] ?? rawData['history'] ?? rawData['items'] ?? rawData['recent'] ?? [];
        if (rawQueries is List) {
          list = rawQueries
              .map((e) => e is Map ? (e['query'] ?? e['keyword'] ?? e['name'] ?? '').toString() : e.toString())
              .where((e) => e.isNotEmpty)
              .toList();
        }
      }
      return ApiResponse<List<String>>(success: true, message: '', data: list);
    } catch (_) {
      return const ApiResponse<List<String>>(success: false, message: '', data: []);
    }
  }

  Future<ApiResponse<bool>> clearSearchHistory() async {
    try {
      final response = await _dio.delete(ApiEndpoints.customerSearchHistory);
      final msg = (response.data as Map?)?['message'] as String? ?? 'Search history cleared.';
      return ApiResponse<bool>(success: true, message: msg, data: true);
    } catch (e) {
      if (e is DioException && e.response != null) {
        final msg = (e.response!.data as Map?)?['message'] as String? ?? 'Failed to clear history';
        return ApiResponse<bool>(success: false, message: msg, data: false);
      }
      return const ApiResponse<bool>(success: false, message: 'Network error', data: false);
    }
  }
}
