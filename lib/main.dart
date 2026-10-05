import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';
import 'widgets/app_drawer.dart';
import 'services/auth_gate.dart';
import 'screens/more_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SouqnaApp());
}

class AppColors {
  static const Color background = Color(0xFF1E2128);
  static const Color card = Color(0xFF2A2E36);
  static const Color accent = Color(0xFFA0285A);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0B8);
  static const Color iconInactive = Color(0xFF7A7A85);
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
        drawer: const AppDrawer(),
        body: const HomeScreen(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: _buildFab(),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildFab() {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      child: FloatingActionButton(
        onPressed: () {
          requireAuth(
            context,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('إضافة إعلان جديد - قريباً')),
              );
            },
            message: 'يجب تسجيل الدخول لإضافة إعلان',
          );
        },
        backgroundColor: AppColors.accent,
        elevation: 8,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomAppBar(
      color: AppColors.background,
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      height: 65,
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItemIcon(Icons.home_outlined, 'الرئيسية', 0),
          _navItemImage('images/icon_myads.png', 'اعلاناتي', 1),
          const SizedBox(width: 55),
          _navItemIcon(Icons.favorite_border, 'المفضلة', 2),
          _navItemIcon(Icons.more_horiz, 'المزيد', 3),
        ],
      ),
    );
  }

  Widget _navItemIcon(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    return InkWell(
      onTap: () {
        if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MoreScreen()),
          );
        } else {
          setState(() => _currentIndex = index);
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.accent : AppColors.iconInactive,
              size: 23,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.accent : AppColors.iconInactive,
                fontSize: 9,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItemImage(String asset, String label, int index) {
    final isActive = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                isActive ? AppColors.accent : AppColors.iconInactive,
                BlendMode.srcIn,
              ),
              child: Image.asset(
                asset,
                width: 23,
                height: 23,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.accent : AppColors.iconInactive,
                fontSize: 9,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
