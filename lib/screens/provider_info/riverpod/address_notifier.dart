import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/api/api_client.dart';
import '../model/address_model.dart';

class AddressState {
  final bool isLoading;
  final List<AddressModel> addresses;
  final String? error;

  AddressState({this.isLoading = false, this.addresses = const [], this.error});

  AddressState copyWith({bool? isLoading, List<AddressModel>? addresses, String? error}) {
    return AddressState(
      isLoading: isLoading ?? this.isLoading,
      addresses: addresses ?? this.addresses,
      error: error ?? this.error,
    );
  }
}

class AddressNotifier extends Notifier<AddressState> {
  final ApiClient _apiClient = ApiClient();

  @override
  AddressState build() {
    Future.microtask(() => fetchAddresses());
    return AddressState();
  }

  Future<void> fetchAddresses() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.get(endpoint: '/provideraddress-list');
      print("address:${response}");
      List<AddressModel> addrList = [];
      if (response is Map && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          addrList = data.map((e) => AddressModel.fromJson(e)).toList();
        } else if (data is Map && data.containsKey('data') && data['data'] is List) {
          addrList = (data['data'] as List).map((e) => AddressModel.fromJson(e)).toList();
        }
      } else if (response is List) {
        addrList = response.map((e) => AddressModel.fromJson(e)).toList();
      }
      state = state.copyWith(isLoading: false, addresses: addrList);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addAddress(Map<String, dynamic> req) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.post(endpoint: '/save-provideraddress', body: req);
      
      if (response != null && response is Map) {
        if (response['status'] == 1 || response['status'] == true) {
          Fluttertoast.showToast(msg: response['message']?.toString() ?? 'Address saved successfully', backgroundColor: Colors.green, textColor: Colors.white);
          await fetchAddresses();
        } else {
          Fluttertoast.showToast(msg: response['message']?.toString() ?? 'Failed to save address', backgroundColor: Colors.red, textColor: Colors.white);
          state = state.copyWith(isLoading: false, error: response['message']?.toString());
        }
      } else {
        Fluttertoast.showToast(msg: 'Invalid response from server', backgroundColor: Colors.red, textColor: Colors.white);
        state = state.copyWith(isLoading: false, error: 'Invalid response');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red, textColor: Colors.white);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteAddress(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.post(endpoint: '/provideraddress-delete/$id');
      
      if (response != null && response is Map) {
        if (response['status'] == 1 || response['status'] == true) {
          Fluttertoast.showToast(msg: response['message']?.toString() ?? 'Address deleted successfully', backgroundColor: Colors.green, textColor: Colors.white);
          await fetchAddresses();
        } else {
          Fluttertoast.showToast(msg: response['message']?.toString() ?? 'Failed to delete address', backgroundColor: Colors.red, textColor: Colors.white);
          state = state.copyWith(isLoading: false, error: response['message']?.toString());
        }
      } else {
        Fluttertoast.showToast(msg: 'Invalid response from server', backgroundColor: Colors.red, textColor: Colors.white);
        state = state.copyWith(isLoading: false, error: 'Invalid response');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red, textColor: Colors.white);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final addressProvider = NotifierProvider<AddressNotifier, AddressState>(() {
  return AddressNotifier();
});
