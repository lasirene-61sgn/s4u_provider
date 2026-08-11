class HandymanEarningModel {
  final String handymanName;
  final String bookingCount;
  final String payDue;
  final String paidAmount;
  final String totalEarning;

  HandymanEarningModel({
    required this.handymanName,
    required this.bookingCount,
    required this.payDue,
    required this.paidAmount,
    required this.totalEarning,
  });

  factory HandymanEarningModel.fromJson(Map<String, dynamic> json) {
    return HandymanEarningModel(
      handymanName: (json['handyman_name'] ?? (json['handyman'] is Map ? (json['handyman']['user'] is Map ? json['handyman']['user']['firstName'] : null) : null) ?? 'N/A').toString(),
      bookingCount: (json['total_bookings'] ?? json['booking'] ?? '0').toString(),
      payDue: (json['handyman_due_amount'] ?? json['due_amount'] ?? '0').toString(),
      paidAmount: (json['handyman_paid_earning'] ?? json['paid_amount'] ?? '0').toString(),
      totalEarning: (json['total_earning'] ?? json['total_amount'] ?? '0').toString(),
    );
  }
}
