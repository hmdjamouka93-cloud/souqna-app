import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SouqnaApp());
}

/// ألوان التطبيق الموحدة
class AppColors {
  static const Color background = Color(0xFF0A0A0F);
  static const Color card = Color(0xFF1A1A22);
  static const Color accent = Color(0xFFA0285A);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0B8);
  static const Color iconInactive = Color(0xFF666670);
}

class SouqnaApp extends StatelessWidget {
  const SouqnaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Souqna',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.accent,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          secondary: AppColors.accent,
          surface: AppColors.card,
        ),
      ),
      home: const MainShell(),
    );
  }
}

/// الهيكل الرئيسي: NavBar + الصفحات
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: const HomeScreen(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: _buildFab(),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  /// زر إضافة إعلان (FAB)
  Widget _buildFab() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('إضافة إعلان جديد')),
          );
        },
        backgroundColor: AppColors.accent,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  /// الشريط السفلي
  Widget _buildBottomNav() {
    return BottomAppBar(
      color: AppColors.background,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      height: 62,
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(icon: Icons.home_outlined, label: 'الرئيسية', index: 0),
          _navItem(icon: Icons.accessibility_new, label: 'اعلاناتي', index: 1),
          const SizedBox(width: 56),
          _navItem(icon: Icons.more_horiz, label: 'المزيد', index: 3),
        ],
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isActive = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.accent : AppColors.iconInactive,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.accent : AppColors.iconInactive,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
