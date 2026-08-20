import 'package:swiftdrop_customer_app/export.dart';

class AddressRepository {
  final _dio = DioClient.instance;

  ApiResponse<void> _apiError(dynamic e) {
    if (e is DioException && e.response != null) {
      final body = e.response!.data;
      String message = 'Something went wrong';
      if (body is Map) {
        message = body['message'] as String? ?? message;
      }
      return ApiResponse(success: false, message: message, data: null);
    }
    return const ApiResponse(success: false, message: 'Network error. Please try again.', data: null);
  }

  Future<ApiResponse<Map<String, dynamic>>> getAddresses({int page = 1}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.customerAddresses,
        queryParameters: {'page': page},
      );
      return ApiResponse(
        success: true,
        message: '',
        data: response.data['data'] as Map<String, dynamic>,
      );
    } catch (_) {
      return const ApiResponse(
        success: true,
        message: '',
        data: {'addresses': [], 'meta': null},
      );
    }
  }

  Future<ApiResponse<dynamic>> saveAddress({
    required String label,
    required String addressLine1,
    required String addressLine2,
    required String city,
    required String county,
    required String postcode,
    required double lat,
    required double lng,
    String? deliveryInstructions,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.customerAddresses,
        data: {
          'label': label,
          'address_line_1': addressLine1.trim().isNotEmpty
              ? addressLine1.trim()
              : (addressLine2.trim().isNotEmpty ? addressLine2.trim() : 'Selected Location'),
          'address_line_2': addressLine2,
          'city': city.trim().isNotEmpty ? city.trim() : 'City',
          'county': county.trim().isNotEmpty ? county.trim() : 'County',
          'postcode': postcode,
          'lat': lat,
          'lng': lng,
          if (deliveryInstructions != null && deliveryInstructions.isNotEmpty)
            'delivery_instructions': deliveryInstructions,
        },
      );
      final success = response.data['success'] as bool? ?? false;
      return ApiResponse(
        success: success,
        message: response.data['message'] as String? ?? '',
        data: response.data['data'],
      );
    } catch (e) {
      return _apiError(e);
    }
  }

  Future<ApiResponse<dynamic>> updateAddress({
    required String id,
    required String label,
    required String addressLine1,
    required String addressLine2,
    required String city,
    required String county,
    required String postcode,
    required double lat,
    required double lng,
    String? deliveryInstructions,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.customerAddressUpdate(id),
        data: {
          '_method': 'PUT',
          'label': label,
          'address_line_1': addressLine1.trim().isNotEmpty
              ? addressLine1.trim()
              : (addressLine2.trim().isNotEmpty ? addressLine2.trim() : 'Selected Location'),
          'address_line_2': addressLine2,
          'city': city.trim().isNotEmpty ? city.trim() : 'City',
          'county': county.trim().isNotEmpty ? county.trim() : 'County',
          'postcode': postcode,
          'lat': lat,
          'lng': lng,
          if (deliveryInstructions != null && deliveryInstructions.isNotEmpty)
            'delivery_instructions': deliveryInstructions,
        },
      );
      final success = response.data['success'] as bool? ?? false;
      return ApiResponse(
        success: success,
        message: response.data['message'] as String? ?? '',
        data: response.data['data'],
      );
    } catch (e) {
      return _apiError(e);
    }
  }

  Future<ApiResponse<void>> deleteAddress(String id) async {
    try {
      final response = await _dio.delete(ApiEndpoints.customerAddressDelete(id));
      final success = response.data['success'] as bool? ?? false;
      return ApiResponse(success: success, message: response.data['message'] as String? ?? '', data: null);
    } catch (e) {
      return _apiError(e);
    }
  }

  Future<ApiResponse<void>> selectAddress(String id) async {
    try {
      final response = await _dio.post(ApiEndpoints.customerAddressSelect(id));
      final success = response.data['success'] as bool? ?? false;
      return ApiResponse(success: success, message: response.data['message'] as String? ?? '', data: null);
    } catch (e) {
      return _apiError(e);
    }
  }
}
