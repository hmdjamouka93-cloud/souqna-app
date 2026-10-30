import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';

class AppDrawer extends StatefulWidget {
  final Function(String) onCategoryTap;
  const AppDrawer({super.key, required this.onCategoryTap});
  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  static const List<_DrawerItem> _items = [
    _DrawerItem('سيارات', Icons.directions_car_outlined),
    _DrawerItem('شاحنات', Icons.local_shipping_outlined),
    _DrawerItem('دراجات', Icons.two_wheeler_outlined),
    _DrawerItem('حافلات', Icons.directions_bus_outlined),
    _DrawerItem('دراجات هوائية وسكوتر', Icons.pedal_bike_outlined),
    _DrawerItem('دراجات رباعية الدفع', Icons.terrain_outlined),
    _DrawerItem('معدات ثقيلة', Icons.construction_outlined),
    _DrawerItem('بحري', Icons.directions_boat_outlined),
    _DrawerItem('قطع غيار', Icons.settings_outlined),
    _DrawerItem('معارض السيارات', Icons.storefront_outlined),
    _DrawerItem('ايجار السيارات', Icons.car_rental_outlined),
    _DrawerItem('سكن للايجار', Icons.home_outlined),
    _DrawerItem('سكن للبيع', Icons.house_outlined),
    _DrawerItem('محلات للايجار', Icons.business_outlined),
    _DrawerItem('محلات للبيع', Icons.apartment_outlined),
    _DrawerItem('اراضي', Icons.landscape_outlined),
    _DrawerItem('اثاث', Icons.chair_outlined),
    _DrawerItem('هواتف', Icons.phone_android_outlined),
    _DrawerItem('حواسيب', Icons.laptop_outlined),
    _DrawerItem('اجهزة منزلية', Icons.kitchen_outlined),
    _DrawerItem('العاب فيديو', Icons.games_outlined),
    _DrawerItem('كاميرات', Icons.camera_alt_outlined),
    _DrawerItem('اجهزة ذكية', Icons.watch_outlined),
    _DrawerItem('ملابس نسائية', Icons.checkroom_outlined),
    _DrawerItem('ملابس رجالية', Icons.man_outlined),
    _DrawerItem('ملابس اطفال', Icons.child_care_outlined),
    _DrawerItem('اكسسوارات', Icons.diamond_outlined),
    _DrawerItem('ملابس اخرى', Icons.shopping_bag_outlined),
    _DrawerItem('الخياطة والأزياء', Icons.cut_outlined),
    _DrawerItem('خدمات', Icons.handyman_outlined),
    _DrawerItem('خدمات الصيانة', Icons.build_outlined),
    _DrawerItem('خدمات البناء', Icons.engineering_outlined),
    _DrawerItem('الخدمات الرقمية', Icons.computer_outlined),
    _DrawerItem('النقل والتوصيل', Icons.local_shipping_outlined),
    _DrawerItem('المناسبات والأعراس', Icons.celebration_outlined),
    _DrawerItem('المأكولات والمشروبات', Icons.restaurant_outlined),
    _DrawerItem('التعليم والدروس الخصوصية', Icons.school_outlined),
    _DrawerItem('الرياضة واللياقة البدنية', Icons.fitness_center_outlined),
    _DrawerItem('الصحة والجمال', Icons.spa_outlined),
    _DrawerItem('السفر والسياحة', Icons.flight_outlined),
    _DrawerItem('خدمات السيارات', Icons.car_repair_outlined),
    _DrawerItem('النظافة ومكافحة الحشرات', Icons.cleaning_services_outlined),
    _DrawerItem('الخدمات القانونية والإدارية', Icons.gavel_outlined),
    _DrawerItem('الفلاحة والثروة الحيوانية', Icons.agriculture_outlined),
    _DrawerItem('الدعاية والإعلان والطباعة', Icons.print_outlined),
    _DrawerItem('الأمن والحراسة', Icons.security_outlined),
    _DrawerItem('رعاية الأطفال والمسنين', Icons.elderly_outlined),
    _DrawerItem('الطاقة الشمسية', Icons.solar_power_outlined),
    _DrawerItem('كلاب وقطط', Icons.pets_outlined),
    _DrawerItem('طيور', Icons.flutter_dash_outlined),
    _DrawerItem('مواشي ودواب', Icons.agriculture_outlined),
    _DrawerItem('حيوانات أخرى', Icons.pest_control_outlined),
    _DrawerItem('الوظائف', Icons.work_outline),
    _DrawerItem('التبرعات والعمل الخيري', Icons.volunteer_activism_outlined),
    _DrawerItem('المفقودات', Icons.search_outlined),
  ];

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      width: MediaQuery.of(context).size.width * 0.82,
      child: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(8, 8, 16, 8), child: Row(children: [
          IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 24), onPressed: () => Navigator.pop(context)),
          const Spacer(),
          const Text('الأقسام', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ])),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: TextField(
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _searchQuery = v),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(hintText: 'بحث في الأقسام', hintStyle:  TextStyle(color: AppColors.textSecondary), prefixIcon:  Icon(Icons.search, color: AppColors.textSecondary), filled: true, fillColor: AppColors.card, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(vertical: 12)),
        )),
        StreamBuilder<User?>(
          stream: AuthService.authStateChanges,
          builder: (context, snapshot) {
            final logged = snapshot.connectionState == ConnectionState.waiting ? AuthService.isLoggedIn : snapshot.data != null;
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              leading: Icon(logged ? Icons.person_outline : Icons.login_outlined, color: AppColors.accent, size: 22),
              title: Text(logged ? 'حسابي' : 'تسجيل الدخول', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.right),
              trailing:  Icon(Icons.arrow_back_ios_new, color: AppColors.textSecondary, size: 14),
              onTap: () {
                Navigator.pop(context);
                if (logged) { Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())); }
                else { Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())); }
              },
            );
          },
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildList(context)),
      ])),
    );
  }

  Widget _buildList(BuildContext context) {
    final filteredItems = _items.where((item) => item.name.contains(_searchQuery) || item.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    if (filteredItems.isEmpty) { return const Center(child: Text('لا توجد أقسام مطابقة', style: TextStyle(color: Colors.white70))); }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: filteredItems.length,
      separatorBuilder: (_, _) => const Divider(color: Colors.white12, height: 1, indent: 16, endIndent: 16),
      itemBuilder: (context, i) {
        final item = filteredItems[i];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          leading: Icon(item.icon, color: AppColors.accent, size: 22),
          title: Text(item.name, style: const TextStyle(color: Colors.white, fontSize: 15), textAlign: TextAlign.right),
          trailing:  Icon(Icons.arrow_back_ios_new, color: AppColors.textSecondary, size: 14),
          onTap: () { Navigator.pop(context); widget.onCategoryTap(item.name); },
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
