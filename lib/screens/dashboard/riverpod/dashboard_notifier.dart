import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/storage/shared_preference_helper.dart';
import '../model/dashboard_model.dart';

class DashboardState {
  final bool isLoading;
  final DashboardStats? stats;
  final String? error;

  DashboardState({this.isLoading = false, this.stats, this.error});

  DashboardState copyWith({bool? isLoading, DashboardStats? stats, String? error}) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      stats: stats ?? this.stats,
      error: error ?? this.error,
    );
  }
}

class DashboardNotifier extends Notifier<DashboardState> {
  final ApiClient _api = ApiClient();

  @override
  DashboardState build() {
    return DashboardState(isLoading: true);
  }

  Future<void> _fetchStats() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final role = SharedPreferenceHelper.getString('role') ?? 'PROVIDER';

      final endpoint = role == 'HANDYMAN' ? ApiConstants.handymanDashboard : ApiConstants.providerDashboard;
      final res = await _api.get(endpoint: endpoint);
      
      DashboardStats? stats;

      if (res['status'] == 1) {
        stats = DashboardStats.fromJson(res['data']);
      } else {
        state = state.copyWith(isLoading: false, error: res['message']);
        return;
      }

      state = state.copyWith(isLoading: false, stats: stats);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    await _fetchStats();
  }
}

final dashboardProvider = NotifierProvider<DashboardNotifier, DashboardState>(() => DashboardNotifier());
