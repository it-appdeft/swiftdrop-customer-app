class BannerModel {
  final int id;
  final String title;
  final String status;
  final String? imageUrl;

  const BannerModel({
    required this.id,
    required this.title,
    required this.status,
    this.imageUrl,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) => BannerModel(
        id: json['id'] as int? ?? 0,
        title: json['title'] as String? ?? json['name'] as String? ?? '',
        status: json['status'] as String? ?? '',
        imageUrl: (json['image_url'] ?? json['image'] ?? json['banner_image'] ?? json['photo']) as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'status': status,
        'image_url': imageUrl,
      };
}
