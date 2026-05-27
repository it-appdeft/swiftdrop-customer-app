import 'dart:async';
import 'package:swiftdrop_customer_app/export.dart';
import '../../../modules/cart/controllers/cart_controller.dart';

class RestaurantDetailController extends BaseController {
  final RestaurantDetailRepository _repo;
  RestaurantDetailController(this._repo);

  final Rx<RestaurantDetailModel?> detail = Rx(null);

  int _restaurantId = 0;
  Timer? _searchDebounce;

  final searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxInt selectedFilterIndex = 2.obs;
  final RxBool isVegSelected = false.obs;
  final RxBool isNonVegSelected = false.obs;
  final RxBool isRatingsSelected = false.obs;
  final RxBool isBestsellerSelected = false.obs;
  final RxBool showCartFloatingBar = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    final id = (args?['id'] as num?)?.toInt() ?? 0;
    _restaurantId = id;
    final q = args?['q'] as String? ?? '';
    if (q.isNotEmpty) {
      searchQuery.value = q;
      searchController.text = q;
    }
    if (id > 0) _loadDetail(id, q: q.isEmpty ? null : q);
    _refreshCart();

    ever(searchQuery, (_) {
      _searchDebounce?.cancel();
      _searchDebounce = Timer(const Duration(milliseconds: 500), () {
        if (_restaurantId > 0) {
          final query = searchQuery.value.trim();
          _loadDetail(_restaurantId, q: query.isEmpty ? null : query);
        }
      });
    });
  }

  void searchNow() {
    _searchDebounce?.cancel();
    final query = searchQuery.value.trim();
    if (_restaurantId > 0) _loadDetail(_restaurantId, q: query.isEmpty ? null : query);
  }

  void _refreshCart() {
    try {
      final cart = Get.find<CartController>();
      cart.fetchCart().then((_) {
        if (cart.items.isNotEmpty) showCartFloatingBar.value = true;
      });
    } catch (_) {}
  }

  Future<void> _loadDetail(int id, {String? q}) async {
    await runAsync(() async {
      final result = await _repo.getRestaurantDetail(id, q: q);
      if (result.success && result.data != null) {
        detail.value = result.data;
      }
    });
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    super.onClose();
  }
}
