import 'package:get/get.dart';
import '../../screens/layout/provider_layout.dart';
import '../../screens/auth/ui/login_screen.dart';
import '../../screens/auth/ui/register_screen.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/bookings/ui/booking_details_screen.dart';

class AppRoutes {
  static final routes = [
    GetPage(name: '/splash', page: () => const SplashScreen()),
    GetPage(name: '/login', page: () => const LoginScreen()),
    GetPage(name: '/register', page: () => const RegisterScreen()),
    GetPage(name: '/', page: () => const ProviderLayout(), transition: Transition.noTransition),
    GetPage(name: '/booking/:id', page: () => BookingDetailsScreen(bookingId: int.parse(Get.parameters['id']!))),
  ];
}
