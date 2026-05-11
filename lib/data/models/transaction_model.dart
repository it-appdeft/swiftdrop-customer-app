class TransactionModel {
  final String id;
  final String type;
  final double amount;
  final String description;
  final DateTime createdAt;
  final String status;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdAt,
    required this.status,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
        id: json['id'] as String,
        type: json['type'] as String,
        amount: (json['amount'] as num).toDouble(),
        description: json['description'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        status: json['status'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'amount': amount,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
        'status': status,
      };

  bool get isCredit => type == 'credit';
  bool get isDebit => type == 'debit';
}
