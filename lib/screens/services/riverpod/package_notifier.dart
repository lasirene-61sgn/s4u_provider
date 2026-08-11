import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import '../../../core/api/api_client.dart';
import '../model/package_model.dart';

class PackageState {
  final bool isLoading;
  final bool isSaving;
  final bool isFetchingMore;
  final String? error;
  final List<PackageModel> packages;
  final int page;
  final bool hasMore;
  final int? deletingPackageId;

  PackageState({
    this.isLoading = false,
    this.isSaving = false,
    this.isFetchingMore = false,
    this.error,
    this.packages = const [],
    this.page = 1,
    this.hasMore = true,
    this.deletingPackageId,
  });

  PackageState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isFetchingMore,
    String? error,
    List<PackageModel>? packages,
    int? page,
    bool? hasMore,
    int? deletingPackageId,
    bool clearDeletingPackageId = false,
  }) {
    return PackageState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      error: error, // Can be null
      packages: packages ?? this.packages,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      deletingPackageId: clearDeletingPackageId ? null : (deletingPackageId ?? this.deletingPackageId),
    );
  }
}

class PackageNotifier extends Notifier<PackageState> {
  final ApiClient _api = ApiClient();

  @override
  PackageState build() => PackageState();

  Future<void> fetchAllPackages({bool loadMore = false, String? search}) async {
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
    final res = await _api.get(endpoint: '/package-list', query: query);
    
    if (res != null && res['data'] != null) {
      final Map<String, dynamic> responseData = res['data'];
      final List data = responseData['data'] ?? [];
      final newPackages = data.map((e) => PackageModel.fromJson(e)).toList();

      final pagination = responseData['pagination'] as Map<String, dynamic>?;
      final totalPages = pagination != null ? (pagination['totalPages'] as int? ?? 1) : 1;
      final hasNextPage = page < totalPages;

      state = state.copyWith(
        isLoading: false,
        isFetchingMore: false,
        packages: loadMore ? [...state.packages, ...newPackages] : newPackages,
        page: page,
        hasMore: hasNextPage,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        isFetchingMore: false,
        error: res?['message'] ?? 'Failed to load packages',
      );
    }
  }

  Future<void> loadMore({String? search}) async {
    await fetchAllPackages(loadMore: true, search: search);
  }

  Future<void> createPackage(PackageModel package, PlatformFile? packageAttachment) async {
    state = state.copyWith(isSaving: true, error: null);
    
    final Map<String, dynamic> files = {};
    final Map<String, dynamic> body = package.toJson();
    if (packageAttachment != null) {
      files['package_attachment_0'] = packageAttachment;
      body['attachment_count'] = '1';
    }

    final res = await _api.requestWithFiles(
      endpoint: '/package-save',
      fields: body,
      files: files.isNotEmpty ? files : null,
    );
    
    bool isSuccess = false;
    if (res != null) {
      if (res['status'] == 1) {
        isSuccess = true;
      } else if (res['message'] != null && res['message'].toString().toLowerCase().contains('success')) {
        isSuccess = true;
      }
    }
    
    if (isSuccess) {
      // Refresh the list after a successful creation
      fetchAllPackages();
      state = state.copyWith(isSaving: false);
      
      Fluttertoast.showToast(
        msg: 'Package created successfully!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      Get.back();
    } else {
      final errorMsg = res?['message'] ?? 'Failed to create package';
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

  Future<bool> deletePackage(int id) async {
    state = state.copyWith(deletingPackageId: id);
    try {
      final res = await _api.post(endpoint: '/package-delete/$id');
      if (res is Map && (res['status'] == 1 || res['status'] == true)) {
        Fluttertoast.showToast(msg: res['message']?.toString() ?? 'Package deleted successfully', backgroundColor: Colors.green, textColor: Colors.white);
        state = state.copyWith(
          packages: state.packages.where((pkg) => pkg.id != id).toList(),
          clearDeletingPackageId: true,
        );
        return true;
      } else {
        Fluttertoast.showToast(msg: (res is Map ? res['message']?.toString() : null) ?? 'Failed to delete package', backgroundColor: Colors.red, textColor: Colors.white);
        state = state.copyWith(clearDeletingPackageId: true);
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red, textColor: Colors.white);
      state = state.copyWith(clearDeletingPackageId: true);
      return false;
    }
  }
}

final packageProvider = NotifierProvider<PackageNotifier, PackageState>(() => PackageNotifier());
