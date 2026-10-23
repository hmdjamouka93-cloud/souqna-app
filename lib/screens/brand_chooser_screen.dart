import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import 'add_listing_screen.dart';
import 'listings_screen.dart';
import 'create_car_listing_screen.dart';
import 'add_listing_screen.dart';

class BrandChooserScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  const BrandChooserScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<BrandChooserScreen> createState() => _BrandChooserScreenState();
}

class _BrandChooserScreenState extends State<BrandChooserScreen> {
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
          .collection('SubCategories')
          .get();

      final list = <Map<String, dynamic>>[];
      for (final d in snap.docs) {
        final x = d.data();
        final catId = (x['categoryId'] ?? '').toString().trim();
        if (catId == widget.categoryName.trim()) {
          list.add({
            'id': d.id,
            'name': (x['name'] ?? '').toString().trim(),
            'image': (x['image'] ?? '').toString(),
            'order': x['order'] ?? 0,
          });
        }
      }

      // نرتبو بأمان (order ممكن يكون String ولا num)
      list.sort((a, b) {
        final oa = a['order'];
        final ob = b['order'];
        final na = oa is num ? oa.toInt() : int.tryParse(oa.toString()) ?? 0;
        final nb = ob is num ? ob.toInt() : int.tryParse(ob.toString()) ?? 0;
        return na.compareTo(nb);
      });

      // نزيدو "جميع الإعلانات" في الأول
      list.insert(0, {
        'id': '__all__',
        'name': 'جميع الإعلانات',
        'image': '',
        'order': -1,
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

  void _pickBrand(Map<String, dynamic> brand) {
    final id = (brand['id'] ?? '').toString();
    final name = (brand['name'] ?? '').toString();

    // "جميع الإعلانات" → ListingsScreen (كل إعلانات القسم)
    if (id == '__all__') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ListingsScreen(
            subCategoryId: '',
            brandName: name,
            categoryName: widget.categoryName,
          ),
        ),
      );
      return;
    }

    // باقي الأنواع → ListingsScreen (عرض الإعلانات)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ListingsScreen(
          subCategoryId: id,
          brandName: name,
          categoryName: widget.categoryName,
        ),
      ),
    );
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
            'اختر النوع - ${widget.categoryName}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
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
          'لا توجد أنواع',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (_, i) => _brandCard(_items[i]),
    );
  }


  Widget _brandCard(Map<String, dynamic> brand) {
    final imageUrl = (brand['image'] ?? '').toString();
    final brandName = (brand['name'] ?? '').toString().trim();

    // إلا كاين صورة → Stack (صورة + نص فوقها)
    if (imageUrl.isNotEmpty) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _pickBrand(brand),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: AppColors.card,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          brandName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // تدرج أسود في الأسفل
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.75),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 4,
                  left: 4,
                  child: Text(
                    brandName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(blurRadius: 4, color: Colors.black87),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // إلا ما كاينش صورة → نص في الوسط فقط
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _pickBrand(brand),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.2),
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                brandName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
