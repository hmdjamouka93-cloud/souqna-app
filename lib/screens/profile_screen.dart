import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/showroom_service.dart';
import 'create_showroom_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true;
  String? _email;
  String? _phone;
  String? _name;
  String? _storeName;
  List<String> _proTypes = [];
  Map<String, dynamic>? _showroom;
  int _count = 0;
  String? _error;

  static const _bg = Color(0xFF1E2128);
  static const _card = Color(0xFF2A2E36);
  static const _accent = Color(0xFFA0285A);
  static const _textSec = Color(0xFFB0B0B8);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final u = AuthService.currentUser;
      if (u == null) {
        if (mounted) Navigator.pop(context);
        return;
      }
      final data = await AuthService.getUserData();
      final count = await AuthService.countMyListings();
      if (!mounted) return;
      final showroom = await ShowroomService.getMyShowroom();
      if (!mounted) return;
      setState(() {
        _email = u.email;
        _phone = data?['phone'] ?? '—';
        _name = data?['name'] ?? '';
        _storeName = (data?['storeName'] ?? '').toString();
        _proTypes = (data?['proTypes'] as List?)?.cast<String>() ?? [];
        _showroom = showroom;
        _count = count;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'خطأ في تحميل البيانات';
        _loading = false;
      });
    }
  }

  Future<void> _openShowroom() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateShowroomScreen(existing: _showroom),
      ),
    );
    if (result == true && mounted) _load();
  }

  Future<void> _editStoreName() async {
    final ctrl = TextEditingController(text: _storeName ?? '');
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: _card,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text('اسم المعرض / المحل',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: ctrl,
            maxLength: 40,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'مثال: معرض النخبة للسيارات',
              hintStyle: TextStyle(color: _textSec),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: _textSec),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: _accent),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء',
                  style: TextStyle(color: _textSec)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: _accent),
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('حفظ',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (newName == null) return;
    await AuthService.updateStoreName(newName);
    if (!mounted) return;
    setState(() => _storeName = newName);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تحديث اسم المحل')),
    );
  }

  Future<void> _editPhone() async {
    final ctrl = TextEditingController(text: _phone == '—' ? '' : _phone);
    final newPhone = await showDialog<String>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: _card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('تعديل رقم الهاتف',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: ctrl,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: Colors.white),
            textDirection: TextDirection.ltr,
            decoration: const InputDecoration(
              hintText: '0555 12 34 56',
              hintStyle: TextStyle(color: _textSec),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: _textSec),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: _accent),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(color: _textSec)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _accent),
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('حفظ', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (newPhone == null || newPhone.isEmpty) return;
    if (newPhone.length < 9) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رقم الهاتف قصير')),
      );
      return;
    }
    await AuthService.updatePhone(newPhone);
    if (!mounted) return;
    setState(() => _phone = newPhone);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تحديث الرقم')),
    );
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: _card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('تسجيل الخروج',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text('هل أنت متأكد من تسجيل الخروج؟',
              style: TextStyle(color: _textSec)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء', style: TextStyle(color: _textSec)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('خروج', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _bg,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('حسابي',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: _accent))
            : _error != null
                ? Center(
                    child: Text(_error!,
                        style: const TextStyle(color: Colors.redAccent)))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 45,
                            backgroundColor: _accent.withValues(alpha: 0.2),
                            child: const Icon(Icons.person,
                                size: 50, color: _accent),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            (_name == null || _name!.isEmpty) ? 'مستخدم' : _name!,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 30),

                        _infoTile(
                          icon: Icons.email_outlined,
                          label: 'الإيميل',
                          value: _email ?? '—',
                        ),
                        const SizedBox(height: 12),
                        _infoTile(
                          icon: Icons.phone_outlined,
                          label: 'رقم الهاتف',
                          value: _phone ?? '—',
                          onEdit: _editPhone,
                        ),
                        const SizedBox(height: 12),
                        if (_proTypes.isNotEmpty) ...[
                          _infoTile(
                            icon: Icons.storefront,
                            label: 'اسم المعرض / المحل',
                            value: (_storeName == null || _storeName!.isEmpty)
                                ? 'لم يُحدَّد بعد'
                                : _storeName!,
                            onEdit: _editStoreName,
                          ),
                          const SizedBox(height: 12),
                        ],
                        _infoTile(
                          icon: Icons.list_alt,
                          label: 'عدد إعلاناتي',
                          value: '$_count',
                        ),

                        if (_proTypes.contains('showroom')) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 52,
                            child: OutlinedButton.icon(
                              onPressed: _openShowroom,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: _accent, width: 1.5),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.storefront,
                                  color: _accent),
                              label: Text(
                                _showroom == null
                                    ? 'إنشاء معرضي'
                                    : 'إدارة معرضي',
                                style: const TextStyle(
                                    color: _accent,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: _logout,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.redAccent),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.logout, color: Colors.redAccent),
                            label: const Text('تسجيل الخروج',
                                style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: _accent, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(color: _textSec, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined,
                  color: _textSec, size: 20),
            ),
        ],
      ),
    );
  }
}
