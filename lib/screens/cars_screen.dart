import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';

class CarsScreen extends StatelessWidget {
  const CarsScreen({super.key});

  Future<QuerySnapshot> _loadBrands() {
    return FirebaseFirestore.instance
        .collection('SubCategories')
        .where('categoryId', isEqualTo: 'سيارات')
        .get();
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
            _buildBrandsGrid(),
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

  Widget _buildBrandsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemCount: 9,
      itemBuilder: (context, i) => Container(
        color: Colors.red,
        child: Center(
          child: Text(
            'BOX $i',
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(List<QueryDocumentSnapshot> docs) {
    final sorted = List<QueryDocumentSnapshot>.from(docs)
      ..sort((a, b) {
        final ao = (a.data() as Map)['order'] ?? 0;
        final bo = (b.data() as Map)['order'] ?? 0;
        return (ao as int).compareTo(bo as int);
      });

    final List<_Brand> brands = [];
    brands.add(const _Brand(name: 'جميع الإعلانات', image: '__all__'));
    for (final doc in sorted) {
      final data = doc.data() as Map<String, dynamic>;
      brands.add(_Brand(
        name: (data['name'] ?? '').toString(),
        image: (data['image'] ?? '').toString(),
      ));
    }
    brands.add(const _Brand(name: 'سيارات أخرى', image: '__other__'));

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
      itemCount: brands.length,
      itemBuilder: (context, i) => _brandCard(brands[i]),
    );
  }

  Widget _brandCard(_Brand brand) {
    if (brand.image == '__other__') {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.more_horiz, color: AppColors.accent, size: 32),
              SizedBox(height: 6),
              Text('سيارات أخرى',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }

    if (brand.image == '__all__') {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Center(
            child: Text('جميع الإعلانات',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.bold)),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 6),
          Text(brand.name,
              style: const TextStyle(
                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              height: _logoHeight(brand.name),
              width: double.infinity,
              child: Center(child: _buildLogo(brand)),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  double _logoHeight(String name) {
    const large = ['دودج', 'كرايسلر', 'بنتلي', 'ماكلارين', 'أستون مارتن', 'هافال'];
    const small = ['شيري', 'جيلي'];
    if (large.contains(name)) return 65;
    if (small.contains(name)) return 28;
    return 40;
  }

  Widget _buildLogo(_Brand brand) {
    if (brand.image.isEmpty) {
      return const Icon(Icons.directions_car, color: Colors.white24, size: 32);
    }
    return Image.network(
      brand.image,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const SizedBox(
          width: 28,
          height: 28,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.directions_car, color: Colors.white24, size: 32),
    );
  }
}

class _Brand {
  final String name;
  final String image;
  const _Brand({required this.name, required this.image});
}
