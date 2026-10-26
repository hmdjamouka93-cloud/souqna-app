import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import 'brand_chooser_screen.dart';
import 'add_listing_screen.dart';
import 'create_car_listing_screen.dart';
import 'showrooms_list_screen.dart';
import 'rentals_list_screen.dart';
import 'create_store_screen.dart';
import 'create_product_screen.dart';
import '../services/store_service.dart';
import '../services/service_provider_service.dart';
import '../services/auth_service.dart';
import '../services/auth_gate.dart';
import 'create_provider_screen.dart';
import 'create_service_screen.dart';

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
            .get();

        final targetId = widget.mainCategoryId.trim();
        final targetName = widget.mainCategoryName.trim();

        final list = snap.docs.where((d) {
          final x = d.data();
          final mId = (x['mainCategoryId'] ?? '').toString().trim();
          return mId == targetId || mId == targetName;
        }).map((d) {
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
  Future<void> _pickCategory(Map<String, dynamic> cat) async {
    if (cat['name'].toString().trim() == 'معارض السيارات') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ShowroomsListScreen()),
      );
      return;
    }
    if (cat['name'].toString().trim() == 'ايجار السيارات') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RentalsListScreen()),
      );
      return;
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

    // ==== أقسام الملابس: نتحققو من وجود متجر ====
    const clothingCats = ['ملابس نسائية', 'ملابس رجالية', 'ملابس اطفال', 'اكسسوارات'];
    if (clothingCats.contains(targetName)) {
      final store = await StoreService.getMyStore(targetName);
      if (!mounted) return;
      if (store == null) {
        await showDialog(
          context: context,
          builder: (ctx) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              backgroundColor: AppColors.card,
              title: const Text('لا يمكنك الإعلان هنا',
                  style: TextStyle(color: Colors.white)),
              content: const Text(
                'لا يمكنك إضافة إعلان في هذا القسم إلا إذا كنت تملك متجراً.\n\n'
                'قم بإنشاء متجرك أولاً لعرض منتجاتك هنا.\n\n'
                'إذا لم ترغب في إنشاء متجر، يمكنك إضافة منتجاتك في قسم "ملابس أخرى".',
                style: TextStyle(color: Colors.white70, height: 1.6),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('إلغاء',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateStoreScreen(
                          categoryName: targetName,
                        ),
                      ),
                    );
                  },
                  child: const Text('إنشاء متجر',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
        return;
      }
      // عندو متجر → نضيفو منتج مباشرة
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CreateProductScreen(
            storeId: (store['id'] ?? '').toString(),
          ),
        ),
      );
      return;
    }
    // ==== نهاية check ====

    if (hasSubs) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BrandChooserScreen(
            categoryId: cat['id'],
            categoryName: cat['name'],
            isAddMode: true,
          ),
        ),
      );
    } else {
      final vehicleCats = ['سيارات', 'شاحنات', 'حافلات', 'دراجات', 'دراجات رباعية الدفع', 'دراجات هوائية وسكوتر', 'بحري'];
      if (vehicleCats.contains(cat['name'].toString().trim())) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CreateCarListingScreen(
              categoryName: cat['name'].toString().trim(),
              brandName: '',
              subCategoryId: '',
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
