import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/storage/shared_preference_helper.dart';
import '../model/profile_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class ProfileState {
  final bool isLoading;
  final Profile? profile;
  final String? error;

  ProfileState({this.isLoading = false, this.profile, this.error});

  ProfileState copyWith({bool? isLoading, Profile? profile, String? error}) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      error: error ?? this.error,
    );
  }
}

class ProfileNotifier extends Notifier<ProfileState> {
  final ApiClient _api = ApiClient();

  @override
  ProfileState build() {
    Future.microtask(() => _fetchProfile());
    return ProfileState(isLoading: true);
  }

  Future<void> _fetchProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final token = SharedPreferenceHelper.getString('token');
      if (token == null || token.isEmpty) {
        state = state.copyWith(isLoading: false, error: 'Not authenticated');
        return;
      }

      // No longer need to parse userId for the new endpoint

      final res = await _api.get(endpoint: '/provider-handyman-profile');
      print('=== Profile API Response ===');
      print(res);
      print('============================');
      if (res != null && (res['status'] == 1 || res['status'] == true)) {
        dynamic responseData = res is List ? res : (res['data'] ?? res);
        if (responseData is Map && responseData.containsKey('data')) {
           responseData = responseData['data'];
        }
        
        state = state.copyWith(isLoading: false, profile: Profile.fromJson(responseData));
      } else {
        String errMsg = 'Failed to load profile';
        if (res != null && res['message'] != null) {
          if (res['message'] is Map) {
            errMsg = res['message']['message']?.toString() ?? errMsg;
          } else {
            errMsg = res['message'].toString();
          }
        }
        state = state.copyWith(isLoading: false, error: errMsg);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  int? _getUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      
      String payload = parts[1];
      payload = payload.replaceAll('-', '+').replaceAll('_', '/');
      switch (payload.length % 4) {
        case 0: break;
        case 2: payload += '=='; break;
        case 3: payload += '='; break;
        default: return null;
      }
      
      final String decoded = utf8.decode(base64Url.decode(payload));
      final Map<String, dynamic> data = json.decode(decoded);
      return data['userId'] as int?;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateProfile(
    String firstName,
    String lastName,
    String username,
    String mobile, {
    String? profileImage,
    String? companyName,
    String? gstNumber,
    String? address,
    String? city,
    String? stateStr, // renamed to avoid conflict with Notifier.state
    String? country,
    int? countryId,
    int? stateId,
    int? cityId,
    String? selectAddress,
    String? handymanCommission,
    String? whyChooseMeTitle,
    String? whyChooseMeDescription,
    List<String>? whyChooseMeReasons,
  }) async {
    final token = SharedPreferenceHelper.getString('token');
    if (token == null || token.isEmpty) return;
    
    // No longer need to parse userId for the new endpoint
    
    final Map<String, dynamic> body = {
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'mobile': mobile,
    };
    if (profileImage != null) body['profileImage'] = profileImage;
    if (companyName != null) body['companyName'] = companyName;
    if (gstNumber != null) body['gstNumber'] = gstNumber;
    if (address != null) body['address'] = address;
    if (city != null) body['city'] = city;
    if (stateStr != null) body['state'] = stateStr;
    if (country != null) body['country'] = country;
    if (countryId != null) body['country_id'] = countryId;
    if (stateId != null) body['state_id'] = stateId;
    if (cityId != null) body['city_id'] = cityId;
    if (selectAddress != null) body['selectAddress'] = selectAddress;
    if (handymanCommission != null) {
      final parsedInt = int.tryParse(handymanCommission);
      final valueToSend = parsedInt ?? handymanCommission;
      body['handymanCommission'] = valueToSend;
      body['handyman_commission'] = valueToSend;
      body['userCommission'] = valueToSend;
      body['user_commission'] = valueToSend;
      body['handymantype_id'] = valueToSend; // Just in case it maps to handymantype_id
    }
    if (whyChooseMeTitle != null) body['whyChooseMeTitle'] = whyChooseMeTitle;
    if (whyChooseMeDescription != null) body['whyChooseMeDescription'] = whyChooseMeDescription;
    if (whyChooseMeReasons != null) body['whyChooseMeReasons'] = whyChooseMeReasons;

    try {
      final res = await _api.post(
        endpoint: '/update-profile',
        body: body,
      );

      // In our ApiClient, standard successful response is wrapped in { "status": 1, "data": ... }
      if (res != null && (res['status'] == 1 || res['status'] == true)) {
        Fluttertoast.showToast(msg: res['message']?.toString() ?? 'Profile updated successfully', backgroundColor: Colors.green, textColor: Colors.white);
        await _fetchProfile(); // refresh the data
      } else {
        Fluttertoast.showToast(msg: res?['message']?.toString() ?? 'Failed to update profile', backgroundColor: Colors.red, textColor: Colors.white);
        state = state.copyWith(error: res?['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red, textColor: Colors.white);
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> refresh() async {
    await _fetchProfile();
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(() => ProfileNotifier());
