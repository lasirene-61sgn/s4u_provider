import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../model/bank_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class BankState {
  final bool isLoading;
  final List<BankModel> banks;
  final String? error;
  final int? deletingBankId;

  BankState({this.isLoading = false, this.banks = const [], this.error, this.deletingBankId});

  BankState copyWith({bool? isLoading, List<BankModel>? banks, String? error, int? deletingBankId, bool clearDeletingBankId = false}) {
    return BankState(
      isLoading: isLoading ?? this.isLoading,
      banks: banks ?? this.banks,
      error: error ?? this.error,
      deletingBankId: clearDeletingBankId ? null : (deletingBankId ?? this.deletingBankId),
    );
  }
}

class BankNotifier extends Notifier<BankState> {
  final ApiClient _apiClient = ApiClient();

  @override
  BankState build() {
    return BankState();
  }

  Future<void> fetchBanks() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.get(endpoint: '/user-bank-detail');
      print("bank:${response}");
      
      if (response != null && response is Map) {
        if (response['status'] == 1 || response['status'] == true) {
          List<BankModel> banksList = [];
          final data = response['data'];
          if (data is List) {
            banksList = data.map((e) => BankModel.fromJson(e as Map<String, dynamic>)).toList();
          } else if (data is Map && data.containsKey('data') && data['data'] is List) {
            banksList = (data['data'] as List).map((e) => BankModel.fromJson(e as Map<String, dynamic>)).toList();
          }
          state = state.copyWith(isLoading: false, banks: banksList, clearDeletingBankId: true);
        } else {
          state = state.copyWith(isLoading: false, error: response['message']?.toString() ?? 'Failed to load banks', clearDeletingBankId: true);
        }
      } else {
        state = state.copyWith(isLoading: false, error: 'Invalid response from server', clearDeletingBankId: true);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString(), clearDeletingBankId: true);
    }
  }

  Future<void> addBank(Map<String, dynamic> req) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.post(endpoint: '/save-bank', body: req);
      
      if (response != null && response is Map) {
        if (response['status'] == 1 || response['status'] == true) {
          Fluttertoast.showToast(msg: response['message']?.toString() ?? 'Bank saved successfully', backgroundColor: Colors.green, textColor: Colors.white);
          await fetchBanks();
        } else {
          Fluttertoast.showToast(msg: response['message']?.toString() ?? 'Failed to save bank', backgroundColor: Colors.red, textColor: Colors.white);
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

  Future<void> deleteBank(int id) async {
    state = state.copyWith(deletingBankId: id, error: null);
    try {
      final response = await _apiClient.get(endpoint: '/user-bank-delete/$id'); // Try user-bank-delete GET instead
      
      if (response != null && response is Map) {
        if (response['status'] == 1 || response['status'] == true) {
          Fluttertoast.showToast(msg: response['message']?.toString() ?? 'Bank deleted successfully', backgroundColor: Colors.green, textColor: Colors.white);
          await fetchBanks();
        } else {
          Fluttertoast.showToast(msg: response['message']?.toString() ?? 'Failed to delete bank', backgroundColor: Colors.red, textColor: Colors.white);
          state = state.copyWith(clearDeletingBankId: true, error: response['message']?.toString());
        }
      } else {
        Fluttertoast.showToast(msg: 'Invalid response from server', backgroundColor: Colors.red, textColor: Colors.white);
        state = state.copyWith(clearDeletingBankId: true, error: 'Invalid response');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red, textColor: Colors.white);
      state = state.copyWith(clearDeletingBankId: true, error: e.toString());
    }
  }
}

final bankProvider = NotifierProvider<BankNotifier, BankState>(() {
  return BankNotifier();
});
