import 'package:swiftdrop_customer_app/export.dart';
import '../../../../data/repositories/favorites_repository.dart';

class FavoritesController extends BaseController {
  final FavoritesRepository _repo;
  FavoritesController(this._repo);

  final RxInt selectedTabIndex = 0.obs; // 0 for Items, 1 for Restaurants
  
  final RxList<Map<String, dynamic>> favoriteItems = <Map<String, dynamic>>[].obs;

  final RxList<Map<String, dynamic>> favoriteRestaurants = <Map<String, dynamic>>[].obs;
  
  final RxBool isFetchingItems = false.obs;
  final RxBool isFetchingRestaurants = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFavoriteItems();
    fetchFavoriteRestaurants();
  }

  Future<void> fetchFavoriteItems() async {
    isFetchingItems.value = true;
    final response = await _repo.getFavoriteItems();
    if (response.success && response.data != null) {
      favoriteItems.value = response.data!.map((item) => {
        'id': item['id'],
        'name': item['name'],
        'price': item['price'].toString(),
        'rating': (item['rating'] ?? 0.0).toString(),
        'isVeg': item['is_veg'],
        'image': item['image_url'],
        'isFavorited': item['is_favorited'],
        'restaurant_id': item['restaurant_id'],
        'restaurant': {
          'id': item['restaurant_id'],
          'name': item['restaurant_name'],
          'time': '25-35',
          'rating': (item['rating'] ?? 0.0).toString(),
        }
      }).toList();
    }
    isFetchingItems.value = false;
  }

  Future<void> fetchFavoriteRestaurants() async {
    isFetchingRestaurants.value = true;
    final response = await _repo.getFavoriteRestaurants();
    if (response.success && response.data != null) {
      favoriteRestaurants.value = response.data!.map((res) => {
        ...res,
        'rating': res['rating'] ?? 0.0,
        'coverUrl': res['cover_url'],
        'image': res['logo_url'],
      }).toList();
    }
    isFetchingRestaurants.value = false;
  }

  Future<void> toggleItemFavorite(int id) async {
    final response = await _repo.toggleFavorite(FavoriteType.menuItem, id);
    if (response.success) {
      favoriteItems.removeWhere((item) => item['id'] == id);
    } else {
      AppUtils.showError(response.message);
    }
  }

  Future<void> toggleRestaurantFavorite(int id) async {
    final response = await _repo.toggleFavorite(FavoriteType.restaurant, id);
    if (response.success) {
      favoriteRestaurants.removeWhere((res) => res['id'] == id);
    } else {
      AppUtils.showError(response.message);
    }
  }

  void onTabChanged(int index) {
    selectedTabIndex.value = index;
  }
}
