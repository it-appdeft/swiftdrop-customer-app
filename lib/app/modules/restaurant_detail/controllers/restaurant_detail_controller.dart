import 'dart:async';
import 'package:swiftdrop_customer_app/export.dart';
import '../../../modules/cart/controllers/cart_controller.dart';

class RestaurantDetailController extends BaseController {
  final RestaurantDetailRepository _repo;
  final FavoritesRepository _favRepo;
  final int? _overrideId;
  RestaurantDetailController(this._repo, this._favRepo, [this._overrideId]);

  final Rx<RestaurantDetailInfoModel?> restaurantInfo = Rx(null);
  final RxList<MenuCategoryModel> categories = <MenuCategoryModel>[].obs;
  final RxList<MenuItemModel> recommended = <MenuItemModel>[].obs;
  final RxSet<int> collapsedCategories = <int>{}.obs;
  final RxBool isFavorited = false.obs;
  final RxBool isScrolled = false.obs;
  final RxBool showStickyName = false.obs;

  int _restaurantId = 0;
  int get restaurantId => _restaurantId;
  Timer? _searchDebounce;
  final scrollController = ScrollController();

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
    final id = _overrideId ?? (args?['id'] as num?)?.toInt() ?? 0;
    _restaurantId = id;
    final q = _overrideId != null ? '' : (args?['q'] as String? ?? '');
    if (q.isNotEmpty) {
      searchQuery.value = q;
      searchController.text = q;
    }
    if (id > 0) _loadDetail(id, search: q.isEmpty ? null : q);
    
    scrollController.addListener(() {
      final offset = scrollController.offset;
      
      // We unify the sticky header state. 
      // 250px is roughly when the restaurant card's title starts getting hidden.
      if (offset > 250) {
        if (!isScrolled.value) isScrolled.value = true;
        if (!showStickyName.value) showStickyName.value = true;
      } else {
        if (isScrolled.value) isScrolled.value = false;
        if (showStickyName.value) showStickyName.value = false;
      }
    });

    // Initial check for cart bar
    try {
      final cart = Get.find<CartController>();
      if (cart.cartItemCount.value > 0) showCartFloatingBar.value = true;
    } catch (_) {}

    ever(searchQuery, (_) {
      _searchDebounce?.cancel();
      _searchDebounce = Timer(const Duration(milliseconds: 500), _reloadWithFilters);
    });
  }

  void searchNow() {
    _searchDebounce?.cancel();
    _reloadWithFilters();
  }

  void clearQuery() {
    searchController.clear();
    searchQuery.value = '';
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
    if (result.success) {
      if (result.message.isNotEmpty) AppUtils.showSuccess(result.message);
    } else {
      isFavorited.value = prev;
    }
  }

  void toggleCategory(int categoryId) {
    if (collapsedCategories.contains(categoryId)) {
      collapsedCategories.remove(categoryId);
    } else {
      collapsedCategories.add(categoryId);
    }
  }

  Future<void> toggleItemFavorite(int itemId) async {
    // Helper to update favorite status in a list of items
    List<MenuItemModel> updateList(List<MenuItemModel> list, int id, bool status) {
      final idx = list.indexWhere((m) => m.id == id);
      if (idx == -1) return list;
      final newList = List<MenuItemModel>.from(list);
      newList[idx] = newList[idx].copyWith(isFavorited: status);
      return newList;
    }

    // Find current status
    bool? currentStatus;
    for (var cat in categories) {
      final item = cat.items.firstWhereOrNull((m) => m.id == itemId);
      if (item != null) {
        currentStatus = item.isFavorited;
        break;
      }
    }
    if (currentStatus == null) {
      final item = recommended.firstWhereOrNull((m) => m.id == itemId);
      if (item != null) currentStatus = item.isFavorited;
    }

    if (currentStatus == null) return;
    final nextStatus = !currentStatus;

    // Optimistically update all occurrences
    // Update categories
    for (int i = 0; i < categories.length; i++) {
      final items = categories[i].items;
      if (items.any((m) => m.id == itemId)) {
        categories[i] = MenuCategoryModel(
          id: categories[i].id,
          name: categories[i].name,
          items: updateList(items, itemId, nextStatus),
        );
      }
    }
    // Update recommended
    if (recommended.any((m) => m.id == itemId)) {
      recommended.value = updateList(recommended, itemId, nextStatus);
    }

    final result = await _favRepo.toggleFavorite(
      FavoriteType.menuItem,
      itemId,
    );

    if (!result.success) {
      // Revert if failed
      for (int i = 0; i < categories.length; i++) {
        final items = categories[i].items;
        if (items.any((m) => m.id == itemId)) {
          categories[i] = MenuCategoryModel(
            id: categories[i].id,
            name: categories[i].name,
            items: updateList(items, itemId, currentStatus),
          );
        }
      }
      if (recommended.any((m) => m.id == itemId)) {
        recommended.value = updateList(recommended, itemId, currentStatus);
      }
    } else if (result.message.isNotEmpty) {
      AppUtils.showSuccess(result.message);
    }
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

  Future<void> _loadDetail(
    int id, {
    String? search,
    String? diet,
    bool minRating4 = false,
  }) async {
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
        categories.value = data.categories;
        recommended.value = data.recommended;
        isFavorited.value = data.restaurant.isFavorited;

        // Sync initial quantities with CartController
        try {
          final cart = Get.find<CartController>();
          for (var category in data.categories) {
            for (var item in category.items) {
              if (item.isInCart) {
                cart.quantities[item.id] = item.cartQuantity;
              } else {
                cart.quantities.remove(item.id);
              }
            }
          }
        } catch (_) {}
      }
    });
  }

  // Removed loadMoreMenu as the new data structure doesn't support flat menu pagination

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    super.onClose();
  }
}
