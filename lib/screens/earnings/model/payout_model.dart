class PayoutModel {
  final int id;
  final String paymentMethod;
  final String description;
  final double amount;
  final String createdAt;

  PayoutModel({
    required this.id,
    required this.paymentMethod,
    required this.description,
    required this.amount,
    required this.createdAt,
  });

  factory PayoutModel.fromJson(Map<String, dynamic> json) {
    return PayoutModel(
      id: json['id'] ?? 0,
      paymentMethod: json['payment_method']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payment_method': paymentMethod,
      'description': description,
      'amount': amount,
      'created_at': createdAt,
    };
  }

  PayoutModel copyWith({
    int? id,
    String? paymentMethod,
    String? description,
    double? amount,
    String? createdAt,
  }) {
    return PayoutModel(
      id: id ?? this.id,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
