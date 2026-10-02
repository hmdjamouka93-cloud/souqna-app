import 'package:flutter/material.dart';
import '../main.dart';

class SparePartsScreen extends StatelessWidget {
  const SparePartsScreen({super.key});

  static const List<_Item> _items = [
    _Item(name: 'جميع الإعلانات', image: ''),
    _Item(name: 'مكابح',
      image: 'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=600&q=80'),
    _Item(name: 'نظام تبريد',
      image: 'https://images.unsplash.com/photo-1631549916768-4119b2e5f926?w=600&q=80'),
    _Item(name: 'بطاريات و اكسسوارات',
      image: 'https://images.unsplash.com/photo-1609592424825-9a0ca25b9b30?w=600&q=80'),
    _Item(name: 'تروس وناقل حركة',
      image: 'https://images.unsplash.com/photo-1581092160562-40aa08e78837?w=600&q=80'),
    _Item(name: 'زيوت و سوائل',
      image: 'https://images.unsplash.com/photo-1635437475580-b2d9a8b6f9a1?w=600&q=80'),
    _Item(name: 'كابلات',
      image: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&q=80'),
    _Item(name: 'زجاج ومرايات',
      image: 'https://images.unsplash.com/photo-1449965408869-eaa3f722e40d?w=600&q=80'),
    _Item(name: 'صالون واكسسوارات',
      image: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=600&q=80'),
    _Item(name: 'فلاتر',
      image: 'https://images.unsplash.com/photo-1622185135505-2d795003994a?w=600&q=80'),
    _Item(name: 'إطارات',
      image: 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=600&q=80'),
    _Item(name: 'قطع كهربائية',
      image: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&q=80'),
    _Item(name: 'الهيكل الخارجي وقطع الغيار',
      image: 'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=600&q=80'),
    _Item(name: 'مصابيح',
      image: 'https://images.unsplash.com/photo-1503736334956-4c8f8e92946d?w=600&q=80'),
    _Item(name: 'رنجات',
      image: 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=600&q=80'),
    _Item(name: 'محرك',
      image: 'https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=600&q=80'),
    _Item(name: 'ورش وكراجات',
      image: 'https://images.unsplash.com/photo-1504222490345-c075b6008014?w=600&q=80'),
    _Item(name: 'قطع أخرى', image: ''),
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
            _buildSearchBar(),
            const SizedBox(height: 12),
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
      title: const Text('قطع غيار',
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

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'بحث',
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
    if (item.name == 'جميع الإعلانات') {
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
    // قطع أخرى
    if (item.name == 'قطع أخرى') {
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
                Text('قطع أخرى',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.accent, fontSize: 12,
                    fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      );
    }
    // باقي الأقسام
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
            Image.network(item.image, fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(color: AppColors.card);
              },
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.card,
                child: const Icon(Icons.settings,
                  color: Colors.white24, size: 40),
              )),
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
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
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
  final String image;
  const _Item({required this.name, required this.image});
}
