import 'package:flutter/material.dart';
import 'auth_service.dart';
import '../screens/login_screen.dart';

/// إذا المستخدم مسجل → ينفذ [onAuthed]
/// إذا ماشي مسجل → يوديه للـ LoginScreen
/// بعد ما يسجل يرجع ويستدعي [onAuthed] تلقائياً
Future<void> requireAuth(
  BuildContext context,
  VoidCallback onAuthed, {
  String message = 'خاصك تسجل باش تكمل',
}) async {
  if (AuthService.isLoggedIn) {
    onAuthed();
    return;
  }

  final goLogin = await showDialog<bool>(
    context: context,
    builder: (ctx) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: const Color(0xFF2A2E36),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'تسجيل الدخول',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Color(0xFFB0B0B8), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: Color(0xFFB0B0B8)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA0285A),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'تسجيل الدخول',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  );

  if (goLogin != true) return;
  if (!context.mounted) return;

  final logged = await Navigator.push<bool>(
    context,
    MaterialPageRoute(builder: (_) => const LoginScreen()),
  );

  if (logged == true) {
    onAuthed();
  }
}
