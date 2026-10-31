import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'about_screen.dart';
import 'my_ads_screen.dart';
import 'favorites_screen.dart';
import 'post_ad_chooser_screen.dart';
import 'my_blocked_users_screen.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  @override
  void initState() {
    super.initState();
    ThemeService.isDarkMode.addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    ThemeService.isDarkMode.removeListener(_onThemeChanged);
    super.dispose();
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
          leading: IconButton(
            icon:  Icon(Icons.close, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title:  Text(
            'المزيد',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions:  [
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.notifications_none, color: AppColors.textPrimary, size: 24),
            ),
          ],
        ),
        body: StreamBuilder<User?>(
          stream: AuthService.authStateChanges,
          builder: (context, snapshot) {
            final user = snapshot.data;
            final logged = user != null;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _accountCard(context, user, logged),
                  const SizedBox(height: 20),
                  _buildGrid(context, logged),
                  const SizedBox(height: 24),
                  _sectionTitle('الإعدادات'),
                  const SizedBox(height: 10),
                  _buildSettingsList(context),
                  const SizedBox(height: 24),
                  _rateCard(context),
                  if (logged) ...[
                    const SizedBox(height: 24),
                    _logoutButton(context),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ============ البطاقة العلوية: حسابي ============
  Widget _accountCard(BuildContext context, User? user, bool logged) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          if (logged) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFA0285A), Color(0xFF6E1A3D)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.textPrimary.withValues(alpha: 0.18),
                child: Icon(
                  logged ? Icons.person : Icons.login,
                  color: AppColors.textPrimary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      logged ? 'حسابي' : 'تسجيل الدخول',
                      style:  TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      logged
                          ? (user?.email ?? '')
                          : 'سجل للاستفادة من كل الميزات',
                      style: TextStyle(
                        color: AppColors.textPrimary.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
               Icon(Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ============ Grid 2x3 ============
  Widget _buildGrid(BuildContext context, bool logged) {
    final items = [
      _GridItem('إضافة إعلان', Icons.add_circle_outline, const Color(0xFFA0285A),
          () {
        if (!logged) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PostAdChooserScreen()),
        );
      }),
      _GridItem('إعلاناتي', Icons.list_alt, const Color(0xFF2E7D32), () {
        if (!logged) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MyAdsScreen()),
        );
      }),
      _GridItem('المفضلة', Icons.star_border, const Color(0xFFF9A825), () {
        if (!logged) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FavoritesScreen()),
        );
      }),
      _GridItem('المحظورين', Icons.block, const Color(0xFFC62828), () {
        if (!logged) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MyBlockedUsersScreen()),
        );
      }),
      _GridItem('اللغة', Icons.language, const Color(0xFF7B1FA2), () {
        showDialog(
          context: context,
          builder: (ctx) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              backgroundColor: AppColors.card,
              title: Text('اللغة', style: TextStyle(color: AppColors.textPrimary)),
              content:  Text('اللغة العربية هي اللغة الافتراضية حالياً.\nسيتم إضافة لغات أخرى قريباً.', style: TextStyle(color: AppColors.textSecondary)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('حسناً', style: TextStyle(color: AppColors.accent)),
                ),
              ],
            ),
          ),
        );
      }),
      _GridItem('الوضع', Icons.brightness_6_outlined, const Color(0xFF1976D2), () {
        final isDark = ThemeService.isDarkMode.value;
        showDialog(
          context: context,
          builder: (ctx) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              backgroundColor: AppColors.card,
              title: Text('اختر الوضع', style: TextStyle(color: AppColors.textPrimary)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<bool>(
                    title: Text('الوضع الداكن', style: TextStyle(color: AppColors.textPrimary)),
                    value: true,
                    groupValue: isDark,
                    activeColor: AppColors.accent,
                    onChanged: (v) {
                      ThemeService.toggleTheme(true);
                      Navigator.pop(ctx);
                    },
                  ),
                  RadioListTile<bool>(
                    title: Text('الوضع الفاتح (بيج)', style: TextStyle(color: AppColors.textPrimary)),
                    value: false,
                    groupValue: isDark,
                    activeColor: AppColors.accent,
                    onChanged: (v) {
                      ThemeService.toggleTheme(false);
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemBuilder: (_, i) {
        final item = items[i];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: item.onTap,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: item.color.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.icon, color: item.color, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.label,
                    style:  TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============ قائمة الإعدادات ============
  Widget _buildSettingsList(BuildContext context) {
    final items = [
      _ListItem('عن سوقنا', Icons.info_outline, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AboutScreen()),
        );
      }),
      _ListItem('شارك سوقنا', Icons.share_outlined, () {
        Share.share(
          'حمل تطبيق سوقنا - السوق الجزائري بين يديك!\n'
          'https://play.google.com/store/apps/details?id=com.souqna.app',
        );
      }),
      _ListItem('سياسة الخصوصية', Icons.description_outlined, () {
        launchUrl(
          Uri.parse('https://souqna.app/privacy'),
          mode: LaunchMode.externalApplication,
        );
      }),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Column(
            children: [
              ListTile(
                leading: Icon(item.icon, color: AppColors.accent, size: 22),
                title: Text(
                  item.label,
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                ),
                trailing:  Icon(Icons.arrow_back_ios_new,
                    color: AppColors.iconInactive, size: 14),
                onTap: item.onTap,
              ),
              if (i != items.length - 1)
                Divider(
                  color: AppColors.textSecondary.withValues(alpha: 0.2),
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }),
      ),
    );
  }

  // ============ قيّم سوقنا (ذهبي) ============
  Widget _rateCard(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openStore(context),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFB8860B), Color(0xFFE0A93B)],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE0A93B).withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child:  Icon(Icons.star, color: AppColors.textPrimary, size: 26),
              ),
              const SizedBox(width: 14),
               Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'قيّم سوقنا',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'رأيك يهمنا لتطوير التطبيق',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 12),
                    ),
                  ],
                ),
              ),
               Icon(Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openStore(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final inAppReview = InAppReview.instance;
      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
        return;
      }
      // fallback: افتح Play Store
      final uri = Uri.parse(
        'https://play.google.com/store/apps/details?id=com.souqna.app',
      );
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text('التطبيق لم يُنشر بعد في المتجر')),
        );
      }
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('التطبيق لم يُنشر بعد في المتجر')),
      );
    }
  }

  // ============ زر تسجيل الخروج ============
  Widget _logoutButton(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () async {
          final ok = await showDialog<bool>(
            context: context,
            builder: (ctx) => Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                backgroundColor: AppColors.card,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title:  Text(
                  'تسجيل الخروج',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content:  Text(
                  'هل أنت متأكد من تسجيل الخروج؟',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child:  Text(
                      'إلغاء',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    onPressed: () => Navigator.pop(ctx, true),
                    child:  Text(
                      'خروج',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          );
          if (ok != true) return;
          await AuthService.logout();
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.redAccent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.logout, color: Colors.redAccent),
        label: const Text(
          'تسجيل الخروج',
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Text(
        t,
        style:  TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _GridItem {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  _GridItem(this.label, this.icon, this.color, this.onTap);
}

class _ListItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  _ListItem(this.label, this.icon, this.onTap);
}
