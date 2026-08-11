import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../../core/api/api_client.dart';
import '../../../core/storage/shared_preference_helper.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/models/user_model.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final bool isForgotLoading;
  final String? errorMessage;
  final UserModel? user;

  AuthState({this.isAuthenticated = false, this.isLoading = false, this.isForgotLoading = false, this.errorMessage, this.user});

  AuthState copyWith({bool? isAuthenticated, bool? isLoading, bool? isForgotLoading, String? errorMessage, UserModel? user}) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      isForgotLoading: isForgotLoading ?? this.isForgotLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  final ApiClient _api = ApiClient();

  @override
  AuthState build() {
    final token = SharedPreferenceHelper.getString('token');
    return AuthState(
      isLoading: false,
      isAuthenticated: token != null && token.isNotEmpty && SharedPreferenceHelper.getBool('isLoggedIn') == true,
    );
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final res = await _api.post(
        endpoint: ApiConstants.login,
        body: {'email': email, 'password': password},
      );
      print("this is error :$res");

      if (res['status'] == 1) {
        final resData = res['data'];
        final Map<String, dynamic>? userData = (resData is Map && resData.containsKey('data')) 
            ? resData['data'] 
            : resData;

        if (userData != null) {
          final user = UserModel.fromJson(userData);
          final role = user.userType?.toUpperCase() ?? '';
          
          if (role == 'PROVIDER' || role == 'HANDYMAN') {
            final token = user.apiToken;
            if (token != null && token.isNotEmpty) {
              await SharedPreferenceHelper.setString('token', token);
              await SharedPreferenceHelper.setBool('isLoggedIn', true);
              await SharedPreferenceHelper.setString('role', role);
              
              state = state.copyWith(isAuthenticated: true, isLoading: false, user: user);
              Get.offAllNamed('/');
              return;
            } else {
               state = state.copyWith(isLoading: false, errorMessage: 'Token missing in response');
               Get.snackbar('Error', 'Login successful but no token received.');
               return;
            }
          } else {
            state = state.copyWith(isLoading: false, errorMessage: 'Unauthorized: Invalid role');
            Get.snackbar('Error', 'You do not have PROVIDER or HANDYMAN access.');
            return;
          }
        }
      } 

      final msg = res['message']?.toString() ?? 'Login Failed';
      state = state.copyWith(isLoading: false, errorMessage: msg);

      final isPending = msg.toLowerCase().contains('pending') ||
          msg.toLowerCase().contains('approval');

      if (isPending) {
        Get.snackbar(
          '⏳ Account Pending Approval',
          'Your account is awaiting admin review. You will be able to log in once approved.',
          backgroundColor: const Color(0xFFFFF3CD),
          colorText: const Color(0xFF856404),
          duration: const Duration(seconds: 6),
          icon: const Icon(Icons.hourglass_top, color: Color(0xFF856404)),
        );
      } else {
        Get.snackbar('Login Failed', msg,
            backgroundColor: const Color(0xFFFFE4E6),
            colorText: const Color(0xFFE11D48));
      }
    } catch (e, stackTrace) {
      debugPrint('Login Error: $e');
      debugPrint('StackTrace: $stackTrace');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      Get.snackbar('Login Error', e.toString(),
          backgroundColor: const Color(0xFFFFE4E6),
          colorText: const Color(0xFFE11D48));
    }
  }

  Future<void> forgotPassword(String email) async {
    if (email.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter your email address first.',
          backgroundColor: const Color(0xFFFFE4E6),
          colorText: const Color(0xFFE11D48));
      return;
    }
    
    state = state.copyWith(isForgotLoading: true, errorMessage: null);
    try {
      final res = await _api.post(
        endpoint: '/forgot-password',
        body: {'email': email.trim()},
      );
      
      state = state.copyWith(isForgotLoading: false);
      
      if (res != null && (res['status'] == 1 || res['status'] == true)) {
        String msg = 'Password reset link sent to your email.';
        if (res['data'] != null && res['data'] is Map && res['data']['message'] != null) {
          msg = res['data']['message'].toString();
        } else if (res['message'] != null) {
          msg = res['message'].toString();
        }
        Get.snackbar('Success', msg,
            backgroundColor: const Color(0xFFD1FAE5),
            colorText: const Color(0xFF065F46));
      } else {
        Get.snackbar('Error', res?['message']?.toString() ?? 'Failed to send reset link.',
            backgroundColor: const Color(0xFFFFE4E6),
            colorText: const Color(0xFFE11D48));
      }
    } catch (e) {
      state = state.copyWith(isForgotLoading: false);
      Get.snackbar('Error', e.toString(),
          backgroundColor: const Color(0xFFFFE4E6),
          colorText: const Color(0xFFE11D48));
    }
  }

  Future<void> logout() async {
    try {
      await _api.post(endpoint: ApiConstants.logout);
    } catch (e) {
      // Ignored
    }
    
    await SharedPreferenceHelper.remove('token');
    await SharedPreferenceHelper.setBool('isLoggedIn', false);
    await SharedPreferenceHelper.remove('role');
    state = state.copyWith(isAuthenticated: false, user: null);
    Get.offAllNamed('/login');
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() => AuthNotifier());
