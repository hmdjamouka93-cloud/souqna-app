import 'package:flutter/material.dart';
import '../main.dart';

class MotorcyclesScreen extends StatelessWidget {
  const MotorcyclesScreen({super.key});

  static const List<_BrandGroup> _groups = [
    _BrandGroup(
      title: 'جميع الإعلانات',
      brands: [
        _Brand(name: 'مشاهدة جميع الإعلانات', slug: '__all__'),
      ],
    ),
    _BrandGroup(
      title: 'دراجات اقتصادية',
      brands: [
        _Brand(name: 'VMS', slug: 'vms'),
        _Brand(name: 'Keeway', slug: 'keeway'),
        _Brand(name: 'Lifan', slug: 'lifan'),
        _Brand(name: 'Bajaj', slug: 'bajaj'),
        _Brand(name: 'Hero', slug: 'hero'),
        _Brand(name: 'TVS', slug: 'tvs'),
        _Brand(name: 'Haojue', slug: 'haojue'),
      ],
    ),
    _BrandGroup(
      title: 'سكوترات',
      brands: [
        _Brand(name: 'فيسبا', slug: 'vespa'),
        _Brand(name: 'بياجيو', slug: 'piaggio'),
        _Brand(name: 'SYM', slug: 'sym'),
        _Brand(name: 'هوندا', slug: 'honda'),
        _Brand(name: 'ياماها', slug: 'yamaha'),
      ],
    ),
    _BrandGroup(
      title: 'دراجات رياضية',
      brands: [
        _Brand(name: 'KTM', slug: 'ktm'),
        _Brand(name: 'دوكاتي', slug: 'ducati'),
        _Brand(name: 'كاواساكي', slug: 'kawasaki'),
        _Brand(name: 'ياماها', slug: 'yamaha'),
        _Brand(name: 'هوندا', slug: 'honda'),
        _Brand(name: 'بي إم دبليو', slug: 'bmw'),
        _Brand(name: 'أبريليا', slug: 'aprilia'),
        _Brand(name: 'بينيلي', slug: 'benelli'),
        _Brand(name: 'رويال إنفيلد', slug: 'royalenfield'),
        _Brand(name: 'MV أجوستا', slug: 'mvagusta'),
      ],
    ),
    _BrandGroup(
      title: 'دراجات كهربائية',
      brands: [
        _Brand(name: 'NIU', slug: 'niu'),
        _Brand(name: 'Sur-Ron', slug: 'surron'),
      ],
    ),
    _BrandGroup(
      title: 'دراجات أخرى',
      brands: [
        _Brand(name: 'ماركات أخرى', slug: '__other__'),
      ],
    ),
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
            const SizedBox(height: 8),
            ..._groups.map((g) => _buildGroup(g)).toList(),
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
      title: const Text('دراجات',
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

  Widget _buildGroup(_BrandGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(group.title,
            style: const TextStyle(color: Colors.white, fontSize: 16,
              fontWeight: FontWeight.bold)),
        ),
        GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10,
            childAspectRatio: 1.0,
          ),
          itemCount: group.brands.length,
          itemBuilder: (context, i) => _brandCard(group.brands[i]),
        ),
      ],
    );
  }

  Widget _brandCard(_Brand brand) {
    if (brand.slug == '__all__') {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Text(brand.name,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.accent, fontSize: 13,
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
                Text('دراجات أخرى',
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
                child: Center(
                  child: Image.network(
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
                      Icons.two_wheeler, color: Colors.white24, size: 32),
                  ),
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

class _Brand {
  final String name;
  final String slug;
  const _Brand({required this.name, required this.slug});
}

class _BrandGroup {
  final String title;
  final List<_Brand> brands;
  const _BrandGroup({required this.title, required this.brands});
}
