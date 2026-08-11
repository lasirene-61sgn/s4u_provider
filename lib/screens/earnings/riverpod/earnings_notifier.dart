import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../model/earnings_model.dart';

class EarningsState {
  final Earnings? earnings;
  final bool isLoading;
  final String? error;

  EarningsState({this.earnings, this.isLoading = false, this.error});

  EarningsState copyWith({Earnings? earnings, bool? isLoading, String? error}) {
    return EarningsState(
      earnings: earnings ?? this.earnings,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class EarningsNotifier extends Notifier<EarningsState> {
  @override
  EarningsState build() => EarningsState();

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final resStats = await ApiClient().get(endpoint: '/provider/earnings');
      
      Earnings earnings = Earnings();
      if (resStats != null && resStats['data'] != null) {
        earnings = Earnings.fromJson(resStats['data']);
      }
      
      // Removed the invalid /earnings/my API call
      
      final fullEarnings = Earnings(
        today: earnings.today,
        thisMonth: earnings.thisMonth,
        total: earnings.total,
        transactions: [], // Temporarily empty since the old endpoint was invalid
      );

      state = state.copyWith(earnings: fullEarnings, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final earningsProvider = NotifierProvider<EarningsNotifier, EarningsState>(() {
  return EarningsNotifier();
});
