import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../model/notification_model.dart';

class NotificationState {
  final bool isLoading;
  final List<NotificationModel> notifications;
  final int unreadCount;
  final String? error;

  NotificationState({
    this.isLoading = false,
    this.notifications = const [],
    this.unreadCount = 0,
    this.error,
  });

  NotificationState copyWith({
    bool? isLoading,
    List<NotificationModel>? notifications,
    int? unreadCount,
    String? error,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      error: error,
    );
  }
}

class NotificationNotifier extends Notifier<NotificationState> {
  @override
  NotificationState build() {
    Future.microtask(() => fetchNotifications());
    return NotificationState();
  }

  Future<void> fetchNotifications() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await ApiClient().post(
        endpoint: '/api/notification-list',
      );

      if (response['status'] == 1 && response['data'] != null) {
        final data = response['data'];
        final List<dynamic> notifData = data['notification_data'] ?? [];
        final int unread = data['all_unread_count'] ?? 0;

        final notifications = notifData.map((e) => NotificationModel.fromJson(e)).toList();

        state = state.copyWith(
          isLoading: false,
          notifications: notifications,
          unreadCount: unread,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response['message']?.toString() ?? 'Failed to load notifications'
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred: $e'
      );
    }
  }
}

final notificationProvider = NotifierProvider<NotificationNotifier, NotificationState>(() {
  return NotificationNotifier();
});
