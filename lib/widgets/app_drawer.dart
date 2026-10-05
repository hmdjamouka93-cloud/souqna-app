import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  static const List<_DrawerItem> _items = [
    _DrawerItem('عقارات تجارية للإيجار', Icons.apartment_outlined),
    _DrawerItem('عقارات تجارية للبيع', Icons.business_outlined),
    _DrawerItem('عقارات سكنية للإيجار', Icons.home_outlined),
    _DrawerItem('أراضي', Icons.landscape_outlined),
    _DrawerItem('عقارات سكنية للبيع', Icons.house_outlined),
    _DrawerItem('أثاث', Icons.chair_outlined),
    _DrawerItem('سيارات', Icons.directions_car_outlined),
    _DrawerItem('دراجات', Icons.two_wheeler_outlined),
    _DrawerItem('إيجار السيارات', Icons.car_rental_outlined),
    _DrawerItem('أدوات بحرية', Icons.directions_boat_outlined),
    _DrawerItem('قطع غيار', Icons.settings_outlined),
    _DrawerItem('خدمات السيارات', Icons.build_outlined),
    _DrawerItem('إلكترونيات', Icons.phone_android_outlined),
    _DrawerItem('أجهزة منزلية', Icons.kitchen_outlined),
    _DrawerItem('ملابس', Icons.checkroom_outlined),
    _DrawerItem('خدمات', Icons.handyman_outlined),
    _DrawerItem('وظائف', Icons.work_outline),
    _DrawerItem('حيوانات و طيور', Icons.pets_outlined),
    _DrawerItem('الرياضة واللياقة', Icons.sports_soccer_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      width: MediaQuery.of(context).size.width * 0.82,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearch(),
                                            _buildAuthTile(context),
            const SizedBox(height: 8),
            Expanded(child: _buildList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          const Text(
            'الأقسام',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'بحث في الأقسام',
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildAuthTile(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.authStateChanges,
      builder: (context, snapshot) {
        final logged = snapshot.connectionState == ConnectionState.waiting
            ? AuthService.isLoggedIn
            : snapshot.data != null;
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          leading: Icon(
            logged ? Icons.person_outline : Icons.login_outlined,
            color: AppColors.accent,
            size: 22,
          ),
          title: Text(
            logged ? 'حسابي' : 'تسجيل الدخول',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
          trailing: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textSecondary,
            size: 14,
          ),
          onTap: () {
            Navigator.pop(context);
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
        );
      },
    );
  }

  Widget _buildList(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: _items.length,
      separatorBuilder: (_, _) => const Divider(
        color: Colors.white12, height: 1, indent: 16, endIndent: 16,
      ),
      itemBuilder: (context, i) {
        final item = _items[i];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          leading: Icon(item.icon, color: AppColors.accent, size: 22),
          title: Text(
            item.name,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            textAlign: TextAlign.right,
          ),
          trailing: const Icon(Icons.arrow_back_ios_new, color: AppColors.textSecondary, size: 14),
          onTap: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${item.name} - قريباً')),
            );
          },
        );
      },
    );
  }
}

class _DrawerItem {
  final String name;
  final IconData icon;
  const _DrawerItem(this.name, this.icon);
}
