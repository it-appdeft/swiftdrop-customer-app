import 'restaurant_detail_model.dart';

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
        hasNextPage: (json['next_page_url'] != null) ||
            ((json['current_page'] as int) < (json['last_page'] as int)),
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
  final String? description;
  final String? cuisines;
  final String? city;
  final String? fullAddress;
  final String? logoUrl;
  final String? coverUrl;
  final double rating;
  final int totalReviews;
  final double distanceMiles;
  final bool isFavorited;
  final bool isAcceptingOrders;
  final bool isOpenNow;
  final TodayHoursModel? todayHours;
  final List<SearchDishModel>? items;

  const RestaurantModel({
    required this.id,
    required this.name,
    this.tagline,
    this.description,
    this.cuisines,
    this.city,
    this.fullAddress,
    this.logoUrl,
    this.coverUrl,
    required this.rating,
    required this.totalReviews,
    required this.distanceMiles,
    this.isFavorited = false,
    this.isAcceptingOrders = true,
    this.isOpenNow = true,
    this.todayHours,
    this.items,
  });

  RestaurantModel copyWith({bool? isFavorited, List<SearchDishModel>? items}) => RestaurantModel(
        id: id,
        name: name,
        tagline: tagline,
        description: description,
        cuisines: cuisines,
        city: city,
        fullAddress: fullAddress,
        logoUrl: logoUrl,
        coverUrl: coverUrl,
        rating: rating,
        totalReviews: totalReviews,
        distanceMiles: distanceMiles,
        isFavorited: isFavorited ?? this.isFavorited,
        isAcceptingOrders: isAcceptingOrders,
        isOpenNow: isOpenNow,
        todayHours: todayHours,
        items: items ?? this.items,
      );

  factory RestaurantModel.fromJson(Map<String, dynamic> json) => RestaurantModel(
        id: json['id'] as int,
        name: json['name'] as String,
        tagline: json['tagline'] as String?,
        description: json['description'] as String?,
        cuisines: json['cuisines'] as String?,
        city: json['city'] as String?,
        fullAddress: json['full_address'] as String?,
        logoUrl: json['logo_url'] as String?,
        coverUrl: json['cover_url'] as String?,
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
        distanceMiles: (json['distance_miles'] as num?)?.toDouble() ?? 0.0,
        isFavorited: json['is_favorited'] as bool? ?? false,
        isAcceptingOrders: json['is_accepting_orders'] as bool? ?? true,
        isOpenNow: json['is_open_now'] as bool? ?? true,
        todayHours: json['today_hours'] != null
            ? TodayHoursModel.fromJson(json['today_hours'] as Map<String, dynamic>)
            : null,
        items: json['items'] != null
            ? (json['items'] as List)
                .map((e) => SearchDishModel.fromJson(e as Map<String, dynamic>))
                .toList()
            : null,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'rating': rating,
        'time': '20-30 min',
        'distance': '${distanceMiles.toStringAsFixed(1)} mi',
        'coverUrl': coverUrl,
        'logoUrl': logoUrl,
        'is_favorited': isFavorited,
        'is_accepting_orders': isAcceptingOrders,
        'is_open_now': isOpenNow,
        'today_hours': todayHours?.toJson(),
        'items': items?.map((e) => e.toMap()).toList(),
        'offer': null,
        'badge': null,
        'tagline': tagline,
        'description': description,
        'cuisines': cuisines,
        'city': city,
        'total_reviews': totalReviews,
      };
}

class TodayHoursModel {
  final bool isOpen;
  final String openFrom;
  final String openTo;

  const TodayHoursModel({
    required this.isOpen,
    required this.openFrom,
    required this.openTo,
  });

  factory TodayHoursModel.fromJson(Map<String, dynamic> json) {
    final rawOpen = json['is_open'] ?? json['isOpen'];
    final bool isOpen = rawOpen == true || rawOpen == 1 || rawOpen == '1';
    return TodayHoursModel(
      isOpen: isOpen,
      openFrom: (json['open_from'] ?? json['opens_at'] ?? json['open'] ?? '').toString(),
      openTo: (json['open_to'] ?? json['closes_at'] ?? json['close'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'is_open': isOpen,
        'open_from': openFrom,
        'open_to': openTo,
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

class RestaurantsPageModel {
  final List<RestaurantModel> restaurants;
  final PaginationMeta meta;

  const RestaurantsPageModel({required this.restaurants, required this.meta});

  factory RestaurantsPageModel.fromJson(Map<String, dynamic> json) =>
      RestaurantsPageModel(
        restaurants: (json['restaurants'] as List? ?? [])
            .map((e) => RestaurantModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        meta: json['meta'] != null
            ? PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>)
            : PaginationMeta.empty,
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
  final String? description;
  final double price;
  final double rating;
  final String? imageUrl;
  final bool isVeg;
  final List<ModifierGroupModel> modifierGroups;

  const SearchDishModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.rating,
    this.imageUrl,
    this.isVeg = false,
    this.modifierGroups = const [],
  });

  factory SearchDishModel.fromJson(Map<String, dynamic> json) => SearchDishModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? '',
        description: json['description'] as String?,
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        imageUrl: json['image_url'] as String?,
        isVeg: json['is_veg'] as bool? ?? false,
        modifierGroups: (json['modifier_groups'] as List? ?? [])
            .map((e) => ModifierGroupModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price.toStringAsFixed(2),
        'rating': rating.toStringAsFixed(1),
        'image': imageUrl,
        'is_veg': isVeg,
        'modifier_groups': modifierGroups,
      };
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
  final PaginationMeta? pagination;

  const SearchResultModel({
    required this.keyword,
    required this.restaurants,
    required this.dishesByRestaurant,
    required this.recent,
    this.pagination,
  });

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    // New structure from log: data: { results: [...], pagination: {...}, recent: [...] }
    final dataPart = json['data'];
    if (dataPart is Map<String, dynamic>) {
      final results = (dataPart['results'] as List? ?? [])
          .map((e) => RestaurantModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final recent = (dataPart['recent'] as List? ?? [])
          .map((e) => SearchRecentModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final pagination = dataPart['pagination'] != null
          ? PaginationMeta.fromJson(dataPart['pagination'] as Map<String, dynamic>)
          : null;
      return SearchResultModel(
        keyword: '',
        restaurants: results,
        dishesByRestaurant: [],
        recent: recent,
        pagination: pagination,
      );
    }

    // New structure from previous prompt: data: [...], pagination: {...}
    if (json.containsKey('pagination')) {
      final restaurants = (json['data'] as List? ?? [])
          .map((e) => RestaurantModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return SearchResultModel(
        keyword: '',
        restaurants: restaurants,
        dishesByRestaurant: [],
        recent: [],
        pagination: PaginationMeta.fromJson(json['pagination'] as Map<String, dynamic>),
      );
    }

    // Legacy structure
    final data = json['data'] is Map ? json['data'] : json;
    return SearchResultModel(
      keyword: data['keyword'] as String? ?? '',
      restaurants: (data['restaurants'] as List? ?? [])
          .map((e) => RestaurantModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      dishesByRestaurant: (data['dishes_by_restaurant'] as List? ?? [])
          .map((e) => SearchDishRestaurantModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      recent: (data['recent'] as List? ?? [])
          .map((e) => SearchRecentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
