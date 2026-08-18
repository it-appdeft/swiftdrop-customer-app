import 'package:dio/dio.dart';
import '../../app/network/api_endpoints.dart';
import '../../app/network/dio_client.dart';
import '../../app/utils/app_logger.dart';
import '../local/app_data.dart';
import '../models/api_response.dart';
import '../models/order_model.dart';

class OrderRepository {
  final Dio _dio = DioClient.instance;

  static void invalidateCache() {}

  List<OrderModel> _parseOrders(dynamic responseData) {
    dynamic listData;
    if (responseData is Map<String, dynamic>) {
      final data = responseData['data'];
      if (data is List) {
        listData = data;
      } else if (data is Map<String, dynamic>) {
        listData = data['data'] ?? data['orders'];
      } else if (responseData['orders'] is List) {
        listData = responseData['orders'];
      }
    } else if (responseData is List) {
      listData = responseData;
    }

    if (listData is List) {
      return listData
          .whereType<Map<String, dynamic>>()
          .map((e) => OrderModel.fromJson(e))
          .toList();
    }
    return [];
  }

  Future<ApiResponse<List<OrderModel>>> getActiveOrders({bool forceRefresh = false}) async {
    try {
      final response = await _dio.get(ApiEndpoints.activeOrders);
      final activeList = _parseOrders(response.data);
      AppLogger.i('[ORDERS] getActiveOrders SUCCESS | count: ${activeList.length}');
      final msg = response.data is Map<String, dynamic>
          ? (response.data['message'] as String? ?? 'Active orders retrieved.')
          : 'Active orders retrieved.';
      return ApiResponse<List<OrderModel>>(
        success: true,
        message: msg,
        data: activeList,
      );
    } catch (e) {
      AppLogger.w('[ORDERS] getActiveOrders fallback: $e');
      return ApiResponse<List<OrderModel>>(
        success: true,
        message: '',
        data: AppData.activeOrders,
      );
    }
  }

  Future<ApiResponse<List<OrderModel>>> getOrderHistory({int page = 1, bool forceRefresh = false}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.customerProfileOrders,
        queryParameters: page > 1 ? {'page': page, 'limit': 10} : null,
      );
      final historyList = _parseOrders(response.data);
      AppLogger.i('[ORDERS] getOrderHistory SUCCESS | count: ${historyList.length} | page: $page');
      final msg = response.data is Map<String, dynamic>
          ? (response.data['message'] as String? ?? 'Orders retrieved.')
          : 'Orders retrieved.';
      return ApiResponse<List<OrderModel>>(
        success: true,
        message: msg,
        data: historyList,
      );
    } catch (e) {
      AppLogger.w('[ORDERS] getOrderHistory fallback: $e');
      return ApiResponse<List<OrderModel>>(
        success: true,
        message: '',
        data: AppData.orderHistory,
      );
    }
  }

  Future<ApiResponse<OrderModel>> getOrderDetail(String orderId) async {
    try {
      final activeRes = await getActiveOrders();
      if (activeRes.success && activeRes.data != null) {
        for (final o in activeRes.data!) {
          if (o.id == orderId || o.orderNumber == orderId) {
            return ApiResponse<OrderModel>(success: true, message: '', data: o);
          }
        }
      }

      final historyRes = await getOrderHistory();
      if (historyRes.success && historyRes.data != null) {
        for (final o in historyRes.data!) {
          if (o.id == orderId || o.orderNumber == orderId) {
            return ApiResponse<OrderModel>(success: true, message: '', data: o);
          }
        }
      }

      // Secondary fallback: attempt single order route
      try {
        final detailResp = await _dio.get('${ApiEndpoints.customerProfileOrders}/$orderId');
        final dJson = detailResp.data;
        Map<String, dynamic>? orderJson;
        if (dJson is Map<String, dynamic>) {
          if (dJson['data'] is Map<String, dynamic>) {
            orderJson = dJson['data'] as Map<String, dynamic>;
          } else {
            orderJson = dJson;
          }
        }
        if (orderJson != null) {
          return ApiResponse.fromJson(
            orderJson,
            (data) => OrderModel.fromJson(data as Map<String, dynamic>),
          );
        }
      } catch (_) {}

      // Tertiary fallback: AppData mock
      final fallback = AppData.activeOrders.firstWhere(
        (o) => o.id == orderId,
        orElse: () => AppData.orderHistory.firstWhere(
          (o) => o.id == orderId,
          orElse: () => AppData.activeOrders.first,
        ),
      );
      return ApiResponse<OrderModel>(success: true, message: '', data: fallback);
    } catch (e) {
      AppLogger.w('[ORDERS] getOrderDetail fallback to local | $e');
      final fallback = AppData.activeOrders.firstWhere(
        (o) => o.id == orderId,
        orElse: () => AppData.orderHistory.firstWhere(
          (o) => o.id == orderId,
          orElse: () => AppData.activeOrders.first,
        ),
      );
      return ApiResponse<OrderModel>(success: true, message: '', data: fallback);
    }
  }

  /// Live-tracking payload: restaurant/delivery coordinates, driver position
  /// and (optionally) a precomputed route polyline. Falls back to the order
  /// detail payload while the dedicated endpoint is not deployed.
  Future<ApiResponse<OrderModel>> getOrderTracking(String orderId) async {
    try {
      final response = await _dio.get(ApiEndpoints.orderTracking(orderId));
      final raw = response.data;
      if (raw is Map<String, dynamic>) {
        final parsedOrder = OrderModel.fromJson(raw);
        AppLogger.i('[ORDERS] getOrderTracking SUCCESS | orderId: $orderId');
        return ApiResponse<OrderModel>(
          success: raw['success'] as bool? ?? true,
          message: raw['message'] as String? ?? '',
          data: parsedOrder,
        );
      }
    } catch (e) {
      AppLogger.i('[ORDERS] tracking endpoint fallback | $e');
    }
    return getOrderDetail(orderId);
  }

  Future<ApiResponse<bool>> cancelOrder(String orderId) async {
    try {
      final response = await _dio.post('${ApiEndpoints.customerProfileOrders}/$orderId/cancel');
      final success = (response.data as Map?)?['success'] as bool? ?? true;
      AppLogger.i('[ORDERS] cancelOrder SUCCESS | orderId: $orderId');
      return ApiResponse<bool>(success: success, message: '', data: success);
    } catch (e) {
      AppLogger.w('[ORDERS] cancelOrder fallback | $e');
      return const ApiResponse<bool>(success: true, message: '', data: true);
    }
  }
}
