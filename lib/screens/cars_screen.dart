import 'package:flutter/material.dart';
import '../main.dart';

class CarsScreen extends StatelessWidget {
  const CarsScreen({super.key});

  static const List<_Brand> _brands = [
    _Brand(name: 'جميع الإعلانات', slug: ''),
    _Brand(name: 'رونو', slug: 'renault'),
    _Brand(name: 'بيجو', slug: 'peugeot'),
    _Brand(name: 'سيتروين', slug: 'citroen'),
    _Brand(name: 'سيات', slug: 'seat'),
    _Brand(name: 'فولكس واجن', slug: 'volkswagen'),
    _Brand(name: 'تويوتا', slug: 'toyota'),
    _Brand(name: 'هيونداي', slug: 'hyundai'),
    _Brand(name: 'كيا', slug: 'kia'),
    _Brand(name: 'نيسان', slug: 'nissan'),
    _Brand(name: 'فيات', slug: 'fiat'),
    _Brand(name: 'سكودا', slug: 'skoda'),
    _Brand(name: 'فورد', slug: 'ford'),
    _Brand(name: 'شيفروليه', slug: 'chevrolet'),
    _Brand(name: 'سوزوكي', slug: 'suzuki'),
    _Brand(name: 'ميتسوبيشي', slug: 'mitsubishi'),
    _Brand(name: 'مازدا', slug: 'mazda'),
    _Brand(name: 'هوندا', slug: 'honda'),
    _Brand(name: 'جيلي', slug: 'geely'),
    _Brand(name: 'بي واي دي', slug: 'byd'),
    _Brand(name: 'إم جي', slug: 'mg'),
    _Brand(name: 'مرسيدس', slug: 'mercedes'),
    _Brand(name: 'بي إم دبليو', slug: 'bmw'),
    _Brand(name: 'أودي', slug: 'audi'),
    _Brand(name: 'فولفو', slug: 'volvo'),
    _Brand(name: 'جيب', slug: 'jeep'),
    _Brand(name: 'لاند روفر', slug: 'landrover'),
    _Brand(name: 'لكزس', slug: 'lexus'),
    _Brand(name: 'إنفينيتي', slug: 'infiniti'),
    _Brand(name: 'بورش', slug: 'porsche'),
    _Brand(name: 'تسلا', slug: 'tesla'),
    _Brand(name: 'بوغاتي', slug: 'bugatti'),
    _Brand(name: 'مازيراتي', slug: 'maserati'),
    _Brand(name: 'لامبورغيني', slug: 'lamborghini'),
    _Brand(name: 'فيراري', slug: 'ferrari'),
    _Brand(name: 'بنتلي', slug: 'bentley'),
    _Brand(name: 'رولز رويس', slug: 'rollsroyce'),
    _Brand(name: 'أستون مارتن', slug: 'astonmartin'),
    _Brand(name: 'ماكلارين', slug: 'mclaren'),
    _Brand(name: 'لوتس', slug: 'lotus'),
    _Brand(name: 'ألفا روميو', slug: 'alfaromeo'),
    _Brand(name: 'دودج', slug: 'dodge'),
    _Brand(name: 'كرايسلر', slug: 'chrysler'),
    _Brand(name: 'كاديلاك', slug: 'cadillac'),
    _Brand(name: 'لينكولن', slug: 'lincoln'),
    _Brand(name: 'جينيسيس', slug: 'genesis'),
    _Brand(name: 'أكيورا', slug: 'acura'),
    _Brand(name: 'إنفينيتي', slug: 'infiniti'),
    _Brand(name: 'داسيا', slug: 'dacia'),
    _Brand(name: 'شيري', slug: 'chery'),
    _Brand(name: 'هافال', slug: 'haval'),
    _Brand(name: 'شانجان', slug: 'changan'),
    _Brand(name: 'أوبل', slug: 'opel'),
    _Brand(name: 'روفر', slug: 'rover'),
    _Brand(name: 'إيسوزو', slug: 'isuzu'),
    _Brand(name: 'سانغ يونغ', slug: 'ssangyong'),
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
        icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
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
    final isAll = brand.slug.isEmpty;
    final logoUrl = 'https://images.weserv.nl/?url=cdn.simpleicons.org/${brand.slug}/white&output=png&w=120&h=120';
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: isAll
            ? const Padding(
                padding: EdgeInsets.all(10),
                child: Center(
                  child: Text('جميع الإعلانات',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.accent, fontSize: 13,
                      fontWeight: FontWeight.bold)),
                ),
              )
            : Column(
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
                    child: Image.network(
                      logoUrl,
                      fit: BoxFit.contain,
                      height: 40,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const SizedBox(
                          width: 32, height: 32,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.accent, strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.directions_car,
                        color: Colors.white24, size: 32),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
      ),
    );
  }
}

class _Brand {
  final String name;
  final String slug;
  const _Brand({required this.name, required this.slug});
}
