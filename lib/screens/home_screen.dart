import 'package:flutter/material.dart';
import '../main.dart';
import 'cars_screen.dart';
import 'cars_screen.dart';

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
                const SizedBox(height: 16),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 26),
            onPressed: () => Scaffold.of(context).openDrawer(),
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
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ],
      ),
    );
  }

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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        textAlign: TextAlign.right,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildVehiclesGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.4,
      ),
      itemCount: _vehiclesItems.length,
      itemBuilder: (context, i) => _vehicleCard(context, _vehiclesItems[i]),
    );
  }

  Widget _vehicleCard(BuildContext context, _VehicleItem item) {
    return GestureDetector(
      onTap: () { if (item.name == "سيارات") { Navigator.push(context, MaterialPageRoute(builder: (context) => const CarsScreen())); } else { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(item.name + " - قريبا"))); } },
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
                    Colors.black.withOpacity(0.75),
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

class _VehicleItem {
  final String name;
  final String image;
  const _VehicleItem({required this.name, required this.image});
}

const String _base = 'https://raw.githubusercontent.com/hmdjamouka93-cloud/souqna-app/main/images';

final List<_VehicleItem> _vehiclesItems = [
  _VehicleItem(name: 'سيارات', image: '$_base/img3.jpg'),
  _VehicleItem(name: 'شاحنات', image: '$_base/img5.jpg'),
  _VehicleItem(name: 'دراجات', image: '$_base/img2.jpg'),
  _VehicleItem(name: 'حافلات', image: '$_base/img4.jpg'),
  _VehicleItem(name: 'معارض السيارات', image: '$_base/img7.jpg'),
  _VehicleItem(name: 'ايجار السيارات', image: '$_base/img8.png'),
  _VehicleItem(name: 'معدات ثقيلة', image: '$_base/img6.jpg'),
  _VehicleItem(name: 'قطع غيار', image: '$_base/img1.jpg'),
];
