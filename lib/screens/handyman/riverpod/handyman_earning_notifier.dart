import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../model/handyman_earning_model.dart';

class HandymanEarningState {
  final bool isLoading;
  final List<HandymanEarningModel> earnings;
  final String? error;

  HandymanEarningState({
    this.isLoading = false,
    this.earnings = const [],
    this.error,
  });

  HandymanEarningState copyWith({
    bool? isLoading,
    List<HandymanEarningModel>? earnings,
    String? error,
  }) {
    return HandymanEarningState(
      isLoading: isLoading ?? this.isLoading,
      earnings: earnings ?? this.earnings,
      error: error,
    );
  }
}

class HandymanEarningNotifier extends Notifier<HandymanEarningState> {
  @override
  HandymanEarningState build() {
    return HandymanEarningState();
  }

  Future<void> refresh({String? search}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final query = <String, dynamic>{};
      if (search != null && search.isNotEmpty) {
        query['search'] = search;
      }
      final res = await ApiClient().get(endpoint: '/handyman-earning-list', query: query);
      List<dynamic> listData = [];
      if (res != null) {
        if (res is List) {
          listData = res;
        } else if (res['data'] != null && res['data'] is List) {
          listData = res['data'];
        } else if (res['data'] != null && res['data'] is Map && res['data']['data'] is List) {
          listData = res['data']['data'];
        }
      }
      final earnings = listData.map((e) => HandymanEarningModel.fromJson(e as Map<String, dynamic>)).toList();
      state = state.copyWith(isLoading: false, earnings: earnings);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final handymanEarningListProvider = NotifierProvider<HandymanEarningNotifier, HandymanEarningState>(() {
  return HandymanEarningNotifier();
});
