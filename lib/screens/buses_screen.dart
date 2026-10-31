import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class BusesScreen extends StatelessWidget {
  const BusesScreen({super.key});

  static const List<_Brand> _brands = [
    _Brand(name: 'جميع الإعلانات', slug: ''),
    _Brand(name: 'هيغر', slug: '', asset: 'images/logos/higer.png'),
    _Brand(name: 'يوتونغ', slug: '', asset: 'images/logos/yutong.png'),
    _Brand(name: 'كينغ لونغ', slug: '', asset: 'images/logos/kinglong.png'),
    _Brand(name: 'غولدن دراغون', slug: '', asset: 'images/logos/goldendragon.png'),
    _Brand(name: 'هيونداي', slug: 'hyundai'),
    _Brand(name: 'تويوتا', slug: 'toyota'),
    _Brand(name: 'مرسيدس', slug: '', asset: 'images/logos/mercedes.png'),
    _Brand(name: 'فولفو', slug: 'volvo'),
    _Brand(name: 'سكانيا', slug: 'scania'),
    _Brand(name: 'مان', slug: 'man'),
    _Brand(name: 'إيفيكو', slug: 'iveco'),
    _Brand(name: 'سيترا', slug: '', asset: 'images/logos/setra.png'),
    _Brand(name: 'دايو', slug: '', asset: 'images/logos/daewoo.png'),
    _Brand(name: 'حافلات أخرى', slug: '__other__'),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
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
            elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon:  Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title:  Text('حافلات',
        style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
      actions: [
        IconButton(
          icon:  Icon(Icons.notifications_none, color: AppColors.textPrimary, size: 24),
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
        style:  TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
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
    // "جميع الإعلانات"
    final isAll = brand.slug.isEmpty && brand.asset.isEmpty && brand.name != 'حافلات أخرى';
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
    // "حافلات أخرى"
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
                Text('حافلات أخرى',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.accent, fontSize: 12,
                    fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      );
    }
    // باقي الماركات
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
              style:  TextStyle(color: AppColors.textPrimary, fontSize: 12,
                fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                height: 40,
                width: double.infinity,
                child: Center(
                  child: brand.asset.isNotEmpty
                      ? Image.asset(brand.asset, fit: BoxFit.contain)
                      : CachedNetworkImage(imageUrl: 
                          'https://images.weserv.nl/?url=cdn.simpleicons.org/${brand.slug}/white&output=png&w=120&h=120',
                          fit: BoxFit.contain,
                          
                          errorWidget: (_, _, _) =>  Icon(
                            Icons.directions_bus, color: AppColors.textSecondary.withValues(alpha: 0.24), size: 32),
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
  final String asset;
  const _Brand({required this.name, required this.slug, this.asset = ''});
}
