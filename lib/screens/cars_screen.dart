import 'package:flutter/material.dart';
import '../main.dart';

class CarsScreen extends StatelessWidget {
  const CarsScreen({super.key});

  static const List<_Brand> _brands = [
    _Brand(name: 'جميع الإعلانات', slug: '', wiki: '', asset: ''),
    _Brand(name: 'رونو', slug: 'renault', wiki: '', asset: ''),
    _Brand(name: 'بيجو', slug: 'peugeot', wiki: '', asset: ''),
    _Brand(name: 'سيتروين', slug: 'citroen', wiki: '', asset: ''),
    _Brand(name: 'سيات', slug: 'seat', wiki: '', asset: ''),
    _Brand(name: 'فولكس واجن', slug: 'volkswagen', wiki: '', asset: ''),
    _Brand(name: 'تويوتا', slug: 'toyota', wiki: '', asset: ''),
    _Brand(name: 'هيونداي', slug: 'hyundai', wiki: '', asset: ''),
    _Brand(name: 'كيا', slug: 'kia', wiki: '', asset: ''),
    _Brand(name: 'نيسان', slug: 'nissan', wiki: '', asset: ''),
    _Brand(name: 'فيات', slug: 'fiat', wiki: '', asset: ''),
    _Brand(name: 'سكودا', slug: 'skoda', wiki: '', asset: ''),
    _Brand(name: 'فورد', slug: 'ford', wiki: '', asset: ''),
    _Brand(name: 'شيفروليه', slug: 'chevrolet', wiki: '', asset: ''),
    _Brand(name: 'سوزوكي', slug: 'suzuki', wiki: '', asset: ''),
    _Brand(name: 'ميتسوبيشي', slug: 'mitsubishi', wiki: '', asset: ''),
    _Brand(name: 'مازدا', slug: 'mazda', wiki: '', asset: ''),
    _Brand(name: 'هوندا', slug: 'honda', wiki: '', asset: ''),
    _Brand(name: 'إم جي', slug: 'mg', wiki: '', asset: ''),
    _Brand(name: 'مرسيدس', slug: '', wiki: '', asset: 'images/logos/mercedes.png'),
    _Brand(name: 'بي إم دبليو', slug: 'bmw', wiki: '', asset: ''),
    _Brand(name: 'أودي', slug: 'audi', wiki: '', asset: ''),
    _Brand(name: 'فولفو', slug: 'volvo', wiki: '', asset: ''),
    _Brand(name: 'جيب', slug: 'jeep', wiki: '', asset: ''),
    _Brand(name: 'إنفينيتي', slug: 'infiniti', wiki: '', asset: ''),
    _Brand(name: 'بورش', slug: 'porsche', wiki: '', asset: ''),
    _Brand(name: 'تسلا', slug: 'tesla', wiki: '', asset: ''),
    _Brand(name: 'كاديلاك', slug: 'cadillac', wiki: '', asset: ''),
    _Brand(name: 'كرايسلر', slug: 'chrysler', wiki: '', asset: ''),
    _Brand(name: 'أوبل', slug: 'opel', wiki: '', asset: ''),
    _Brand(name: 'داسيا', slug: 'dacia', wiki: '', asset: ''),
    _Brand(name: 'بوغاتي', slug: 'bugatti', wiki: '', asset: ''),
    _Brand(name: 'لامبورغيني', slug: 'lamborghini', wiki: '', asset: ''),
    _Brand(name: 'فيراري', slug: 'ferrari', wiki: '', asset: ''),
    _Brand(name: 'مازيراتي', slug: 'maserati', wiki: '', asset: ''),
    _Brand(name: 'بنتلي', slug: 'bentley', wiki: '', asset: ''),
    _Brand(name: 'رولز رويس', slug: 'rollsroyce', wiki: '', asset: ''),
    _Brand(name: 'أستون مارتن', slug: 'astonmartin', wiki: '', asset: ''),
    _Brand(name: 'ماكلارين', slug: 'mclaren', wiki: '', asset: ''),
    _Brand(name: 'أكيورا', slug: 'acura', wiki: '', asset: ''),
    _Brand(name: 'ميني', slug: 'mini', wiki: '', asset: ''),
    _Brand(name: 'سمارت', slug: 'smart', wiki: '', asset: ''),
    _Brand(name: 'لكزس', slug: '', wiki: '', asset: 'images/logos/lexus.png'),
    _Brand(name: 'لاند روفر', slug: '', wiki: '', asset: 'images/logos/landrover.png'),
    _Brand(name: 'ألفا روميو', slug: '', wiki: '', asset: 'images/logos/alfaromeo.png'),
    _Brand(name: 'جينيسيس', slug: '', wiki: '', asset: 'images/logos/genesis.png'),
    _Brand(name: 'دودج', slug: '', wiki: '', asset: 'images/logos/dodge.png'),
    _Brand(name: 'لينكولن', slug: '', wiki: '', asset: 'images/logos/lincoln.png'),
    _Brand(name: 'روفر', slug: '', wiki: '', asset: 'images/logos/rover.png'),
    _Brand(name: 'لوتس', slug: '', wiki: '', asset: 'images/logos/lotus.png'),
    _Brand(name: 'كوبرا', slug: '', wiki: '', asset: 'images/logos/cupra.png'),
    _Brand(name: 'إيسوزو', slug: '', wiki: '', asset: 'images/logos/isuzu.png'),
    _Brand(name: 'جيلي', slug: '', wiki: '', asset: 'images/logos/geely.png'),
    _Brand(name: 'شيري', slug: '', wiki: '', asset: 'images/logos/chery.png'),
    _Brand(name: 'هافال', slug: '', wiki: '', asset: 'images/logos/haval.png'),
    _Brand(name: 'سانغ يونغ', slug: '', wiki: '', asset: 'images/logos/ssangyong.png'),
    _Brand(name: 'فينفاست', slug: '', wiki: '', asset: 'images/logos/vinfast.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context),
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text('سيارات',
        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white, size: 24),
          onPressed: () {},
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.0,
      ),
      itemCount: _brands.length,
      itemBuilder: (context, i) => _brandCard(_brands[i]),
    );
  }

  Widget _brandCard(_Brand brand) {
    final isAll = brand.slug.isEmpty && brand.wiki.isEmpty && brand.asset.isEmpty;
    if (isAll) {
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
              style: TextStyle(color: AppColors.accent, fontSize: 13,
                fontWeight: FontWeight.bold)),
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 6),
            Text(brand.name,
              style: const TextStyle(color: Colors.white, fontSize: 12,
                fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                height: 40,
                child: Center(child: _buildLogo(brand)),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(_Brand brand) {
    if (brand.asset.isNotEmpty) {
      return Image.asset(brand.asset, fit: BoxFit.contain);
    }
    final url = brand.slug.isNotEmpty
        ? 'https://images.weserv.nl/?url=cdn.simpleicons.org/${brand.slug}/white&output=png&w=120&h=120'
        : 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/commons/${brand.wiki}&output=png&w=120&h=120';
    return Image.network(
      url,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const SizedBox(
          width: 28, height: 28,
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.accent, strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (_, __, ___) => const Icon(
        Icons.directions_car, color: Colors.white24, size: 32),
    );
  }
}

class _Brand {
  final String name;
  final String slug;
  final String wiki;
  final String asset;
  const _Brand({
    required this.name,
    required this.slug,
    required this.wiki,
    required this.asset,
  });
}
