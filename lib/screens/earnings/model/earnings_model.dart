class Earnings {
  final double today;
  final double thisMonth;
  final double total;
  final List<ProviderEarningModel> transactions;

  Earnings({this.today = 0, this.thisMonth = 0, this.total = 0, this.transactions = const []});

  
  Earnings copyWith({
    double? today, double? thisMonth, double? total, List<ProviderEarningModel>? transactions
  }) {
    return Earnings(
      today: today ?? this.today,
      thisMonth: thisMonth ?? this.thisMonth,
      total: total ?? this.total,
      transactions: transactions ?? this.transactions,
    );
  }

  factory Earnings.fromJson(Map<String, dynamic> json) {
    return Earnings(
      today: (json['today'] as num?)?.toDouble() ?? 0.0,
      thisMonth: (json['this_month'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      transactions: [], // Not populated from this endpoint initially
    );
  }
}

class ProviderEarningModel {
  final int id;
  final int bookingId;
  final double totalAmount;
  final double providerEarning;
  final double adminEarning;
  final double handymanEarning;
  final String date;

  ProviderEarningModel({
    required this.id,
    required this.bookingId,
    required this.totalAmount,
    required this.providerEarning,
    required this.adminEarning,
    required this.handymanEarning,
    required this.date,
  });

  factory ProviderEarningModel.fromJson(Map<String, dynamic> json) {
    return ProviderEarningModel(
      id: json['id'] ?? 0,
      bookingId: json['bookingId'] ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      providerEarning: (json['providerEarning'] as num?)?.toDouble() ?? 0.0,
      adminEarning: (json['adminEarning'] as num?)?.toDouble() ?? 0.0,
      handymanEarning: (json['handymanEarning'] as num?)?.toDouble() ?? 0.0,
      date: json['createdAt']?.toString() ?? '',
    );
  }
}
