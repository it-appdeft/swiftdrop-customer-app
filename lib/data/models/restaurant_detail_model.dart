import 'dashboard_model.dart';

class ModifierOptionModel {
  final int id;
  final String name;
  final double priceDelta;

  const ModifierOptionModel({
    required this.id,
    required this.name,
    required this.priceDelta,
  });

  factory ModifierOptionModel.fromJson(Map<String, dynamic> json) =>
      ModifierOptionModel(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String,
        priceDelta: (json['price_delta'] as num?)?.toDouble() ?? 0.0,
      );
}

class ModifierGroupModel {
  final int id;
  final String name;
  final String? description;
  final String selectionType;
  final bool isRequired;
  final int minSelections;
  final int? maxSelections;
  final List<ModifierOptionModel> options;

  const ModifierGroupModel({
    required this.id,
    required this.name,
    this.description,
    required this.selectionType,
    required this.isRequired,
    required this.minSelections,
    this.maxSelections,
    required this.options,
  });

  factory ModifierGroupModel.fromJson(Map<String, dynamic> json) =>
      ModifierGroupModel(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String,
        description: json['description'] as String?,
        selectionType: json['selection_type'] as String? ?? 'single',
        isRequired: json['is_required'] as bool? ?? false,
        minSelections: (json['min_selections'] as num?)?.toInt() ?? 0,
        maxSelections: (json['max_selections'] as num?)?.toInt(),
        options: (json['options'] as List? ?? [])
            .map((e) => ModifierOptionModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
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
    required this.modifierGroups,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) => MenuItemModel(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String,
        description: json['description'] as String?,
        price: (json['price'] as num).toDouble(),
        isVeg: json['is_veg'] as bool? ?? true,
        imageUrl: json['image_url'] as String?,
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        isFavorited: json['is_favorited'] as bool? ?? false,
        modifierGroups: (json['modifier_groups'] as List? ?? [])
            .map((e) => ModifierGroupModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  MenuItemModel copyWith({bool? isFavorited}) => MenuItemModel(
        id: id,
        name: name,
        description: description,
        price: price,
        isVeg: isVeg,
        imageUrl: imageUrl,
        rating: rating,
        isFavorited: isFavorited ?? this.isFavorited,
        modifierGroups: modifierGroups,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price.toStringAsFixed(2),
        'isVeg': isVeg,
        'image': imageUrl,
        'rating': rating.toStringAsFixed(1),
        'isFavorited': isFavorited,
        'modifier_groups': modifierGroups,
      };
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
  final String? shareUrl;

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
    this.shareUrl,
  });

  factory RestaurantDetailInfoModel.fromJson(Map<String, dynamic> json) =>
      RestaurantDetailInfoModel(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String,
        tagline: json['tagline'] as String?,
        cuisines: json['cuisines'] as String?,
        city: json['city'] as String?,
        fullAddress: json['full_address'] as String?,
        logoUrl: json['logo_url'] as String?,
        coverUrl: json['cover_url'] as String?,
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
        distanceMiles: (json['distance_miles'] as num?)?.toDouble(),
        description: json['description'] as String?,
        isTopRated: json['is_top_rated'] as bool? ?? false,
        isFavorited: json['is_favorited'] as bool? ?? false,
        shareUrl: json['share_url'] as String?,
      );
}

class RestaurantDetailModel {
  final RestaurantDetailInfoModel restaurant;
  final String keyword;
  final List<MenuItemModel> menu;
  final PaginationMeta menuMeta;
  final List<MenuItemModel> recommended;

  const RestaurantDetailModel({
    required this.restaurant,
    required this.keyword,
    required this.menu,
    required this.menuMeta,
    required this.recommended,
  });

  factory RestaurantDetailModel.fromJson(Map<String, dynamic> json) =>
      RestaurantDetailModel(
        restaurant: RestaurantDetailInfoModel.fromJson(
            json['restaurant'] as Map<String, dynamic>),
        keyword: json['keyword'] as String? ?? '',
        menu: (json['menu'] as List? ?? [])
            .map((e) => MenuItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        menuMeta: json['menu_meta'] != null
            ? PaginationMeta.fromJson(json['menu_meta'] as Map<String, dynamic>)
            : PaginationMeta.empty,
        recommended: (json['recommended'] as List? ?? [])
            .map((e) => MenuItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
