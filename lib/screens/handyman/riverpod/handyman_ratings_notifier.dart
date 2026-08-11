import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../model/handyman_rating_model.dart';

class HandymanRatingsState {
  final bool isLoading;
  final List<HandymanRatingModel> ratings;
  final String? error;

  HandymanRatingsState({
    this.isLoading = false,
    this.ratings = const [],
    this.error,
  });

  HandymanRatingsState copyWith({
    bool? isLoading,
    List<HandymanRatingModel>? ratings,
    String? error,
  }) {
    return HandymanRatingsState(
      isLoading: isLoading ?? this.isLoading,
      ratings: ratings ?? this.ratings,
      error: error ?? this.error,
    );
  }
}

class HandymanRatingsNotifier extends Notifier<HandymanRatingsState> {
  final ApiClient _api = ApiClient();

  @override
  HandymanRatingsState build() {
    return HandymanRatingsState();
  }

  Future<void> loadRatings({String? search}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final query = <String, dynamic>{};
      if (search != null && search.isNotEmpty) {
        query['search'] = search;
      }
      final response = await _api.get(endpoint: '/get-handymanrating-list', query: query);
      print('handyman rating api response: $response');
      List<HandymanRatingModel> loadedRatings = [];
      if (response is Map) {
        dynamic data = response['data'] ?? response;
        if (data is Map && data.containsKey('data')) {
          data = data['data'];
        }
        if (data is List) {
          loadedRatings = data.map((e) => HandymanRatingModel.fromJson(e as Map<String, dynamic>)).toList();
        }
      } else if (response is List) {
        loadedRatings = response.map((e) => HandymanRatingModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      state = state.copyWith(isLoading: false, ratings: loadedRatings);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final handymanRatingsProvider = NotifierProvider<HandymanRatingsNotifier, HandymanRatingsState>(() {
  return HandymanRatingsNotifier();
});
