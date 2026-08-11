import 'dart:io';

void main() {
  final files = [
    'lib/screens/services/ui/service_request_list_screen.dart',
    'lib/screens/dashboard/ui/dashboard_screen.dart',
    'lib/screens/layout/provider_layout.dart',
    'lib/screens/auth/ui/login_screen.dart',
    'lib/core/widgets/provider_top_bar.dart',
    'lib/screens/auth/ui/register_screen.dart',
    'lib/screens/bookings/ui/bookings_screen.dart',
    'lib/screens/splash/splash_screen.dart',
    'lib/screens/handyman/ui/handyman_screen.dart',
    'pubspec.yaml',
  ];

  for (var file in files) {
    final f = File(file);
    if (!f.existsSync()) continue;
    String content = f.readAsStringSync();
    content = content.replaceAll('assets/logo.png', 'assets/s4u_logo.jpeg');
    content = content.replaceAll('assets/real_logo.png', 'assets/s4u_logo.jpeg');
    f.writeAsStringSync(content);
  }
}
