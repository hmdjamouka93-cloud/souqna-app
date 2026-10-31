import 'package:flutter/material.dart';
import '../main.dart';
import '../services/block_service.dart';

class MyBlockedUsersScreen extends StatefulWidget {
  const MyBlockedUsersScreen({super.key});
  @override
  State<MyBlockedUsersScreen> createState() => _MyBlockedUsersScreenState();
}

class _MyBlockedUsersScreenState extends State<MyBlockedUsersScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _blocks = [];
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await BlockService.getMyBlockedUsers();
    if (!mounted) return;
    setState(() { _blocks = list; _loading = false; });
  }
  Future<void> _unblock(String docId) async {
    final ok = await BlockService.unblockUser(docId);
    if (!mounted) return;
    if (ok) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إلغاء الحظر'))); _load(); }
  }
  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection: TextDirection.rtl, child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.background, elevation: 0, centerTitle: true, leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)), title: const Text('المحظورين', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
      body: _loading ? const Center(child: CircularProgressIndicator(color: AppColors.accent)) : _blocks.isEmpty ? Center(child: Text('لا يوجد مستخدمون محظورون.', style: TextStyle(color: AppColors.textSecondary))) : ListView.builder(padding: const EdgeInsets.all(16), itemCount: _blocks.length, itemBuilder: (context, i) {
        final b = _blocks[i];
        return Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)), child: ListTile(leading: const Icon(Icons.person_off, color: Colors.redAccent, size: 28), title: Text(b['blockedName'], style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)), trailing: TextButton(onPressed: () => _unblock(b['id']), child: const Text('إلغاء الحظر', style: TextStyle(color: AppColors.accent)))));
      }),
    ));
  }
}
