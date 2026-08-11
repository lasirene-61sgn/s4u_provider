import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../model/payment_model.dart';

class CashPaymentState {
  final bool isLoading;
  final List<PaymentModel> payments;
  final double todayCash;
  final double totalCashInHand;
  final String? error;

  CashPaymentState({
    this.isLoading = false,
    this.payments = const [],
    this.todayCash = 0.0,
    this.totalCashInHand = 0.0,
    this.error,
  });

  CashPaymentState copyWith({
    bool? isLoading,
    List<PaymentModel>? payments,
    double? todayCash,
    double? totalCashInHand,
    String? error,
  }) {
    return CashPaymentState(
      isLoading: isLoading ?? this.isLoading,
      payments: payments ?? this.payments,
      todayCash: todayCash ?? this.todayCash,
      totalCashInHand: totalCashInHand ?? this.totalCashInHand,
      error: error ?? this.error,
    );
  }
}

class CashPaymentNotifier extends Notifier<CashPaymentState> {
  final ApiClient _apiClient = ApiClient();

  @override
  CashPaymentState build() {
    return CashPaymentState();
  }

  Future<void> fetchCashPayments({String? search}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Fetch paginated cash payments
      final query = <String, dynamic>{'per_page': 100, 'page': 1};
      if (search != null && search.isNotEmpty) {
        query['search'] = search;
      }
      final paymentsResponse = await _apiClient.get(endpoint: '/get-cash-payment', query: query);
      List<PaymentModel> paymentsList = [];
      if (paymentsResponse is Map && paymentsResponse.containsKey('data')) {
        final rData = paymentsResponse['data'];
        if (rData is List) {
          paymentsList = rData.map((e) => PaymentModel.fromJson(e)).toList();
        } else if (rData is Map && rData.containsKey('data')) {
          paymentsList = (rData['data'] as List).map((e) => PaymentModel.fromJson(e)).toList();
        }
      } else if (paymentsResponse is List) {
        paymentsList = paymentsResponse.map((e) => PaymentModel.fromJson(e)).toList();
      }

      // Fetch cash details (totals)
      final detailResponse = await _apiClient.get(endpoint: '/cash-detail?per_page=100&page=1');
      double today = 0.0;
      double total = 0.0;
      if (detailResponse is Map) {
        final dData = detailResponse['data'] ?? detailResponse;
        if (dData is Map) {
          today = (dData['today_cash'] ?? 0).toDouble();
          total = (dData['total_cash_in_hand'] ?? 0).toDouble();
        }
      }

      state = state.copyWith(
        isLoading: false,
        payments: paymentsList,
        todayCash: today,
        totalCashInHand: total,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final cashPaymentProvider = NotifierProvider<CashPaymentNotifier, CashPaymentState>(() => CashPaymentNotifier());
