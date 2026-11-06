import 'package:flutter/material.dart';
import '../services/language_service.dart';

import '../main.dart';
import 'admin_block_screen.dart';
import 'admin_reports_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
                appBar: AppBar(
                    elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon:  Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title:  Text(
            LanguageService.trCategory(LanguageService.trCategory('لوحة التحكم (Admin)')),
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _menuCard(Icons.report, LanguageService.trCategory('البلاغات'), LanguageService.trCategory('مراجعة إعلانات ومستخدمين'), () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminReportsScreen()));
            }),
            _menuCard(Icons.block, LanguageService.trCategory('الحظر'), LanguageService.trCategory('حظر مستخدمين أو متاجر'), () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminBlockScreen()));
            }),
            _menuCard(Icons.restore, LanguageService.trCategory('استرجاع'), LanguageService.trCategory('استرجاع متجر أو بروفايل محذوف'), () {}),
            _menuCard(Icons.star, LanguageService.trCategory('إدارة VIP'), LanguageService.trCategory('ترقية إعلانات لمدة معينة'), () {}),
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
        title: Text(title, style:  TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style:  TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        trailing:  Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary, size: 14),
        onTap: onTap,
      ),
    );
  }
}
