import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../model/payment_model.dart';

class PaymentState {
  final bool isLoading;
  final List<PaymentModel> payments;
  final String? error;

  PaymentState({this.isLoading = false, this.payments = const [], this.error});

  PaymentState copyWith({bool? isLoading, List<PaymentModel>? payments, String? error}) {
    return PaymentState(
      isLoading: isLoading ?? this.isLoading,
      payments: payments ?? this.payments,
      error: error ?? this.error,
    );
  }
}

class PaymentNotifier extends Notifier<PaymentState> {
  final ApiClient _apiClient = ApiClient();

  @override
  PaymentState build() {
    return PaymentState();
  }

  Future<void> fetchPayments({String? search}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final query = <String, dynamic>{'per_page': 100, 'page': 1};
      if (search != null && search.isNotEmpty) {
        query['search'] = search;
      }
      final response = await _apiClient.get(endpoint: '/payment-list', query: query);
      List<PaymentModel> paymentsList = [];
      if (response is Map && response.containsKey('data')) {
        final rData = response['data'];
        if (rData is List) {
          paymentsList = rData.map((e) => PaymentModel.fromJson(e)).toList();
        } else if (rData is Map && rData.containsKey('data')) {
          paymentsList = (rData['data'] as List).map((e) => PaymentModel.fromJson(e)).toList();
        }
      } else if (response is List) {
        paymentsList = response.map((e) => PaymentModel.fromJson(e)).toList();
      }
      state = state.copyWith(isLoading: false, payments: paymentsList);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final paymentProvider = NotifierProvider<PaymentNotifier, PaymentState>(() => PaymentNotifier());
