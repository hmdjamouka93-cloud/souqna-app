import 'package:flutter/material.dart';
import '../services/language_service.dart';
import '../main.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  static const _bg = Color(0xFF1E2128);
  static const _card = Color(0xFF2A2E36);
  static const _accent = Color(0xFFA0285A);
  static const _textSec = Color(0xFFB0B0B8);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final pass = _passCtrl.text;

    if (name.isEmpty) {
      setState(() => _error = LanguageService.tr('err_enter_name'));
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = LanguageService.tr('err_invalid_email'));
      return;
    }
    if (phone.length < 9) {
      setState(() => _error = LanguageService.tr('err_short_phone'));
      return;
    }
    if (pass.length < 6) {
      setState(() => _error = LanguageService.tr('err_short_pass'));
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await AuthService.signup(
        email: email,
        password: pass,
        phone: phone,
        name: name,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } on Exception catch (e) {
      String msg = LanguageService.tr('err_signup_generic');
      final s = e.toString();
      
      if (s.contains('رقم الهاتف هذا مستعمل')) {
        msg = LanguageService.tr('err_phone_used');
      } else if (s.contains('email-already-in-use')) {
        msg = LanguageService.tr('err_email_used');
      } else if (s.contains('invalid-email')) {
        msg = LanguageService.tr('err_invalid_email');
      } else if (s.contains('weak-password')) {
        msg = LanguageService.tr('err_weak_pass');
      } else if (s.contains('network')) {
        msg = LanguageService.tr('err_check_net');
      }
      setState(() => _error = msg);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          iconTheme:  IconThemeData(color: AppColors.textPrimary),
          title:  Text(
            LanguageService.tr('signup'),
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),

                _label(LanguageService.tr('full_name')),
                _field(
                  controller: _nameCtrl,
                  hint: LanguageService.tr('full_name_hint'),
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),

                _label(LanguageService.tr('email')),
                _field(
                  controller: _emailCtrl,
                  hint: 'example@mail.com',
                  icon: Icons.email_outlined,
                  keyboard: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                _label(LanguageService.tr('phone_number')),
                _field(
                  controller: _phoneCtrl,
                  hint: '0555 12 34 56',
                  icon: Icons.phone_outlined,
                  keyboard: TextInputType.phone,
                ),

                const SizedBox(height: 16),
                _label(LanguageService.tr('password')),
                _field(
                  controller: _passCtrl,
                  hint: '••••••••',
                  icon: Icons.lock_outline,
                  obscure: _obscure,
                  suffix: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      color: _textSec,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                    ),
                  ),
                ],

                const SizedBox(height: 26),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _loading ? null : _signup,
                    child: _loading
                        ?  SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: AppColors.textPrimary,
                              strokeWidth: 2.5,
                            ),
                          )
                        :  Text(
                            LanguageService.tr('register_btn'),
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 12),
                Center(
                  child: Text(
                    LanguageService.tr('phone_visible_note'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _textSec, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8, right: 4),
        child: Text(
          t,
          style:  TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboard,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        obscureText: obscure,
        style:  TextStyle(color: AppColors.textPrimary),
        textDirection: TextDirection.ltr,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: _textSec, fontSize: 14),
          prefixIcon: Icon(icon, color: _textSec, size: 20),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        ),
      ),
    );
  }
}
