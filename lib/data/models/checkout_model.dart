import 'address_model.dart';
import 'cart_model.dart';

class CheckoutBill {
  final double itemTotal;
  final double itemDiscount;
  final double deliveryFee;
  final bool freeDelivery;
  final double taxes;
  final double toPay;

  const CheckoutBill({
    required this.itemTotal,
    required this.itemDiscount,
    required this.deliveryFee,
    required this.freeDelivery,
    required this.taxes,
    required this.toPay,
  });

  factory CheckoutBill.fromJson(Map<String, dynamic> json) => CheckoutBill(
        itemTotal: (json['item_total'] as num?)?.toDouble() ?? 0.0,
        itemDiscount: (json['item_discount'] as num?)?.toDouble() ?? 0.0,
        deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0.0,
        freeDelivery: json['free_delivery'] as bool? ?? false,
        taxes: (json['taxes'] as num?)?.toDouble() ?? 0.0,
        toPay: (json['to_pay'] as num?)?.toDouble() ?? 0.0,
      );
}

class CheckoutCoupon {
  final int id;
  final String code;
  final String? title;
  final String? description;
  final String type;
  final double value;
  final String headline;
  final double? minOrderValue;
  final String trigger;
  final String? validFrom;
  final String? validUntil;
  final bool eligible;
  final bool upcoming;

  const CheckoutCoupon({
    required this.id,
    required this.code,
    this.title,
    this.description,
    required this.type,
    required this.value,
    required this.headline,
    this.minOrderValue,
    required this.trigger,
    this.validFrom,
    this.validUntil,
    required this.eligible,
    required this.upcoming,
  });

  factory CheckoutCoupon.fromJson(Map<String, dynamic> json) => CheckoutCoupon(
        id: (json['id'] as num?)?.toInt() ?? 0,
        code: json['code'] as String,
        title: json['title'] as String?,
        description: json['description'] as String?,
        type: json['type'] as String? ?? 'flat',
        value: (json['value'] as num?)?.toDouble() ?? 0.0,
        headline: json['headline'] as String? ?? '',
        minOrderValue: (json['min_order_value'] as num?)?.toDouble(),
        trigger: json['trigger'] as String? ?? 'all',
        validFrom: json['valid_from'] as String?,
        validUntil: json['valid_until'] as String?,
        eligible: json['eligible'] as bool? ?? false,
        upcoming: json['upcoming'] as bool? ?? false,
      );
}

class CheckoutModel {
  final int? restaurantId;
  final bool isEmpty;
  final String? restaurantName;
  final String? restaurantArea;
  final String? restaurantLogoUrl;
  final List<AddressModel> addresses;
  final String? selectedAddressId;
  final bool inRange;
  final String? rangeMessage;
  final double? distanceMiles;
  final bool acceptsCookingRequests;
  final String? specialInstructions;
  final CheckoutCoupon? appliedCoupon;
  final String? couponError;
  final List<CheckoutCoupon> availableCoupons;
  final CheckoutBill bill;
  final List<CartApiItem> items;

  const CheckoutModel({
    this.restaurantId,
    required this.isEmpty,
    this.restaurantName,
    this.restaurantArea,
    this.restaurantLogoUrl,
    required this.addresses,
    this.selectedAddressId,
    required this.inRange,
    this.rangeMessage,
    this.distanceMiles,
    required this.acceptsCookingRequests,
    this.specialInstructions,
    this.appliedCoupon,
    this.couponError,
    required this.availableCoupons,
    required this.bill,
    required this.items,
  });

  AddressModel? get selectedAddress {
    if (addresses.isEmpty) return null;
    if (selectedAddressId == null) return addresses.first;
    return addresses.firstWhere(
      (a) => a.id == selectedAddressId,
      orElse: () => addresses.first,
    );
  }

  factory CheckoutModel.fromJson(Map<String, dynamic> json) {
    final restaurant = json['restaurant'] as Map<String, dynamic>?;

    // addresses can be a List or a single Map
    List<AddressModel> addresses;
    final raw = json['addresses'];
    if (raw is List) {
      addresses = raw
          .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (raw is Map<String, dynamic>) {
      addresses = [AddressModel.fromJson(raw)];
    } else {
      addresses = [];
    }

    return CheckoutModel(
      restaurantId: (restaurant?['id'] as num?)?.toInt(),
      isEmpty: json['is_empty'] as bool? ?? true,
      restaurantName: restaurant?['name'] as String?,
      restaurantArea: restaurant?['area'] as String?,
      restaurantLogoUrl: restaurant?['logo_url'] as String?,
      addresses: addresses,
      selectedAddressId: json['selected_address_id']?.toString(),
      inRange: json['in_range'] as bool? ?? false,
      rangeMessage: json['range_message'] as String?,
      distanceMiles: (json['distance_miles'] as num?)?.toDouble(),
      acceptsCookingRequests: (json['accepts_cooking_requests'] as bool?) ?? true,
      specialInstructions: json['special_instructions'] as String?,
      appliedCoupon: json['applied_coupon'] != null
          ? CheckoutCoupon.fromJson(json['applied_coupon'] as Map<String, dynamic>)
          : null,
      couponError: json['coupon_error'] as String?,
      availableCoupons: (json['available_coupons'] as List? ?? [])
          .map((e) => CheckoutCoupon.fromJson(e as Map<String, dynamic>))
          .toList(),
      items: (json['items'] as List? ?? [])
          .map((e) => CartApiItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      bill: json['bill'] != null
          ? CheckoutBill.fromJson(json['bill'] as Map<String, dynamic>)
          : const CheckoutBill(
              itemTotal: 0,
              itemDiscount: 0,
              deliveryFee: 0,
              freeDelivery: false,
              taxes: 0,
              toPay: 0,
            ),
    );
  }
}
