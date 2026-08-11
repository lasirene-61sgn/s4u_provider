import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../../screens/auth/riverpod/auth_notifier.dart';

class ProviderTopBar extends ConsumerWidget {
  final String? title;
  final String? subtitle;
  final String? actionButtonText;
  final VoidCallback? onAddPressed;
  final VoidCallback? onMyInfo;
  final VoidCallback? onMyProfile;

  const ProviderTopBar({
    super.key,
    this.title,
    this.subtitle,
    this.actionButtonText,
    this.onAddPressed,
    this.onMyInfo,
    this.onMyProfile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const bool isMobile = true;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 32, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        children: [
          if (isMobile)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: AppColors.primaryDark, size: 28),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          if (isMobile) const SizedBox(width: 16),
          
          if (title != null) ...[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title!, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryDark, letterSpacing: -0.5)),
              ],
            ),
          ],
          const Spacer(),

          if (actionButtonText != null && onAddPressed != null) ...[
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              icon: const Icon(Icons.add, size: 20),
              label: Text(actionButtonText!, style: const TextStyle(fontWeight: FontWeight.bold)),
              onPressed: onAddPressed,
            ),
            const SizedBox(width: 24),
          ],
          
          // Sun icon (Purple background)
            if (!isMobile) Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.light_mode_outlined, color: Colors.white, size: 20),
                onPressed: () {},
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
              ),
            ),
            if (!isMobile) const SizedBox(width: 16),
            
            // Bell with badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                _buildNotificationsPopup(context),
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Text('10', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),

            // Flag icon
            if (!isMobile) const Text('🇺🇸', style: TextStyle(fontSize: 24)),
            if (!isMobile) const SizedBox(width: 24),

            // Profile Popup Menu
            PopupMenuButton<String>(
              offset: const Offset(0, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              color: Colors.white,
              elevation: 4,
              onSelected: (val) {
                if (val == 'logout') {
                  ref.read(authProvider.notifier).logout();
                } else if (val == 'profile') {
                  onMyProfile?.call();
                } else if (val == 'info') {
                  onMyInfo?.call();
                }
              },
              itemBuilder: (context) => [
                _buildPopupMenuItem('home', Icons.home_outlined, 'HOME'),
                const PopupMenuDivider(height: 1),
                _buildPopupMenuItem('profile', Icons.person_outline, 'MY PROFILE'),
                const PopupMenuDivider(height: 1),
                _buildPopupMenuItem('info', Icons.info_outline, 'MY INFO'),
                const PopupMenuDivider(height: 1),
                _buildPopupMenuItem('settings', Icons.settings_outlined, 'SETTINGS'),
                const PopupMenuDivider(height: 1),
                _buildPopupMenuItem('logout', Icons.logout_outlined, 'LOG OUT'),
              ],
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primaryLight,
                    backgroundImage: const AssetImage('assets/s4u_logo.jpeg'),
                  ),
                  if (!isMobile) ...[
                    const SizedBox(width: 12),
                    const Text('PROVIDER', style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
                    const SizedBox(width: 4),
                  ]
                ],
              ),
            ), // Closes PopupMenuButton
        ], // Closes Row.children
      ), // Closes Row
    ); // Closes Container
  }

  PopupMenuItem<String> _buildPopupMenuItem(String value, IconData icon, String title) {
    return PopupMenuItem<String>(
      value: value,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF64748B)),
          const SizedBox(width: 16),
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155), letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildNotificationsPopup(BuildContext context) {
    return PopupMenuButton<void>(
      offset: const Offset(0, 50),
      icon: const Icon(Icons.notifications_outlined, color: AppColors.textMuted, size: 24),
      tooltip: 'Notifications',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Container(
            width: 300,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryDark)),
                const Divider(height: 16),
                _buildPopupNotificationItem(
                  icon: Icons.star_rate_rounded,
                  iconColor: Colors.amber,
                  title: 'Welcome Partner!',
                  subtitle: 'Start accepting jobs to grow your business.',
                ),
                const SizedBox(height: 16),
                _buildPopupNotificationItem(
                  icon: Icons.calendar_today_rounded,
                  iconColor: Colors.blue,
                  title: 'Schedule Check',
                  subtitle: 'Review your assigned handyman listings.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPopupNotificationItem({required IconData icon, required Color iconColor, required String title, required String subtitle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryDark)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        ),
      ],
    );
  }

}
