import 'package:swiftdrop_customer_app/export.dart';

class CartRepository {
  final _dio = DioClient.instance;

  Future<ApiResponse<CartApiResponse>> getCart() async {
    try {
      final response = await _dio.get(ApiEndpoints.customerCart);
      final data = CartApiResponse.fromJson(
          response.data['data'] as Map<String, dynamic>);
      return ApiResponse(success: true, message: '', data: data);
    } catch (_) {
      return ApiResponse(success: false, message: '', data: null);
    }
  }

  Future<ApiResponse<bool>> addToCart({
    required int menuItemId,
    required List<int> options,
    required int quantity,
  }) async {
    try {
      await _dio.post(ApiEndpoints.customerCart, data: {
        'menu_item_id': menuItemId,
        'options': options,
        'quantity': quantity,
      });
      return ApiResponse(success: true, message: '', data: true);
    } catch (_) {
      return ApiResponse(success: false, message: '', data: false);
    }
  }

  Future<ApiResponse<bool>> updateCartItemQuantity(
      int cartItemId, int quantity) async {
    try {
      await _dio.post(ApiEndpoints.customerCartItem(cartItemId), data: {
        'quantity': quantity,
        '_method': 'PUT',
      });
      return ApiResponse(success: true, message: '', data: true);
    } catch (_) {
      return ApiResponse(success: false, message: '', data: false);
    }
  }

  Future<ApiResponse<bool>> removeCartItem(int cartItemId) async {
    try {
      await _dio.delete(ApiEndpoints.customerCartItem(cartItemId));
      return ApiResponse(success: true, message: '', data: true);
    } catch (_) {
      return ApiResponse(success: false, message: '', data: false);
    }
  }

  Future<ApiResponse<bool>> clearCart() async {
    try {
      await _dio.delete(ApiEndpoints.customerCart);
      return ApiResponse(success: true, message: '', data: true);
    } catch (_) {
      return ApiResponse(success: false, message: '', data: false);
    }
  }
}
