class AddressModel {
  final String id;
  final String label;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String county;
  final String postcode;
  final double lat;
  final double lng;
  final bool isDefault;
  final bool isSelected;
  final String? deliveryInstructions;

  AddressModel({
    required this.id,
    required this.label,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.county,
    required this.postcode,
    required this.lat,
    required this.lng,
    this.isDefault = false,
    this.isSelected = false,
    this.deliveryInstructions,
  });

  String get address =>
      [addressLine1, city].where((s) => s.isNotEmpty).join(', ');

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'].toString(),
      label: json['label'] as String? ?? '',
      addressLine1: json['address_line_1'] as String? ?? '',
      addressLine2: json['address_line_2'] as String?,
      city: json['city'] as String? ?? '',
      county: json['county'] as String? ?? '',
      postcode: json['postcode'] as String? ?? '',
      lat: double.tryParse(json['lat']?.toString() ?? '') ?? 0.0,
      lng: double.tryParse(json['lng']?.toString() ?? '') ?? 0.0,
      isDefault: json['is_default'] as bool? ?? false,
      isSelected: json['is_selected'] as bool? ?? false,
      deliveryInstructions: json['delivery_instructions'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'address_line_1': addressLine1,
        'address_line_2': addressLine2,
        'city': city,
        'county': county,
        'postcode': postcode,
        'lat': lat.toString(),
        'lng': lng.toString(),
        'is_default': isDefault,
        'is_selected': isSelected,
        'delivery_instructions': deliveryInstructions,
      };

  AddressModel copyWith({
    String? id,
    String? label,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? county,
    String? postcode,
    double? lat,
    double? lng,
    bool? isDefault,
    bool? isSelected,
    String? deliveryInstructions,
  }) {
    return AddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      county: county ?? this.county,
      postcode: postcode ?? this.postcode,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      isDefault: isDefault ?? this.isDefault,
      isSelected: isSelected ?? this.isSelected,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
    );
  }
}
