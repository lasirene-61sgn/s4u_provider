import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../../../core/api/api_client.dart';
import '../model/addon_model.dart';
import '../../profile/riverpod/profile_notifier.dart';
import '../../auth/riverpod/auth_notifier.dart';

class AddonState {
  final bool isLoading;
  final bool isFetchingMore;
  final bool isSaving;
  final List<AddonModel> addons;
  final String? error;
  final int page;
  final bool hasMore;
  final int? deletingAddonId;

  AddonState({
    this.isLoading = false,
    this.isFetchingMore = false,
    this.isSaving = false,
    this.addons = const [],
    this.error,
    this.page = 1,
    this.hasMore = true,
    this.deletingAddonId,
  });

  AddonState copyWith({
    bool? isLoading,
    bool? isFetchingMore,
    bool? isSaving,
    List<AddonModel>? addons,
    String? error,
    int? page,
    bool? hasMore,
    int? deletingAddonId,
    bool clearDeletingAddonId = false,
  }) {
    return AddonState(
      isLoading: isLoading ?? this.isLoading,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      isSaving: isSaving ?? this.isSaving,
      addons: addons ?? this.addons,
      error: error,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      deletingAddonId: clearDeletingAddonId ? null : (deletingAddonId ?? this.deletingAddonId),
    );
  }
}

class AddonNotifier extends Notifier<AddonState> {
  final ApiClient _api = ApiClient();

  @override
  AddonState build() => AddonState();

  Future<void> fetchAllAddons({bool loadMore = false, String? search}) async {
    if (loadMore) {
      if (!state.hasMore || state.isFetchingMore) return;
      state = state.copyWith(isFetchingMore: true, error: null);
    } else {
      state = state.copyWith(isLoading: true, error: null, page: 1, hasMore: true);
    }

    final page = loadMore ? state.page + 1 : 1;
    final query = <String, dynamic>{'page': page};
    if (search != null && search.isNotEmpty) {
      query['search'] = search;
    }
    final res = await _api.get(endpoint: '/service-addon-list', query: query);
    
    if (res != null && res['data'] != null) {
      final Map<String, dynamic> responseData = res['data'];
      final List data = responseData['data'] ?? [];
      final newAddons = data.map((e) => AddonModel.fromJson(e)).toList();

      final pagination = responseData['pagination'] as Map<String, dynamic>?;
      final totalPages = pagination != null ? (pagination['totalPages'] as int? ?? 1) : 1;
      final hasNextPage = page < totalPages;

      state = state.copyWith(
        isLoading: false,
        isFetchingMore: false,
        addons: loadMore ? [...state.addons, ...newAddons] : newAddons,
        page: page,
        hasMore: hasNextPage,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        isFetchingMore: false,
        error: res?['message'] ?? 'Failed to load addons',
      );
    }
  }

  Future<void> loadMore({String? search}) async {
    await fetchAllAddons(loadMore: true, search: search);
  }

  Future<void> fetchAddonsByService(int serviceId) async {
    // Currently relying on fetchAllAddons if backend doesn't support filtering by service directly on list view
    // A future implementation can append `?service_id=$serviceId` to `/service-addon-list` if backend supports it.
  }

  Future<void> createAddon({
    int? id,
    required String name,
    required double price,
    required String status,
    required int serviceId,
    String? imageUrl,
  }) async {
    state = state.copyWith(isSaving: true, error: null);
    final body = <String, dynamic>{
      'name': name,
      'price': price,
      'status': status == 'ACTIVE' ? 1 : 0,
      'service_id': serviceId,
      if (imageUrl != null) 'serviceaddon_image': imageUrl,
    };
    if (id != null && id != 0) {
      body['id'] = id;
    }
    final res = await _api.post(endpoint: '/service-addon-save', body: body);
    
    bool success = false;
    if (res != null) {
      if (res['status'] == 1) {
        success = true;
      } else if (res['message'] != null && res['message'].toString().toLowerCase().contains('success')) {
        success = true;
      }
    }

    if (success) {
      state = state.copyWith(isSaving: false);
      fetchAllAddons();
      
      Fluttertoast.showToast(
        msg: 'Addon created successfully!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      Get.back();
    } else {
      final errorMsg = res?['message'] ?? 'Failed to create addon';
      state = state.copyWith(isSaving: false, error: errorMsg);
      
      Fluttertoast.showToast(
        msg: errorMsg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<bool> deleteAddon(int id) async {
    state = state.copyWith(deletingAddonId: id);
    try {
      final res = await _api.post(endpoint: '/service-addon-delete/$id');
      if (res is Map && (res['status'] == 1 || res['status'] == true)) {
        Fluttertoast.showToast(msg: res['message']?.toString() ?? 'Addon deleted successfully', backgroundColor: Colors.green, textColor: Colors.white);
        state = state.copyWith(
          addons: state.addons.where((addon) => addon.id != id).toList(),
          clearDeletingAddonId: true,
        );
        return true;
      } else {
        Fluttertoast.showToast(msg: (res is Map ? res['message']?.toString() : null) ?? 'Failed to delete addon', backgroundColor: Colors.red, textColor: Colors.white);
        state = state.copyWith(clearDeletingAddonId: true);
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red, textColor: Colors.white);
      state = state.copyWith(clearDeletingAddonId: true);
      return false;
    }
  }
}

final addonProvider = NotifierProvider<AddonNotifier, AddonState>(() => AddonNotifier());
