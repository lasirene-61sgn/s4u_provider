
import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'package:get/get.dart';
import 'core/routes/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';


import 'core/storage/shared_preference_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferenceHelper.init();
  runApp(const ProviderScope(child: ProviderApp()));
}

class ProviderApp extends ConsumerWidget {
  const ProviderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetMaterialApp(
      title: 'S4U Partner App',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, primary: AppColors.primary),
        textTheme: GoogleFonts.outfitTextTheme(),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: AppColors.primaryDark, elevation: 0),
        useMaterial3: true,
      ),
      getPages: AppRoutes.routes,
      initialRoute: '/splash',
      debugShowCheckedModeBanner: false,
    );
  }
}
