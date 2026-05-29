import 'package:dio/dio.dart';
import '../../app/network/api_endpoints.dart';
import '../../app/network/dio_client.dart';
import '../models/api_response.dart';

enum FavoriteType { restaurant, menuItem }

class FavoritesRepository {
  final Dio _dio = DioClient.instance;

  Future<ApiResponse<void>> toggleFavorite(
    FavoriteType type,
    int id,
  ) async {
    try {
      final endpoint = type == FavoriteType.restaurant
          ? ApiEndpoints.favoriteRestaurant(id)
          : ApiEndpoints.favoriteMenuItem(id);
      final response = await _dio.post(endpoint);
      final msg = (response.data as Map?)?['message'] as String? ?? '';
      return ApiResponse(success: true, message: msg, data: null);
    } catch (e) {
      if (e is DioException && e.response != null) {
        final msg = (e.response!.data as Map?)?['message'] as String? ?? 'Something went wrong';
        return ApiResponse(success: false, message: msg, data: null);
      }
      return const ApiResponse(success: false, message: 'Network error. Please try again.', data: null);
    }
  }
}
