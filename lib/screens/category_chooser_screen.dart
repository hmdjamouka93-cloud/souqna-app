import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import '../services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'brand_chooser_screen.dart';
import 'add_listing_screen.dart';

class CategoryChooserScreen extends StatefulWidget {
  final String mainCategoryId;
  final String mainCategoryName;
  const CategoryChooserScreen({
    super.key,
    required this.mainCategoryId,
    required this.mainCategoryName,
  });

  @override
  State<CategoryChooserScreen> createState() => _CategoryChooserScreenState();
}

class _CategoryChooserScreenState extends State<CategoryChooserScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('Categories')
          .where('mainCategoryId', isEqualTo: widget.mainCategoryId)
          .get();

      final list = snap.docs.map((d) {
        final x = d.data();
        return {
          'id': d.id,
          'name': (x['name'] ?? '').toString().trim(),
          'image': (x['image'] ?? '').toString(),
          'order': x['order'] ?? 0,
        };
      }).toList();

      // نرتبو بأمان (order ممكن يكون String ولا num)
      list.sort((a, b) {
        final oa = a['order'];
        final ob = b['order'];
        final na = oa is num ? oa.toInt() : int.tryParse(oa.toString()) ?? 0;
        final nb = ob is num ? ob.toInt() : int.tryParse(ob.toString()) ?? 0;
        return na.compareTo(nb);
      });

      if (!mounted) return;
      setState(() {
        _items = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  /// خريطة الأقسام اللي تحتاج تصريح
  static const _proCategories = {
    'معارض السيارات': 'showroom',
    'ايجار السيارات': 'rental',
    'معدات ثقيلة': 'equipment_shop',
    'قطع غيار': 'spare_parts_shop',
    'ملابس': 'clothing_store',
    'خدمات': 'service_shop',
  };

  void _showProRequiredDialog(String categoryName) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'تحتاج تصريح',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'قسم "$categoryName" مخصص لأصحاب المحلات والمعارض.\n\n'
            'إذا كنت صاحب معرض أو محل، تواصل معنا للحصول على التصريح.',
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 14, height: 1.6),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent),
              onPressed: () {
                Navigator.pop(ctx);
                _contactAdmin();
              },
              icon: const Icon(Icons.email_outlined,
                  color: Colors.white, size: 18),
              label: const Text('تواصل معنا',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _contactAdmin() async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri(
      scheme: 'mailto',
      path: 'souqna.dz@gmail.com',
      query: 'subject=طلب تصريح لصاحب معرض/محل',
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        messenger.showSnackBar(
          const SnackBar(
              content: Text('راسلنا على souqna.dz@gmail.com')),
        );
      }
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
            content: Text('راسلنا على souqna.dz@gmail.com')),
      );
    }
  }

  Future<void> _pickCategory(Map<String, dynamic> cat) async {
    final catName = (cat['name'] ?? '').toString().trim();

    // نتحققو واش القسم يحتاج تصريح
    final proType = _proCategories[catName];
    if (proType != null) {
      final isPro = await AuthService.isProUser(proType);
      if (!isPro) {
        if (!mounted) return;
        _showProRequiredDialog(catName);
        return;
      }
    }

    // نجيبو كل الـ SubCategories ونفلترو client-side
    final subSnap = await FirebaseFirestore.instance
        .collection('SubCategories')
        .get();

    final targetName = (cat['name'] ?? '').toString()
        .replaceAll(RegExp('[\u200B-\u200F\u202A-\u202E\u2066-\u2069\uFEFF]'), '')
        .replaceAll('\u00A0', ' ')
        .trim();

    final hasSubs = subSnap.docs.any((d) {
      final catId = (d.data()['categoryId'] ?? '').toString()
          .replaceAll(RegExp('[\u200B-\u200F\u202A-\u202E\u2066-\u2069\uFEFF]'), '')
          .replaceAll('\u00A0', ' ')
          .trim();
      return catId == targetName;
    });

    if (!mounted) return;

    if (hasSubs) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BrandChooserScreen(
            categoryId: cat['id'],
            categoryName: cat['name'],
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddListingScreen(
            categoryId: cat['id'],
            categoryName: cat['name'],
          ),
        ),
      );
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
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.mainCategoryName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }
    if (_items.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد أقسام',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (_, i) => _categoryCard(_items[i]),
    );
  }

  Widget _categoryCard(Map<String, dynamic> cat) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _pickCategory(cat),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.25),
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                cat['name'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
