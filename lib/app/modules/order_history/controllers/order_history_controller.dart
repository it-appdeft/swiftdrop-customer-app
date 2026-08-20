import 'package:get/get.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../base/base_controller.dart';
import '../../../constants/app_constants.dart';

class OrderHistoryController extends BaseController {
  final OrderRepository _repo;
  OrderHistoryController(this._repo);

  final historyOrders = <OrderModel>[].obs;
  final RxBool hasMoreHistory = true.obs;
  final RxString searchQuery = ''.obs;
  int _historyPage = 1;

  List<OrderModel> get filteredOrders {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return historyOrders;
    return historyOrders.where((order) {
      final rName = order.displayRestaurantName.toLowerCase();
      if (rName.contains(query)) return true;
      for (final item in order.items) {
        if (item.name.toLowerCase().contains(query)) return true;
      }
      return false;
    }).toList();
  }

  Future<void> loadOrders({bool force = false}) async {
    if (isLoading.value && !force) return;
    await runAsync(() async {
      await _loadHistory();
    });
  }

  Future<void> _loadHistory() async {
    _historyPage = 1;
    final historyResult = await _repo.getOrderHistory(page: 1);
    if (historyResult.success && historyResult.data != null) {
      historyOrders.value = historyResult.data!;
      hasMoreHistory.value = historyResult.data!.length >= AppConstants.paginationLimit;
    }
  }

  Future<void> loadMoreHistory() async {
    if (!hasMoreHistory.value || isLoadingMore.value) return;
    isLoadingMore.value = true;
    _historyPage++;
    try {
      final result = await _repo.getOrderHistory(page: _historyPage);
      if (result.success && result.data != null) {
        historyOrders.addAll(result.data!);
        hasMoreHistory.value = result.data!.length >= AppConstants.paginationLimit;
      }
    } finally {
      isLoadingMore.value = false;
    }
  }
}
