import 'package:flutter/foundation.dart';

class ApiConstants {
  static const String baseUrl = 'https://s4u.lasireneexim.com';
  static const String login = '/login';
  static const String logout = '/logout';
  static const String register = '/register';
  
  static const String providerDashboard = '/provider-dashboard';
  static const String handymanDashboard = '/handyman-dashboard';
  static const String providerBookings = '/api/provider/bookings';
  static const String providerHandymen = '/api/provider/handymen';
  static const String providerEarnings = '/api/provider/earnings';
  static const String providerPayments = '/api/provider/payments';
  static const String providerProfile = '/api/provider/profile';
  static const String notifications = '/api/notifications';

  static String assignHandyman(int bookingId) => '/api/bookings/$bookingId/assign-handyman';
  static String handymanAccept(int bookingId) => '/api/bookings/$bookingId/accept';
  static String handymanStart(int bookingId) => '/api/bookings/$bookingId/start';
  static String handymanComplete(int bookingId) => '/api/bookings/$bookingId/complete';
  static String providerConfirm(int bookingId) => '/api/bookings/$bookingId/confirm';
  static String bookingHistory(int bookingId) => '/api/bookings/$bookingId/history';
  static const String banners = '/api/banners';
  
  static const String categories = '/api/category-list';
  static const String subcategories = '/api/subcategory-list';
  static String subcategoriesByCategory(dynamic categoryId) => '/api/subcategory-list?category_id=$categoryId';
  static const String services = '/api/services';

  // Post Job / Service Request
  static const String getPostJobs = '/get-post-job';
  static const String getPostJobDetail = '/get-post-job-detail';
  static const String postJobStatus = '/post-job-status';
  static const String getBidList = '/get-bid-list';
  static const String saveBid = '/save-bid';
}
