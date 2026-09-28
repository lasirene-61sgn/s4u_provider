import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/api/api_client.dart';
import '../model/booking_model.dart';
import '../../dashboard/riverpod/dashboard_notifier.dart';
import '../../earnings/riverpod/earnings_notifier.dart';

class BookingsState {
  final bool isLoading;
  final bool isDetailLoading;
  final bool isFetchingMore;
  final List<Booking> bookings;
  final String? error;
  final int page;
  final bool hasMore;
  final int downloadingInvoiceId;
  final BookingDetailResponse? currentBookingDetail;

  BookingsState({
    this.isLoading = false,
    this.isDetailLoading = false,
    this.isFetchingMore = false,
    this.bookings = const [],
    this.error,
    this.page = 1,
    this.hasMore = true,
    this.downloadingInvoiceId = -1,
    this.currentBookingDetail,
  });

  BookingsState copyWith({
    bool? isLoading,
    bool? isDetailLoading,
    bool? isFetchingMore,
    List<Booking>? bookings,
    String? error,
    int? page,
    bool? hasMore,
    int? downloadingInvoiceId,
    BookingDetailResponse? currentBookingDetail,
  }) {
    return BookingsState(
      isLoading: isLoading ?? this.isLoading,
      isDetailLoading: isDetailLoading ?? this.isDetailLoading,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      bookings: bookings ?? this.bookings,
      error: error ?? this.error,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      downloadingInvoiceId: downloadingInvoiceId ?? this.downloadingInvoiceId,
      currentBookingDetail: currentBookingDetail ?? this.currentBookingDetail,
    );
  }
}

class BookingsNotifier extends Notifier<BookingsState> {
  final ApiClient _api = ApiClient();

  @override
  BookingsState build() {
    return BookingsState(isLoading: true);
  }

  Future<void> _fetchBookings({bool loadMore = false, String? search}) async {
    if (loadMore) {
      if (!state.hasMore || state.isFetchingMore) return;
      state = state.copyWith(isFetchingMore: true, error: null);
    } else {
      state = state.copyWith(isLoading: true, error: null, page: 1, hasMore: true);
    }

    final page = loadMore ? state.page + 1 : 1;
    final query = <String, dynamic>{'page': page};
    if (search != null && search.isNotEmpty) {
      query['search'] = search;
    }
    final res = await _api.get(endpoint: '/booking-list', query: query);

    if (res['status'] == 1 && res['data'] != null) {
      final responseModel = BookingListResponse.fromJson(res['data']);
      final newBookings = responseModel.data;
      
      final totalPages = responseModel.pagination?.totalPages ?? 1;
      final hasNextPage = page < totalPages;

      state = state.copyWith(
        isLoading: false,
        isFetchingMore: false,
        bookings: loadMore ? [...state.bookings, ...newBookings] : newBookings,
        page: page,
        hasMore: hasNextPage,
      );
    } else {
      state = state.copyWith(isLoading: false, isFetchingMore: false, error: res['message']);
    }
  }

  Future<void> loadMore({String? search}) async {
    await _fetchBookings(loadMore: true, search: search);
  }

  Future<void> refresh({String? search}) async {
    await _fetchBookings(loadMore: false, search: search);
  }

  Future<void> fetchBookingDetail(int bookingId) async {
    state = state.copyWith(isDetailLoading: true, currentBookingDetail: null);
    try {
      final res = await _api.post(
        endpoint: '/booking-detail',
        body: {'booking_id': bookingId},
      );
      if (res is Map && res['status'] == 1 && res['data'] != null) {
        state = state.copyWith(
          isDetailLoading: false,
          currentBookingDetail: BookingDetailResponse.fromJson(res['data']),
        );
      } else {
        state = state.copyWith(isDetailLoading: false);
      }
    } catch (e) {
      debugPrint('Error fetching booking detail: $e');
      state = state.copyWith(isDetailLoading: false);
    }
  }

  Future<void> assignHandyman(int bookingId, int handymanId) async {
    try {
      final res = await _api.post(
        endpoint: '/booking-assigned',
        body: {'id': bookingId, 'handyman_id': [handymanId]},
      );
      if (res is Map && (res['status'] == 1 || res['status'] == true)) {
        Fluttertoast.showToast(msg: res['message']?.toString() ?? 'Handyman assigned successfully', backgroundColor: Colors.green, textColor: Colors.white);
        await _fetchBookings();
        if (state.currentBookingDetail?.bookingDetail?.id == bookingId) {
          await fetchBookingDetail(bookingId);
        }
        ref.invalidate(dashboardProvider);
      } else {
        Fluttertoast.showToast(msg: (res is Map ? res['message']?.toString() : null) ?? 'Failed to assign handyman', backgroundColor: Colors.red, textColor: Colors.white);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red, textColor: Colors.white);
    }
  }

  Future<void> assignSelf(int bookingId) async {
    try {
      final res = await _api.post(
        endpoint: '/booking-assign-self',
        body: {'id': bookingId},
      );
      if (res is Map && (res['status'] == 1 || res['status'] == true)) {
        Fluttertoast.showToast(msg: res['message']?.toString() ?? 'Self assigned successfully', backgroundColor: Colors.green, textColor: Colors.white);
        await _fetchBookings();
        if (state.currentBookingDetail?.bookingDetail?.id == bookingId) {
          await fetchBookingDetail(bookingId);
        }
        ref.invalidate(dashboardProvider);
      } else {
        Fluttertoast.showToast(msg: (res is Map ? res['message']?.toString() : null) ?? 'Failed to self assign', backgroundColor: Colors.red, textColor: Colors.white);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red, textColor: Colors.white);
    }
  }

  Future<void> confirmCompletion(int bookingId) async {
    try {
      final res = await _api.post(
        endpoint: '/provider/bookings/$bookingId/complete',
        body: {},
      );
      if (res is Map && (res['status'] == 1 || res['status'] == true)) {
        Fluttertoast.showToast(msg: res['message']?.toString() ?? 'Completion confirmed successfully', backgroundColor: Colors.green, textColor: Colors.white);
        await _fetchBookings();
        if (state.currentBookingDetail?.bookingDetail?.id == bookingId) {
          await fetchBookingDetail(bookingId);
        }
        ref.invalidate(dashboardProvider);
        ref.invalidate(earningsProvider);
      } else {
        Fluttertoast.showToast(msg: (res is Map ? res['message']?.toString() : null) ?? 'Failed to confirm completion', backgroundColor: Colors.red, textColor: Colors.white);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red, textColor: Colors.white);
    }
  }

  Future<void> confirmJob(int bookingId) async {
    try {
      final res = await _api.put(
        endpoint: '/bookings/$bookingId/confirm',
      );
      if (res is Map && (res['status'] == 1 || res['status'] == true)) {
        Fluttertoast.showToast(msg: res['message']?.toString() ?? 'Job confirmed successfully', backgroundColor: Colors.green, textColor: Colors.white);
        await _fetchBookings();
        if (state.currentBookingDetail?.bookingDetail?.id == bookingId) {
          await fetchBookingDetail(bookingId);
        }
        ref.invalidate(dashboardProvider);
        ref.invalidate(earningsProvider);
      } else {
        Fluttertoast.showToast(msg: (res is Map ? res['message']?.toString() : null) ?? 'Failed to confirm job', backgroundColor: Colors.red, textColor: Colors.white);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red, textColor: Colors.white);
    }
  }
  Future<void> bookingAction(int bookingId, String type, {String? reason}) async {
    try {
      final body = {
        'id': bookingId,
        'type': type,
      };
      if (reason != null) body['reason'] = reason;

      final res = await _api.post(
        endpoint: '/booking-action',
        body: body,
      );
      if (res is Map && (res['status'] == 1 || res['status'] == true)) {
        Fluttertoast.showToast(msg: res['message']?.toString() ?? 'Booking action successful', backgroundColor: Colors.green, textColor: Colors.white);
        await _fetchBookings();
        if (state.currentBookingDetail?.bookingDetail?.id == bookingId) {
          await fetchBookingDetail(bookingId);
        }
        ref.invalidate(dashboardProvider);
        ref.invalidate(earningsProvider);
      } else {
        Fluttertoast.showToast(msg: (res is Map ? res['message']?.toString() : null) ?? 'Failed to perform action', backgroundColor: Colors.red, textColor: Colors.white);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red, textColor: Colors.white);
    }
  }

  Future<void> saveServiceProof(int bookingId, String title, PlatformFile file) async {
    try {
      final res = await _api.requestWithFiles(
        endpoint: '/save-service-proof',
        fields: {
          'booking_id': bookingId.toString(),
          'title': title,
        },
        files: {
          'booking_attachment[0]': file,
        },
      );
      if (res is Map && (res['status'] == 1 || res['status'] == true)) {
        Fluttertoast.showToast(msg: res['message']?.toString() ?? 'Proof uploaded successfully', backgroundColor: Colors.green, textColor: Colors.white);
        await _fetchBookings();
        if (state.currentBookingDetail?.bookingDetail?.id == bookingId) {
          await fetchBookingDetail(bookingId);
        }
        ref.invalidate(dashboardProvider);
      } else {
        Fluttertoast.showToast(msg: (res is Map ? res['message']?.toString() : null) ?? 'Failed to upload proof', backgroundColor: Colors.red, textColor: Colors.white);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red, textColor: Colors.white);
    }
  }

  Future<void> updateBookingStatus(int bookingId, String status, {String paymentStatus = 'pending'}) async {
    try {
      final res = await _api.post(
        endpoint: '/booking-update',
        body: {'id': bookingId, 'status': status, 'payment_status': paymentStatus},
      );
      if (res is Map && (res['status'] == 1 || res['status'] == true)) {
        Fluttertoast.showToast(msg: res['message']?.toString() ?? 'Booking status updated', backgroundColor: Colors.green, textColor: Colors.white);
        await _fetchBookings();
        if (state.currentBookingDetail?.bookingDetail?.id == bookingId) {
          await fetchBookingDetail(bookingId);
        }
        ref.invalidate(dashboardProvider);
        ref.invalidate(earningsProvider);
      } else {
        Fluttertoast.showToast(msg: (res is Map ? res['message']?.toString() : null) ?? 'Failed to update status', backgroundColor: Colors.red, textColor: Colors.white);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red, textColor: Colors.white);
    }
  }

  Future<void> markArrived(int bookingId) async {
    try {
      final res = await _api.post(
        endpoint: '/bookings/$bookingId/arrive',
      );
      if (res is Map && (res['status'] == 1 || res['status'] == true)) {
        Fluttertoast.showToast(msg: res['message']?.toString() ?? 'Marked as arrived', backgroundColor: Colors.green, textColor: Colors.white);
        await _fetchBookings();
        if (state.currentBookingDetail?.bookingDetail?.id == bookingId) {
          await fetchBookingDetail(bookingId);
        }
        ref.invalidate(dashboardProvider);
      } else {
        Fluttertoast.showToast(msg: (res is Map ? res['message']?.toString() : null) ?? 'Failed to mark arrived', backgroundColor: Colors.red, textColor: Colors.white);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red, textColor: Colors.white);
    }
  }

  Future<bool> verifyStartOtp(int bookingId, String otp) async {
    try {
      final res = await _api.post(
        endpoint: '/bookings/$bookingId/verify-start',
        body: {'otp': otp},
      );
      if (res is Map && (res['status'] == 1 || res['status'] == true)) {
        Fluttertoast.showToast(msg: res['message']?.toString() ?? 'OTP verified successfully', backgroundColor: Colors.green, textColor: Colors.white);
        await _fetchBookings();
        if (state.currentBookingDetail?.bookingDetail?.id == bookingId) {
          await fetchBookingDetail(bookingId);
        }
        ref.invalidate(dashboardProvider);
        return true;
      } else {
        Fluttertoast.showToast(msg: (res is Map ? res['message']?.toString() : null) ?? 'Failed to verify OTP', backgroundColor: Colors.red, textColor: Colors.white);
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red, textColor: Colors.white);
      return false;
    }
  }

  Future<bool> verifyCompletionOtp(int bookingId, String otp) async {
    try {
      final res = await _api.post(
        endpoint: '/bookings/$bookingId/verify-complete',
        body: {'otp': otp},
      );
      if (res is Map && (res['status'] == 1 || res['status'] == true)) {
        Fluttertoast.showToast(msg: res['message']?.toString() ?? 'Completion OTP verified', backgroundColor: Colors.green, textColor: Colors.white);
        await _fetchBookings();
        if (state.currentBookingDetail?.bookingDetail?.id == bookingId) {
          await fetchBookingDetail(bookingId);
        }
        ref.invalidate(dashboardProvider);
        ref.invalidate(earningsProvider);
        return true;
      } else {
        Fluttertoast.showToast(msg: (res is Map ? res['message']?.toString() : null) ?? 'Failed to verify OTP', backgroundColor: Colors.red, textColor: Colors.white);
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red, textColor: Colors.white);
      return false;
    }
  }

  Future<void> downloadInvoice(int bookingId, String email) async {
    state = state.copyWith(downloadingInvoiceId: bookingId);
    try {
      final res = await _api.post(
        endpoint: '/download-invoice',
        body: {'booking_id': bookingId, 'email': email},
      );
      
      if (res is Map && res['status'] == 1) {
        final data = res['data'];
        if (data is Map && data.containsKey('message') && data['message'] == 'Something went wrong.') {
          Fluttertoast.showToast(msg: data['message'].toString(), backgroundColor: Colors.red, textColor: Colors.white);
        } else if (data is Map && data.containsKey('message')) {
            Fluttertoast.showToast(msg: data['message'].toString(), backgroundColor: Colors.green, textColor: Colors.white);
        } else {
          Fluttertoast.showToast(msg: 'Invoice generated successfully', backgroundColor: Colors.green, textColor: Colors.white);
        }
      } else {
        final msg = res is Map ? res['message'] : 'Failed to download invoice';
        Fluttertoast.showToast(msg: msg?.toString() ?? 'Error', backgroundColor: Colors.red, textColor: Colors.white);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e', backgroundColor: Colors.red, textColor: Colors.white);
    } finally {
      state = state.copyWith(downloadingInvoiceId: -1);
    }
  }
}

final bookingsProvider = NotifierProvider<BookingsNotifier, BookingsState>(() => BookingsNotifier());
