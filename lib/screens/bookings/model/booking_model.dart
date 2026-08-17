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
  final int? paymentId;
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
    this.paymentId,
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

  Booking copyWith({
    int? id,
    String? bookingStatus,
    String? serviceImage,
    String? serviceName,
    String? userName,
    String? address,
    String? bookingDate,
    double? totalAmount,
    String? bookingPlaced,
    String? paymentMethod,
    String? paymentStatus,
    int? paymentId,
    String? userPhone,
    String? userEmail,
    String? userImage,
    String? providerName,
    String? providerPhone,
    String? providerEmail,
    String? providerImage,
    String? providerAddress,
    String? handymanName,
    String? handymanPhone,
    String? handymanEmail,
    String? handymanImage,
    String? handymanAddress,
    double? advanceAmount,
    double? discount,
    double? subtotal,
    double? tax,
    bool? hasAttachment,
  }) {
    return Booking(
      id: id ?? this.id,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      serviceImage: serviceImage ?? this.serviceImage,
      serviceName: serviceName ?? this.serviceName,
      userName: userName ?? this.userName,
      address: address ?? this.address,
      bookingDate: bookingDate ?? this.bookingDate,
      totalAmount: totalAmount ?? this.totalAmount,
      bookingPlaced: bookingPlaced ?? this.bookingPlaced,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentId: paymentId ?? this.paymentId,
      userPhone: userPhone ?? this.userPhone,
      userEmail: userEmail ?? this.userEmail,
      userImage: userImage ?? this.userImage,
      providerName: providerName ?? this.providerName,
      providerPhone: providerPhone ?? this.providerPhone,
      providerEmail: providerEmail ?? this.providerEmail,
      providerImage: providerImage ?? this.providerImage,
      providerAddress: providerAddress ?? this.providerAddress,
      handymanName: handymanName ?? this.handymanName,
      handymanPhone: handymanPhone ?? this.handymanPhone,
      handymanEmail: handymanEmail ?? this.handymanEmail,
      handymanImage: handymanImage ?? this.handymanImage,
      handymanAddress: handymanAddress ?? this.handymanAddress,
      advanceAmount: advanceAmount ?? this.advanceAmount,
      discount: discount ?? this.discount,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      hasAttachment: hasAttachment ?? this.hasAttachment,
    );
  }



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
      paymentId: json['payment_id'] != null ? int.tryParse(json['payment_id'].toString()) : null,
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

class BookingDetailResponse {
  final Booking? bookingDetail;
  final UserData? customer;
  final UserData? providerData;
  final List<UserData> handymanData;
  final List<BookingActivity> bookingActivity;

  BookingDetailResponse({
    this.bookingDetail,
    this.customer,
    this.providerData,
    this.handymanData = const [],
    this.bookingActivity = const [],
  });

  BookingDetailResponse copyWith({
    Booking? bookingDetail,
    UserData? customer,
    UserData? providerData,
    List<UserData>? handymanData,
    List<BookingActivity>? bookingActivity,
  }) {
    return BookingDetailResponse(
      bookingDetail: bookingDetail ?? this.bookingDetail,
      customer: customer ?? this.customer,
      providerData: providerData ?? this.providerData,
      handymanData: handymanData ?? this.handymanData,
      bookingActivity: bookingActivity ?? this.bookingActivity,
    );
  }

  factory BookingDetailResponse.fromJson(Map<String, dynamic> json) {
    return BookingDetailResponse(
      bookingDetail: json['booking_detail'] != null ? Booking.fromJson(json['booking_detail']) : null,
      customer: json['customer'] != null ? UserData.fromJson(json['customer']) : null,
      providerData: json['provider_data'] != null ? UserData.fromJson(json['provider_data']) : null,
      handymanData: json['handyman_data'] != null ? (json['handyman_data'] as List).map((i) => UserData.fromJson(i)).toList() : [],
      bookingActivity: json['booking_activity'] != null ? (json['booking_activity'] as List).map((i) => BookingActivity.fromJson(i)).toList() : [],
    );
  }
}

class UserData {
  final int id;
  final String? firstName;
  final String? lastName;
  final String? displayName;
  final String? email;
  final String? contactNumber;
  final String? address;
  final String? profileImage;

  UserData({
    required this.id,
    this.firstName,
    this.lastName,
    this.displayName,
    this.email,
    this.contactNumber,
    this.address,
    this.profileImage,
  });

  UserData copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? displayName,
    String? email,
    String? contactNumber,
    String? address,
    String? profileImage,
  }) {
    return UserData(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      contactNumber: contactNumber ?? this.contactNumber,
      address: address ?? this.address,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? 0,
      firstName: json['first_name'],
      lastName: json['last_name'],
      displayName: json['display_name'],
      email: json['email'],
      contactNumber: json['contact_number'],
      address: json['address'],
      profileImage: json['profile_image'],
    );
  }
}

class BookingActivity {
  final int id;
  final int bookingId;
  final String? datetime;
  final String? activityType;
  final String? activityMessage;

  BookingActivity({
    required this.id,
    required this.bookingId,
    this.datetime,
    this.activityType,
    this.activityMessage,
  });

  BookingActivity copyWith({
    int? id,
    int? bookingId,
    String? datetime,
    String? activityType,
    String? activityMessage,
  }) {
    return BookingActivity(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      datetime: datetime ?? this.datetime,
      activityType: activityType ?? this.activityType,
      activityMessage: activityMessage ?? this.activityMessage,
    );
  }

  factory BookingActivity.fromJson(Map<String, dynamic> json) {
    return BookingActivity(
      id: json['id'] ?? 0,
      bookingId: json['booking_id'] ?? 0,
      datetime: json['datetime'],
      activityType: json['activity_type'],
      activityMessage: json['activity_message'],
    );
  }
}
