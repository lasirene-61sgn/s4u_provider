import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';

class CommissionState {
  final bool isLoading;
  final List<dynamic> commissions;
  final String? error;

  CommissionState({this.isLoading = false, this.commissions = const [], this.error});

  CommissionState copyWith({bool? isLoading, List<dynamic>? commissions, String? error}) {
    return CommissionState(
      isLoading: isLoading ?? this.isLoading,
      commissions: commissions ?? this.commissions,
      error: error ?? this.error,
    );
  }
}

class CommissionNotifier extends Notifier<CommissionState> {
  final ApiClient _apiClient = ApiClient();

  @override
  CommissionState build() {
    Future.microtask(() => loadCommissions());
    return CommissionState();
  }

  Future<void> loadCommissions() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // API Call Removed as requested:
      // endpoint: '/api/provider/handyman-commission-types'
      List<dynamic> list = [];
      state = state.copyWith(isLoading: false, commissions: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addCommission(Map<String, dynamic> data) async {
    try {
      // API Call Removed as requested:
      // endpoint: '/api/provider/handyman-commission-types'
      await loadCommissions();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteCommission(int id) async {
    try {
      // API Call Removed as requested:
      // endpoint: '/api/provider/handyman-commission-types/$id'
      await loadCommissions();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final commissionProvider = NotifierProvider<CommissionNotifier, CommissionState>(() {
  return CommissionNotifier();
});
