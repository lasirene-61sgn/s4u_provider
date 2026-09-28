import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../model/handyman_model.dart';
import '../model/handyman_detail_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class HandymanState {
  final bool isLoading;
  final bool isFetchingMore;
  final bool isLoadingPending;
  final bool isFetchingMorePending;
  final bool isLoadingUnassigned;
  final bool isFetchingMoreUnassigned;
  final List<Handyman> handymen;
  final List<Handyman> pendingHandymen;
  final List<Handyman> unassignedHandymen;
  final String? error;
  final int currentPage;
  final int totalPages;
  final int currentPendingPage;
  final int totalPendingPages;
  final int currentUnassignedPage;
  final int totalUnassignedPages;
  final int approvingId;
  final int deletingId;
  final int editingId;
  final HandymanDetail? selectedDetail;
  final bool isLoadingDetail;
  final bool isSaving;
  final String? savingError;

  HandymanState({
    this.isLoading = false,
    this.isFetchingMore = false,
    this.isLoadingPending = false,
    this.isFetchingMorePending = false,
    this.isLoadingUnassigned = false,
    this.isFetchingMoreUnassigned = false,
    this.handymen = const [],
    this.pendingHandymen = const [],
    this.unassignedHandymen = const [],
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.currentPendingPage = 1,
    this.totalPendingPages = 1,
    this.currentUnassignedPage = 1,
    this.totalUnassignedPages = 1,
    this.approvingId = -1,
    this.deletingId = -1,
    this.editingId = -1,
    this.selectedDetail,
    this.isLoadingDetail = false,
    this.isSaving = false,
    this.savingError,
  });

  HandymanState copyWith({
    bool? isLoading,
    bool? isFetchingMore,
    bool? isLoadingPending,
    bool? isFetchingMorePending,
    bool? isLoadingUnassigned,
    bool? isFetchingMoreUnassigned,
    List<Handyman>? handymen,
    List<Handyman>? pendingHandymen,
    List<Handyman>? unassignedHandymen,
    String? error,
    int? currentPage,
    int? totalPages,
    int? currentPendingPage,
    int? totalPendingPages,
    int? currentUnassignedPage,
    int? totalUnassignedPages,
    int? approvingId,
    int? deletingId,
    int? editingId,
    HandymanDetail? selectedDetail,
    bool? isLoadingDetail,
    bool? isSaving,
    String? savingError,
  }) {
    return HandymanState(
      isLoading: isLoading ?? this.isLoading,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      isLoadingPending: isLoadingPending ?? this.isLoadingPending,
      isFetchingMorePending: isFetchingMorePending ?? this.isFetchingMorePending,
      isLoadingUnassigned: isLoadingUnassigned ?? this.isLoadingUnassigned,
      isFetchingMoreUnassigned: isFetchingMoreUnassigned ?? this.isFetchingMoreUnassigned,
      handymen: handymen ?? this.handymen,
      pendingHandymen: pendingHandymen ?? this.pendingHandymen,
      unassignedHandymen: unassignedHandymen ?? this.unassignedHandymen,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      currentPendingPage: currentPendingPage ?? this.currentPendingPage,
      totalPendingPages: totalPendingPages ?? this.totalPendingPages,
      currentUnassignedPage: currentUnassignedPage ?? this.currentUnassignedPage,
      totalUnassignedPages: totalUnassignedPages ?? this.totalUnassignedPages,
      approvingId: approvingId ?? this.approvingId,
      deletingId: deletingId ?? this.deletingId,
      editingId: editingId ?? this.editingId,
      selectedDetail: selectedDetail ?? this.selectedDetail,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      isSaving: isSaving ?? this.isSaving,
      savingError: savingError ?? this.savingError,
    );
  }
}

class HandymanNotifier extends Notifier<HandymanState> {
  final ApiClient _api = ApiClient();

  @override
  HandymanState build() {

    return HandymanState(isLoading: true);
  }

  Future<void> _fetchHandymen({int page = 1, String? search}) async {
    if (page == 1) {
      state = state.copyWith(isLoading: true, error: null);
    } else {
      state = state.copyWith(isFetchingMore: true, error: null);
    }
    
    try {
      final query = <String, dynamic>{'status': 1, 'per_page': 10, 'page': page};
      if (search != null && search.isNotEmpty) {
        query['search'] = search;
      }
      final res = await _api.get(endpoint: '/new-register-handyman-list', query: query);
      if (res != null && res['data'] != null) {
        final rawData = res['data'];
        final List data = rawData is List ? rawData : (rawData['data'] as List? ?? []);
        
        int totalPages = 1;
        if (rawData is Map && rawData['pagination'] != null) {
          totalPages = rawData['pagination']['totalPages'] ?? 1;
        }

        final newHandymen = data.map((e) => Handyman.fromJson(e)).toList();
        state = state.copyWith(
          isLoading: false,
          isFetchingMore: false,
          handymen: page == 1 ? newHandymen : [...state.handymen, ...newHandymen],
          currentPage: page,
          totalPages: totalPages,
        );
      } else {
        state = state.copyWith(isLoading: false, isFetchingMore: false, error: 'Failed to fetch handymen');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, isFetchingMore: false, error: e.toString());
    }
  }

  Future<void> _fetchPendingHandymen({int page = 1, String? search}) async {
    if (page == 1) {
      state = state.copyWith(isLoadingPending: true, error: null);
    } else {
      state = state.copyWith(isFetchingMorePending: true, error: null);
    }
    
    try {
      final query = <String, dynamic>{'status': 0, 'per_page': 10, 'page': page};
      if (search != null && search.isNotEmpty) {
        query['search'] = search;
      }
      final res = await _api.get(endpoint: '/new-register-handyman-list', query: query);
      if (res != null && res['data'] != null) {
        final rawData = res['data'];
        final List data = rawData is List ? rawData : (rawData['data'] as List? ?? []);
        
        int totalPages = 1;
        if (rawData is Map && rawData['pagination'] != null) {
          totalPages = rawData['pagination']['totalPages'] ?? 1;
        }

        final newHandymen = data.map((e) => Handyman.fromJson(e)).toList();
        state = state.copyWith(
          isLoadingPending: false,
          isFetchingMorePending: false,
          pendingHandymen: page == 1 ? newHandymen : [...state.pendingHandymen, ...newHandymen],
          currentPendingPage: page,
          totalPendingPages: totalPages,
        );
      } else {
        state = state.copyWith(isLoadingPending: false, isFetchingMorePending: false, error: 'Failed to fetch pending handymen');
      }
    } catch (e) {
      state = state.copyWith(isLoadingPending: false, isFetchingMorePending: false, error: e.toString());
    }
  }

  Future<void> _fetchUnassignedHandymen({int page = 1, String? search}) async {
    if (page == 1) {
      state = state.copyWith(isLoadingUnassigned: true, error: null);
    } else {
      state = state.copyWith(isFetchingMoreUnassigned: true, error: null);
    }
    
    try {
      final query = <String, dynamic>{'user_type': 'handyman', 'type': 'unassigned', 'per_page': 10, 'page': page};
      if (search != null && search.isNotEmpty) {
        query['search'] = search;
      }
      final res = await _api.get(endpoint: '/user-list', query: query);
      if (res != null && res['data'] != null) {
        final rawData = res['data'];
        final List data = rawData is List ? rawData : (rawData['data'] as List? ?? []);
        
        int totalPages = 1;
        if (rawData is Map && rawData['pagination'] != null) {
          totalPages = rawData['pagination']['totalPages'] ?? 1;
        }

        final newHandymen = data.map((e) => Handyman.fromJson(e)).toList();
        state = state.copyWith(
          isLoadingUnassigned: false,
          isFetchingMoreUnassigned: false,
          unassignedHandymen: page == 1 ? newHandymen : [...state.unassignedHandymen, ...newHandymen],
          currentUnassignedPage: page,
          totalUnassignedPages: totalPages,
        );
      } else {
        state = state.copyWith(isLoadingUnassigned: false, isFetchingMoreUnassigned: false, error: 'Failed to fetch unassigned handymen');
      }
    } catch (e) {
      state = state.copyWith(isLoadingUnassigned: false, isFetchingMoreUnassigned: false, error: e.toString());
    }
  }

  Future<void> loadMore({String? search}) async {
    if (state.isLoading || state.isFetchingMore) return;
    if (state.currentPage >= state.totalPages) return;
    await _fetchHandymen(page: state.currentPage + 1, search: search);
  }

  Future<void> refresh({String? search}) async {
    await _fetchHandymen(page: 1, search: search);
    await _fetchPendingHandymen(page: 1, search: search);
    await _fetchUnassignedHandymen(page: 1, search: search);
  }

  Future<void> loadMorePending({String? search}) async {
    if (state.isLoadingPending || state.isFetchingMorePending) return;
    if (state.currentPendingPage >= state.totalPendingPages) return;
    await _fetchPendingHandymen(page: state.currentPendingPage + 1, search: search);
  }

  Future<bool> fetchHandymanDetail(int id) async {
    state = state.copyWith(isLoadingDetail: true, error: null, selectedDetail: null, editingId: id);
    try {
      final res = await _api.get(endpoint: '/user-detail?id=$id');
      print("resdetail$res");
      if (res is Map && (res['status'] == true || res['status'] == 1)) {
        if (res['data'] != null) {
          final detailResponse = HandymanDetailResponse.fromJson(res as Map<String, dynamic>);
          state = state.copyWith(selectedDetail: detailResponse.data);
          return true;
        }
        return false;
      } else {
        final msg = (res is Map ? res['message']?.toString() : null) ?? 'Failed to load details';
        state = state.copyWith(error: msg);
        Fluttertoast.showToast(msg: msg, backgroundColor: Colors.red, textColor: Colors.white);
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red, textColor: Colors.white);
      return false;
    } finally {
      state = state.copyWith(isLoadingDetail: false, editingId: -1);
    }
  }

  void clearSelectedDetail() {
    state = state.copyWith(selectedDetail: null, editingId: -1);
  }

  Future<void> loadMoreUnassigned() async {
    if (state.isLoadingUnassigned || state.isFetchingMoreUnassigned) return;
    if (state.currentUnassignedPage >= state.totalUnassignedPages) return;
    await _fetchUnassignedHandymen(page: state.currentUnassignedPage + 1);
  }

  Future<void> approveHandyman(int id) async {
    state = state.copyWith(approvingId: id);
    try {
      final res = await _api.post(endpoint: '/approve-handyman', body: {'handyman_id': id, 'status': 1});
      if (res is Map && (res['status'] == true || res['status'] == 1)) {
        Fluttertoast.showToast(msg: res['message']?.toString() ?? 'Handyman approved', backgroundColor: Colors.green, textColor: Colors.white);
        await refresh();
      } else {
        Fluttertoast.showToast(msg: (res is Map ? res['message']?.toString() : null) ?? 'Failed to approve', backgroundColor: Colors.red, textColor: Colors.white);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red, textColor: Colors.white);
    } finally {
      state = state.copyWith(approvingId: -1);
    }
  }

  Future<void> addHandyman(BuildContext context, String firstName, String lastName, String username, String email, String mobile, String password, int? countryId, int? stateId, int? cityId, String address, int? serviceAddressId, String handymanCommission, {String? imageUrl}) async {
    state = state.copyWith(isSaving: true, savingError: null);
    try {
      final parsedInt = int.tryParse(handymanCommission);
      final valueToSend = parsedInt ?? handymanCommission;
      
      final res = await _api.post(
        endpoint: '/handyman-save',
        body: {
          'first_name': firstName, 
          'last_name': lastName, 
          'username': username, 
          'email': email,
          'contact_number': mobile,
          'password': password,
          'user_type': 'handyman',
          if (countryId != null) 'country_id': countryId,
          if (stateId != null) 'state_id': stateId,
          if (cityId != null) 'city_id': cityId,
          'address': address,
          if (serviceAddressId != null) 'service_address_id': serviceAddressId,
          'handyman_commission': valueToSend,
          'handymantype_id': valueToSend,
          'handymanCommission': valueToSend,
          if (imageUrl != null) 'profile_image': imageUrl,
        },
      );
      print("response: $res");
      if (res is Map && (res['status'] == true || res['status'] == 1)) {
        Fluttertoast.showToast(msg: res['message']?.toString() ?? 'Handyman added successfully', backgroundColor: Colors.green, textColor: Colors.white);
        final data = res['data'];
        if (data != null && data is Map && data.containsKey('id')) {
          final newHandyman = Handyman.fromJson(data as Map<String, dynamic>);
          state = state.copyWith(
            handymen: [...state.handymen, newHandyman],
            isSaving: false,
          );
        } else {
          state = state.copyWith(isSaving: false);
          await _fetchHandymen();
        }
        if (context.mounted) Navigator.pop(context);
      } else {
        final msg = (res is Map ? res['message']?.toString() : null) ?? 'Failed to add handyman';
        state = state.copyWith(isSaving: false, savingError: msg);
        Fluttertoast.showToast(msg: msg, backgroundColor: Colors.red, textColor: Colors.white);
      }
    } catch (e) {
      state = state.copyWith(isSaving: false, savingError: e.toString());
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red, textColor: Colors.white);
    }
  }

  Future<void> updateHandyman(BuildContext context, int id, String firstName, String lastName, String username, String email, String mobile, int? countryId, int? stateId, int? cityId, String address, int? serviceAddressId, String handymanCommission, {String? imageUrl}) async {
    state = state.copyWith(isSaving: true, savingError: null);
    try {
      final parsedInt = int.tryParse(handymanCommission);
      final valueToSend = parsedInt ?? handymanCommission;

      final res = await _api.post(
        endpoint: '/handyman-save',
        body: {
          'id': id,
          'first_name': firstName, 
          'last_name': lastName, 
          'username': username, 
          'email': email,
          'contact_number': mobile,
          'user_type': 'handyman',
          if (countryId != null) 'country_id': countryId,
          if (stateId != null) 'state_id': stateId,
          if (cityId != null) 'city_id': cityId,
          'address': address,
          if (serviceAddressId != null) 'service_address_id': serviceAddressId,
          'handyman_commission': valueToSend,
          'handymantype_id': valueToSend,
          'handymanCommission': valueToSend,
          if (imageUrl != null) 'profile_image': imageUrl,
        },
      );
      print("edit:$res");
      if (res is Map && (res['status'] == true || res['status'] == 1)) {
        Fluttertoast.showToast(msg: res['message']?.toString() ?? 'Handyman updated successfully', backgroundColor: Colors.green, textColor: Colors.white);
        final data = res['data'];
        if (data != null && data is Map && data.containsKey('id')) {
          final updatedHandyman = Handyman.fromJson(data as Map<String, dynamic>);
          state = state.copyWith(
            handymen: state.handymen.map((h) => h.id == id ? updatedHandyman : h).toList(),
            pendingHandymen: state.pendingHandymen.map((h) => h.id == id ? updatedHandyman : h).toList(),
            isSaving: false,
          );
        } else {
          state = state.copyWith(isSaving: false);
          await _fetchHandymen();
        }
        if (context.mounted) Navigator.pop(context);
      } else {
        final msg = (res is Map ? res['message']?.toString() : null) ?? 'Failed to update handyman';
        state = state.copyWith(isSaving: false, savingError: msg);
        Fluttertoast.showToast(msg: msg, backgroundColor: Colors.red, textColor: Colors.white);
      }
    } catch (e) {
      state = state.copyWith(isSaving: false, savingError: e.toString());
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red, textColor: Colors.white);
    }
  }

  Future<void> deleteHandyman(int id) async {
    state = state.copyWith(deletingId: id);
    try {
      final res = await _api.post(endpoint: '/handyman-delete/$id');
      print("delete:$res");
      if (res is Map && (res['status'] == true || res['status'] == 1)) {
        Fluttertoast.showToast(msg: res['message']?.toString() ?? 'Handyman deleted successfully', backgroundColor: Colors.green, textColor: Colors.white);
        await refresh();
      } else {
        final msg = (res is Map ? res['message']?.toString() : null) ?? 'Failed to delete handyman';
        Fluttertoast.showToast(msg: msg, backgroundColor: Colors.red, textColor: Colors.white);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red, textColor: Colors.white);
    } finally {
      state = state.copyWith(deletingId: -1);
    }
  }

  Future<void> restoreHandyman(int id) async {
    try {
      final res = await _api.post(endpoint: '/handyman-action', body: {'id': id, 'type': 'restore'});
      if (res is Map && (res['status'] == true || res['status'] == 1)) {
        Fluttertoast.showToast(msg: res['message']?.toString() ?? 'Handyman restored', backgroundColor: Colors.green, textColor: Colors.white);
        await refresh();
      } else {
        Fluttertoast.showToast(msg: (res is Map ? res['message']?.toString() : null) ?? 'Failed to restore', backgroundColor: Colors.red, textColor: Colors.white);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red, textColor: Colors.white);
    }
  }

  Future<void> forceDeleteHandyman(int id) async {
    try {
      final res = await _api.post(endpoint: '/handyman-action', body: {'id': id, 'type': 'forcedelete'});
      if (res is Map && (res['status'] == true || res['status'] == 1)) {
        Fluttertoast.showToast(msg: res['message']?.toString() ?? 'Handyman permanently deleted', backgroundColor: Colors.green, textColor: Colors.white);
        await refresh();
      } else {
        Fluttertoast.showToast(msg: (res is Map ? res['message']?.toString() : null) ?? 'Failed to delete', backgroundColor: Colors.red, textColor: Colors.white);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red, textColor: Colors.white);
    }
  }

  Future<void> updateAvailableStatus(int id, int status) async {
    state = state.copyWith(approvingId: id);
    try {
      final res = await _api.post(
        endpoint: '/handyman-update-available-status',
        body: {
          'id': id,
          'status': status,
        },
      );
      print("status:$res");
      if (res is Map && (res['status'] == true || res['status'] == 1 || res.containsKey('data') || (res.containsKey('message') && res['message'].toString().toLowerCase().contains('successfully')))) {
        Fluttertoast.showToast(msg: res['message']?.toString() ?? 'Status updated successfully', backgroundColor: Colors.green, textColor: Colors.white);
        
        if (status == 1) {
          // If approved, remove from pending list locally since the backend filter might be delayed/broken
          state = state.copyWith(
            pendingHandymen: state.pendingHandymen.where((h) => h.id != id).toList(),
            unassignedHandymen: state.unassignedHandymen.where((h) => h.id != id).toList(),
          );
        }
        await refresh();
      } else {
        final msg = res is Map ? res['message']?.toString() : 'Failed to update status';
        Fluttertoast.showToast(msg: msg ?? 'Failed to update status', backgroundColor: Colors.red, textColor: Colors.white);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red, textColor: Colors.white);
    } finally {
      state = state.copyWith(approvingId: -1);
    }
  }

  Future<void> changeHandymanStatus(int id, int status) async {
    try {
      final res = await _api.requestWithFiles(
        endpoint: '/user-update-status',
        fields: {
          'id': id.toString(),
          'status': status.toString(),
        },
      );
      if (res is Map && (res['status'] == true || res['status'] == 1)) {
        Fluttertoast.showToast(msg: res['message']?.toString() ?? 'Handyman status updated', backgroundColor: Colors.green, textColor: Colors.white);
        refresh(); // Refresh list to reflect changes
      } else {
        Fluttertoast.showToast(msg: (res is Map ? res['message']?.toString() : null) ?? 'Failed to update handyman status', backgroundColor: Colors.red, textColor: Colors.white);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red, textColor: Colors.white);
    }
  }


}

final handymenProvider = NotifierProvider<HandymanNotifier, HandymanState>(() => HandymanNotifier());
