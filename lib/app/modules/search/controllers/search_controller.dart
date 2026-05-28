import 'dart:async';
import 'package:swiftdrop_customer_app/export.dart';

class SearchTabController extends BaseController {
  final HomeRepository _repo;
  SearchTabController(this._repo);

  final queryController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxList<String> recentSearches = <String>[].obs;

  final RxInt selectedTabIndex = 0.obs;
  final RxSet<String> activeFilters = <String>{}.obs;

  final RxList<Map<String, dynamic>> restaurantResults = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> itemResults = <Map<String, dynamic>>[].obs;
  final RxBool isSearching = false.obs;
  final RxBool isLoadingRecent = false.obs;

  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    loadRecent();
  }

  Future<void> loadRecent() async {
    isLoadingRecent.value = true;
    final result = await _repo.getRecent();
    if (result.success && result.data != null && result.data!.recent.isNotEmpty) {
      recentSearches.assignAll(result.data!.recent.map((r) => r.keyword).toList());
    }
    isLoadingRecent.value = false;
  }

  void onQueryChanged(String text) {
    final trimmed = text.trim();
    searchQuery.value = trimmed;
    _debounceTimer?.cancel();

    if (trimmed.isEmpty) {
      _clearResults();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () => _performSearch(trimmed));
  }

  bool get _offersActive => activeFilters.contains('Offers');
  bool get _highestRatedActive => activeFilters.contains('Highest rated');

  Future<void> _performSearch(String q) async {
    if (q.isEmpty) return;

    _clearResults();
    isSearching.value = true;

    final result = await _repo.search(
      q,
      offers: _offersActive,
      highestRated: _highestRatedActive,
    );
    isSearching.value = false;

    if (result.success && result.data != null) {
      final data = result.data!;
      restaurantResults.assignAll(data.restaurants.map((r) => r.toMap()).toList());
      itemResults.assignAll(data.dishesByRestaurant.map((r) => r.toItemsMap()).toList());
      if (data.recent.isNotEmpty) {
        recentSearches.assignAll(data.recent.map((r) => r.keyword).toList());
      }
    }
  }

  void _clearResults() {
    restaurantResults.clear();
    itemResults.clear();
  }

  void toggleFilter(String filter) {
    if (activeFilters.contains(filter)) {
      activeFilters.remove(filter);
    } else {
      activeFilters.add(filter);
    }
    if (searchQuery.value.isNotEmpty) _performSearch(searchQuery.value);
  }

  void onSubmit(String q) {
    final t = q.trim();
    if (t.isEmpty) return;
    _debounceTimer?.cancel();
    _performSearch(t);
  }

  void tapRecent(String q) {
    queryController.text = q;
    queryController.selection = TextSelection.collapsed(offset: q.length);
    searchQuery.value = q;
    _debounceTimer?.cancel();
    _performSearch(q);
  }

  void removeRecent(String q) => recentSearches.remove(q);
  void clearRecent() => recentSearches.clear();

  void clearQuery() {
    queryController.clear();
    searchQuery.value = '';
    _debounceTimer?.cancel();
    _clearResults();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    queryController.dispose();
    super.onClose();
  }
}
