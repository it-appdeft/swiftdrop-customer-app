class UserModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? avatar;
  final String? countryCode;
  final String? type;
  final String? vehicleType;
  final String? vehicleNumber;
  final double? rating;
  final int totalDeliveries;
  final bool isActive;
  final bool isVerified;
  final bool isOnline;
  final double walletBalance;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.avatar,
    this.countryCode,
    this.type,
    this.vehicleType,
    this.vehicleNumber,
    this.rating,
    this.totalDeliveries = 0,
    this.isActive = true,
    this.isVerified = false,
    this.isOnline = false,
    this.walletBalance = 0.0,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId.toString() : rawId as String? ?? '';
    return UserModel(
      id: id,
      name: json['name'] as String? ?? '',
      phone: (json['mobile'] ?? json['phone'] ?? '') as String,
      email: json['email'] as String?,
      avatar: (json['profile_photo'] ?? json['avatar']) as String?,
      countryCode: json['country_code'] as String?,
      type: json['type'] as String?,
      vehicleType: json['vehicleType'] as String?,
      vehicleNumber: json['vehicleNumber'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      totalDeliveries: json['totalDeliveries'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      isVerified: json['isVerified'] as bool? ?? false,
      isOnline: json['isOnline'] as bool? ?? false,
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'avatar': avatar,
        'country_code': countryCode,
        'type': type,
        'vehicleType': vehicleType,
        'vehicleNumber': vehicleNumber,
        'rating': rating,
        'totalDeliveries': totalDeliveries,
        'isActive': isActive,
        'isVerified': isVerified,
        'isOnline': isOnline,
        'walletBalance': walletBalance,
        'createdAt': createdAt?.toIso8601String(),
      };

  UserModel copyWith({
    String? name,
    String? email,
    String? avatar,
    String? countryCode,
    String? type,
    double? walletBalance,
    bool? isVerified,
    bool? isOnline,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      phone: phone,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      countryCode: countryCode ?? this.countryCode,
      type: type ?? this.type,
      vehicleType: vehicleType,
      vehicleNumber: vehicleNumber,
      rating: rating,
      totalDeliveries: totalDeliveries,
      isActive: isActive,
      isVerified: isVerified ?? this.isVerified,
      isOnline: isOnline ?? this.isOnline,
      walletBalance: walletBalance ?? this.walletBalance,
      createdAt: createdAt,
    );
  }
}
