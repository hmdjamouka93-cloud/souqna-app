import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import 'cars_screen.dart';
import 'buses_screen.dart';
import 'trucks_screen.dart';
import 'motorcycles_screen.dart';
import 'showrooms_screen.dart';
import 'car_rental_screen.dart';
import 'heavy_equipment_screen.dart';
import 'spare_parts_screen.dart';

/// الشاشة الرئيسية
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(context),
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

  Widget _buildHeader(BuildContext context) {
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
            icon: const Icon(Icons.notifications_none, color: Colors.white, size: 26),
            onPressed: () {},
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
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3), width: 1),
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
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Categories')
          .where('type', isEqualTo: 'vehicle')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          );
        }
        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                'حدث خطأ أثناء تحميل الأقسام',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }
        final docs = List<QueryDocumentSnapshot>.from(snapshot.data?.docs ?? [])
          ..sort((a, b) {
            final ao = (a.data() as Map)['order'] ?? 0;
            final bo = (b.data() as Map)['order'] ?? 0;
            return (ao as int).compareTo(bo as int);
          });
        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                'لا توجد أقسام',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }
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
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final name = (data['name'] ?? '').toString();
            final image = (data['image'] ?? '').toString();
            return _vehicleCard(context, name, image);
          },
        );
      },
    );
  }

  Widget _vehicleCard(BuildContext context, String name, String image) {
    return GestureDetector(
      onTap: () => _navigateToCategory(context, name),
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
              image,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(color: AppColors.card);
              },
              errorBuilder: (context, error, stack) => Container(
                color: AppColors.card,
                child: const Icon(
                  Icons.image_outlined,
                  color: Colors.white24,
                  size: 40,
                ),
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
              right: 10,
              left: 10,
              child: Text(
                name,
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

  void _navigateToCategory(BuildContext context, String name) {
    if (name == 'سيارات') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const CarsScreen()));
    } else if (name == 'حافلات') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const BusesScreen()));
    } else if (name == 'شاحنات') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const TrucksScreen()));
    } else if (name == 'دراجات') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const MotorcyclesScreen()));
    } else if (name == 'معارض السيارات') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ShowroomsScreen()));
    } else if (name == 'ايجار السيارات') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const CarRentalScreen()));
    } else if (name == 'معدات ثقيلة') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const HeavyEquipmentScreen()));
    } else if (name == 'قطع غيار') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const SparePartsScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name - قريباً')),
      );
    }
  }
}
