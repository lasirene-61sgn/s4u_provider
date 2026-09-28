import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../model/handyman_detail_model.dart';

class HandymanDetailState {
  final bool isLoading;
  final String? error;
  final HandymanDetail? detail;

  HandymanDetailState({
    this.isLoading = false,
    this.error,
    this.detail,
  });

  HandymanDetailState copyWith({
    bool? isLoading,
    String? error,
    HandymanDetail? detail,
  }) {
    return HandymanDetailState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      detail: detail ?? this.detail,
    );
  }
}

class HandymanDetailNotifier extends Notifier<HandymanDetailState> {
  final ApiClient _apiClient = ApiClient();

  @override
  HandymanDetailState build() {
    return HandymanDetailState();
  }

  Future<void> fetchHandymanDetail(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.get(endpoint: '/user-detail?id=$id');
      if (response != null) {
        final parsed = HandymanDetailResponse.fromJson(response as Map<String, dynamic>);
        state = state.copyWith(isLoading: false, detail: parsed.data);
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to load details');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final handymanDetailProvider = NotifierProvider<HandymanDetailNotifier, HandymanDetailState>(() {
  return HandymanDetailNotifier();
});
