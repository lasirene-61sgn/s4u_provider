import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';

class ReviewState {
  final bool isLoading;
  final List<dynamic> reviews;
  final String? error;

  ReviewState({this.isLoading = false, this.reviews = const [], this.error});

  ReviewState copyWith({bool? isLoading, List<dynamic>? reviews, String? error}) {
    return ReviewState(
      isLoading: isLoading ?? this.isLoading,
      reviews: reviews ?? this.reviews,
      error: error ?? this.error,
    );
  }
}

class ReviewNotifier extends Notifier<ReviewState> {
  final ApiClient _apiClient = ApiClient();

  @override
  ReviewState build() {
    return ReviewState();
  }

  Future<void> fetchReviews() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // API call removed because route does not exist.
      state = state.copyWith(isLoading: false, reviews: []);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final reviewProvider = NotifierProvider<ReviewNotifier, ReviewState>(() {
  return ReviewNotifier();
});
