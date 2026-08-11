import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../model/payout_model.dart';

class PayoutState {
  final bool isLoading;
  final bool isSubmitting;
  final List<PayoutModel> payouts;
  final String? error;

  PayoutState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.payouts = const [],
    this.error,
  });

  PayoutState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    List<PayoutModel>? payouts,
    String? error,
  }) {
    return PayoutState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      payouts: payouts ?? this.payouts,
      error: error ?? this.error,
    );
  }
}

class PayoutNotifier extends Notifier<PayoutState> {
  final ApiClient _apiClient = ApiClient();

  @override
  PayoutState build() {
    return PayoutState();
  }

  Future<void> fetchPayouts({String? search}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final query = <String, dynamic>{'per_page': 100, 'page': 1};
      if (search != null && search.isNotEmpty) {
        query['search'] = search;
      }
      final response = await _apiClient.get(endpoint: '/provider-payout-list', query: query);
      List<PayoutModel> payoutList = [];
      if (response is Map && response.containsKey('data')) {
        final rData = response['data'];
        if (rData is List) {
          payoutList = rData.map((e) => PayoutModel.fromJson(e)).toList();
        } else if (rData is Map && rData.containsKey('data')) {
          payoutList = (rData['data'] as List).map((e) => PayoutModel.fromJson(e)).toList();
        }
      } else if (response is List) {
        payoutList = response.map((e) => PayoutModel.fromJson(e)).toList();
      }
      state = state.copyWith(isLoading: false, payouts: payoutList);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> requestPayout(double amount, String paymentMethod, int bankId, String description) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      await _apiClient.post(
        endpoint: '/provider-payout',
        body: {
          'amount': amount,
          'payment_method': paymentMethod,
          'bank_id': bankId,
          'description': description,
        },
      );
      state = state.copyWith(isSubmitting: false);
      await fetchPayouts();
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      rethrow;
    }
  }
}

final payoutProvider = NotifierProvider<PayoutNotifier, PayoutState>(() => PayoutNotifier());
