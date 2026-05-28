import 'dart:async';
import 'package:swiftdrop_customer_app/export.dart';
import '../../../modules/cart/controllers/cart_controller.dart';

class RestaurantDetailController extends BaseController {
  final RestaurantDetailRepository _repo;
  final FavoritesRepository _favRepo;
  RestaurantDetailController(this._repo, this._favRepo);

  final Rx<RestaurantDetailInfoModel?> restaurantInfo = Rx(null);
  final RxList<MenuItemModel> menuItems = <MenuItemModel>[].obs;
  final RxBool hasMoreMenu = false.obs;
  final RxBool isFavorited = false.obs;

  int _restaurantId = 0;
  int _menuPage = 1;
  Timer? _searchDebounce;

  final searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxBool isVegSelected = false.obs;
  final RxBool isNonVegSelected = false.obs;
  final RxBool isRatingsSelected = false.obs;
  final RxBool showCartFloatingBar = false.obs;

  String? get _activeDiet {
    if (isVegSelected.value) return 'veg';
    if (isNonVegSelected.value) return 'non_veg';
    return null;
  }

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
    if (id > 0) _loadDetail(id, search: q.isEmpty ? null : q);
    _refreshCart();

    ever(searchQuery, (_) {
      _searchDebounce?.cancel();
      _searchDebounce = Timer(const Duration(milliseconds: 500), _reloadWithFilters);
    });
  }

  void searchNow() {
    _searchDebounce?.cancel();
    _reloadWithFilters();
  }

  void toggleVeg() {
    final next = !isVegSelected.value;
    isVegSelected.value = next;
    if (next) isNonVegSelected.value = false;
    _reloadWithFilters();
  }

  void toggleNonVeg() {
    final next = !isNonVegSelected.value;
    isNonVegSelected.value = next;
    if (next) isVegSelected.value = false;
    _reloadWithFilters();
  }

  void toggleRatings() {
    isRatingsSelected.toggle();
    _reloadWithFilters();
  }

  Future<void> toggleRestaurantFavorite() async {
    final prev = isFavorited.value;
    isFavorited.value = !prev;
    final result = await _favRepo.toggleFavorite(
      FavoriteType.restaurant,
      _restaurantId,
    );
    if (!result.success) isFavorited.value = prev;
  }

  Future<void> toggleItemFavorite(int itemId) async {
    final idx = menuItems.indexWhere((m) => m.id == itemId);
    if (idx == -1) return;
    final prev = menuItems[idx].isFavorited;
    menuItems[idx] = menuItems[idx].copyWith(isFavorited: !prev);
    final result = await _favRepo.toggleFavorite(
      FavoriteType.menuItem,
      itemId,
    );
    if (!result.success) menuItems[idx] = menuItems[idx].copyWith(isFavorited: prev);
  }

  void _reloadWithFilters() {
    if (_restaurantId > 0) {
      final q = searchQuery.value.trim();
      _loadDetail(
        _restaurantId,
        search: q.isEmpty ? null : q,
        diet: _activeDiet,
        minRating4: isRatingsSelected.value,
      );
    }
  }

  void _refreshCart() {
    try {
      final cart = Get.find<CartController>();
      cart.fetchCart().then((_) {
        if (cart.items.isNotEmpty) showCartFloatingBar.value = true;
      });
    } catch (_) {}
  }

  Future<void> _loadDetail(
    int id, {
    String? search,
    String? diet,
    bool minRating4 = false,
  }) async {
    _menuPage = 1;
    await runAsync(() async {
      final result = await _repo.getRestaurantDetail(
        id,
        search: search,
        diet: diet,
        minRating4: minRating4,
        page: 1,
      );
      if (result.success && result.data != null) {
        final data = result.data!;
        restaurantInfo.value = data.restaurant;
        menuItems.value = data.menu;
        hasMoreMenu.value = data.menuMeta.hasNextPage;
        isFavorited.value = data.restaurant.isFavorited;
      }
    });
  }

  Future<void> loadMoreMenu() async {
    if (!hasMoreMenu.value || isLoadingMore.value) return;
    isLoadingMore.value = true;
    try {
      _menuPage++;
      final q = searchQuery.value.trim();
      final result = await _repo.getRestaurantDetail(
        _restaurantId,
        search: q.isEmpty ? null : q,
        diet: _activeDiet,
        minRating4: isRatingsSelected.value,
        page: _menuPage,
      );
      if (result.success && result.data != null) {
        menuItems.addAll(result.data!.menu);
        hasMoreMenu.value = result.data!.menuMeta.hasNextPage;
      } else {
        _menuPage--;
      }
    } finally {
      isLoadingMore.value = false;
    }
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    super.onClose();
  }
}
