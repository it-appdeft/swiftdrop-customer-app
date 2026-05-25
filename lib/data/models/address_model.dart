class AddressModel {
  final String id;
  final String label; // Home, Work, Office
  final String address;
  final bool isSelected;

  AddressModel({
    required this.id,
    required this.label,
    required this.address,
    this.isSelected = false,
  });

  AddressModel copyWith({
    String? id,
    String? label,
    String? address,
    bool? isSelected,
  }) {
    return AddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      address: address ?? this.address,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
