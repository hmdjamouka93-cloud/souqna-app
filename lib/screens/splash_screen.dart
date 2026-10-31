import 'dart:async';
import 'package:flutter/material.dart';
import '../main.dart';
import '../services/notification_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      // نحاولو نهيئو الإشعارات مع Timeout باش ما يعلقش التطبيق
      await NotificationService.init().timeout(const Duration(seconds: 3));
    } catch (e) {
      print('Notification init timeout or error: $e');
    }

    // نستناو شوية باش تبان الشاشة، ومن بعد نروحو للرئيسية
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainShell(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.storefront, size: 100, color: AppColors.accent),
            const SizedBox(height: 16),
             Text(
              'Souqna',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 32),
            CircularProgressIndicator(
              color: AppColors.accent.withValues(alpha: 0.8),
            ),
          ],
        ),
      ),
    );
  }
}
