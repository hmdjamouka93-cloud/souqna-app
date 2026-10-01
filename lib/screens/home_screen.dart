import 'package:flutter/material.dart';
import '../main.dart';

/// الشاشة الرئيسية
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildBanner(),
                _buildSearchBar(),
                const SizedBox(height: 12),
                _buildSectionTitle('المركبات'),
                _buildVehiclesGrid(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// الهيدر العلوي
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 26),
            onPressed: () {},
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Souqna',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none,
                color: Colors.white, size: 26),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  /// مساحة الإعلان
  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withOpacity(0.3), width: 1),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.campaign_outlined, color: AppColors.accent, size: 32),
            SizedBox(height: 6),
            Text(
              'مساحة إعلانية',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  /// شريط البحث
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'ابحث في السوق...',
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          prefixIcon:
              const Icon(Icons.search, color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  /// عنوان القسم
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 3,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  /// شبكة أقسام المركبات
  Widget _buildVehiclesGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.5,
      ),
      itemCount: _vehiclesItems.length,
      itemBuilder: (context, i) => _vehicleCard(_vehiclesItems[i]),
    );
  }

  /// كارت قسم واحد
  Widget _vehicleCard(_VehicleItem item) {
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
            Image.network(
              item.image,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(color: AppColors.card);
              },
              errorBuilder: (context, error, stack) => Container(
                color: AppColors.card,
                child: const Icon(Icons.image_outlined,
                    color: Colors.white24, size: 40),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 10,
              left: 10,
              child: Text(
                item.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black87,
                      blurRadius: 4,
                      offset: Offset(1, 1),
                    ),
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

/// نموذج قسم مركبة
class _VehicleItem {
  final String name;
  final String image;
  const _VehicleItem({required this.name, required this.image});
}

/// قائمة أقسام المركبات (8 أقسام)
const List<_VehicleItem> _vehiclesItems = [
  _VehicleItem(
    name: 'سيارات',
    image: 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=600',
  ),
  _VehicleItem(
    name: 'شاحنات',
    image: 'https://images.unsplash.com/photo-1519003722824-194d4455a60c?w=600',
  ),
  _VehicleItem(
    name: 'دراجات',
    image: 'https://images.unsplash.com/photo-1558981806-ec527fa84c39?w=600',
  ),
  _VehicleItem(
    name: 'حافلات',
    image: 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=600',
  ),
  _VehicleItem(
    name: 'معارض السيارات',
    image: 'https://images.unsplash.com/photo-1562911791-c7a97b729ec5?w=600',
  ),
  _VehicleItem(
    name: 'ايجار السيارات',
    image: 'https://images.unsplash.com/photo-1449965408869-eaa3f722e40d?w=600',
  ),
  _VehicleItem(
    name: 'معدات ثقيلة',
    image: 'https://images.unsplash.com/photo-1579412847947-7f0a9e58fc31?w=600',
  ),
  _VehicleItem(
    name: 'قطع غيار',
    image: 'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=600',
  ),
];
