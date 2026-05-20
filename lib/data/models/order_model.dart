class OrderItem {
  final String name;
  final int quantity;
  final double price;

  const OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        name: json['name'] as String,
        quantity: json['quantity'] as int,
        price: (json['price'] as num).toDouble(),
      );

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
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'] as String,
        orderNumber: json['orderNumber'] as String,
        status: json['status'] as String,
        pickupAddress: json['pickupAddress'] as String,
        deliveryAddress: json['deliveryAddress'] as String,
        items: (json['items'] as List<dynamic>)
            .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalAmount: (json['totalAmount'] as num).toDouble(),
        deliveryFee: (json['deliveryFee'] as num).toDouble(),
        driverTip: (json['driverTip'] as num?)?.toDouble() ?? 0.0,
        distance: (json['distance'] as num).toDouble(),
        estimatedTime: json['estimatedTime'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
        acceptedAt: json['acceptedAt'] != null
            ? DateTime.tryParse(json['acceptedAt'] as String)
            : null,
        pickedUpAt: json['pickedUpAt'] != null
            ? DateTime.tryParse(json['pickedUpAt'] as String)
            : null,
        deliveredAt: json['deliveredAt'] != null
            ? DateTime.tryParse(json['deliveredAt'] as String)
            : null,
      );

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
      };

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isPickedUp => status == 'picked_up';
  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';
  bool get isActive => isPending || isAccepted || isPickedUp;
}
