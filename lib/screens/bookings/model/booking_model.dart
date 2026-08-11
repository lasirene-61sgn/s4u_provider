class BookingListResponse {
  final Pagination? pagination;
  final List<Booking> data;
  final String totalEarning;
  final PaymentBreakdown? paymentBreakdown;

  BookingListResponse({
    this.pagination,
    this.data = const [],
    this.totalEarning = "0.00",
    this.paymentBreakdown,
  });

  factory BookingListResponse.fromJson(Map<String, dynamic> json) {
    return BookingListResponse(
      pagination: json['pagination'] != null ? Pagination.fromJson(json['pagination']) : null,
      data: json['data'] != null ? (json['data'] as List).map((i) => Booking.fromJson(i)).toList() : [],
      totalEarning: json['total_earning']?.toString() ?? "0.00",
      paymentBreakdown: json['payment_breakdown'] != null ? PaymentBreakdown.fromJson(json['payment_breakdown']) : null,
    );
  }
}

class Pagination {
  final int totalItems;
  final int perPage;
  final int currentPage;
  final int totalPages;
  final int? from;
  final int? to;
  final String? nextPage;
  final String? previousPage;

  Pagination({
    this.totalItems = 0,
    this.perPage = 10,
    this.currentPage = 1,
    this.totalPages = 1,
    this.from,
    this.to,
    this.nextPage,
    this.previousPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      totalItems: json['total_items'] ?? 0,
      perPage: json['per_page'] ?? 10,
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      from: json['from'],
      to: json['to'],
      nextPage: json['next_page']?.toString(),
      previousPage: json['previous_page']?.toString(),
    );
  }
}

class PaymentBreakdown {
  final String adminEarned;
  final String handymanEarned;
  final String providerEarned;
  final String tax;
  final String discount;

  PaymentBreakdown({
    this.adminEarned = "0.00",
    this.handymanEarned = "0.00",
    this.providerEarned = "0.00",
    this.tax = "0.00",
    this.discount = "0.00",
  });

  factory PaymentBreakdown.fromJson(Map<String, dynamic> json) {
    return PaymentBreakdown(
      adminEarned: json['admin_earned']?.toString() ?? "0.00",
      handymanEarned: json['handyman_earned']?.toString() ?? "0.00",
      providerEarned: json['provider_earned']?.toString() ?? "0.00",
      tax: json['tax']?.toString() ?? "0.00",
      discount: json['discount']?.toString() ?? "0.00",
    );
  }
}

class Booking {
  final int id;
  final String bookingStatus;
  final String? serviceImage;
  final String? serviceName;
  final String? userName;
  final String? address;
  final String? bookingDate;
  final double? totalAmount;

  final String? bookingPlaced;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? userPhone;
  final String? userEmail;
  final String? userImage;
  
  final String? providerName;
  final String? providerPhone;
  final String? providerEmail;
  final String? providerImage;
  final String? providerAddress;

  final String? handymanName;
  final String? handymanPhone;
  final String? handymanEmail;
  final String? handymanImage;
  final String? handymanAddress;

  final double? advanceAmount;
  final double? discount;
  final double? subtotal;
  final double? tax;
  final bool hasAttachment;

  Booking({
    required this.id,
    required this.bookingStatus,
    this.serviceImage,
    this.serviceName,
    this.userName,
    this.address,
    this.bookingDate,
    this.totalAmount,
    this.bookingPlaced,
    this.paymentMethod,
    this.paymentStatus,
    this.userPhone,
    this.userEmail,
    this.userImage,
    this.providerName,
    this.providerPhone,
    this.providerEmail,
    this.providerImage,
    this.providerAddress,
    this.handymanName,
    this.handymanPhone,
    this.handymanEmail,
    this.handymanImage,
    this.handymanAddress,
    this.advanceAmount,
    this.discount,
    this.subtotal,
    this.tax,
    this.hasAttachment = false,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    String? hmName, hmPhone, hmEmail, hmImage, hmAddress;
    final handymanList = json['handyman'] as List?;
    if (handymanList != null && handymanList.isNotEmpty) {
      final hm = handymanList[0]['handyman'];
      if (hm != null) {
        hmName = hm['display_name'];
        hmPhone = hm['contact_number'];
        hmEmail = hm['email'];
        hmImage = hm['handyman_image'];
        hmAddress = hm['address'];
      }
    }

    return Booking(
      id: json['id'] ?? 0,
      bookingStatus: json['status'] ?? 'UNKNOWN',
      serviceImage: (json['service_attchments'] != null && (json['service_attchments'] as List).isNotEmpty) ? json['service_attchments'][0] : null,
      serviceName: json['service_name'],
      userName: json['customer_name'],
      address: json['address'],
      bookingDate: json['booking_date'] ?? json['date'],
      totalAmount: parseDouble(json['total_amount']),
      bookingPlaced: json['date'],
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'],
      userPhone: null, // Not provided directly in the root JSON
      userEmail: null,
      userImage: json['customer_image'],
      providerName: json['provider_name'],
      providerPhone: null,
      providerEmail: null,
      providerImage: json['provider_image'],
      providerAddress: null,
      handymanName: hmName,
      handymanPhone: hmPhone,
      handymanEmail: hmEmail,
      handymanImage: hmImage,
      handymanAddress: hmAddress,
      advanceAmount: parseDouble(json['advance_paid_amount']),
      discount: parseDouble(json['discount']),
      subtotal: parseDouble(json['amount']),
      tax: 0.0, // Assuming tax can be extracted later if needed
      hasAttachment: json['booking_attachment'] != null && (json['booking_attachment'] as List).isNotEmpty,
    );
  }
}
