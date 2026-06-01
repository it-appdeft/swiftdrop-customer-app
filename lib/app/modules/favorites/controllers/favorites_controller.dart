import 'package:swiftdrop_customer_app/export.dart';
import '../../../../data/repositories/favorites_repository.dart';

class FavoritesController extends BaseController {
  final FavoritesRepository _repo;
  FavoritesController(this._repo);

  final RxInt selectedTabIndex = 0.obs; // 0 for Items, 1 for Restaurants
  
  final RxList<Map<String, dynamic>> favoriteItems = <Map<String, dynamic>>[
    {
      'id': 1,
      'name': 'Margherita Ultimate Cheese Pizza',
      'price': '8.23',
      'rating': '4.8',
      'isVeg': true,
      'image': 'https://swiftdrop.ams3.digitaloceanspaces.com/menu-items/pizza.jpg',
      'isFavorited': true,
      'restaurant': {
        'id': 101,
        'name': 'The Marble Grill',
        'time': '25-35',
        'rating': '4.8',
      }
    },
    {
      'id': 2,
      'name': 'Chocolate Lawa Cake 1Kg',
      'price': '8.23',
      'rating': '4.8',
      'isVeg': true,
      'image': 'https://swiftdrop.ams3.digitaloceanspaces.com/menu-items/cake.jpg',
      'isFavorited': true,
      'restaurant': {
        'id': 102,
        'name': 'Cake Studio',
        'time': '25-35',
        'rating': '4.8',
      }
    },
  ].obs;

  final RxList<Map<String, dynamic>> favoriteRestaurants = <Map<String, dynamic>>[
    {
      'id': 101,
      'name': 'Pizza Studio',
      'time': '20-30 min',
      'distance': '4.9 Km',
      'rating': '4.5',
      'image': 'https://placeholder.com/pizza_studio.jpg',
      'offer': '60% OFF select items',
      'is_favorited': true,
    },
    {
      'id': 103,
      'name': 'My World Pizza',
      'time': '20-30 min',
      'distance': '5.9 Km',
      'rating': '4.6',
      'image': 'https://placeholder.com/my_world_pizza.jpg',
      'offer': '20% OFF select items',
      'is_favorited': true,
    },
  ].obs;
  
  final RxBool isFetchingItems = false.obs;
  final RxBool isFetchingRestaurants = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Static data used for now
  }

  Future<void> fetchFavoriteItems() async {}
  Future<void> fetchFavoriteRestaurants() async {}

  Future<void> toggleItemFavorite(int id) async {
    favoriteItems.removeWhere((item) => item['id'] == id);
  }

  Future<void> toggleRestaurantFavorite(int id) async {
    favoriteRestaurants.removeWhere((res) => res['id'] == id);
  }

  void onTabChanged(int index) {
    selectedTabIndex.value = index;
  }
}
