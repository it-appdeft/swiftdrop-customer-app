import 'package:geolocator/geolocator.dart';
import 'package:swiftdrop_customer_app/export.dart';

class HomeController extends BaseController {
  final HomeRepository _repo;
  HomeController(this._repo);

  final RxList<FoodItemModel> foodItems = <FoodItemModel>[].obs;
  final RxList<RestaurantModel> restaurants = <RestaurantModel>[].obs;
  final RxString currentAddress = 'Select Location'.obs;
  final RxInt currentBannerPage = 0.obs;
  final RxInt selectedCategoryIndex = (-1).obs;
  final RxBool hasMoreRestaurants = false.obs;

  late final PageController bannerPageController;
  late final ScrollController scrollController;

  int _restaurantsPage = 1;
  int? _selectedFoodItemId;

  List<RestaurantModel> get topPicks => restaurants.take(5).toList();

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
    _loadDashboard();
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
    _initFlow();
  }

  void _onBannerPage() {
    if (bannerPageController.page != null) {
      currentBannerPage.value = bannerPageController.page!.round();
    }
  }

  Future<void> _initFlow() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      await _loadDashboard();
    } else {
      Get.toNamed(AppRoutes.address, arguments: {'permissionDenied': true});
    }
  }

  Future<void> _loadDashboard() async {
    await runAsync(() async {
      final result = await _repo.getDashboard(
        restaurantsPage: 1,
        foodItemId: _selectedFoodItemId,
      );
      if (result.success && result.data != null) {
        final data = result.data!;
        foodItems.value = data.foodItems;
        restaurants.value = data.restaurants;
        hasMoreRestaurants.value = data.restaurantsMeta.hasNextPage;
        _restaurantsPage = data.restaurantsMeta.currentPage;
        if (data.address == null) {
          Get.toNamed(AppRoutes.address);
          return;
        }
        final addr = data.address!;
        currentAddress.value = '${addr.addressLine1}, ${addr.city}';
      }
    });
  }

  Future<void> _loadMoreRestaurants() async {
    if (isLoadingMore.value || !hasMoreRestaurants.value) return;
    isLoadingMore.value = true;
    try {
      final result = await _repo.getDashboard(
        restaurantsPage: _restaurantsPage + 1,
        foodItemId: _selectedFoodItemId,
      );
      if (result.success && result.data != null) {
        final data = result.data!;
        restaurants.addAll(data.restaurants);
        hasMoreRestaurants.value = data.restaurantsMeta.hasNextPage;
        _restaurantsPage = data.restaurantsMeta.currentPage;
      }
    } catch (_) {
    } finally {
      isLoadingMore.value = false;
    }
  }

  @override
  Future<void> refresh() async {
    _selectedFoodItemId = null;
    selectedCategoryIndex.value = -1;
    restaurants.clear();
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
