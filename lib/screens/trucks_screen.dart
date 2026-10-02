import 'package:flutter/material.dart';
import '../main.dart';

class TrucksScreen extends StatelessWidget {
  const TrucksScreen({super.key});

  static const List<_Brand> _brands = [
    _Brand(name: 'جميع الإعلانات', slug: '__all__'),
    _Brand(name: 'مرسيدس', slug: '', asset: 'images/logos/mercedes.png'),
    _Brand(name: 'فولفو', slug: 'volvo'),
    _Brand(name: 'مان', slug: 'man'),
    _Brand(name: 'سكانيا', slug: 'scania'),
    _Brand(name: 'إيفيكو', slug: 'iveco'),
    _Brand(name: 'داف', slug: 'daf'),
    _Brand(name: 'رينو', slug: 'renault'),
    _Brand(name: 'إيسوزو', slug: '', asset: 'images/logos/isuzu.png'),
    _Brand(name: 'هينو', slug: 'hino'),
    _Brand(name: 'ميتسوبيشي', slug: 'mitsubishi'),
    _Brand(name: 'سينوتراك', slug: 'sinotruk'),
    _Brand(name: 'شاكمان', slug: 'shacman'),
    _Brand(name: 'فاو', slug: 'faw'),
    _Brand(name: 'دونغ فينغ', slug: 'dongfeng'),
    _Brand(name: 'شاحنات أخرى', slug: '__other__'),
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
      title: const Text('شاحنات',
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
    if (brand.slug == '__all__') {
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
    if (brand.slug == '__other__') {
      return GestureDetector(
        onTap: () {},
        child: Container(
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
                Text('شاحنات أخرى',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.accent, fontSize: 12,
                    fontWeight: FontWeight.bold)),
              ],
            ),
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
                width: double.infinity,
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
    return Image.network(
      'https://images.weserv.nl/?url=cdn.simpleicons.org/${brand.slug}/white&output=png&w=120&h=120',
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
        Icons.local_shipping, color: Colors.white24, size: 32),
    );
  }
}

class _Brand {
  final String name;
  final String slug;
  final String asset;
  const _Brand({required this.name, required this.slug, this.asset = ''});
}
