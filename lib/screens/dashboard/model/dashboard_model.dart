class DashboardStats {
  final int totalBooking;
  final int totalService;
  final int totalActiveHandyman;
  final double totalCashInHand;
  final double totalRevenue;
  final double remainingPayout;
  final int notificationUnreadCount;
  final int isSubscribed;
  final double providerWalletAmount;
  final List<dynamic> services;
  final List<dynamic> handymen;
  final List<dynamic> upcomingBookings;
  final Map<String, dynamic>? monthlyRevenue;
  final Map<String, dynamic>? commission;
  final int completedBooking;
  final int todayBooking;

  DashboardStats({
    this.totalBooking = 0,
    this.totalService = 0,
    this.totalActiveHandyman = 0,
    this.totalCashInHand = 0.0,
    this.totalRevenue = 0.0,
    this.remainingPayout = 0.0,
    this.notificationUnreadCount = 0,
    this.isSubscribed = 0,
    this.providerWalletAmount = 0.0,
    this.services = const [],
    this.handymen = const [],
    this.upcomingBookings = const [],
    this.monthlyRevenue,
    this.commission,
    this.completedBooking = 0,
    this.todayBooking = 0,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    return DashboardStats(
      totalBooking: parseInt(json['total_booking']),
      totalService: parseInt(json['total_service']),
      totalActiveHandyman: parseInt(json['total_active_handyman']),
      totalCashInHand: parseDouble(json['total_cash_in_hand']),
      totalRevenue: parseDouble(json['total_revenue']),
      remainingPayout: parseDouble(json['remaining_payout']),
      notificationUnreadCount: parseInt(json['notification_unread_count']),
      isSubscribed: parseInt(json['is_subscribed']),
      providerWalletAmount: json['provider_wallet'] != null ? parseDouble(json['provider_wallet']['amount']) : 0.0,
      services: json['service'] as List<dynamic>? ?? [],
      handymen: json['handyman'] as List<dynamic>? ?? [],
      upcomingBookings: json['upcomming_booking'] as List<dynamic>? ?? [],
      monthlyRevenue: json['monthly_revenue'] as Map<String, dynamic>?,
      commission: json['commission'] as Map<String, dynamic>?,
      completedBooking: parseInt(json['completed_booking']),
      todayBooking: parseInt(json['today_booking']),
    );
  }
}
