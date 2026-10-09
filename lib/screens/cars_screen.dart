import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import 'listings_screen.dart';

class CarsScreen extends StatefulWidget {
  const CarsScreen({super.key});
  @override
  State<CarsScreen> createState() => _CarsScreenState();
}

class _CarsScreenState extends State<CarsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _brands = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('SubCategories')
          .where('categoryId', isEqualTo: 'سيارات')
          .get();
      final list = snap.docs.map((d) {
        final x = d.data();
        return {
          'id': d.id,
          'name': (x['name'] ?? '').toString(),
          'image': (x['image'] ?? '').toString(),
          'order': (x['order'] ?? 0) is int ? x['order'] : 0,
        };
      }).toList();
      list.sort((a, b) => (a['order'] as int).compareTo(b['order'] as int));
      if (!mounted) return;
      setState(() {
        _brands = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  static const _bigLogos = [
    'جيلي', 'شيري', 'فوتون', 'بي واي دي', 'لاند روفر', 'جاكوار',
    'مارسيدس', 'مايباخ', 'لوتس', 'هامر', 'جاك', 'هافال',
    'فورتينغ', 'بروتون', 'جيتور', 'ايسوزو', 'كرايسلر',
  ];

  double _logoSize(String name) {
    return _bigLogos.contains(name) ? 80.0 : 45.0;
  }

  void _openBrand(Map<String, dynamic> b) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ListingsScreen(
          subCategoryId: b['id'],
          brandName: b['name'],
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
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('سيارات',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 8),
            _buildAdBanner(),
            const SizedBox(height: 16),
            _buildSectionTitle('الأقسام الفرعية'),
            _buildContent(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAdBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3), width: 1),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.campaign_outlined, color: AppColors.accent, size: 30),
            SizedBox(height: 6),
            Text('مساحة إعلانية',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Text(title,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }
    if (_brands.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Text('لا توجد ماركات',
              style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemCount: _brands.length,
      itemBuilder: (context, i) => _brandCard(_brands[i]),
    );
  }

  Widget _brandCard(Map<String, dynamic> b) {
    final name = (b['name'] as String).trim();
    final image = (b['image'] as String).trim();

    return GestureDetector(
      onTap: () => _openBrand(b),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(name,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(4),
              child: SizedBox(
                width: _logoSize(name),
                height: _logoSize(name),
                child: image.isEmpty
                    ? const Icon(Icons.directions_car, color: Colors.white24, size: 32)
                    : Image.network(
                        image,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.directions_car, color: Colors.white24, size: 32),
                      ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
