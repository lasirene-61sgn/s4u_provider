import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../model/provider_commission_model.dart';

class ProviderCommissionState {
  final List<ProviderCommissionModel> commissions;
  final bool isLoading;
  final String? error;

  ProviderCommissionState({this.commissions = const [], this.isLoading = false, this.error});

  ProviderCommissionState copyWith({List<ProviderCommissionModel>? commissions, bool? isLoading, String? error}) {
    return ProviderCommissionState(
      commissions: commissions ?? this.commissions,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ProviderCommissionNotifier extends Notifier<ProviderCommissionState> {
  @override
  ProviderCommissionState build() {
    return ProviderCommissionState();
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await ApiClient().get(endpoint: '/provider-commission-list');
      if (res != null) {
        dynamic responseData = res is List ? res : res['data'];
        if (responseData is Map && responseData.containsKey('data')) {
          responseData = responseData['data'];
        }
        final rawList = responseData as List? ?? [];
        final list = rawList.map((x) => ProviderCommissionModel.fromJson(x)).toList();
        state = state.copyWith(commissions: list, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final providerCommissionProvider = NotifierProvider<ProviderCommissionNotifier, ProviderCommissionState>(() {
  return ProviderCommissionNotifier();
});
