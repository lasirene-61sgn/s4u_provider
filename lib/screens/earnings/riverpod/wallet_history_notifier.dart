import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../model/wallet_history_model.dart';

class WalletHistoryState {
  final WalletHistoryResponse? data;
  final bool isLoading;
  final String? error;

  WalletHistoryState({this.data, this.isLoading = false, this.error});

  WalletHistoryState copyWith({WalletHistoryResponse? data, bool? isLoading, String? error}) {
    return WalletHistoryState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class WalletHistoryNotifier extends Notifier<WalletHistoryState> {
  @override
  WalletHistoryState build() => WalletHistoryState();

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await ApiClient().get(endpoint: '/wallet-history');
      
      if (res != null && res['data'] != null) {
        state = state.copyWith(
          data: WalletHistoryResponse.fromJson(res['data']),
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to load wallet history');
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final walletHistoryProvider = NotifierProvider<WalletHistoryNotifier, WalletHistoryState>(() {
  return WalletHistoryNotifier();
});
