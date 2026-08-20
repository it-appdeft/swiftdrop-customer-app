import 'package:intl/intl.dart';
import '../../app/config/app_config.dart';

class OrderItem {
  final String name;
  final int quantity;
  final double price;
  final double subtotal;
  final bool isVeg;

  const OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
    this.subtotal = 0.0,
    this.isVeg = true,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final menuItem = json['menu_item'] is Map ? json['menu_item'] as Map : null;
    final name = (json['name'] ?? json['item_name'] ?? json['title'] ?? menuItem?['name'] ?? '').toString();

    int parseInt(dynamic val) {
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    double parseDouble(dynamic val) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    final rawQty = parseInt(json['quantity'] ?? json['qty']);
    final quantity = rawQty <= 0 ? 1 : rawQty;

    final price = parseDouble(json['unit_price'] ?? json['price'] ?? menuItem?['price']);
    final rawSub = parseDouble(json['subtotal']);
    final subtotal = rawSub > 0 ? rawSub : (price * quantity);
    final isVeg = menuItem?['is_veg'] == true || json['is_veg'] == true;

    return OrderItem(
      name: name,
      quantity: quantity,
      price: price,
      subtotal: subtotal,
      isVeg: isVeg,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'price': price,
        'subtotal': subtotal,
        'is_veg': isVeg,
      };
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String status;
  final String pickupAddress;
  final String deliveryAddress;
  final List<OrderItem> items;
  final double totalAmount;
  final double subtotalAmount;
  final double vatAmount;
  final double discountAmount;
  final double deliveryFee;
  final double driverTip;
  final double distance;
  final int estimatedTime;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? preparingAt;
  final DateTime? readyAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final String? cancelledBy;
  final String? cancellationReason;
  final bool isAcceptedFlag;
  final String? rawPlacedAt;

  final String? addressLine1;
  final String? addressLine2;
  final String? addressCity;
  final String? addressLabel;

  final double? pickupLat;
  final double? pickupLng;
  final double? deliveryLat;
  final double? deliveryLng;

  final String? restaurantName;
  final String? restaurantImage;

  final double? driverLat;
  final double? driverLng;
  final String? driverName;
  final String? driverImage;
  final double? driverRating;

  /// Encoded polyline supplied by the backend, when it precomputes the route.
  final String? routePolyline;

  final String? paymentMethod;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.items,
    required this.totalAmount,
    this.subtotalAmount = 0.0,
    this.vatAmount = 0.0,
    this.discountAmount = 0.0,
    required this.deliveryFee,
    this.driverTip = 0.0,
    required this.distance,
    required this.estimatedTime,
    required this.createdAt,
    this.acceptedAt,
    this.preparingAt,
    this.readyAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.cancelledAt,
    this.cancelledBy,
    this.cancellationReason,
    this.isAcceptedFlag = false,
    this.rawPlacedAt,
    this.addressLine1,
    this.addressLine2,
    this.addressCity,
    this.addressLabel,
    this.pickupLat,
    this.pickupLng,
    this.deliveryLat,
    this.deliveryLng,
    this.restaurantName,
    this.restaurantImage,
    this.driverLat,
    this.driverLng,
    this.driverName,
    this.driverImage,
    this.driverRating,
    this.routePolyline,
    this.paymentMethod,
  });

  factory OrderModel.fromJson(Map<String, dynamic> rawJson) {
    Map<String, dynamic> json = rawJson;
    if (rawJson.containsKey('data') && rawJson['data'] is Map) {
      json = Map<String, dynamic>.from(rawJson['data'] as Map);
    }
    if (json.containsKey('order') && json['order'] is Map) {
      final orderMap = Map<String, dynamic>.from(json['order'] as Map);
      if (json['restaurant'] != null && orderMap['restaurant'] == null) orderMap['restaurant'] = json['restaurant'];
      if (json['address'] != null && orderMap['address'] == null) orderMap['address'] = json['address'];
      if (json['items'] != null && orderMap['items'] == null) orderMap['items'] = json['items'];
      if (json['delivery'] != null && orderMap['delivery'] == null) orderMap['delivery'] = json['delivery'];
      if (json['payment'] != null && orderMap['payment'] == null) orderMap['payment'] = json['payment'];
      json = orderMap;
    }

    final id = (json['id'] ?? json['order_id'] ?? json['uuid'] ?? '').toString();

    final orderNumber = (json['orderNumber'] ??
            json['order_number'] ??
            json['order_code'] ??
            (id.isNotEmpty
                ? (id.length > 8 ? 'SD-${id.substring(0, 8).toUpperCase()}' : 'SD-$id')
                : 'SD-0000'))
        .toString();

    final status = (json['status'] ?? json['order_status'] ?? 'pending')
        .toString()
        .toLowerCase();

    final isAcceptedFlag = json['is_accepted'] == true || json['is_accepted'] == 1 || json['is_accepted'] == '1';

    final rawPlacedAt = (json['placed_at'] ?? json['placedAt'] ?? json['created_at'] ?? json['createdAt'])?.toString();

    String pickup = (json['pickupAddress'] ??
            json['pickup_address'] ??
            json['restaurant_address'] ??
            json['location'] ??
            '')
        .toString();
    if (pickup.isEmpty && json['restaurant'] != null) {
      final r = json['restaurant'];
      if (r is Map) {
        final rName = (r['name'] ?? r['title'] ?? '').toString();
        final fullAddr = (r['full_address'] ?? r['address'] ?? r['formatted_address'] ?? '').toString();
        final city = (r['city'] ?? '').toString();
        final rAddr = fullAddr.isNotEmpty && city.isNotEmpty ? '$fullAddr, $city' : (fullAddr.isNotEmpty ? fullAddr : city);
        pickup = rName.isNotEmpty && rAddr.isNotEmpty
            ? '$rName, $rAddr'
            : (rName.isNotEmpty ? rName : rAddr);
      } else if (r is String) {
        pickup = r;
      }
    }
    if (pickup.isEmpty && json['restaurant_name'] != null) {
      pickup = json['restaurant_name'].toString();
    }
    if (pickup.isEmpty) pickup = 'Restaurant';

    String delivery = (json['deliveryAddress'] ??
            json['delivery_address'] ??
            json['user_address'] ??
            '')
        .toString();

    String? addrLine1;
    String? addrLine2;
    String? addrCity;
    String? addrLabel;
    if (json['address'] != null) {
      final a = json['address'];
      if (a is Map) {
        addrLine1 = (a['address_line_1'] ?? a['line1'] ?? a['street'])?.toString();
        addrLine2 = (a['address_line_2'] ?? a['line2'] ?? a['suite'])?.toString();
        addrCity = a['city']?.toString();
        addrLabel = a['label']?.toString();
        final parts = <String>[];
        if (addrLine1 != null && addrLine1.isNotEmpty) parts.add(addrLine1);
        if (addrLine2 != null && addrLine2.isNotEmpty) parts.add(addrLine2);
        if (addrCity != null && addrCity.isNotEmpty) parts.add(addrCity);
        if (delivery.isEmpty && parts.isNotEmpty) {
          delivery = parts.join(', ');
        }
        if (delivery.isEmpty) {
          delivery = (a['formatted_address'] ?? a['address'] ?? '').toString();
        }
      } else if (a is String) {
        delivery = a;
      }
    }
    if (delivery.isEmpty) delivery = 'Customer Location';

    final rawItems = json['items'] ?? json['order_items'] ?? json['details'];
    final itemsList = <OrderItem>[];
    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map) {
          itemsList.add(OrderItem.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    double parseDouble(dynamic val) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    double? parseNullableDouble(dynamic val) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val);
      return null;
    }

    int parseInt(dynamic val) {
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    final totalAmount = parseDouble(
        json['totalAmount'] ?? json['total_amount'] ?? json['total'] ?? json['grand_total'] ?? json['order_total'] ?? json['amount']);
    final subtotalAmount = parseDouble(
        json['subtotal'] ?? json['subtotal_amount']);
    final vatAmount = parseDouble(
        json['vat_amount'] ?? json['vat'] ?? json['tax_amount'] ?? json['taxes']);
    final discountAmount = parseDouble(
        json['discount_amount'] ?? json['discount']);
    final deliveryFee = parseDouble(
        json['deliveryFee'] ?? json['delivery_fee'] ?? json['shipping_fee']);
    final driverTip = parseDouble(
        json['driverTip'] ?? json['driver_tip'] ?? json['tip']);
    final distance = parseDouble(json['distance']);
    final rawEst = parseInt(
        json['estimatedTime'] ?? json['estimated_time'] ?? json['delivery_time'] ?? json['eta_minutes']);
    final estimatedTime = rawEst == 0 ? 20 : rawEst;

    Map<String, dynamic>? mapOf(String key) {
      final value = json[key];
      return value is Map ? Map<String, dynamic>.from(value) : null;
    }

    dynamic pick(Map<String, dynamic>? source, List<String> keys) {
      if (source == null) return null;
      for (final k in keys) {
        final v = source[k];
        if (v != null && v.toString().isNotEmpty) return v;
      }
      return null;
    }

    final restaurantJson = mapOf('restaurant') ?? mapOf('store') ?? mapOf('vendor');
    final addressJson = mapOf('address') ??
        mapOf('selected_address') ??
        mapOf('delivery_address_details') ??
        mapOf('customer_address');
    final driverJson =
        mapOf('driver') ?? mapOf('rider') ?? mapOf('delivery_partner');

    const latKeys = ['lat', 'latitude'];
    const lngKeys = ['lng', 'long', 'longitude'];

    final pickupLat = parseNullableDouble(json['pickupLat'] ??
        json['pickup_lat'] ??
        pick(restaurantJson, latKeys));
    final pickupLng = parseNullableDouble(json['pickupLng'] ??
        json['pickup_lng'] ??
        pick(restaurantJson, lngKeys));
    final deliveryLat = parseNullableDouble(json['deliveryLat'] ??
        json['delivery_lat'] ??
        pick(addressJson, latKeys));
    final deliveryLng = parseNullableDouble(json['deliveryLng'] ??
        json['delivery_lng'] ??
        pick(addressJson, lngKeys));

    final restaurantName = (json['restaurantName'] ??
            json['restaurant_name'] ??
            (json['restaurant'] is String ? json['restaurant'] : null) ??
            pick(restaurantJson, ['name', 'title']))
        ?.toString();
    final restaurantImage = (json['restaurantImage'] ??
            json['restaurant_image'] ??
            json['restaurant_logo'] ??
            json['image'] ??
            pick(restaurantJson,
                ['logo_url', 'image_url', 'cover_url', 'logo', 'image']))
        ?.toString();

    final driverLat = parseNullableDouble(
        json['driverLat'] ?? json['driver_lat'] ?? pick(driverJson, latKeys));
    final driverLng = parseNullableDouble(
        json['driverLng'] ?? json['driver_lng'] ?? pick(driverJson, lngKeys));
    final driverName = (json['driverName'] ??
            json['driver_name'] ??
            pick(driverJson, ['name', 'full_name']))
        ?.toString();
    final driverImage = (json['driverImage'] ??
            json['driver_image'] ??
            pick(driverJson, ['avatar', 'image_url', 'photo', 'image']))
        ?.toString();
    final driverRating = parseNullableDouble(
        json['driverRating'] ?? json['driver_rating'] ?? pick(driverJson, ['rating']));

    final routePolyline = (json['routePolyline'] ??
            json['route_polyline'] ??
            json['polyline'] ??
            (json['route'] is Map ? json['route']['polyline'] : null))
        ?.toString();

    final paymentMethod = (json['paymentMethod'] ??
            json['payment_method'] ??
            json['payment_mode'] ??
            json['payment_type'] ??
            (json['payment'] is Map ? (json['payment']['method'] ?? json['payment']['payment_method']) : null))
        ?.toString();

    DateTime parseDate(dynamic val) {
      if (val is String && val.isNotEmpty) {
        return DateTime.tryParse(val) ?? DateTime.now();
      }
      return DateTime.now();
    }

    DateTime? parseNullableDate(dynamic val) {
      if (val is String && val.isNotEmpty) {
        return DateTime.tryParse(val);
      }
      return null;
    }

    final createdAt = parseDate(json['createdAt'] ?? json['created_at'] ?? json['placed_at'] ?? json['placedAt']);
    final acceptedAt = parseNullableDate(json['acceptedAt'] ?? json['accepted_at']);
    final preparingAt = parseNullableDate(json['preparingAt'] ?? json['preparing_at']);
    final readyAt = parseNullableDate(json['readyAt'] ?? json['ready_at']);
    final pickedUpAt = parseNullableDate(json['pickedUpAt'] ?? json['picked_up_at']);
    final deliveredAt = parseNullableDate(json['deliveredAt'] ?? json['delivered_at']);
    final cancelledAt = parseNullableDate(json['cancelledAt'] ?? json['cancelled_at']);
    final cancelledBy = (json['cancelled_by'] ?? json['canceled_by'])?.toString();
    final cancellationReason = (json['cancellation_reason'] ?? json['cancel_reason'] ?? json['reason'])?.toString();

    return OrderModel(
      id: id,
      orderNumber: orderNumber,
      status: status,
      pickupAddress: pickup,
      deliveryAddress: delivery,
      items: itemsList,
      totalAmount: totalAmount,
      subtotalAmount: subtotalAmount,
      vatAmount: vatAmount,
      discountAmount: discountAmount,
      deliveryFee: deliveryFee,
      driverTip: driverTip,
      distance: distance,
      estimatedTime: estimatedTime,
      createdAt: createdAt,
      acceptedAt: acceptedAt,
      preparingAt: preparingAt,
      readyAt: readyAt,
      pickedUpAt: pickedUpAt,
      deliveredAt: deliveredAt,
      cancelledAt: cancelledAt,
      cancelledBy: cancelledBy,
      cancellationReason: cancellationReason,
      isAcceptedFlag: isAcceptedFlag,
      rawPlacedAt: rawPlacedAt,
      addressLine1: addrLine1,
      addressLine2: addrLine2,
      addressCity: addrCity,
      addressLabel: addrLabel,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      deliveryLat: deliveryLat,
      deliveryLng: deliveryLng,
      restaurantName: restaurantName,
      restaurantImage: restaurantImage,
      driverLat: driverLat,
      driverLng: driverLng,
      driverName: driverName,
      driverImage: driverImage,
      driverRating: driverRating,
      routePolyline: routePolyline,
      paymentMethod: paymentMethod,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderNumber': orderNumber,
        'status': status,
        'pickupAddress': pickupAddress,
        'deliveryAddress': deliveryAddress,
        'items': items.map((e) => e.toJson()).toList(),
        'totalAmount': totalAmount,
        'deliveryFee': deliveryFee,
        'driverTip': driverTip,
        'distance': distance,
        'estimatedTime': estimatedTime,
        'createdAt': createdAt.toIso8601String(),
        'acceptedAt': acceptedAt?.toIso8601String(),
        'pickedUpAt': pickedUpAt?.toIso8601String(),
        'deliveredAt': deliveredAt?.toIso8601String(),
        'isAcceptedFlag': isAcceptedFlag,
        'rawPlacedAt': rawPlacedAt,
        'pickupLat': pickupLat,
        'pickupLng': pickupLng,
        'deliveryLat': deliveryLat,
        'deliveryLng': deliveryLng,
        'restaurantName': restaurantName,
        'restaurantImage': restaurantImage,
        'driverLat': driverLat,
        'driverLng': driverLng,
        'driverName': driverName,
        'driverImage': driverImage,
        'driverRating': driverRating,
        'routePolyline': routePolyline,
        'paymentMethod': paymentMethod,
      };

  String get displayRestaurantName {
    final fromApi = restaurantName?.trim() ?? '';
    if (fromApi.isNotEmpty) return fromApi;
    final first = pickupAddress.split(',').first.trim();
    return first.isNotEmpty ? first : 'Restaurant';
  }

  String? get fullRestaurantImage {
    final img = restaurantImage?.trim();
    if (img == null || img.isEmpty) return null;
    if (img.startsWith('http://') || img.startsWith('https://')) return img;
    final base = AppConfig.baseUrl.endsWith('/')
        ? AppConfig.baseUrl.substring(0, AppConfig.baseUrl.length - 1)
        : AppConfig.baseUrl;
    final path = img.startsWith('/') ? img : '/$img';
    return '$base$path';
  }

  String get displayPlacedAt {
    if (rawPlacedAt != null && rawPlacedAt!.isNotEmpty) {
      return rawPlacedAt!;
    }
    return DateFormat('MMMM d, h:mm a').format(createdAt);
  }

  String get restaurantAddressLine {
    final parts = pickupAddress.split(',');
    if (restaurantName != null && restaurantName!.trim().isNotEmpty) {
      return pickupAddress.trim() == restaurantName!.trim()
          ? ''
          : pickupAddress.trim();
    }
    return parts.length > 1 ? parts.sublist(1).join(',').trim() : '';
  }

  bool get hasPickupCoordinates => pickupLat != null && pickupLng != null;
  bool get hasDeliveryCoordinates => deliveryLat != null && deliveryLng != null;
  bool get hasDriverCoordinates => driverLat != null && driverLng != null;
  bool get isDriverAssigned =>
      (driverName != null && driverName!.trim().isNotEmpty) ||
      hasDriverCoordinates;

  bool get isPending => status == 'pending' || status == 'placed';
  bool get isAccepted =>
      isAcceptedFlag || status == 'accepted' || status == 'preparing' || status == 'confirmed' || status == 'in_progress';
  bool get isPickedUp =>
      status == 'picked_up' || status == 'on_the_way' || status == 'out_for_delivery' || status == 'in_transit' || status == 'arrived';
  bool get isDelivered => status == 'delivered' || status == 'completed';
  bool get isCancelled => status == 'cancelled' || status == 'canceled' || status == 'rejected' || status == 'failed';
  bool get isActive => !isDelivered && !isCancelled;

  String get effectiveCancellationReason {
    if (cancellationReason != null && cancellationReason!.trim().isNotEmpty) {
      return cancellationReason!.trim();
    }
    if (cancelledBy != null && cancelledBy!.trim().isNotEmpty) {
      final by = cancelledBy!.trim().toLowerCase();
      if (by == 'restaurant' || by == 'vendor') return 'Cancelled by Restaurant';
      if (by == 'customer' || by == 'user') return 'Cancelled by Customer';
      if (by == 'driver' || by == 'rider') return 'Cancelled by Delivery Partner';
      return 'Cancelled by ${cancelledBy![0].toUpperCase()}${cancelledBy!.substring(1)}';
    }
    return status == 'rejected' ? 'Order rejected by restaurant' : 'Order was cancelled';
  }

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? status,
    String? pickupAddress,
    String? deliveryAddress,
    List<OrderItem>? items,
    double? totalAmount,
    double? subtotalAmount,
    double? vatAmount,
    double? discountAmount,
    double? deliveryFee,
    double? driverTip,
    double? distance,
    int? estimatedTime,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? preparingAt,
    DateTime? readyAt,
    DateTime? pickedUpAt,
    DateTime? deliveredAt,
    DateTime? cancelledAt,
    String? cancelledBy,
    String? cancellationReason,
    bool? isAcceptedFlag,
    String? rawPlacedAt,
    String? addressLine1,
    String? addressLine2,
    String? addressCity,
    String? addressLabel,
    double? pickupLat,
    double? pickupLng,
    double? deliveryLat,
    double? deliveryLng,
    String? restaurantName,
    String? restaurantImage,
    double? driverLat,
    double? driverLng,
    String? driverName,
    String? driverImage,
    double? driverRating,
    String? routePolyline,
    String? paymentMethod,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      status: status ?? this.status,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      subtotalAmount: subtotalAmount ?? this.subtotalAmount,
      vatAmount: vatAmount ?? this.vatAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      driverTip: driverTip ?? this.driverTip,
      distance: distance ?? this.distance,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      preparingAt: preparingAt ?? this.preparingAt,
      readyAt: readyAt ?? this.readyAt,
      pickedUpAt: pickedUpAt ?? this.pickedUpAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      isAcceptedFlag: isAcceptedFlag ?? this.isAcceptedFlag,
      rawPlacedAt: rawPlacedAt ?? this.rawPlacedAt,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      addressCity: addressCity ?? this.addressCity,
      addressLabel: addressLabel ?? this.addressLabel,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      deliveryLat: deliveryLat ?? this.deliveryLat,
      deliveryLng: deliveryLng ?? this.deliveryLng,
      restaurantName: restaurantName ?? this.restaurantName,
      restaurantImage: restaurantImage ?? this.restaurantImage,
      driverLat: driverLat ?? this.driverLat,
      driverLng: driverLng ?? this.driverLng,
      driverName: driverName ?? this.driverName,
      driverImage: driverImage ?? this.driverImage,
      driverRating: driverRating ?? this.driverRating,
      routePolyline: routePolyline ?? this.routePolyline,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}
