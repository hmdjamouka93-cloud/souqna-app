import 'package:flutter/material.dart';
import '../main.dart';

class CarsScreen extends StatelessWidget {
  const CarsScreen({super.key});

  // slug = Simple Icons | wiki = Wikimedia SVG path
  static const List<_Brand> _brands = [
    _Brand(name: 'جميع الإعلانات', slug: '', wiki: ''),
    _Brand(name: 'رونو', slug: 'renault', wiki: ''),
    _Brand(name: 'بيجو', slug: 'peugeot', wiki: ''),
    _Brand(name: 'سيتروين', slug: 'citroen', wiki: ''),
    _Brand(name: 'سيات', slug: 'seat', wiki: ''),
    _Brand(name: 'فولكس واجن', slug: 'volkswagen', wiki: ''),
    _Brand(name: 'تويوتا', slug: 'toyota', wiki: ''),
    _Brand(name: 'هيونداي', slug: 'hyundai', wiki: ''),
    _Brand(name: 'كيا', slug: 'kia', wiki: ''),
    _Brand(name: 'نيسان', slug: 'nissan', wiki: ''),
    _Brand(name: 'فيات', slug: 'fiat', wiki: ''),
    _Brand(name: 'سكودا', slug: 'skoda', wiki: ''),
    _Brand(name: 'فورد', slug: 'ford', wiki: ''),
    _Brand(name: 'شيفروليه', slug: 'chevrolet', wiki: ''),
    _Brand(name: 'سوزوكي', slug: 'suzuki', wiki: ''),
    _Brand(name: 'ميتسوبيشي', slug: 'mitsubishi', wiki: ''),
    _Brand(name: 'مازدا', slug: 'mazda', wiki: ''),
    _Brand(name: 'هوندا', slug: 'honda', wiki: ''),
    _Brand(name: 'إم جي', slug: 'mg', wiki: ''),
    _Brand(name: 'مرسيدس', slug: '', wiki: '9/90/Mercedes-Benz_Logo_2010.svg'),
    _Brand(name: 'بي إم دبليو', slug: 'bmw', wiki: ''),
    _Brand(name: 'أودي', slug: 'audi', wiki: ''),
    _Brand(name: 'فولفو', slug: 'volvo', wiki: ''),
    _Brand(name: 'جيب', slug: 'jeep', wiki: ''),
    _Brand(name: 'لاند روفر', slug: '', wiki: 'a/a1/Land_Rover_logo.svg'),
    _Brand(name: 'لكزس', slug: '', wiki: '1/17/Lexus_division_emblem.svg'),
    _Brand(name: 'إنفينيتي', slug: 'infiniti', wiki: ''),
    _Brand(name: 'بورش', slug: 'porsche', wiki: ''),
    _Brand(name: 'تسلا', slug: 'tesla', wiki: ''),
    _Brand(name: 'ألفا روميو', slug: '', wiki: 'd/d7/Alfa_Romeo_logo.svg'),
    _Brand(name: 'جينيسيس', slug: '', wiki: '7/7d/Genesis_Motors_logo.svg'),
    _Brand(name: 'كاديلاك', slug: 'cadillac', wiki: ''),
    _Brand(name: 'كرايسلر', slug: 'chrysler', wiki: ''),
    _Brand(name: 'دودج', slug: '', wiki: 'b/be/Dodge_logo.svg'),
    _Brand(name: 'لينكولن', slug: '', wiki: '6/6c/Lincoln_Motor_Company_logo.svg'),
    _Brand(name: 'أوبل', slug: 'opel', wiki: ''),
    _Brand(name: 'داسيا', slug: 'dacia', wiki: ''),
    _Brand(name: 'جيلي', slug: '', wiki: '8/8e/Geely_Logo_2019.svg'),
    _Brand(name: 'بي واي دي', slug: '', wiki: '1/1f/BYD_Auto_2022_logo.svg'),
    _Brand(name: 'شيري', slug: '', wiki: '4/4a/Chery_logo.svg'),
    _Brand(name: 'هافال', slug: '', wiki: '7/7c/Haval_logo.svg'),
    _Brand(name: 'بوغاتي', slug: 'bugatti', wiki: ''),
    _Brand(name: 'لامبورغيني', slug: 'lamborghini', wiki: ''),
    _Brand(name: 'فيراري', slug: 'ferrari', wiki: ''),
    _Brand(name: 'مازيراتي', slug: 'maserati', wiki: ''),
    _Brand(name: 'بنتلي', slug: 'bentley', wiki: ''),
    _Brand(name: 'رولز رويس', slug: 'rollsroyce', wiki: ''),
    _Brand(name: 'أستون مارتن', slug: 'astonmartin', wiki: ''),
    _Brand(name: 'ماكلارين', slug: 'mclaren', wiki: ''),
    _Brand(name: 'لوتس', slug: 'lotus', wiki: ''),
    _Brand(name: 'أكيورا', slug: 'acura', wiki: ''),
    _Brand(name: 'روفر', slug: 'rover', wiki: ''),
    _Brand(name: 'إيسوزو', slug: 'isuzu', wiki: ''),
    _Brand(name: 'شانجان', slug: 'changan', wiki: ''),
    _Brand(name: 'سانغ يونغ', slug: 'ssangyong', wiki: ''),
    _Brand(name: 'كوبرا', slug: 'cupra', wiki: ''),
    _Brand(name: 'سمارت', slug: 'smart', wiki: ''),
    _Brand(name: 'ميني', slug: 'mini', wiki: ''),
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

  String _getLogoUrl(_Brand brand) {
    if (brand.slug.isNotEmpty) {
      return 'https://images.weserv.nl/?url=cdn.simpleicons.org/${brand.slug}/white&output=png&w=120&h=120';
    }
    return 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/commons/${brand.wiki}&output=png&w=120&h=120';
  }

  Widget _brandCard(_Brand brand) {
    final isAll = brand.slug.isEmpty && brand.wiki.isEmpty;
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
              child: Image.network(
                _getLogoUrl(brand),
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
  final String wiki;
  const _Brand({required this.name, required this.slug, required this.wiki});
}
