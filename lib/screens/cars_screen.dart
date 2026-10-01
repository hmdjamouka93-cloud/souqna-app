import 'package:flutter/material.dart';
import '../main.dart';

class CarsScreen extends StatelessWidget {
  const CarsScreen({super.key});

  static const List<_Brand> _brands = [
    _Brand(name: 'جميع الإعلانات', logo: ''),
    _Brand(name: 'سيات', logo: 'https://logo.clearbit.com/seat.com'),
    _Brand(name: 'بيجو', logo: 'https://logo.clearbit.com/peugeot.com'),
    _Brand(name: 'رونو', logo: 'https://logo.clearbit.com/renault.com'),
    _Brand(name: 'كيا', logo: 'https://logo.clearbit.com/kia.com'),
    _Brand(name: 'سيتروين', logo: 'https://logo.clearbit.com/citroen.com'),
    _Brand(name: 'تويوتا', logo: 'https://logo.clearbit.com/toyota.com'),
    _Brand(name: 'هيونداي', logo: 'https://logo.clearbit.com/hyundai.com'),
    _Brand(name: 'فولكس واجن', logo: 'https://logo.clearbit.com/vw.com'),
    _Brand(name: 'نيسان', logo: 'https://logo.clearbit.com/nissan-global.com'),
    _Brand(name: 'مرسيدس', logo: 'https://logo.clearbit.com/mercedes-benz.com'),
    _Brand(name: 'بي إم دبليو', logo: 'https://logo.clearbit.com/bmw.com'),
    _Brand(name: 'شيفروليه', logo: 'https://logo.clearbit.com/chevrolet.com'),
    _Brand(name: 'ميتسوبيشي', logo: 'https://logo.clearbit.com/mitsubishi-motors.com'),
    _Brand(name: 'جي إم سي', logo: 'https://logo.clearbit.com/gmc.com'),
    _Brand(name: 'لكزس', logo: 'https://logo.clearbit.com/lexus.com'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    final isAll = brand.logo.isEmpty;
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
                    style: TextStyle(color: AppColors.accent, fontSize: 14,
                      fontWeight: FontWeight.bold)),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  Text(brand.name,
                    style: const TextStyle(color: Colors.white, fontSize: 13,
                      fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Image.network(
                      brand.logo,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const SizedBox(
                          width: 40, height: 40,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.accent, strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.directions_car,
                        color: Colors.white24, size: 36),
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
  final String logo;
  const _Brand({required this.name, required this.logo});
}
