class PaymentModel {
  final int id;
  final int bookingId;
  final int customerId;
  final double totalAmount;
  final String paymentStatus;
  final String paymentType;
  final String paymentMethod;
  final String customerName;
  final int quantity;
  final double price;
  final double discount;
  final double advancePaidAmount;
  final String date;
  final String txnId;

  PaymentModel({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.totalAmount,
    required this.paymentStatus,
    required this.paymentType,
    required this.paymentMethod,
    required this.customerName,
    required this.quantity,
    required this.price,
    required this.discount,
    required this.advancePaidAmount,
    required this.date,
    required this.txnId,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? 0,
      bookingId: json['booking_id'] ?? 0,
      customerId: json['customer_id'] ?? 0,
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      paymentStatus: json['payment_status']?.toString() ?? '',
      paymentType: json['payment_type']?.toString() ?? '',
      paymentMethod: json['payment_method']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      advancePaidAmount: (json['advance_paid_amount'] ?? 0).toDouble(),
      date: json['date']?.toString() ?? '',
      txnId: json['txn_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'customer_id': customerId,
      'total_amount': totalAmount,
      'payment_status': paymentStatus,
      'payment_type': paymentType,
      'payment_method': paymentMethod,
      'customer_name': customerName,
      'quantity': quantity,
      'price': price,
      'discount': discount,
      'advance_paid_amount': advancePaidAmount,
      'date': date,
      'txn_id': txnId,
    };
  }

  PaymentModel copyWith({
    int? id,
    int? bookingId,
    int? customerId,
    double? totalAmount,
    String? paymentStatus,
    String? paymentType,
    String? paymentMethod,
    String? customerName,
    int? quantity,
    double? price,
    double? discount,
    double? advancePaidAmount,
    String? date,
    String? txnId,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      customerId: customerId ?? this.customerId,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentType: paymentType ?? this.paymentType,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      customerName: customerName ?? this.customerName,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      advancePaidAmount: advancePaidAmount ?? this.advancePaidAmount,
      date: date ?? this.date,
      txnId: txnId ?? this.txnId,
    );
  }
}
