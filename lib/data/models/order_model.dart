import 'package:intl/intl.dart';
import 'package:swiftdrop_customer_app/app/config/app_config.dart';
import 'package:swiftdrop_customer_app/app/widgets/app_image.dart';

class OrderItem {
  final String id;
  final String name;
  final int quantity;
  final double price;
  final double subtotal;
  final bool isVeg;
  final List<String> modifiers;
  final String? image;

  double get unitPrice => price;

  const OrderItem({
    this.id = '',
    required this.name,
    required this.quantity,
    required this.price,
    this.subtotal = 0.0,
    this.isVeg = true,
    this.modifiers = const [],
    this.image,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final menuItem = json['menu_item'] is Map ? json['menu_item'] as Map : null;
    final id = (json['menu_item_id'] ?? json['item_id'] ?? menuItem?['id'] ?? json['id'] ?? '').toString();
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

    final rawImg = (json['image'] ?? json['image_url'] ?? menuItem?['image'] ?? menuItem?['image_url'])?.toString();
    final image = (rawImg != null && rawImg.isNotEmpty)
        ? AppImage.buildUrl(rawImg)
        : null;

    final rawModifiers = json['modifiers'] ?? json['options'] ?? json['addons'];
    final modifiers = <String>[];
    if (rawModifiers is List) {
      for (final m in rawModifiers) {
        if (m is String && m.isNotEmpty) {
          modifiers.add(m);
        } else if (m is Map) {
          final opt = (m['name'] ?? m['option_name'] ?? m['title'])?.toString();
          if (opt != null && opt.isNotEmpty) modifiers.add(opt);
        }
      }
    }

    return OrderItem(
      id: id,
      name: name,
      quantity: quantity,
      price: price,
      subtotal: subtotal,
      isVeg: isVeg,
      modifiers: modifiers,
      image: image,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'quantity': quantity,
        'price': price,
        'subtotal': subtotal,
        'is_veg': isVeg,
        'modifiers': modifiers,
      };
}

class OrderStatusHistory {
  final String status;
  final DateTime at;

  const OrderStatusHistory({required this.status, required this.at});

  factory OrderStatusHistory.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val is String && val.isNotEmpty) {
        return DateTime.tryParse(val) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return OrderStatusHistory(
      status: (json['status'] ?? '').toString().toLowerCase(),
      at: parseDate(json['at'] ?? json['created_at'] ?? json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'at': at.toIso8601String(),
      };
}

class OrderModel {
  final String id;
  final String? uuid;
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
  final int? etaMinutes;
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
  final bool? cancellable;
  final String? deliveryCode;
  final String? rawPlacedAt;
  final String? specialInstructions;
  final List<OrderStatusHistory> statusHistory;

  final String? addressLine1;
  final String? addressLine2;
  final String? addressCity;
  final String? addressLabel;

  final double? pickupLat;
  final double? pickupLng;
  final double? deliveryLat;
  final double? deliveryLng;

  final int? restaurantId;
  final String? restaurantName;
  final String? restaurantImage;

  final double? driverLat;
  final double? driverLng;
  final String? driverName;
  final String? driverImage;
  final double? driverRating;

  /// Encoded polyline supplied by the backend, when it precomputes the route.
  final String? routePolyline;

  final String? orderStatus;
  final String? deliveryStatus;

  final String? paymentMethod;

  const OrderModel({
    required this.id,
    this.uuid,
    required this.orderNumber,
    required this.status,
    this.orderStatus,
    this.deliveryStatus,
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
    this.etaMinutes,
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
    this.cancellable,
    this.deliveryCode,
    this.rawPlacedAt,
    this.specialInstructions,
    this.statusHistory = const [],
    this.addressLine1,
    this.addressLine2,
    this.addressCity,
    this.addressLabel,
    this.pickupLat,
    this.pickupLng,
    this.deliveryLat,
    this.deliveryLng,
    this.restaurantId,
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
      if (json['status_history'] != null && orderMap['status_history'] == null) orderMap['status_history'] = json['status_history'];
      if (json['special_instructions'] != null && orderMap['special_instructions'] == null) orderMap['special_instructions'] = json['special_instructions'];
      json = orderMap;
    }

    final uuid = (json['uuid'] ??
            rawJson['uuid'] ??
            (rawJson['data'] is Map
                ? (rawJson['data']['uuid'] ??
                    (rawJson['data']['order'] is Map
                        ? rawJson['data']['order']['uuid']
                        : null))
                : null))
        ?.toString();

    final id = (json['id'] ?? json['order_id'] ?? uuid ?? '').toString();

    final orderNumber = (json['orderNumber'] ??
            json['order_number'] ??
            json['order_code'] ??
            (id.isNotEmpty
                ? (id.length > 8 ? 'SD-${id.substring(0, 8).toUpperCase()}' : 'SD-$id')
                : (uuid != null && uuid.isNotEmpty
                    ? 'SD-${uuid.substring(0, 8).toUpperCase()}'
                    : 'SD-0000')))
        .toString();

    final rawOrderStatus = (json['order_status'] ?? json['orderStatus'] ?? json['status'])?.toString();
    final rawDeliveryStatus = (json['delivery_status'] ??
            json['deliveryStatus'] ??
            (json['delivery'] is Map ? json['delivery']['status'] : null) ??
            (rawJson['data'] is Map && rawJson['data']['delivery'] is Map ? rawJson['data']['delivery']['status'] : null))
        ?.toString();

    String normalizeStatus(String? val) {
      if (val == null || val.isEmpty) return '';
      return val.trim().toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');
    }

    final parsedOrderStatus = normalizeStatus(rawOrderStatus);
    final parsedDeliveryStatus = normalizeStatus(rawDeliveryStatus);

    final status = (parsedOrderStatus.isNotEmpty
            ? parsedOrderStatus
            : (parsedDeliveryStatus.isNotEmpty ? parsedDeliveryStatus : 'pending'))
        .toLowerCase();

    final isAcceptedFlag = json['is_accepted'] == true || json['is_accepted'] == 1 || json['is_accepted'] == '1';
    final cancellable = json['cancellable'] is bool
        ? json['cancellable'] as bool
        : (json['can_cancel'] is bool ? json['can_cancel'] as bool : null);

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
        final fullAddr = (r['full_address'] ?? r['address'] ?? r['formatted_address'] ?? r['location'] ?? '').toString();
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
        addrLine1 = (a['address_line_1'] ?? a['line1'] ?? a['line'] ?? a['street'])?.toString();
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
          delivery = (a['line'] ?? a['formatted_address'] ?? a['address'] ?? '').toString();
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

    int? parseNullableInt(dynamic val) {
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val);
      return null;
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
    final deliveryCode = (json['delivery_code'] ??
            json['deliveryCode'] ??
            json['pin'] ??
            json['code'] ??
            (rawJson['data'] is Map && rawJson['data']['order'] is Map
                ? rawJson['data']['order']['delivery_code']
                : null))
        ?.toString();

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

    final restaurantJson = mapOf('restaurant') ??
        mapOf('store') ??
        mapOf('vendor') ??
        (rawJson['data'] is Map && rawJson['data']['restaurant'] is Map
            ? Map<String, dynamic>.from(rawJson['data']['restaurant'] as Map)
            : null);
    final addressJson = mapOf('address') ??
        mapOf('selected_address') ??
        mapOf('delivery_address_details') ??
        mapOf('customer_address') ??
        (rawJson['data'] is Map && rawJson['data']['address'] is Map
            ? Map<String, dynamic>.from(rawJson['data']['address'] as Map)
            : null);
    final deliveryJson = mapOf('delivery') ??
        (rawJson['data'] is Map && rawJson['data']['delivery'] is Map
            ? Map<String, dynamic>.from(rawJson['data']['delivery'] as Map)
            : null);
    final driverJson = mapOf('driver') ??
        mapOf('rider') ??
        mapOf('delivery_partner') ??
        (deliveryJson != null && deliveryJson['driver'] is Map
            ? Map<String, dynamic>.from(deliveryJson['driver'] as Map)
            : null) ??
        (deliveryJson != null && deliveryJson['rider'] is Map
            ? Map<String, dynamic>.from(deliveryJson['rider'] as Map)
            : null) ??
        (rawJson['data'] is Map && rawJson['data']['driver'] is Map
            ? Map<String, dynamic>.from(rawJson['data']['driver'] as Map)
            : null);

    final etaMinutes = parseNullableInt(
        json['eta_minutes'] ??
        json['etaMinutes'] ??
        json['eta'] ??
        deliveryJson?['eta_minutes'] ??
        deliveryJson?['eta']);

    final rawEst = parseInt(json['estimatedTime'] ??
        json['estimated_time'] ??
        json['delivery_time'] ??
        etaMinutes ??
        deliveryJson?['estimated_time']);
    final estimatedTime = rawEst > 0 ? rawEst : (etaMinutes ?? 20);

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

    final rawRestaurantId = parseInt(json['restaurant_id'] ?? json['restaurantId'] ?? pick(restaurantJson, ['id', 'restaurant_id']));
    final restaurantId = rawRestaurantId > 0 ? rawRestaurantId : null;

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
        json['driverLat'] ?? json['driver_lat'] ?? pick(driverJson, latKeys) ?? deliveryJson?['lat']);
    final driverLng = parseNullableDouble(
        json['driverLng'] ?? json['driver_lng'] ?? pick(driverJson, lngKeys) ?? deliveryJson?['lng']);
    final driverName = (json['driverName'] ??
            json['driver_name'] ??
            pick(driverJson, ['name', 'full_name', 'title']))
        ?.toString();
    final driverImage = (json['driverImage'] ??
            json['driver_image'] ??
            pick(driverJson, ['photo', 'avatar', 'image_url', 'image', 'profile_photo', 'picture']))
        ?.toString();
    final driverRating = parseNullableDouble(
        json['driverRating'] ?? json['driver_rating'] ?? pick(driverJson, ['rating']));

    final routePolyline = (json['routePolyline'] ??
            json['route_polyline'] ??
            pick(deliveryJson, ['polyline', 'route_polyline', 'route']))
        ?.toString();

    final paymentMethod = (json['paymentMethod'] ??
            json['payment_method'] ??
            json['payment_type'] ??
            pick(mapOf('payment'), ['method', 'type', 'gateway']))
        ?.toString();

    final specialInstructions = (json['special_instructions'] ??
            json['specialInstructions'] ??
            json['cooking_instructions'] ??
            json['cooking_request'] ??
            json['instructions'] ??
            json['notes'] ??
            json['note'])
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

    final rawHistory = json['status_history'] ??
        rawJson['status_history'] ??
        (rawJson['data'] is Map ? rawJson['data']['status_history'] : null);
    final statusHistoryList = <OrderStatusHistory>[];
    DateTime? historyPlacedAt;
    DateTime? historyAcceptedAt;
    DateTime? historyPreparingAt;
    DateTime? historyReadyAt;
    DateTime? historyPickedUpAt;
    DateTime? historyDeliveredAt;
    DateTime? historyCancelledAt;

    if (rawHistory is List) {
      for (final h in rawHistory) {
        if (h is Map) {
          final item = OrderStatusHistory.fromJson(Map<String, dynamic>.from(h));
          statusHistoryList.add(item);
          final hStatus = item.status;
          final hAt = item.at;
          if (hStatus == 'placed' || hStatus == 'pending') historyPlacedAt = hAt;
          if (hStatus == 'accepted' || hStatus == 'confirmed') historyAcceptedAt = hAt;
          if (hStatus == 'preparing' || hStatus == 'kitchen' || hStatus == 'in_progress') historyPreparingAt = hAt;
          if (hStatus == 'ready' || hStatus == 'ready_for_pickup') historyReadyAt = hAt;
          if (hStatus == 'picked_up' || hStatus == 'out_for_delivery' || hStatus == 'on_the_way' || hStatus == 'in_transit') historyPickedUpAt = hAt;
          if (hStatus == 'delivered' || hStatus == 'completed') historyDeliveredAt = hAt;
          if (hStatus == 'cancelled' || hStatus == 'canceled' || hStatus == 'rejected' || hStatus == 'failed') historyCancelledAt = hAt;
        }
      }
    }

    final createdAt = parseDate(json['createdAt'] ?? json['created_at'] ?? json['placed_at'] ?? json['placedAt'] ?? historyPlacedAt?.toIso8601String());
    final acceptedAt = parseNullableDate(json['acceptedAt'] ?? json['accepted_at']) ?? historyAcceptedAt;
    final preparingAt = parseNullableDate(json['preparingAt'] ?? json['preparing_at']) ?? historyPreparingAt;
    final readyAt = parseNullableDate(json['readyAt'] ?? json['ready_at']) ?? historyReadyAt;
    final pickedUpAt = parseNullableDate(json['pickedUpAt'] ?? json['picked_up_at']) ?? historyPickedUpAt;
    final deliveredAt = parseNullableDate(json['deliveredAt'] ?? json['delivered_at']) ?? historyDeliveredAt;
    final cancelledAt = parseNullableDate(json['cancelledAt'] ?? json['cancelled_at']) ?? historyCancelledAt;
    final cancelledBy = (json['cancelled_by'] ?? json['canceled_by'])?.toString();
    final cancellationReason = (json['cancellation_reason'] ?? json['cancel_reason'] ?? json['reason'])?.toString();

    return OrderModel(
      id: id,
      uuid: uuid,
      orderNumber: orderNumber,
      status: status,
      orderStatus: parsedOrderStatus.isNotEmpty ? parsedOrderStatus : null,
      deliveryStatus: parsedDeliveryStatus.isNotEmpty ? parsedDeliveryStatus : null,
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
      etaMinutes: etaMinutes,
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
      cancellable: cancellable,
      deliveryCode: deliveryCode,
      rawPlacedAt: rawPlacedAt,
      specialInstructions: specialInstructions,
      statusHistory: statusHistoryList,
      addressLine1: addrLine1,
      addressLine2: addrLine2,
      addressCity: addrCity,
      addressLabel: addrLabel,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      deliveryLat: deliveryLat,
      deliveryLng: deliveryLng,
      restaurantId: restaurantId,
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
        if (uuid != null) 'uuid': uuid,
        'orderNumber': orderNumber,
        'status': status,
        if (orderStatus != null) 'order_status': orderStatus,
        if (deliveryStatus != null) 'delivery_status': deliveryStatus,
        'pickupAddress': pickupAddress,
        'deliveryAddress': deliveryAddress,
        'items': items.map((e) => e.toJson()).toList(),
        'totalAmount': totalAmount,
        'deliveryFee': deliveryFee,
        'driverTip': driverTip,
        'distance': distance,
        if (etaMinutes != null) 'eta_minutes': etaMinutes,
        'estimatedTime': estimatedTime,
        'createdAt': createdAt.toIso8601String(),
        'acceptedAt': acceptedAt?.toIso8601String(),
        'pickedUpAt': pickedUpAt?.toIso8601String(),
        'deliveredAt': deliveredAt?.toIso8601String(),
        'isAcceptedFlag': isAcceptedFlag,
        if (cancellable != null) 'cancellable': cancellable,
        if (deliveryCode != null) 'deliveryCode': deliveryCode,
        'rawPlacedAt': rawPlacedAt,
        if (specialInstructions != null) 'special_instructions': specialInstructions,
        if (statusHistory.isNotEmpty) 'status_history': statusHistory.map((e) => e.toJson()).toList(),
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

  /// Identifier used for backend API endpoints (prefers numeric id over uuid)
  String get targetId => (id.isNotEmpty && id != '0') ? id : (uuid ?? '');

  String get cancelId => targetId;

  String get displayRestaurantName {
    final fromApi = restaurantName?.trim() ?? '';
    if (fromApi.isNotEmpty) return fromApi;
    final first = pickupAddress.split(',').first.trim();
    return first.isNotEmpty ? first : 'Restaurant';
  }

  String? get fullRestaurantImage {
    final img = restaurantImage?.trim();
    if (img == null || img.isEmpty) return null;
    return AppImage.buildUrl(img);
  }

  String get displayPlacedAt {
    if (rawPlacedAt != null && rawPlacedAt!.isNotEmpty) {
      return rawPlacedAt!;
    }
    return DateFormat('MMMM d, h:mm a').format(createdAt);
  }

  String get displayCancelledAt {
    if (cancelledAt != null) {
      return DateFormat('MMMM d, h:mm a').format(cancelledAt!.toLocal());
    }
    return displayPlacedAt;
  }

  String get displayDeliveredAt {
    if (deliveredAt != null) {
      return DateFormat('MMMM d, h:mm a').format(deliveredAt!.toLocal());
    }
    return displayPlacedAt;
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

  String get effectiveOrderStatus =>
      (orderStatus != null && orderStatus!.isNotEmpty) ? orderStatus! : status;
  String get effectiveDeliveryStatus =>
      (deliveryStatus != null && deliveryStatus!.isNotEmpty) ? deliveryStatus! : '';

  bool get isPending =>
      effectiveOrderStatus == 'pending' ||
      effectiveOrderStatus == 'placed' ||
      effectiveOrderStatus == 'order_placed';

  bool get isAccepted =>
      isAcceptedFlag ||
      effectiveOrderStatus == 'accepted' ||
      effectiveOrderStatus == 'order_accepted';

  bool get isPreparing =>
      effectiveOrderStatus == 'preparing' ||
      effectiveOrderStatus == 'kitchen' ||
      effectiveOrderStatus == 'in_kitchen' ||
      effectiveOrderStatus == 'in_progress' ||
      effectiveOrderStatus == 'food_preparing';

  bool get isReadyForPickup =>
      effectiveOrderStatus == 'ready' ||
      effectiveOrderStatus == 'ready_for_pickup' ||
      effectiveOrderStatus == 'ready_to_pickup' ||
      effectiveOrderStatus == 'food_ready';

  bool get isOutForDelivery =>
      effectiveOrderStatus == 'out_for_delivery' ||
      effectiveOrderStatus == 'out_of_delivery' ||
      effectiveOrderStatus == 'on_the_way' ||
      effectiveOrderStatus == 'in_transit' ||
      effectiveOrderStatus == 'picked_up' ||
      effectiveDeliveryStatus == 'on_the_way' ||
      effectiveDeliveryStatus == 'picked_up' ||
      effectiveDeliveryStatus == 'in_transit';

  bool get isPickedUp => isOutForDelivery || isDriverReachedCustomer;

  bool get isDelivered =>
      effectiveOrderStatus == 'delivered' ||
      effectiveOrderStatus == 'completed' ||
      effectiveDeliveryStatus == 'delivered';

  bool get isCancelled =>
      effectiveOrderStatus == 'cancelled' ||
      effectiveOrderStatus == 'canceled' ||
      effectiveOrderStatus == 'rejected' ||
      effectiveOrderStatus == 'failed';

  bool get isActive => !isDelivered && !isCancelled;

  // Delivery status specific helpers
  bool get isDriverUnassigned =>
      effectiveDeliveryStatus.isEmpty ||
      effectiveDeliveryStatus == 'unassigned' ||
      effectiveDeliveryStatus == 'pending';

  bool get isDriverAssigned =>
      (effectiveDeliveryStatus.isNotEmpty && effectiveDeliveryStatus != 'unassigned') ||
      (driverName != null && driverName!.trim().isNotEmpty) ||
      hasDriverCoordinates;

  bool get isDriverReachedRestaurant =>
      effectiveDeliveryStatus == 'reached_restaurant' ||
      effectiveDeliveryStatus == 'arrived_at_restaurant' ||
      effectiveDeliveryStatus == 'at_restaurant' ||
      effectiveDeliveryStatus == 'reached_resturant';

  bool get isDriverOnTheWay =>
      effectiveDeliveryStatus == 'on_the_way' ||
      effectiveDeliveryStatus == 'picked_up' ||
      effectiveDeliveryStatus == 'in_transit';

  bool get isDriverReachedCustomer =>
      effectiveDeliveryStatus == 'reached_customer' ||
      effectiveDeliveryStatus == 'arrived' ||
      effectiveDeliveryStatus == 'driver_reached' ||
      effectiveDeliveryStatus == 'driver_arrived';

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
    String? uuid,
    String? orderNumber,
    String? status,
    String? orderStatus,
    String? deliveryStatus,
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
    int? etaMinutes,
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
    bool? cancellable,
    String? deliveryCode,
    String? rawPlacedAt,
    String? specialInstructions,
    List<OrderStatusHistory>? statusHistory,
    String? addressLine1,
    String? addressLine2,
    String? addressCity,
    String? addressLabel,
    double? pickupLat,
    double? pickupLng,
    double? deliveryLat,
    double? deliveryLng,
    int? restaurantId,
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
      uuid: uuid ?? this.uuid,
      orderNumber: orderNumber ?? this.orderNumber,
      status: status ?? this.status,
      orderStatus: orderStatus ?? this.orderStatus,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
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
      etaMinutes: etaMinutes ?? this.etaMinutes,
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
      cancellable: cancellable ?? this.cancellable,
      deliveryCode: deliveryCode ?? this.deliveryCode,
      rawPlacedAt: rawPlacedAt ?? this.rawPlacedAt,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      statusHistory: statusHistory ?? this.statusHistory,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      addressCity: addressCity ?? this.addressCity,
      addressLabel: addressLabel ?? this.addressLabel,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      deliveryLat: deliveryLat ?? this.deliveryLat,
      deliveryLng: deliveryLng ?? this.deliveryLng,
      restaurantId: restaurantId ?? this.restaurantId,
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
