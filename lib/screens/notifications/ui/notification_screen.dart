import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/image_viewer.dart';
import '../riverpod/notification_notifier.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  String _stripHtml(String html) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return html.replaceAll(exp, '').trim();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundScaffold,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryDark),
        actions: [
          if (state.unreadCount > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  '${state.unreadCount} Unread',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ),
            )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(notificationProvider.notifier).fetchNotifications(),
        child: _buildBody(state, context),
      ),
    );
  }

  Widget _buildBody(NotificationState state, BuildContext context) {
    if (state.isLoading && state.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    if (state.notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined, size: 64, color: AppColors.textMuted),
            SizedBox(height: 16),
            Text('No notifications yet', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: state.notifications.length,
      itemBuilder: (context, index) {
        final notif = state.notifications[index];
        final isUnread = notif.readAt == null || notif.readAt!.isEmpty;

        return Container(
          color: isUnread ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: GestureDetector(
              onTap: () {
                if (notif.profileImage != null && notif.profileImage!.isNotEmpty) {
                  ImageViewer.show(context, NetworkImage(notif.profileImage!));
                }
              },
              child: CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.borderLight,
                backgroundImage: (notif.profileImage != null && notif.profileImage!.isNotEmpty) ? NetworkImage(notif.profileImage!) : null,
                child: (notif.profileImage == null || notif.profileImage!.isEmpty)
                    ? const Icon(Icons.notifications, color: AppColors.textMuted)
                    : null,
              ),
            ),
            title: Text(notif.data.type, style: TextStyle(fontWeight: isUnread ? FontWeight.bold : FontWeight.w600, color: AppColors.primaryDark, fontSize: 15)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(_stripHtml(notif.data.message), style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4)),
                const SizedBox(height: 8),
                Text(notif.createdAt, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        );
      },
    );
  }
}
