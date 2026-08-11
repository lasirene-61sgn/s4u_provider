import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';

class RegisterState {
  final bool isLoading;
  final String? errorMessage;
  final List<dynamic> providers;

  RegisterState({
    this.isLoading = false,
    this.errorMessage,
    this.providers = const [],
  });

  RegisterState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<dynamic>? providers,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      providers: providers ?? this.providers,
    );
  }
}

class RegisterNotifier extends Notifier<RegisterState> {
  final ApiClient _api = ApiClient();

  @override
  RegisterState build() {
    return RegisterState();
  }

  Future<void> loadProviders() async {
    try {
      final res = await _api.get(endpoint: '/handyman-provider-list');
      
      dynamic responseData = res is List ? res : (res['data'] ?? res);
      if (responseData is Map && responseData.containsKey('data')) {
        responseData = responseData['data'];
      }
      
      if (responseData is List) {
        state = state.copyWith(providers: responseData);
      }
    } catch (e) {
      // silently fail
    }
  }


  Future<void> register({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String contactNumber,
    required String role,
    required String userCommission,
    required String designation,
    int? providerId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final Map<String, dynamic> body = {
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'email': email,
      'password': password,
      'user_type': role.toLowerCase(), // e.g., 'provider' or 'handyman'
      'contact_number': contactNumber,
      'providertype_id': '1', // Defaulting to 1 as per requirements
    };

    if (role.toLowerCase() == 'handyman' && providerId != null) {
      body['providerId'] = providerId;
    }

    try {
      // Using requestWithFiles to send as form-data
      final res = await _api.requestWithFiles(endpoint: ApiConstants.register, fields: body);

      final int resStatus = (res['status'] as num?)?.toInt() ?? 0;
      String message = res['message']?.toString() ?? '';
      
      // If ApiClient nested the response under 'data', extract the message from there
      if (message.isEmpty && res['data'] is Map && res['data']['message'] != null) {
        message = res['data']['message'].toString();
      } else if (message.startsWith('{') && res['data'] == null) {
         // sometimes dio error data stringifies the map
         // it's better to leave it, but just in case we can attempt to parse it or let it be
      }

      if (resStatus == 1 ||
          resStatus >= 0 &&
              (message.toLowerCase().contains('pending') ||
                  message.toLowerCase().contains('registered') ||
                  message.toLowerCase().contains('success') ||
                  message.toLowerCase().contains('email verification') ||
                  res['token'] != null && res['token'].toString().isNotEmpty)) {
        state = state.copyWith(isLoading: false);
        Get.snackbar(
          '✅ Registration Successful',
          message.isNotEmpty ? message : 'Your account has been created.',
          duration: const Duration(seconds: 5),
        );
        Get.offAllNamed('/login');
      } else {
        state = state.copyWith(isLoading: false, errorMessage: message);
        Get.snackbar('Error', message.isNotEmpty ? message : 'Registration Failed');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      Get.snackbar('Error', e.toString());
    }
  }
}

final registerProvider =
    NotifierProvider<RegisterNotifier, RegisterState>(() => RegisterNotifier());
