class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasNextPage;

  const PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.hasNextPage,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) => PaginationMeta(
        currentPage: json['current_page'] as int,
        lastPage: json['last_page'] as int,
        perPage: json['per_page'] as int,
        total: json['total'] as int,
        hasNextPage: json['next_page_url'] != null,
      );

  static PaginationMeta get empty => const PaginationMeta(
        currentPage: 1,
        lastPage: 1,
        perPage: 10,
        total: 0,
        hasNextPage: false,
      );
}

class FoodItemModel {
  final int id;
  final String name;
  final String slug;
  final String? imageUrl;

  const FoodItemModel({
    required this.id,
    required this.name,
    required this.slug,
    this.imageUrl,
  });

  factory FoodItemModel.fromJson(Map<String, dynamic> json) => FoodItemModel(
        id: json['id'] as int,
        name: json['name'] as String,
        slug: json['slug'] as String,
        imageUrl: json['image_url'] as String?,
      );
}

class RestaurantModel {
  final int id;
  final String name;
  final String? tagline;
  final String? cuisines;
  final String? city;
  final String? fullAddress;
  final String? logoUrl;
  final String? coverUrl;
  final double rating;
  final int totalReviews;
  final double distanceMiles;
  final bool isFavorited;

  const RestaurantModel({
    required this.id,
    required this.name,
    this.tagline,
    this.cuisines,
    this.city,
    this.fullAddress,
    this.logoUrl,
    this.coverUrl,
    required this.rating,
    required this.totalReviews,
    required this.distanceMiles,
    this.isFavorited = false,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) => RestaurantModel(
        id: json['id'] as int,
        name: json['name'] as String,
        tagline: json['tagline'] as String?,
        cuisines: json['cuisines'] as String?,
        city: json['city'] as String?,
        fullAddress: json['full_address'] as String?,
        logoUrl: json['logo_url'] as String?,
        coverUrl: json['cover_url'] as String?,
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
        distanceMiles: (json['distance_miles'] as num?)?.toDouble() ?? 0.0,
        isFavorited: json['is_favorited'] as bool? ?? false,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'rating': rating,
        'time': '20-30 min',
        'distance': '${distanceMiles.toStringAsFixed(1)} mi',
        'coverUrl': coverUrl,
        'logoUrl': logoUrl,
        'offer': null,
        'badge': null,
        'tagline': tagline,
        'cuisines': cuisines,
        'city': city,
        'total_reviews': totalReviews,
      };
}

class DashboardAddressModel {
  final int id;
  final String label;
  final String addressLine1;
  final String city;
  final String postcode;
  final double lat;
  final double lng;

  const DashboardAddressModel({
    required this.id,
    required this.label,
    required this.addressLine1,
    required this.city,
    required this.postcode,
    required this.lat,
    required this.lng,
  });

  factory DashboardAddressModel.fromJson(Map<String, dynamic> json) =>
      DashboardAddressModel(
        id: json['id'] as int,
        label: json['label'] as String,
        addressLine1: json['address_line_1'] as String,
        city: json['city'] as String,
        postcode: json['postcode'] as String,
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
      );
}

class DashboardModel {
  final List<FoodItemModel> foodItems;
  final PaginationMeta foodItemsMeta;
  final List<RestaurantModel> restaurants;
  final PaginationMeta restaurantsMeta;
  final DashboardAddressModel? address;
  final double radiusMiles;
  final bool usingFallback;
  final int? selectedFoodItem;

  const DashboardModel({
    required this.foodItems,
    required this.foodItemsMeta,
    required this.restaurants,
    required this.restaurantsMeta,
    this.address,
    required this.radiusMiles,
    required this.usingFallback,
    this.selectedFoodItem,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) => DashboardModel(
        foodItems: (json['food_items'] as List)
            .map((e) => FoodItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        foodItemsMeta: json['food_items_meta'] != null
            ? PaginationMeta.fromJson(json['food_items_meta'] as Map<String, dynamic>)
            : PaginationMeta.empty,
        restaurants: (json['restaurants'] as List)
            .map((e) => RestaurantModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        restaurantsMeta: json['restaurants_meta'] != null
            ? PaginationMeta.fromJson(json['restaurants_meta'] as Map<String, dynamic>)
            : PaginationMeta.empty,
        address: json['address'] != null
            ? DashboardAddressModel.fromJson(json['address'] as Map<String, dynamic>)
            : null,
        radiusMiles: (json['radius_miles'] as num?)?.toDouble() ?? 0.0,
        usingFallback: json['using_fallback'] as bool? ?? false,
        selectedFoodItem: json['selected_food_item'] as int?,
      );
}

class SearchRecentModel {
  final int id;
  final String keyword;

  const SearchRecentModel({required this.id, required this.keyword});

  factory SearchRecentModel.fromJson(Map<String, dynamic> json) => SearchRecentModel(
        id: json['id'] as int,
        keyword: json['keyword'] as String,
      );
}

class SearchDishModel {
  final int id;
  final String name;
  final double price;
  final double rating;
  final String? imageUrl;

  const SearchDishModel({
    required this.id,
    required this.name,
    required this.price,
    required this.rating,
    this.imageUrl,
  });

  factory SearchDishModel.fromJson(Map<String, dynamic> json) => SearchDishModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        imageUrl: json['image_url'] as String?,
      );
}

class SearchDishRestaurantModel {
  final int id;
  final String name;
  final double distanceMiles;
  final List<SearchDishModel> dishes;

  const SearchDishRestaurantModel({
    required this.id,
    required this.name,
    required this.distanceMiles,
    required this.dishes,
  });

  factory SearchDishRestaurantModel.fromJson(Map<String, dynamic> json) =>
      SearchDishRestaurantModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? '',
        distanceMiles: (json['distance_miles'] as num?)?.toDouble() ?? 0.0,
        dishes: (json['dishes'] as List? ?? [])
            .map((e) => SearchDishModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toItemsMap() => {
        'id': id,
        'name': name,
        'time': '20-30 min',
        'distance': '${distanceMiles.toStringAsFixed(1)} mi',
        'items': dishes
            .map((d) => {
                  'name': d.name,
                  'price': d.price.toStringAsFixed(2),
                  'rating': d.rating.toStringAsFixed(1),
                  'image': d.imageUrl,
                })
            .toList(),
      };
}

class SearchResultModel {
  final String keyword;
  final List<RestaurantModel> restaurants;
  final List<SearchDishRestaurantModel> dishesByRestaurant;
  final List<SearchRecentModel> recent;

  const SearchResultModel({
    required this.keyword,
    required this.restaurants,
    required this.dishesByRestaurant,
    required this.recent,
  });

  factory SearchResultModel.fromJson(Map<String, dynamic> json) => SearchResultModel(
        keyword: json['keyword'] as String? ?? '',
        restaurants: (json['restaurants'] as List? ?? [])
            .map((e) => RestaurantModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        dishesByRestaurant: (json['dishes_by_restaurant'] as List? ?? [])
            .map((e) => SearchDishRestaurantModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        recent: (json['recent'] as List? ?? [])
            .map((e) => SearchRecentModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
