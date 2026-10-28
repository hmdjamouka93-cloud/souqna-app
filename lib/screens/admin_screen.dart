import 'package:flutter/material.dart';
import '../main.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'لوحة التحكم (Admin)',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _menuCard(Icons.report, 'البلاغات', 'مراجعة إعلانات ومستخدمين', () {}),
            _menuCard(Icons.block, 'الحظر', 'حظر مستخدمين أو متاجر', () {}),
            _menuCard(Icons.restore, 'استرجاع', 'استرجاع متجر أو بروفايل محذوف', () {}),
            _menuCard(Icons.star, 'إدارة VIP', 'ترقية إعلانات لمدة معينة', () {}),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Card(
      color: AppColors.card,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: AppColors.accent, size: 30),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 14),
        onTap: onTap,
      ),
    );
  }
}
