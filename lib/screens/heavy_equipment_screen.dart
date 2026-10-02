import 'package:flutter/material.dart';
import '../main.dart';

class HeavyEquipmentScreen extends StatelessWidget {
  const HeavyEquipmentScreen({super.key});

  static const List<_Item> _items = [
    _Item(name: 'جميع الإعلانات', slug: '__all__', image: ''),
    _Item(
      name: 'ثلاجات',
      slug: 'refrigerators',
      image: 'images/equipment/refrigerators.jpg',
    ),
    _Item(
      name: 'الرافعات الشوكية',
      slug: 'forklifts',
      image: 'images/equipment/forklifts.jpg',
    ),
    _Item(
      name: 'قطع غيار',
      slug: 'spare_parts',
      image: 'images/equipment/spare_parts.jpg',
    ),
    _Item(
      name: 'معدات الخرسانة',
      slug: 'concrete',
      image: 'images/equipment/concrete.jpg',
    ),
    _Item(
      name: 'الرافعات',
      slug: 'cranes',
      image: 'images/equipment/cranes.jpg',
    ),
    _Item(
      name: 'قلابات وحفارات',
      slug: 'dump_excavators',
      image: 'images/equipment/dump_excavators.jpg',
    ),
    _Item(name: 'معدات أخرى', slug: '__other__', image: ''),
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
            _buildGrid(),
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
      title: const Text('معدات ثقيلة',
        style: TextStyle(color: Colors.white, fontSize: 18,
          fontWeight: FontWeight.bold)),
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
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
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
        style: const TextStyle(color: Colors.white, fontSize: 16,
          fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildGrid() {
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
      itemCount: _items.length,
      itemBuilder: (context, i) => _itemCard(_items[i]),
    );
  }

  Widget _itemCard(_Item item) {
    // جميع الإعلانات
    if (item.slug == '__all__') {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Center(
            child: Text('مشاهدة جميع\nالإعلانات',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.accent, fontSize: 13,
                fontWeight: FontWeight.bold, height: 1.4)),
          ),
        ),
      );
    }
    // معدات أخرى
    if (item.slug == '__other__') {
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
                Text('معدات أخرى',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.accent, fontSize: 12,
                    fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      );
    }
    // باقي الأقسام (صورة + اسم)
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              item.image,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(color: AppColors.card);
              },
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.card,
                child: const Icon(Icons.construction,
                  color: Colors.white24, size: 40),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.75),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              left: 8,
              child: Text(
                item.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(color: Colors.black87, blurRadius: 4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Item {
  final String name;
  final String slug;
  final String image;
  const _Item({required this.name, required this.slug, required this.image});
}
