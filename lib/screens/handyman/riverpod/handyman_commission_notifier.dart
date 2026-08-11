import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../profile/riverpod/profile_notifier.dart';
import '../model/handyman_commission_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class HandymanCommissionState {
  final bool isLoading;
  final List<HandymanCommissionModel> items;
  final String? error;

  HandymanCommissionState({
    this.isLoading = false,
    this.items = const [],
    this.error,
  });

  HandymanCommissionState copyWith({
    bool? isLoading,
    List<HandymanCommissionModel>? items,
    String? error,
  }) {
    return HandymanCommissionState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      error: error,
    );
  }
}

class HandymanCommissionNotifier extends Notifier<HandymanCommissionState> {
  final ApiClient _api = ApiClient();

  @override
  HandymanCommissionState build() {
    return HandymanCommissionState(isLoading: false);
  }

  Future<void> _fetch({String? search}) async {
    state = state.copyWith(isLoading: true, error: null);
    final endpoint = '/handyman-commission-list';
    final query = <String, dynamic>{};
    if (search != null && search.isNotEmpty) {
      query['search'] = search;
    }
    final res = await _api.get(endpoint: endpoint, query: query);
    if (res != null) {
      dynamic responseData = res is List ? res : (res['data'] ?? res);
      if (responseData is Map && responseData.containsKey('data')) {
        responseData = responseData['data'];
      }
      final List data = responseData is List ? responseData : [];
      state = state.copyWith(
        isLoading: false,
        items: data.map((e) => HandymanCommissionModel.fromJson(e)).toList(),
      );
    } else {
      state = state.copyWith(isLoading: false, error: 'Failed to load');
    }
  }

  Future<void> refresh({String? search}) => _fetch(search: search);

  Future<void> fetchByProviderId(int providerId) async {
    state = state.copyWith(isLoading: true, error: null);
    final res = await _api.get(endpoint: '/handyman-commission-list?provider_id=$providerId');
    if (res != null) {
      dynamic responseData = res is List ? res : (res['data'] ?? res);
      if (responseData is Map && responseData.containsKey('data')) {
        responseData = responseData['data'];
      }
      final List data = responseData is List ? responseData : [];
      state = state.copyWith(
        isLoading: false,
        items: data.map((e) => HandymanCommissionModel.fromJson(e)).toList(),
      );
    } else {
      state = state.copyWith(isLoading: false, error: 'Failed to load');
    }
  }

  Future<void> add({
    required String name,
    required double commission,
    required String type,
    required String status,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final payload = {
      'name': name,
      'commission': commission,
      'type': type.toLowerCase(),
      'status': status.toUpperCase() == 'ACTIVE' ? 1 : 0,
    };
    
    try {
      final res = await _api.post(endpoint: '/save-handyman-commission', body: payload);
      if (res is Map && (res['status'] == true || res['status'] == 1)) {
        Fluttertoast.showToast(msg: res['message']?.toString() ?? 'Commission added successfully', backgroundColor: Colors.green, textColor: Colors.white);
        await _fetch(); // Refresh the list
      } else {
        Fluttertoast.showToast(msg: (res is Map ? res['message']?.toString() : null) ?? 'Failed to save commission', backgroundColor: Colors.red, textColor: Colors.white);
        state = state.copyWith(isLoading: false, error: (res is Map ? res['message']?.toString() : null) ?? 'Failed to save');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red, textColor: Colors.white);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> update(
    int id, {
    required String name,
    required double commission,
    required String type,
    required String status,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final payload = {
      'id': id,
      'name': name,
      'commission': commission,
      'type': type.toLowerCase(),
      'status': status.toUpperCase() == 'ACTIVE' ? 1 : 0,
    };
    
    try {
      final res = await _api.post(endpoint: '/save-handyman-commission', body: payload);
      if (res is Map && (res['status'] == true || res['status'] == 1)) {
        Fluttertoast.showToast(msg: res['message']?.toString() ?? 'Commission updated successfully', backgroundColor: Colors.green, textColor: Colors.white);
        await _fetch(); // Refresh the list
      } else {
        Fluttertoast.showToast(msg: (res is Map ? res['message']?.toString() : null) ?? 'Failed to update commission', backgroundColor: Colors.red, textColor: Colors.white);
        state = state.copyWith(isLoading: false, error: (res is Map ? res['message']?.toString() : null) ?? 'Failed to update');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red, textColor: Colors.white);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> delete(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _api.post(endpoint: '/delete-handyman-commission/$id');
      if (res is Map && (res['status'] == true || res['status'] == 1)) {
        Fluttertoast.showToast(msg: res['message']?.toString() ?? 'Commission deleted successfully', backgroundColor: Colors.green, textColor: Colors.white);
        await _fetch();
      } else {
        Fluttertoast.showToast(msg: (res is Map ? res['message']?.toString() : null) ?? 'Failed to delete commission', backgroundColor: Colors.red, textColor: Colors.white);
        state = state.copyWith(isLoading: false, error: (res is Map ? res['message']?.toString() : null) ?? 'Failed to delete');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red, textColor: Colors.white);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final handymanCommissionProvider =
    NotifierProvider<HandymanCommissionNotifier, HandymanCommissionState>(
        () => HandymanCommissionNotifier());
