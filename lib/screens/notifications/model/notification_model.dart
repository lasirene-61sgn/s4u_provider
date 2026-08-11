class NotificationModel {
  final String id;
  final String? readAt;
  final String? profileImage;
  final String createdAt;
  final NotificationData data;

  NotificationModel({
    required this.id,
    this.readAt,
    this.profileImage,
    required this.createdAt,
    required this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      readAt: json['read_at']?.toString(),
      profileImage: json['profile_image']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      data: NotificationData.fromJson(json['data'] ?? {}),
    );
  }
}

class NotificationData {
  final int id;
  final String type;
  final String message;
  final String? adminName;
  final String? companyName;
  final String? customerName;
  final String? bookingDate;
  final String? bookingTime;

  NotificationData({
    required this.id,
    required this.type,
    required this.message,
    this.adminName,
    this.companyName,
    this.customerName,
    this.bookingDate,
    this.bookingTime,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      type: json['type']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      adminName: json['admin_name']?.toString(),
      companyName: json['company_name']?.toString(),
      customerName: json['customer_name']?.toString(),
      bookingDate: json['booking_date']?.toString(),
      bookingTime: json['booking_time']?.toString(),
    );
  }
}
