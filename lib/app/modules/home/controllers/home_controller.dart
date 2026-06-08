import 'package:swiftdrop_customer_app/export.dart';

class HomeController extends BaseController {
  final HomeRepository _repo;
  final FavoritesRepository _favRepo;
  HomeController(this._repo, this._favRepo);

  final RxList<FoodItemModel> foodItems = <FoodItemModel>[].obs;
  final RxList<RestaurantModel> topPickRestaurants = <RestaurantModel>[].obs;
  final RxList<RestaurantModel> restaurants = <RestaurantModel>[].obs;
  final RxString currentAddress = 'Select Location'.obs;
  final RxInt currentBannerPage = 0.obs;
  final RxInt selectedCategoryIndex = (-1).obs;
  final RxBool hasMoreRestaurants = false.obs;

  late final PageController bannerPageController;
  late final ScrollController scrollController;

  int _restaurantsPage = 1;
  int? _selectedFoodItemId;
  bool _isInitialized = false;

  void selectCategory(int index, int foodItemId) {
    if (selectedCategoryIndex.value == index) {
      selectedCategoryIndex.value = -1;
      _selectedFoodItemId = null;
    } else {
      selectedCategoryIndex.value = index;
      _selectedFoodItemId = foodItemId;
    }
    restaurants.clear();
    hasMoreRestaurants.value = false;
    Future.wait([_reloadRestaurants(), _reloadTopPicks()]);
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final max = scrollController.position.maxScrollExtent;
    final current = scrollController.position.pixels;
    if (current >= max - 200 && !isLoadingMore.value && hasMoreRestaurants.value) {
      _loadMoreRestaurants();
    }
  }

  @override
  void onInit() {
    super.onInit();
    bannerPageController = PageController();
    bannerPageController.addListener(_onBannerPage);
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
    currentAddress.value = LocationService.to.displayAddress.value;
    // Display label updates (e.g. reverse geocode) — update bar only, no reload
    ever(LocationService.to.displayAddress, (val) => currentAddress.value = val);
    // Coordinate changes — trigger dashboard reload
    ever(LocationService.to.locationKey, _onCoordsChanged);
    _initFlow();
  }

  void _onCoordsChanged(String key) {
    if (!_isInitialized || key.isEmpty) return;
    refresh();
  }

  void _onBannerPage() {
    if (bannerPageController.page != null) {
      currentBannerPage.value = bannerPageController.page!.round();
    }
  }

  Future<void> _initFlow() async {
    final hasLoc = await LocationService.to.initLocation();
    if (!hasLoc) {
      Get.toNamed(AppRoutes.address, arguments: {'permissionDenied': true});
      _isInitialized = true;
      return;
    }
    await _loadDashboard();
    _isInitialized = true;
  }

  Future<void> _loadDashboard() async {
    if (isLoading.value) return;
    final lat = LocationService.to.lat;
    final lng = LocationService.to.lng;
    await runAsync(() async {
      final results = await Future.wait<dynamic>([
        _repo.getFoodItems(),
        _repo.getTopPicks(foodItemId: _selectedFoodItemId, lat: lat, lng: lng),
        _repo.getRestaurants(page: 1, foodItemId: _selectedFoodItemId, lat: lat, lng: lng),
      ]);

      final foodResult = results[0] as ApiResponse<List<FoodItemModel>>;
      final topPicksResult = results[1] as ApiResponse<List<RestaurantModel>>;
      final restaurantsResult = results[2] as ApiResponse<RestaurantsPageModel>;

      if (foodResult.success && foodResult.data != null) {
        foodItems.value = foodResult.data!;
      }
      if (topPicksResult.success && topPicksResult.data != null) {
        topPickRestaurants.value = topPicksResult.data!;
      }
      if (restaurantsResult.success && restaurantsResult.data != null) {
        final page = restaurantsResult.data!;
        restaurants.value = page.restaurants;
        hasMoreRestaurants.value = page.meta.hasNextPage;
        _restaurantsPage = page.meta.currentPage;
      }
    });
  }

  Future<void> _reloadRestaurants() async {
    final lat = LocationService.to.lat;
    final lng = LocationService.to.lng;
    await runAsync(() async {
      final result = await _repo.getRestaurants(
        page: 1,
        foodItemId: _selectedFoodItemId,
        lat: lat,
        lng: lng,
      );
      if (result.success && result.data != null) {
        final page = result.data!;
        restaurants.value = page.restaurants;
        hasMoreRestaurants.value = page.meta.hasNextPage;
        _restaurantsPage = page.meta.currentPage;
      }
    });
  }

  Future<void> _reloadTopPicks() async {
    final lat = LocationService.to.lat;
    final lng = LocationService.to.lng;
    topPickRestaurants.clear();
    final result = await _repo.getTopPicks(foodItemId: _selectedFoodItemId, lat: lat, lng: lng);
    if (result.success && result.data != null) {
      topPickRestaurants.value = result.data!;
    }
  }

  Future<void> _loadMoreRestaurants() async {
    if (isLoadingMore.value || !hasMoreRestaurants.value) return;
    isLoadingMore.value = true;
    try {
      final lat = LocationService.to.lat;
      final lng = LocationService.to.lng;
      final result = await _repo.getRestaurants(
        page: _restaurantsPage + 1,
        foodItemId: _selectedFoodItemId,
        lat: lat,
        lng: lng,
      );
      if (result.success && result.data != null) {
        final page = result.data!;
        restaurants.addAll(page.restaurants);
        hasMoreRestaurants.value = page.meta.hasNextPage;
        _restaurantsPage = page.meta.currentPage;
      }
    } catch (_) {
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> toggleRestaurantFavorite(int id) async {
    final idx = restaurants.indexWhere((r) => r.id == id);
    if (idx == -1) return;

    final restaurant = restaurants[idx];
    final prev = restaurant.isFavorited;

    restaurants[idx] = restaurant.copyWith(isFavorited: !prev);

    final result = await _favRepo.toggleFavorite(FavoriteType.restaurant, id);
    if (result.success) {
      if (result.message.isNotEmpty) AppUtils.showSuccess(result.message);
    } else {
      restaurants[idx] = restaurant.copyWith(isFavorited: prev);
    }
  }

  @override
  Future<void> refresh() async {
    _selectedFoodItemId = null;
    selectedCategoryIndex.value = -1;
    restaurants.clear();
    topPickRestaurants.clear();
    hasMoreRestaurants.value = false;
    await _loadDashboard();
  }

  @override
  void onClose() {
    bannerPageController.removeListener(_onBannerPage);
    bannerPageController.dispose();
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }
}
