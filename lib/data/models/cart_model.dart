import 'restaurant_detail_model.dart';

class CartApiModifier {
  final int groupId;
  final String groupName;
  final int optionId;
  final String optionName;
  final double priceDelta;

  const CartApiModifier({
    required this.groupId,
    required this.groupName,
    required this.optionId,
    required this.optionName,
    required this.priceDelta,
  });

  factory CartApiModifier.fromJson(Map<String, dynamic> json) => CartApiModifier(
        groupId: (json['group_id'] as num).toInt(),
        groupName: json['group_name'] as String,
        optionId: (json['option_id'] as num).toInt(),
        optionName: json['option_name'] as String,
        priceDelta: (json['price_delta'] as num?)?.toDouble() ?? 0.0,
      );
}

class CartApiItem {
  final int id;
  final int menuItemId;
  final String name;
  final String? description;
  final bool isVeg;
  final String? imageUrl;
  final double unitPrice;
  final int quantity;
  final double lineTotal;
  final List<CartApiModifier> modifiers;
  final List<ModifierGroupModel> modifierGroups;

  const CartApiItem({
    required this.id,
    required this.menuItemId,
    required this.name,
    this.description,
    required this.isVeg,
    this.imageUrl,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
    required this.modifiers,
    required this.modifierGroups,
  });

  factory CartApiItem.fromJson(Map<String, dynamic> json) => CartApiItem(
        id: (json['id'] as num).toInt(),
        menuItemId: (json['menu_item_id'] as num).toInt(),
        name: json['name'] as String,
        description: json['description'] as String?,
        isVeg: json['is_veg'] as bool? ?? true,
        imageUrl: (json['image_url'] ?? json['image']) as String?,
        unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
        quantity: (json['quantity'] as num?)?.toInt() ?? 0,
        lineTotal: (json['line_total'] as num?)?.toDouble() ?? 0.0,
        modifiers: (json['modifiers'] as List? ?? [])
            .map((e) => CartApiModifier.fromJson(e as Map<String, dynamic>))
            .toList(),
        modifierGroups: (json['modifier_groups'] as List? ?? [])
            .map((e) => ModifierGroupModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'id': menuItemId,
        'cart_item_id': id,
        'name': name,
        'description': description,
        'price': unitPrice.toStringAsFixed(2),
        'isVeg': isVeg,
        'image': imageUrl,
        'modifier_groups': modifierGroups,
      };
}

class CartApiResponse {
  final int cartId;
  final int? restaurantId;
  final String? restaurantName;
  final String? restaurantLogoUrl;
  final List<CartApiItem> items;
  final int itemCount;
  final int lineCount;
  final double subtotal;

  const CartApiResponse({
    required this.cartId,
    this.restaurantId,
    this.restaurantName,
    this.restaurantLogoUrl,
    required this.items,
    required this.itemCount,
    required this.lineCount,
    required this.subtotal,
  });

  factory CartApiResponse.fromJson(Map<String, dynamic> json) {
    final restaurant = json['restaurant'] as Map<String, dynamic>?;
    return CartApiResponse(
      cartId: (json['id'] as num).toInt(),
      restaurantId: (json['restaurant_id'] as num?)?.toInt() ??
          (restaurant?['id'] as num?)?.toInt(),
      restaurantName: restaurant?['name'] as String?,
      restaurantLogoUrl: restaurant?['logo_url'] as String?,
      items: (json['items'] as List? ?? [])
          .map((e) => CartApiItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      itemCount: (json['item_count'] as num?)?.toInt() ?? 0,
      lineCount: (json['line_count'] as num?)?.toInt() ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
