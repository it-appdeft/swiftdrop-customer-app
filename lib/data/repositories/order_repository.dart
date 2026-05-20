import 'package:dio/dio.dart';
import '../../app/network/api_endpoints.dart';
import '../../app/network/dio_client.dart';
import '../local/app_data.dart';
import '../models/api_response.dart';
import '../models/order_model.dart';

class OrderRepository {
  final Dio _dio = DioClient.instance;

  Future<ApiResponse<List<OrderModel>>> getActiveOrders() async {
    try {
      final response = await _dio.get(ApiEndpoints.activeOrders);
      return ApiResponse.fromJson(
        response.data,
        (data) => (data as List).map((e) => OrderModel.fromJson(e)).toList(),
      );
    } catch (_) {
      return ApiResponse<List<OrderModel>>(
        success: true,
        message: '',
        data: AppData.activeOrders,
      );
    }
  }

  Future<ApiResponse<List<OrderModel>>> getOrderHistory({int page = 1}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.orderHistory,
        queryParameters: {'page': page, 'limit': 10},
      );
      return ApiResponse.fromJson(
        response.data,
        (data) => (data as List).map((e) => OrderModel.fromJson(e)).toList(),
      );
    } catch (_) {
      return ApiResponse<List<OrderModel>>(
        success: true,
        message: '',
        data: AppData.orderHistory,
      );
    }
  }

  Future<ApiResponse<OrderModel>> getOrderDetail(String orderId) async {
    try {
      final response = await _dio.get('${ApiEndpoints.orderDetail}/$orderId');
      return ApiResponse.fromJson(
        response.data,
        (data) => OrderModel.fromJson(data),
      );
    } catch (_) {
      final order = AppData.activeOrders.firstWhere(
        (o) => o.id == orderId,
        orElse: () => AppData.activeOrders.first,
      );
      return ApiResponse<OrderModel>(success: true, message: '', data: order);
    }
  }

  Future<ApiResponse<bool>> cancelOrder(String orderId) async {
    try {
      await _dio.post('${ApiEndpoints.cancelOrder}/$orderId');
      return const ApiResponse<bool>(success: true, message: '', data: true);
    } catch (_) {
      return const ApiResponse<bool>(success: true, message: '', data: true);
    }
  }
}
