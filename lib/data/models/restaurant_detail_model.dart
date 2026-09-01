import 'dashboard_model.dart';

class ModifierOptionModel {
  final int id;
  final String name;
  final double priceDelta;
  final bool isDefault;

  const ModifierOptionModel({
    required this.id,
    required this.name,
    required this.priceDelta,
    this.isDefault = false,
  });

  factory ModifierOptionModel.fromJson(Map<String, dynamic> json) {
    double delta = 0.0;
    if (json.containsKey('price_delta') && json['price_delta'] != null) {
      final raw = json['price_delta'];
      if (raw is num) {
        delta = raw.toDouble();
      } else {
        delta = double.tryParse(raw.toString()) ?? 0.0;
      }
    } else if (json.containsKey('price') && json['price'] != null) {
      final raw = json['price'];
      if (raw is num) {
        delta = raw.toDouble();
      } else {
        delta = double.tryParse(raw.toString()) ?? 0.0;
      }
    }
    final rawDef = json['is_default'] ?? json['isDefault'];
    final bool isDefault = rawDef == true || rawDef == 1 || rawDef == '1' || rawDef == 'true';
    return ModifierOptionModel(
      id: (json['id'] as num?)?.toInt() ??
          int.tryParse(json['id']?.toString() ?? '0') ??
          0,
      name: json['name']?.toString() ?? '',
      priceDelta: delta,
      isDefault: isDefault,
    );
  }
}

class ModifierGroupModel {
  final int id;
  final String name;
  final String? description;
  final String selectionType;
  final bool isRequired;
  final bool isPriceDriver;
  final int minSelections;
  final int? maxSelections;
  final List<ModifierOptionModel> options;

  const ModifierGroupModel({
    required this.id,
    required this.name,
    this.description,
    required this.selectionType,
    required this.isRequired,
    this.isPriceDriver = false,
    required this.minSelections,
    this.maxSelections,
    required this.options,
  });

  factory ModifierGroupModel.fromJson(Map<String, dynamic> json) {
    final rawDriver = json['is_price_driver'] ?? json['isPriceDriver'];
    final bool isPriceDriver = rawDriver == true ||
        rawDriver == 1 ||
        rawDriver == '1' ||
        rawDriver == 'true';
    return ModifierGroupModel(
      id: (json['id'] as num?)?.toInt() ??
          int.tryParse(json['id']?.toString() ?? '0') ??
          0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      selectionType: json['selection_type']?.toString() ?? 'single',
      isRequired: json['is_required'] == true ||
          json['is_required'] == 1 ||
          json['is_required'] == '1',
      isPriceDriver: isPriceDriver,
      minSelections: (json['min_selections'] as num?)?.toInt() ??
          int.tryParse(json['min_selections']?.toString() ?? '0') ??
          0,
      maxSelections: (json['max_selections'] as num?)?.toInt() ??
          int.tryParse(json['max_selections']?.toString() ?? ''),
      options: (json['options'] as List? ??
              json['modifier_options'] as List? ??
              [])
          .map((e) => ModifierOptionModel.fromJson(
              e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class MenuItemModel {
  final int id;
  final String name;
  final String? description;
  final double price;
  final bool isVeg;
  final String? imageUrl;
  final double rating;
  final bool isFavorited;
  final bool isAvailable;
  final int cartQuantity;
  final bool isInCart;
  final List<ModifierGroupModel> modifierGroups;

  const MenuItemModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.isVeg,
    this.imageUrl,
    required this.rating,
    required this.isFavorited,
    this.isAvailable = true,
    this.cartQuantity = 0,
    this.isInCart = false,
    required this.modifierGroups,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    final rawVeg = json['is_veg'] ?? json['isVeg'];
    final bool isVeg = rawVeg == null || rawVeg == true || rawVeg == 1 || rawVeg == '1';

    final rawFav = json['is_favorited'] ?? json['isFavorited'];
    final bool isFavorited = rawFav == true || rawFav == 1 || rawFav == '1';

    final rawAvail = json['is_available'] ?? json['available'] ?? json['isAvailable'];
    final bool isAvailable = rawAvail == null || rawAvail == true || rawAvail == 1 || rawAvail == '1';

    final rawInCart = json['is_in_cart'] ?? json['isInCart'];
    final bool isInCart = rawInCart == true || rawInCart == 1 || rawInCart == '1';

    final rawPrice = json['price'] ?? json['base_price'];
    final double price = (rawPrice as num?)?.toDouble() ??
        double.tryParse(rawPrice?.toString() ?? '0') ??
        0.0;

    final rawRating = json['rating'];
    final double rating = (rawRating as num?)?.toDouble() ??
        double.tryParse(rawRating?.toString() ?? '0') ??
        0.0;

    final rawQty = json['cart_quantity'] ?? json['quantity'] ?? json['cartQuantity'];
    final int cartQuantity = (rawQty as num?)?.toInt() ??
        int.tryParse(rawQty?.toString() ?? '0') ??
        0;

    final groupsRaw = json['modifier_groups'] ??
        json['modifierGroups'] ??
        json['modifiers'] ??
        json['groups'];

    return MenuItemModel(
      id: (json['id'] as num?)?.toInt() ??
          int.tryParse(json['id']?.toString() ?? '0') ??
          0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      price: price,
      isVeg: isVeg,
      imageUrl: json['image_url']?.toString() ?? json['image']?.toString(),
      rating: rating,
      isFavorited: isFavorited,
      isAvailable: isAvailable,
      cartQuantity: cartQuantity,
      isInCart: isInCart,
      modifierGroups: (groupsRaw as List? ?? [])
          .map((e) => ModifierGroupModel.fromJson(
              e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  MenuItemModel copyWith({bool? isFavorited, bool? isAvailable}) => MenuItemModel(
        id: id,
        name: name,
        description: description,
        price: price,
        isVeg: isVeg,
        imageUrl: imageUrl,
        rating: rating,
        isFavorited: isFavorited ?? this.isFavorited,
        isAvailable: isAvailable ?? this.isAvailable,
        cartQuantity: cartQuantity,
        isInCart: isInCart,
        modifierGroups: modifierGroups,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price.toStringAsFixed(2),
        'base_price': price.toStringAsFixed(2),
        'isVeg': isVeg,
        'image': imageUrl,
        'rating': rating.toStringAsFixed(1),
        'isFavorited': isFavorited,
        'is_available': isAvailable,
        'cart_quantity': cartQuantity,
        'is_in_cart': isInCart,
        'modifier_groups': modifierGroups,
      };
}

class MenuCategoryModel {
  final int id;
  final String name;
  final List<MenuItemModel> items;

  const MenuCategoryModel({
    required this.id,
    required this.name,
    required this.items,
  });

  factory MenuCategoryModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] ??
        json['menu_items'] ??
        json['dishes'] ??
        json['products'];
    return MenuCategoryModel(
      id: (json['id'] as num?)?.toInt() ??
          int.tryParse(json['id']?.toString() ?? '0') ??
          0,
      name: json['name']?.toString() ?? '',
      items: (rawItems as List? ?? [])
          .map((e) => MenuItemModel.fromJson(
              e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class RestaurantDetailInfoModel {
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
  final double? distanceMiles;
  final String? description;
  final bool isTopRated;
  final bool isFavorited;
  final bool isAcceptingOrders;
  final bool isOpenNow;
  final String? shareUrl;
  final int? deliveryMinutesMin;
  final int? deliveryMinutesMax;
  final TodayHoursModel? todayHours;
  final String? hoursSummary;

  const RestaurantDetailInfoModel({
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
    this.distanceMiles,
    this.description,
    required this.isTopRated,
    required this.isFavorited,
    this.isAcceptingOrders = true,
    this.isOpenNow = true,
    this.shareUrl,
    this.deliveryMinutesMin,
    this.deliveryMinutesMax,
    this.todayHours,
    this.hoursSummary,
  });

  factory RestaurantDetailInfoModel.fromJson(Map<String, dynamic> json) {
    final storeInfo = json['store_info'] is Map
        ? (json['store_info'] is Map<String, dynamic>
            ? json['store_info'] as Map<String, dynamic>
            : Map<String, dynamic>.from(json['store_info'] as Map))
        : null;

    final rawRating = json['rating'];
    final double rating = (rawRating as num?)?.toDouble() ??
        double.tryParse(rawRating?.toString() ?? '0') ??
        0.0;

    final rawReviews = json['total_reviews'] ?? json['reviews_count'];
    final int totalReviews = (rawReviews as num?)?.toInt() ??
        int.tryParse(rawReviews?.toString() ?? '0') ??
        0;

    final rawDist = json['distance_miles'] ?? json['distance'];
    final double? distanceMiles = (rawDist as num?)?.toDouble() ??
        double.tryParse(rawDist?.toString() ?? '');

    final rawTopRated = json['is_top_rated'];
    final bool isTopRated = rawTopRated == true || rawTopRated == 1 || rawTopRated == '1';

    final rawFav = json['is_favorited'];
    final bool isFavorited = rawFav == true || rawFav == 1 || rawFav == '1';

    final rawAccept = json['is_accepting_orders'];
    final bool isAcceptingOrders =
        rawAccept == null || rawAccept == true || rawAccept == 1 || rawAccept == '1';

    final rawOpen = json['is_open_now'] ?? json['is_open'];
    final bool isOpenNow =
        rawOpen == null || rawOpen == true || rawOpen == 1 || rawOpen == '1';

    String? cuisines;
    if (json['cuisines'] is List) {
      cuisines = (json['cuisines'] as List).map((e) => e.toString()).join(', ');
    } else if (json['cuisines'] != null) {
      cuisines = json['cuisines'].toString();
    }

    final rawMin = storeInfo?['delivery_minutes_min'] ?? json['delivery_minutes_min'];
    final int? deliveryMinutesMin =
        (rawMin as num?)?.toInt() ?? int.tryParse(rawMin?.toString() ?? '');

    final rawMax = storeInfo?['delivery_minutes_max'] ?? json['delivery_minutes_max'];
    final int? deliveryMinutesMax =
        (rawMax as num?)?.toInt() ?? int.tryParse(rawMax?.toString() ?? '');

    TodayHoursModel? todayHours;
    if (storeInfo?['today_hours'] != null && storeInfo!['today_hours'] is Map) {
      todayHours = TodayHoursModel.fromJson(
          Map<String, dynamic>.from(storeInfo['today_hours'] as Map));
    } else if (storeInfo?['today'] != null && storeInfo!['today'] is Map) {
      todayHours = TodayHoursModel.fromJson(
          Map<String, dynamic>.from(storeInfo['today'] as Map));
    } else if (json['today_hours'] != null && json['today_hours'] is Map) {
      todayHours = TodayHoursModel.fromJson(
          Map<String, dynamic>.from(json['today_hours'] as Map));
    }

    return RestaurantDetailInfoModel(
      id: (json['id'] as num?)?.toInt() ??
          int.tryParse(json['id']?.toString() ?? '0') ??
          0,
      name: json['name']?.toString() ?? '',
      tagline: json['tagline']?.toString(),
      cuisines: cuisines,
      city: json['city']?.toString(),
      fullAddress: json['full_address']?.toString() ?? json['address']?.toString(),
      logoUrl: json['logo_url']?.toString(),
      coverUrl: json['cover_url']?.toString(),
      rating: rating,
      totalReviews: totalReviews,
      distanceMiles: distanceMiles,
      description: json['description']?.toString(),
      isTopRated: isTopRated,
      isFavorited: isFavorited,
      isAcceptingOrders: isAcceptingOrders,
      isOpenNow: isOpenNow,
      shareUrl: json['share_url']?.toString(),
      deliveryMinutesMin: deliveryMinutesMin,
      deliveryMinutesMax: deliveryMinutesMax,
      todayHours: todayHours,
      hoursSummary: storeInfo?['hours_summary']?.toString() ??
          json['hours_summary']?.toString(),
    );
  }
}

class RestaurantDetailModel {
  final RestaurantDetailInfoModel restaurant;
  final String keyword;
  final List<MenuCategoryModel> categories;
  final List<MenuItemModel> recommended;

  const RestaurantDetailModel({
    required this.restaurant,
    required this.keyword,
    required this.categories,
    required this.recommended,
  });

  factory RestaurantDetailModel.fromJson(Map<String, dynamic> json) {
    final restJson = json['restaurant'] ?? json['data'] ?? json;
    final Map<String, dynamic> restMap = restJson is Map<String, dynamic>
        ? restJson
        : (restJson is Map
            ? Map<String, dynamic>.from(restJson)
            : <String, dynamic>{});

    final categoriesRaw = json['categories'] ??
        json['menu_categories'] ??
        json['menu'] ??
        json['menus'] ??
        restMap['categories'] ??
        restMap['menu_categories'] ??
        [];

    final List<MenuCategoryModel> categoriesList = [];
    if (categoriesRaw is List) {
      for (var e in categoriesRaw) {
        if (e is Map) {
          categoriesList.add(MenuCategoryModel.fromJson(
              e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e)));
        }
      }
    } else if (categoriesRaw is Map) {
      for (var val in categoriesRaw.values) {
        if (val is Map) {
          categoriesList.add(MenuCategoryModel.fromJson(
              val is Map<String, dynamic> ? val : Map<String, dynamic>.from(val)));
        }
      }
    }

    final recRaw = json['recommended'] ??
        json['popular_items'] ??
        json['top_items'] ??
        json['featured'] ??
        restMap['recommended'] ??
        restMap['popular_items'] ??
        [];

    final List<MenuItemModel> recommendedList = [];
    if (recRaw is List) {
      for (var e in recRaw) {
        if (e is Map) {
          recommendedList.add(MenuItemModel.fromJson(
              e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e)));
        }
      }
    }

    return RestaurantDetailModel(
      restaurant: RestaurantDetailInfoModel.fromJson(restMap),
      keyword: json['keyword']?.toString() ?? '',
      categories: categoriesList,
      recommended: recommendedList,
    );
  }
}
