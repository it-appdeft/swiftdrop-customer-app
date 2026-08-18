import 'dart:async';
import 'package:swiftdrop_customer_app/export.dart';

class SearchTabController extends BaseController {
  final HomeRepository _repo;
  final FavoritesRepository _favRepo;
  SearchTabController(this._repo, this._favRepo);

  final queryController = TextEditingController();
  final scrollController = ScrollController();
  final RxString inputText = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxList<String> recentSearches = <String>[].obs;

  final RxInt selectedTabIndex = 0.obs;
  final RxSet<String> activeFilters = <String>{}.obs;

  final RxList<Map<String, dynamic>> restaurantResults = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> itemResults = <Map<String, dynamic>>[].obs;
  final RxBool isSearching = false.obs;
  final RxBool isLoadingRecent = false.obs;

  int _restaurantPage = 1;
  int _itemPage = 1;
  final RxBool hasMoreRestaurants = false.obs;
  final RxBool hasMoreItems = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadRecent();
    scrollController.addListener(_onScroll);
    ever(selectedTabIndex, (_) {
      if (searchQuery.value.isNotEmpty) {
        _performSearch(searchQuery.value);
      }
    });
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final max = scrollController.position.maxScrollExtent;
    final current = scrollController.position.pixels;
    if (current >= max - 200) {
      loadMore();
    }
  }

  Future<void> loadRecent({bool showLoading = true}) async {
    if (showLoading) isLoadingRecent.value = true;
    final historyResponse = await _repo.getSearchHistory();
    if (historyResponse.success && historyResponse.data != null && historyResponse.data!.isNotEmpty) {
      recentSearches.assignAll(historyResponse.data!);
    } else {
      final result = await _repo.getRecent();
      if (result.success && result.data != null) {
        recentSearches.assignAll(result.data!.recent.map((r) => r.keyword).toList());
      }
    }
    if (showLoading) isLoadingRecent.value = false;
  }

  void onQueryChanged(String text) {
    inputText.value = text;
    final trimmed = text.trim();

    if (trimmed.isEmpty) {
      searchQuery.value = '';
      _clearResults();
      loadRecent(showLoading: false);
    }
  }

  bool get _offersActive => activeFilters.contains('Offers');
  bool get _highestRatedActive => activeFilters.contains('Highest rated');

  Future<void> _performSearch(String q) async {
    if (q.isEmpty) return;

    final isItems = selectedTabIndex.value == 1;
    if (isItems) {
      _itemPage = 1;
      itemResults.clear();
      hasMoreItems.value = false;
    } else {
      _restaurantPage = 1;
      restaurantResults.clear();
      hasMoreRestaurants.value = false;
    }

    isSearching.value = true;

    final result = await _repo.search(
      q,
      offers: _offersActive,
      highestRated: _highestRatedActive,
      page: 1,
      isItems: isItems,
      lat: LocationService.to.lat,
      lng: LocationService.to.lng,
    );

    // If query changed while search request was in-flight, ignore stale response
    if (searchQuery.value != q) return;

    isSearching.value = false;

    if (result.success && result.data != null) {
      final data = result.data!;
      if (isItems) {
        itemResults.assignAll(data.restaurants.map((r) => r.toMap()).toList());
        hasMoreItems.value = data.pagination?.hasNextPage ?? false;
        _itemPage = data.pagination?.currentPage ?? 1;
      } else {
        restaurantResults.assignAll(data.restaurants.map((r) => r.toMap()).toList());
        hasMoreRestaurants.value = data.pagination?.hasNextPage ?? false;
        _restaurantPage = data.pagination?.currentPage ?? 1;
      }
      if (data.recent.isNotEmpty) {
        recentSearches.assignAll(data.recent.map((r) => r.keyword).toList());
      }
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || searchQuery.isEmpty) return;
    final isItems = selectedTabIndex.value == 1;
    final hasMore = isItems ? hasMoreItems.value : hasMoreRestaurants.value;
    if (!hasMore) return;

    final currentQ = searchQuery.value;
    isLoadingMore.value = true;
    final page = isItems ? _itemPage + 1 : _restaurantPage + 1;

    final result = await _repo.search(
      currentQ,
      offers: _offersActive,
      highestRated: _highestRatedActive,
      page: page,
      isItems: isItems,
      lat: LocationService.to.lat,
      lng: LocationService.to.lng,
    );

    if (searchQuery.value != currentQ) {
      isLoadingMore.value = false;
      return;
    }

    isLoadingMore.value = false;

    if (result.success && result.data != null) {
      final data = result.data!;
      if (isItems) {
        itemResults.addAll(data.restaurants.map((r) => r.toMap()).toList());
        hasMoreItems.value = data.pagination?.hasNextPage ?? false;
        _itemPage = data.pagination?.currentPage ?? 1;
      } else {
        restaurantResults.addAll(data.restaurants.map((r) => r.toMap()).toList());
        hasMoreRestaurants.value = data.pagination?.hasNextPage ?? false;
        _restaurantPage = data.pagination?.currentPage ?? 1;
      }
    }
  }

  void _clearResults() {
    restaurantResults.clear();
    itemResults.clear();
    _restaurantPage = 1;
    _itemPage = 1;
    hasMoreRestaurants.value = false;
    hasMoreItems.value = false;
  }

  void toggleFilter(String filter) {
    if (activeFilters.contains(filter)) {
      activeFilters.remove(filter);
    } else {
      activeFilters.add(filter);
    }
    if (searchQuery.value.isNotEmpty) {
      _performSearch(searchQuery.value);
    }
  }

  void onSubmit(String q) {
    final t = q.trim();
    if (t.isEmpty) return;
    searchQuery.value = t;
    _performSearch(t);
  }

  void tapRecent(String q) {
    queryController.text = q;
    queryController.selection = TextSelection.collapsed(offset: q.length);
    inputText.value = q;
    searchQuery.value = q;
    _performSearch(q);
  }

  void removeRecent(String q) => recentSearches.remove(q);

  Future<void> clearRecent() async {
    recentSearches.clear();
    final response = await _repo.clearSearchHistory();
    if (response.success && response.message.isNotEmpty) {
      AppUtils.showSuccess(response.message);
    }
  }

  void clearQuery() {
    queryController.clear();
    inputText.value = '';
    searchQuery.value = '';
    _clearResults();
    loadRecent(showLoading: false);
  }

  Future<void> toggleRestaurantFavorite(int id) async {
    final idx = restaurantResults.indexWhere((r) => r['id'] == id);
    if (idx == -1) return;

    final restaurant = restaurantResults[idx];
    final prev = restaurant['is_favorited'] ?? false;

    final updated = Map<String, dynamic>.from(restaurant);
    updated['is_favorited'] = !prev;
    restaurantResults[idx] = updated;

    final result = await _favRepo.toggleFavorite(FavoriteType.restaurant, id);
    if (result.success) {
      if (result.message.isNotEmpty) AppUtils.showSuccess(result.message);
    } else {
      updated['is_favorited'] = prev;
      restaurantResults[idx] = updated;
    }
  }

  Future<void> toggleItemFavorite(int id) async {
    final idx = itemResults.indexWhere((r) => r['id'] == id);
    if (idx == -1) return;

    final item = itemResults[idx];
    final prev = item['is_favorited'] ?? false;

    final updated = Map<String, dynamic>.from(item);
    updated['is_favorited'] = !prev;
    itemResults[idx] = updated;

    final result = await _favRepo.toggleFavorite(FavoriteType.menuItem, id);
    if (result.success) {
      if (result.message.isNotEmpty) AppUtils.showSuccess(result.message);
    } else {
      updated['is_favorited'] = prev;
      itemResults[idx] = updated;
    }
  }

  @override
  void onClose() {
    queryController.dispose();
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }
}
