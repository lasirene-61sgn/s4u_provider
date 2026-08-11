import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/storage/shared_preference_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Artificial delay for splash screen animation
    await Future.delayed(const Duration(seconds: 2));
    
    final token = SharedPreferenceHelper.getString('token');
    final isLoggedIn = SharedPreferenceHelper.getBool('isLoggedIn');
    
    if (token != null && token.isNotEmpty && isLoggedIn == true) {
      Get.offAllNamed('/');
    } else {
      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 10)),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/s4u_logo.jpeg',
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ).animate().scale(duration: const Duration(milliseconds: 800), curve: Curves.easeOutBack),
            const SizedBox(height: 32),
            const Text(
              'S4U Partner',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ).animate().fadeIn(delay: const Duration(milliseconds: 400)).slideY(begin: 0.3, end: 0),
            const SizedBox(height: 8),
            const Text(
              'PORTAL',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
                letterSpacing: 6.0,
              ),
            ).animate().fadeIn(delay: const Duration(milliseconds: 600)),
            const SizedBox(height: 64),
            const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            ).animate().fadeIn(delay: const Duration(milliseconds: 800)),
          ],
        ),
      ),
    );
  }
}
