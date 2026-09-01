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
      final response = await _dio.post(ApiEndpoints.customerCart, data: {
        'menu_item_id': menuItemId,
        'options': options,
        'quantity': quantity,
      });
      final msg = (response.data as Map?)?['message'] as String? ?? '';
      return ApiResponse(success: true, message: msg, data: true);
    } catch (e) {
      String msg = '';
      if (e is DioException) {
        msg = (e.response?.data as Map?)?['message'] as String? ?? '';
      }
      return ApiResponse(success: false, message: msg, data: false);
    }
  }

  Future<ApiResponse<bool>> updateCartItemQuantity(
      int cartItemId, int quantity, {List<int>? options}) async {
    try {
      final map = <String, dynamic>{
        'quantity': quantity,
        '_method': 'PUT',
      };
      if (options != null) {
        map['options'] = options;
      }
      final response = await _dio.post(ApiEndpoints.customerCartItem(cartItemId), data: map);
      final msg = (response.data as Map?)?['message'] as String? ?? '';
      return ApiResponse(success: true, message: msg, data: true);
    } catch (e) {
      String msg = '';
      if (e is DioException) {
        msg = (e.response?.data as Map?)?['message'] as String? ?? '';
      }
      return ApiResponse(success: false, message: msg, data: false);
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

  Future<ApiResponse<CheckoutModel>> getCheckout() async {
    try {
      final response = await _dio.get(ApiEndpoints.customerCheckout);
      final data = CheckoutModel.fromJson(response.data['data'] as Map<String, dynamic>);
      return ApiResponse(success: true, message: '', data: data);
    } catch (_) {
      return ApiResponse(success: false, message: '', data: null);
    }
  }

  Future<ApiResponse<bool>> clearCart() async {
    try {
      final response = await _dio.delete(ApiEndpoints.customerCart);
      final msg = (response.data as Map?)?['message'] as String? ?? '';
      return ApiResponse(success: true, message: msg, data: true);
    } catch (_) {
      return ApiResponse(success: false, message: '', data: false);
    }
  }

  Future<ApiResponse<bool>> applyCoupon(int couponId) async {
    try {
      final response = await _dio.post(ApiEndpoints.customerApplyCoupon, data: {
        'coupon_id': couponId,
      });
      final success = response.data['success'] as bool? ?? false;
      final msg = response.data['message'] as String? ?? '';
      return ApiResponse(success: success, message: msg, data: success);
    } catch (e) {
      return ApiResponse(success: false, message: AppUtils.extractErrorMessage(e), data: false);
    }
  }

  Future<ApiResponse<bool>> removeCoupon() async {
    try {
      final response = await _dio.delete(ApiEndpoints.customerApplyCoupon);
      final success = response.data['success'] as bool? ?? false;
      final msg = response.data['message'] as String? ?? '';
      return ApiResponse(success: success, message: msg, data: success);
    } catch (_) {
      try {
        final response = await _dio.post(ApiEndpoints.customerApplyCoupon, data: {
          'coupon_id': null,
        });
        final success = response.data['success'] as bool? ?? false;
        final msg = response.data['message'] as String? ?? '';
        return ApiResponse(success: success, message: msg, data: success);
      } catch (e) {
        return ApiResponse(success: false, message: AppUtils.extractErrorMessage(e), data: false);
      }
    }
  }

  Future<ApiResponse<bool>> updateCookingRequest(String request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.customerCookingRequest,
        queryParameters: {'special_instructions': request},
      );
      final success = response.data['success'] as bool? ?? false;
      final msg = response.data['message'] as String? ?? '';
      return ApiResponse(success: success, message: msg, data: success);
    } catch (e) {
      return ApiResponse(success: false, message: AppUtils.extractErrorMessage(e), data: false);
    }
  }

  Future<ApiResponse<bool>> placeOrder(int addressId) async {
    try {
      final response = await _dio.post(ApiEndpoints.customerCheckout, data: {
        'address_id': addressId,
      });
      final success = response.data['success'] as bool? ?? false;
      final msg = response.data['message'] as String? ?? '';
      return ApiResponse(success: success, message: msg, data: success);
    } catch (e) {
      return ApiResponse(success: false, message: AppUtils.extractErrorMessage(e), data: false);
    }
  }
}
