import 'package:dio/dio.dart';
import '../../app/network/api_endpoints.dart';
import '../../app/network/dio_client.dart';
import '../../app/utils/app_logger.dart';
import '../local/app_data.dart';
import '../models/api_response.dart';
import '../models/order_model.dart';

class OrderRepository {
  final Dio _dio = DioClient.instance;

  static final Map<String, OrderModel> _orderCache = {};

  static void invalidateCache() {
    _orderCache.clear();
  }

  void _cacheOrder(OrderModel order) {
    if (order.id.isNotEmpty) _orderCache[order.id] = order;
    if (order.uuid != null && order.uuid!.isNotEmpty) _orderCache[order.uuid!] = order;
    if (order.orderNumber.isNotEmpty) _orderCache[order.orderNumber] = order;
  }

  String _resolveNumericId(String idOrUuid) {
    final trimmed = idOrUuid.trim();
    if (int.tryParse(trimmed) != null) return trimmed;
    final cached = _orderCache[trimmed];
    if (cached != null && cached.id.isNotEmpty && int.tryParse(cached.id) != null) {
      return cached.id;
    }
    return trimmed;
  }

  String _resolveTrackingUuid(String idOrUuid) {
    final trimmed = idOrUuid.trim();
    final cached = _orderCache[trimmed];
    if (cached?.uuid != null && cached!.uuid!.isNotEmpty) {
      return cached.uuid!;
    }
    return trimmed;
  }

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
      final parsed = listData
          .whereType<Map<String, dynamic>>()
          .map((e) => OrderModel.fromJson(e))
          .toList();
      for (final order in parsed) {
        _cacheOrder(order);
      }
      return parsed;
    }
    return [];
  }

  Future<ApiResponse<List<OrderModel>>> getActiveOrders({bool forceRefresh = false}) async {
    try {
      final response = await _dio.get(ApiEndpoints.activeOrders);
      final activeList = _parseOrders(response.data).where((o) => o.isActive).toList();
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
      AppLogger.w('[ORDERS] getActiveOrders error: $e');
      return const ApiResponse<List<OrderModel>>(
        success: false,
        message: '',
        data: [],
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
    final numericId = _resolveNumericId(orderId);

    // 1. Try /customer/profile/order/{numericId} if numericId is a number
    if (int.tryParse(numericId) != null) {
      try {
        final response = await _dio.get(ApiEndpoints.customerProfileOrderDetail(numericId));
        final dJson = response.data;
        if (dJson is Map<String, dynamic>) {
          final parsedOrder = OrderModel.fromJson(dJson);
          _cacheOrder(parsedOrder);
          AppLogger.i('[ORDERS] getOrderDetail SUCCESS | numericId: $numericId (requested: $orderId)');
          return ApiResponse<OrderModel>(
            success: dJson['success'] as bool? ?? true,
            message: dJson['message'] as String? ?? 'Order detail retrieved.',
            data: parsedOrder,
          );
        }
      } catch (e) {
        AppLogger.w('[ORDERS] getOrderDetail numericId failed: $numericId | $e');
      }
    }

    // 2. Fallback to /customer/orders/{numericId}/status
    try {
      final response = await _dio.get(ApiEndpoints.orderTracking(numericId));
      final raw = response.data;
      if (raw is Map<String, dynamic>) {
        final parsedOrder = OrderModel.fromJson(raw);
        _cacheOrder(parsedOrder);
        AppLogger.i('[ORDERS] getOrderDetail from tracking status SUCCESS | id: $numericId');
        return ApiResponse<OrderModel>(
          success: raw['success'] as bool? ?? true,
          message: raw['message'] as String? ?? 'Order detail retrieved.',
          data: parsedOrder,
        );
      }
    } catch (e) {
      AppLogger.w('[ORDERS] getOrderDetail tracking status fallback failed | $e');
    }

    // 3. In-memory cache fallback
    try {
      if (_orderCache.containsKey(orderId)) {
        return ApiResponse<OrderModel>(success: true, message: '', data: _orderCache[orderId]!);
      }
      if (_orderCache.containsKey(numericId)) {
        return ApiResponse<OrderModel>(success: true, message: '', data: _orderCache[numericId]!);
      }

      final activeRes = await getActiveOrders();
      if (activeRes.success && activeRes.data != null) {
        for (final o in activeRes.data!) {
          if (o.id == orderId || o.uuid == orderId || o.id == numericId || o.orderNumber == orderId) {
            return ApiResponse<OrderModel>(success: true, message: '', data: o);
          }
        }
      }

      final historyRes = await getOrderHistory();
      if (historyRes.success && historyRes.data != null) {
        for (final o in historyRes.data!) {
          if (o.id == orderId || o.uuid == orderId || o.id == numericId || o.orderNumber == orderId) {
            return ApiResponse<OrderModel>(success: true, message: '', data: o);
          }
        }
      }
    } catch (_) {}

    return const ApiResponse<OrderModel>(
      success: false,
      message: 'Failed to retrieve order detail',
    );
  }

  /// Live-tracking payload: restaurant/delivery coordinates, driver position
  /// and (optionally) a precomputed route polyline.
  Future<ApiResponse<OrderModel>> getOrderTracking(String orderId) async {
    final numericId = _resolveNumericId(orderId);
    try {
      final response = await _dio.get(ApiEndpoints.orderTracking(numericId));
      final raw = response.data;
      if (raw is Map<String, dynamic>) {
        final parsedOrder = OrderModel.fromJson(raw);
        _cacheOrder(parsedOrder);
        AppLogger.i('[ORDERS] getOrderTracking SUCCESS | id: $numericId (requested: $orderId)');
        return ApiResponse<OrderModel>(
          success: raw['success'] as bool? ?? true,
          message: raw['message'] as String? ?? '',
          data: parsedOrder,
        );
      }
    } catch (e) {
      AppLogger.w('[ORDERS] getOrderTracking endpoint fallback | $e');
    }
    return getOrderDetail(orderId);
  }

  Future<ApiResponse<bool>> cancelOrder(String orderIdOrUuid, {String? reason}) async {
    try {
      final targetId = _resolveNumericId(orderIdOrUuid);

      final params = <String, dynamic>{};
      if (reason != null && reason.trim().isNotEmpty) {
        params['reason'] = reason.trim();
      }

      final response = await _dio.post(
        ApiEndpoints.customerCancelOrder(targetId),
        queryParameters: params.isNotEmpty ? params : null,
        data: params.isNotEmpty ? params : null,
      );

      final success = (response.data as Map?)?['success'] as bool? ?? true;
      final msg = (response.data as Map?)?['message'] as String? ?? 'Order cancelled.';
      AppLogger.i('[ORDERS] cancelOrder SUCCESS | targetId: $targetId, reason: $reason');
      return ApiResponse<bool>(success: success, message: msg, data: success);
    } catch (e) {
      AppLogger.w('[ORDERS] cancelOrder error | $e');
      if (e is DioException && e.response != null) {
        final msg = (e.response!.data as Map?)?['message'] as String? ?? 'Failed to cancel order';
        return ApiResponse<bool>(success: false, message: msg, data: false);
      }
      return const ApiResponse<bool>(success: false, message: 'Failed to cancel order', data: false);
    }
  }

  Future<ApiResponse<List<String>>> getCancellationReasons() async {
    try {
      final response = await _dio.get(ApiEndpoints.cancellationReasons);

      final rawData = response.data['data'];
      List<String> list = [];
      if (rawData is List) {
        list = rawData.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
      }
      return ApiResponse<List<String>>(success: true, message: '', data: list);
    } catch (e) {
      AppLogger.w('[ORDERS] getCancellationReasons error | $e');
      return const ApiResponse<List<String>>(success: false, message: '', data: []);
    }
  }
}
