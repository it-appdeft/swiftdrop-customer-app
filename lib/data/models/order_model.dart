import 'package:intl/intl.dart';
import '../../app/config/app_config.dart';

class OrderItem {
  final String name;
  final int quantity;
  final double price;

  const OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] ?? json['item_name'] ?? json['title'] ?? '').toString();
    final quantity = (json['quantity'] as num?)?.toInt() ??
        (json['qty'] as num?)?.toInt() ??
        int.tryParse(json['quantity']?.toString() ?? '') ??
        1;
    final price = (json['price'] as num?)?.toDouble() ??
        (json['unit_price'] as num?)?.toDouble() ??
        double.tryParse(json['price']?.toString() ?? '') ??
        0.0;

    return OrderItem(
      name: name,
      quantity: quantity,
      price: price,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'price': price,
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
  final double deliveryFee;
  final double driverTip;
  final double distance;
  final int estimatedTime;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final bool isAcceptedFlag;
  final String? rawPlacedAt;

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
    required this.deliveryFee,
    this.driverTip = 0.0,
    required this.distance,
    required this.estimatedTime,
    required this.createdAt,
    this.acceptedAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.isAcceptedFlag = false,
    this.rawPlacedAt,
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
    if (rawJson.containsKey('data') && rawJson['data'] is Map<String, dynamic>) {
      json = rawJson['data'] as Map<String, dynamic>;
    }
    if (json.containsKey('order') && json['order'] is Map<String, dynamic>) {
      final orderMap = Map<String, dynamic>.from(json['order'] as Map);
      if (json['restaurant'] != null) orderMap['restaurant'] = json['restaurant'];
      if (json['address'] != null) orderMap['address'] = json['address'];
      if (json['items'] != null) orderMap['items'] = json['items'];
      if (json['delivery'] != null) orderMap['delivery'] = json['delivery'];
      if (json['payment'] != null) orderMap['payment'] = json['payment'];
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

    final isAcceptedFlag = (json['is_accepted'] as bool?) ?? false;

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
        final rAddr = (r['address'] ?? r['formatted_address'] ?? '').toString();
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
    if (delivery.isEmpty && json['address'] != null) {
      final a = json['address'];
      if (a is Map) {
        delivery = (a['formatted_address'] ?? a['address'] ?? a['street'] ?? '')
            .toString();
      } else if (a is String) {
        delivery = a;
      }
    }
    if (delivery.isEmpty) delivery = 'Customer Location';

    final rawItems = json['items'] ?? json['order_items'] ?? json['details'];
    final itemsList = <OrderItem>[];
    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map<String, dynamic>) {
          itemsList.add(OrderItem.fromJson(item));
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
        json['totalAmount'] ?? json['total_amount'] ?? json['total'] ?? json['grand_total']);
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
            json['payment_type'])
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
    final pickedUpAt = parseNullableDate(json['pickedUpAt'] ?? json['picked_up_at']);
    final deliveredAt = parseNullableDate(json['deliveredAt'] ?? json['delivered_at']);

    return OrderModel(
      id: id,
      orderNumber: orderNumber,
      status: status,
      pickupAddress: pickup,
      deliveryAddress: delivery,
      items: itemsList,
      totalAmount: totalAmount,
      deliveryFee: deliveryFee,
      driverTip: driverTip,
      distance: distance,
      estimatedTime: estimatedTime,
      createdAt: createdAt,
      acceptedAt: acceptedAt,
      pickedUpAt: pickedUpAt,
      deliveredAt: deliveredAt,
      isAcceptedFlag: isAcceptedFlag,
      rawPlacedAt: rawPlacedAt,
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
}
