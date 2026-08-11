import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/api/api_client.dart';
import '../model/promotional_banner_model.dart';

class PromotionalBannerState {
  final bool isFetching;
  final bool isSaving;
  final int? deletingBannerId;
  final String? error;
  final List<PromotionalBannerModel> banners;

  PromotionalBannerState({
    this.isFetching = false,
    this.isSaving = false,
    this.deletingBannerId,
    this.error,
    this.banners = const [],
  });

  PromotionalBannerState copyWith({
    bool? isFetching,
    bool? isSaving,
    int? deletingBannerId,
    bool clearDeletingId = false,
    String? error,
    List<PromotionalBannerModel>? banners,
  }) {
    return PromotionalBannerState(
      isFetching: isFetching ?? this.isFetching,
      isSaving: isSaving ?? this.isSaving,
      deletingBannerId: clearDeletingId ? null : (deletingBannerId ?? this.deletingBannerId),
      error: error, // Can be null
      banners: banners ?? this.banners,
    );
  }
}

class PromotionalBannerNotifier extends Notifier<PromotionalBannerState> {
  final ApiClient _api = ApiClient();

  @override
  PromotionalBannerState build() => PromotionalBannerState();

  Future<void> fetchAllBanners({String? search}) async {
    state = state.copyWith(isFetching: true, error: null);
    
    final query = <String, dynamic>{};
    if (search != null && search.isNotEmpty) {
      query['search'] = search;
    }
    
    final res = await _api.get(endpoint: '/promotional-banner-list', query: query);
    print('--- fetchAllBanners API RESPONSE ---');
    print(res);
    print('------------------------------------');
    
    if (res != null && res['status'] == 1 && res['data'] != null) {
      final dataObj = res['data'];
      List dataList = [];
      
      // If it's directly a list (old behavior)
      if (dataObj is List) {
        dataList = dataObj;
      } 
      // If it's wrapped in a data object (new API response format)
      else if (dataObj is Map && dataObj['data'] is List) {
        dataList = dataObj['data'];
      }
      
      state = state.copyWith(
        isFetching: false,
        banners: dataList.map((e) => PromotionalBannerModel.fromJson(e)).toList(),
      );
    } else {
      state = state.copyWith(isFetching: false, error: 'Failed to load banners');
    }
  }

  Future<void> createBanner(PromotionalBannerModel banner, PlatformFile? bannerAttachment) async {
    state = state.copyWith(isSaving: true, error: null);
    
    final Map<String, dynamic> files = {};
    if (bannerAttachment != null) {
      files['banner_attachment'] = bannerAttachment;
    }

    final res = await _api.requestWithFiles(
      endpoint: '/save-banner',
      fields: banner.toJson(),
      files: files.isNotEmpty ? files : null,
    );
    
    print('--- createBanner API RESPONSE ---');
    print(res);
    print('---------------------------------');
    
    if (res != null && res['status'] == 1) {
      state = state.copyWith(isSaving: false);
      await fetchAllBanners();
    } else {
      state = state.copyWith(isSaving: false, error: res?['message'] ?? 'Failed to create promotional banner');
    }
  }

  Future<void> deleteBanner(int id) async {
    state = state.copyWith(deletingBannerId: id, error: null);
    
    // First try the most common delete pattern
    try {
      final res = await _api.post(endpoint: '/delete-banner/$id');
      print('--- deleteBanner API RESPONSE ---');
      print(res);
      
      if (res != null && (res['status'] == 1 || res['message'] != null)) {
        state = state.copyWith(clearDeletingId: true);
        await fetchAllBanners();
        return;
      }
      
      // If that didn't work, try another pattern just in case
      final res2 = await _api.post(endpoint: '/delete-promotional-banner', body: {'id': id});
      if (res2 != null) {
         await fetchAllBanners();
      }
      state = state.copyWith(clearDeletingId: true);
    } catch (e) {
      print('Delete banner error: $e');
      state = state.copyWith(clearDeletingId: true, error: e.toString());
      // Refresh list anyway just in case it deleted but gave a weird response
      await fetchAllBanners();
    }
  }
}

final promotionalBannerProvider = NotifierProvider<PromotionalBannerNotifier, PromotionalBannerState>(() => PromotionalBannerNotifier());
