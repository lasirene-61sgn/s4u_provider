import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/api/api_client.dart';
import '../model/slot_model.dart';

class TimeSlotState {
  final bool isLoading;
  final bool isSaving;
  final List<SlotModel> savedSlots;
  final String? error;

  TimeSlotState({
    this.isLoading = false,
    this.isSaving = false,
    this.savedSlots = const [],
    this.error,
  });

  TimeSlotState copyWith({
    bool? isLoading,
    bool? isSaving,
    List<SlotModel>? savedSlots,
    String? error,
  }) {
    return TimeSlotState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      savedSlots: savedSlots ?? this.savedSlots,
      error: error ?? this.error,
    );
  }
}

class TimeSlotNotifier extends Notifier<TimeSlotState> {
  final ApiClient _api = ApiClient();

  @override
  TimeSlotState build() => TimeSlotState();

  Future<void> fetchSlots() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _api.get(endpoint: '/get-provider-slot');
      print("slot:$res");
      
      if (res != null && (res['status'] == 1 || res['status'] == true)) {
        final data = res['data'];
        if (data is List) {
          final List<SlotModel> newSlots = data.map((e) => SlotModel.fromJson(e as Map<String, dynamic>)).toList();
          state = state.copyWith(isLoading: false, savedSlots: newSlots);
        } else {
          state = state.copyWith(isLoading: false, error: 'Unexpected response format');
        }
      } else {
        state = state.copyWith(isLoading: false, error: res?['message'] ?? 'Failed to load slots');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  String _mapDayToShort(String shortDay) {
    switch (shortDay.toUpperCase()) {
      case 'MON': return 'mon';
      case 'TUE': return 'tue';
      case 'WED': return 'wed';
      case 'THU': return 'thu';
      case 'FRI': return 'fri';
      case 'SAT': return 'sat';
      case 'SUN': return 'sun';
      default: return shortDay.toLowerCase();
    }
  }

  Future<void> saveSlots(int providerId, String day, List<String> times) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      final List<Map<String, String>> slotsPayload = [];
      
      // We must send slots for all active days, not just the one being saved, 
      // because the API overrides the entire provider schedule with the payload.
      final allDays = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
      
      for (final d in allDays) {
        List<String> dayTimes = [];
        if (d == _mapDayToShort(day)) {
          dayTimes = times; // Use the newly saved times for this day
        } else {
          // Use existing times for other days
          final existing = state.savedSlots.where((s) => s.day.toLowerCase() == d).firstOrNull;
          if (existing != null) {
            dayTimes = existing.times;
          }
        }
        
        for (final time in dayTimes) {
          String formatted = time;
          if (formatted.isNotEmpty && formatted.split(':').length == 2) {
            formatted += ':00';
          }
          slotsPayload.add({
            'day': d,
            'start_at': formatted,
            'end_at': formatted, // The API seems to just read start_at to store the slot hour
          });
        }
      }

      final res = await _api.post(
        endpoint: '/save-provider-slot',
        body: {
          'provider_id': providerId,
          'slots': slotsPayload,
        },
      );
      
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
        await fetchSlots();
        Fluttertoast.showToast(
          msg: 'Provider slot has been saved successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        final err = res?['message'] ?? 'Failed to save';
        state = state.copyWith(isSaving: false, error: err);
        Fluttertoast.showToast(
          msg: err,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      Fluttertoast.showToast(
        msg: e.toString(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
}

final timeSlotProvider = NotifierProvider<TimeSlotNotifier, TimeSlotState>(() => TimeSlotNotifier());
