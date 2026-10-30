import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import 'listings_screen.dart';

class CarsScreen extends StatefulWidget {
  final String categoryName;
  final String screenTitle;
  const CarsScreen({
    super.key,
    this.categoryName = 'سيارات',
    this.screenTitle = 'سيارات',
  });

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
          .where('categoryId', isEqualTo: widget.categoryName)
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

      // نزيدو "جميع الإعلانات" في البداية
      list.insert(0, {
        'id': '',
        'name': 'جميع الإعلانات',
        'image': '',
        'order': -1,
      });
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

  // أقسام كتستعمل صور (ماشي شعارات) → cover + حجم كبير
  static const _photoCategories = [
    'قطع غيار',
    'معدات ثقيلة',
    'معارض السيارات',
    'ايجار السيارات',
  ];

  static const _bigLogos = [
    'جيلي', 'شيري', 'فوتون', 'بي واي دي', 'لاند روفر', 'جاكوار',
    'مارسيدس', 'مايباخ', 'لوتس', 'هامر', 'جاك', 'هافال',
    'فورتينغ', 'بروتون', 'جيتور', 'ايسوزو', 'كرايسلر',
  ];

  double _logoSize(String name) {
    if (_photoCategories.contains(widget.categoryName)) return 100.0;
    return _bigLogos.contains(name) ? 80.0 : 45.0;
  }

  void _openBrand(Map<String, dynamic> b) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ListingsScreen(
          subCategoryId: b['id'],
          brandName: b['name'],
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
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(widget.screenTitle,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
      child:  Center(
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
    final isPhoto = _photoCategories.contains(widget.categoryName);

    // "جميع الإعلانات"
    if (name == 'جميع الإعلانات') {
      return GestureDetector(
        onTap: () => _openBrand(b),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'جميع الإعلانات',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // "أنواع أخرى" (سيارات اخرى، شاحنات أخرى، إلخ)
    final isOther = name.contains('أخرى') ||
        name.contains('اخرى') ||
        name.contains('معدات أخرى');

    // ============ أقسام الصور (قطع غيار، معدات، معارض، إيجار) ============
    if (isPhoto) {
      return GestureDetector(
        onTap: () => _openBrand(b),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (image.isNotEmpty)
                CachedNetworkImage(imageUrl: 
                  image,
                  fit: BoxFit.cover,
                  errorWidget: (_, _, _) => Container(
                    color: Colors.black26,
                    child: const Icon(Icons.image_outlined,
                        color: Colors.white24, size: 40),
                  ),
                )
              else
                Container(
                  color: Colors.black26,
                  child: const Icon(Icons.image_outlined,
                      color: Colors.white24, size: 40),
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
              // النص في الأسفل
              Positioned(
                bottom: 8,
                right: 6,
                left: 6,
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black87)],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ============ "أنواع أخرى" (نص وردي في الوسط) ============
    if (isOther) {
      return GestureDetector(
        onTap: () => _openBrand(b),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('•••',
                    style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      );
    }

    // ============ شعارات (تويوتا، بيجو، إلخ) ============
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
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
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
                    ? const Icon(Icons.directions_car,
                        color: Colors.white24, size: 32)
                    : CachedNetworkImage(imageUrl: 
                        image,
                        fit: BoxFit.contain,
                        errorWidget: (_, _, _) => const Icon(
                            Icons.directions_car,
                            color: Colors.white24,
                            size: 32),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
