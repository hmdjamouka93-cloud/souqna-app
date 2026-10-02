import 'package:flutter/material.dart';
import '../main.dart';
import 'rental_car_detail_screen.dart';

class CarRentalScreen extends StatelessWidget {
  const CarRentalScreen({super.key});

  static const List<_RentalCar> _cars = [
    _RentalCar(
      id: 'r1',
      name: 'تويوتا كامري 2024',
      pricePerDay: '8,000 د.ج',
      pricePerWeek: '50,000 د.ج',
      pricePerMonth: '180,000 د.ج',
      image: 'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=600&q=80',
      owner: 'أس في موتورز',
      city: 'الجزائر العاصمة',
    ),
    _RentalCar(
      id: 'r2',
      name: 'هيونداي إلنترا 2023',
      pricePerDay: '7,000 د.ج',
      pricePerWeek: '42,000 د.ج',
      pricePerMonth: '150,000 د.ج',
      image: 'https://images.unsplash.com/photo-1617469767053-d3b523a0b982?w=600&q=80',
      owner: 'معرض الحزم',
      city: 'وهران',
    ),
    _RentalCar(
      id: 'r3',
      name: 'كيا سبورتاج 2024',
      pricePerDay: '12,000 د.ج',
      pricePerWeek: '70,000 د.ج',
      pricePerMonth: '250,000 د.ج',
      image: 'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=600&q=80',
      owner: 'ديلز أون ويلز',
      city: 'قسنطينة',
    ),
    _RentalCar(
      id: 'r4',
      name: 'رونو كليو 2023',
      pricePerDay: '5,500 د.ج',
      pricePerWeek: '33,000 د.ج',
      pricePerMonth: '120,000 د.ج',
      image: 'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=600&q=80',
      owner: 'بريميوم موتورز',
      city: 'عنابة',
    ),
    _RentalCar(
      id: 'r5',
      name: 'بيجو 208 2024',
      pricePerDay: '6,500 د.ج',
      pricePerWeek: '38,000 د.ج',
      pricePerMonth: '135,000 د.ج',
      image: 'https://images.unsplash.com/photo-1609521263047-f8f205293f24?w=600&q=80',
      owner: 'رويال كارز',
      city: 'سطيف',
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
            _buildSearchBar(),
            const SizedBox(height: 12),
            _buildBanner(),
            const SizedBox(height: 12),
            ..._cars.map((c) => _buildCarCard(context, c)).toList(),
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
      title: const Text('تأجير السيارات',
        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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

  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800&q=80'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.black.withValues(alpha: 0.4),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('جميع سيارات التأجير',
                    style: TextStyle(color: AppColors.accent, fontSize: 14,
                      fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_back, color: AppColors.accent, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarCard(BuildContext context, _RentalCar c) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RentalCarDetailScreen(carId: c.id)),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(c.image, height: 160, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 160, color: Colors.black26,
                child: const Icon(Icons.directions_car,
                  color: Colors.white24, size: 50),
              )),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.name,
                    style: const TextStyle(color: Colors.white, fontSize: 15,
                      fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person_outline,
                        color: AppColors.textSecondary, size: 12),
                      const SizedBox(width: 4),
                      Text(c.owner,
                        style: const TextStyle(color: AppColors.textSecondary,
                          fontSize: 11)),
                      const Spacer(),
                      const Icon(Icons.location_on_outlined,
                        color: AppColors.textSecondary, size: 12),
                      const SizedBox(width: 4),
                      Text(c.city,
                        style: const TextStyle(color: AppColors.textSecondary,
                          fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _priceChip('اليوم', c.pricePerDay),
                      const SizedBox(width: 6),
                      _priceChip('الأسبوع', c.pricePerWeek),
                      const SizedBox(width: 6),
                      _priceChip('الشهر', c.pricePerMonth),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceChip(String label, String price) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Text(label,
              style: const TextStyle(color: AppColors.textSecondary,
                fontSize: 10)),
            const SizedBox(height: 2),
            Text(price,
              style: const TextStyle(color: AppColors.accent, fontSize: 10,
                fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _RentalCar {
  final String id;
  final String name;
  final String pricePerDay;
  final String pricePerWeek;
  final String pricePerMonth;
  final String image;
  final String owner;
  final String city;

  const _RentalCar({
    required this.id,
    required this.name,
    required this.pricePerDay,
    required this.pricePerWeek,
    required this.pricePerMonth,
    required this.image,
    required this.owner,
    required this.city,
  });
}
