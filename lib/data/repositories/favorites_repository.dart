import 'package:dio/dio.dart';
import '../../app/network/api_endpoints.dart';
import '../../app/network/dio_client.dart';
import '../models/api_response.dart';

enum FavoriteType { restaurant, menuItem }

class FavoritesRepository {
  final Dio _dio = DioClient.instance;

  Future<ApiResponse<bool>> toggleFavorite(
    FavoriteType type,
    int id,
  ) async {
    try {
      final endpoint = type == FavoriteType.restaurant
          ? ApiEndpoints.favoriteRestaurant(id)
          : ApiEndpoints.favoriteMenuItem(id);
      final response = await _dio.post(endpoint);
      final body = response.data as Map<String, dynamic>?;
      final dataMap = body?['data'] as Map<String, dynamic>?;
      final bool isFavorited = dataMap?['favorited'] as bool? ?? true;
      final msg = body?['message'] as String? ??
          (isFavorited ? 'Added to favorites' : 'Removed from favorites');
      return ApiResponse(success: true, message: msg, data: isFavorited);
    } catch (e) {
      if (e is DioException && e.response != null) {
        final msg = (e.response!.data as Map?)?['message'] as String? ??
            'Something went wrong';
        return ApiResponse(success: false, message: msg, data: null);
      }
      return const ApiResponse(
        success: false,
        message: 'Network error. Please try again.',
        data: null,
      );
    }
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getFavoriteRestaurants() async {
    try {
      final response = await _dio.get(ApiEndpoints.favoriteRestaurants);
      final rawData = response.data['data'];
      final List rawList = rawData is List
          ? rawData
          : (rawData?['restaurants'] ?? rawData?['results'] ?? []);
      final list = rawList.cast<Map<String, dynamic>>();
      return ApiResponse(success: true, message: '', data: list);
    } catch (e) {
      return const ApiResponse(
        success: false,
        message: 'Failed to fetch favorites',
        data: null,
      );
    }
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getFavoriteItems() async {
    try {
      final response = await _dio.get(ApiEndpoints.favoriteMenuItems);
      final rawData = response.data['data'];
      final List rawList = rawData is List
          ? rawData
          : (rawData?['menu_items'] ?? rawData?['results'] ?? []);
      final list = rawList.cast<Map<String, dynamic>>();
      return ApiResponse(success: true, message: '', data: list);
    } catch (e) {
      return const ApiResponse(
        success: false,
        message: 'Failed to fetch favorites',
        data: null,
      );
    }
  }
}
