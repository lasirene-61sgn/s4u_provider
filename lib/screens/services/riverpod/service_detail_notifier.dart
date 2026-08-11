import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../model/service_detail_model.dart';

final serviceIdProvider = Provider<int>((ref) => throw UnimplementedError());

class ServiceDetailState {
  final bool isLoading;
  final ServiceDetailModel? detail;
  final String? error;

  ServiceDetailState({
    this.isLoading = false,
    this.detail,
    this.error,
  });

  ServiceDetailState copyWith({
    bool? isLoading,
    ServiceDetailModel? detail,
    String? error,
  }) {
    return ServiceDetailState(
      isLoading: isLoading ?? this.isLoading,
      detail: detail ?? this.detail,
      error: error ?? this.error,
    );
  }
}

class ServiceDetailNotifier extends Notifier<ServiceDetailState> {
  final ApiClient _api = ApiClient();

  @override
  ServiceDetailState build() {
    final id = ref.watch(serviceIdProvider);
    _fetchDetail(id);
    return ServiceDetailState(isLoading: true);
  }

  Future<void> _fetchDetail(int id) async {
    try {
      final res = await _api.post(endpoint: '/service-detail', body: {'service_id': id});
      if (res != null && res['status'] == 1 && res['data'] != null) {
        state = state.copyWith(
          isLoading: false,
          detail: ServiceDetailModel.fromJson(res['data']),
          error: null,
        );
      } else if (res != null && res['data'] == null && res['service_detail'] != null) {
        state = state.copyWith(
          isLoading: false,
          detail: ServiceDetailModel.fromJson(res),
          error: null,
        );
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to load details.');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> retry() async {
    state = state.copyWith(isLoading: true, error: null);
    await _fetchDetail(ref.read(serviceIdProvider));
  }
}

final serviceDetailNotifierProvider = NotifierProvider<ServiceDetailNotifier, ServiceDetailState>(
  () => ServiceDetailNotifier(),
  dependencies: [serviceIdProvider],
);
