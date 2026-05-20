class DeletionReason {
  final int id;
  final String reason;

  const DeletionReason({required this.id, required this.reason});

  factory DeletionReason.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int
        ? rawId
        : (rawId is String ? int.tryParse(rawId) ?? 0 : 0);
    final raw = json['reason'] ??
        json['title'] ??
        json['label'] ??
        json['name'] ??
        '';
    return DeletionReason(id: id, reason: raw as String);
  }
}
