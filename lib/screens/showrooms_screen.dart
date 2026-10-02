import 'package:flutter/material.dart';
import '../main.dart';
import 'showroom_detail_screen.dart';

class ShowroomsScreen extends StatelessWidget {
  const ShowroomsScreen({super.key});

  // بيانات مؤقتة (تتبدل بـ Firestore لاحقاً)
  static const List<_Showroom> _showrooms = [
    _Showroom(
      id: 'sv_motors',
      name: 'أس في موتورز',
      description: 'بيع وشراء وعرض جميع انواع السيارات',
      phone: '+97470466633',
      followers: 50,
      following: 5,
      adCount: 26,
      views: 19162,
      verified: true,
      logo: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=200&q=80',
      banner: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800&q=80',
    ),
    _Showroom(
      id: 'al_hazem',
      name: 'معرض الحزم للسيارات',
      description: 'معرض متخصص في بيع السيارات الجديدة والمستعملة',
      phone: '60099934',
      followers: 120,
      following: 15,
      adCount: 46,
      views: 74492,
      verified: true,
      logo: 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=200&q=80',
      banner: 'https://images.unsplash.com/photo-1544636331-e26879cd4d9b?w=800&q=80',
    ),
    _Showroom(
      id: 'deals_on_wheels',
      name: 'ديلز أون ويلز',
      description: 'أفضل العروض على السيارات',
      phone: '33774443',
      followers: 85,
      following: 8,
      adCount: 137,
      views: 137577,
      verified: true,
      logo: 'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=200&q=80',
      banner: 'https://images.unsplash.com/photo-1553440569-bcc63803a83d?w=800&q=80',
    ),
    _Showroom(
      id: 'premium_motors',
      name: 'بريميوم موتورز',
      description: 'سيارات فاخرة ومستعملة بحالة ممتازة',
      phone: '55512345',
      followers: 45,
      following: 3,
      adCount: 18,
      views: 8663,
      verified: true,
      logo: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=200&q=80',
      banner: 'https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=800&q=80',
    ),
    _Showroom(
      id: 'royal_cars',
      name: 'رويال كارز',
      description: 'معرض السيارات الفاخرة والرياضية',
      phone: '66677888',
      followers: 200,
      following: 25,
      adCount: 52,
      views: 95420,
      verified: true,
      logo: 'https://images.unsplash.com/photo-1544636331-e26879cd4d9b?w=200&q=80',
      banner: 'https://images.unsplash.com/photo-1493238792000-8113da705763?w=800&q=80',
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
            _buildAllShowroomsBanner(),
            const SizedBox(height: 8),
            _buildAllCard(),
            const SizedBox(height: 12),
            ..._showrooms.map((s) => _buildShowroomCard(context, s)).toList(),
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
      title: const Text('معارض السيارات',
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

  Widget _buildAllShowroomsBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1493238792000-8113da705763?w=800&q=80'),
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
                  Text('جميع إعلانات المعارض',
                    style: TextStyle(color: AppColors.accent, fontSize: 14,
                      fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_back, color: AppColors.accent, size: 18),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                color: Colors.black54,
                child: const Text('كل المعارض',
                  style: TextStyle(color: Colors.white, fontSize: 13)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.grid_view, color: AppColors.accent, size: 24),
          SizedBox(width: 10),
          Text('كل المعارض',
            style: TextStyle(color: Colors.white, fontSize: 14,
              fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildShowroomCard(BuildContext context, _Showroom s) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ShowroomDetailScreen(showroomId: s.id)),
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
            // الشعار (فوق، على خلفية البانر)
            Stack(
              children: [
                Image.network(
                  s.banner,
                  height: 130,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 130,
                    color: Colors.black26,
                  ),
                ),
                // عدد الإعلانات (يمين)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('${s.adCount} إعلانات',
                      style: const TextStyle(color: Colors.black, fontSize: 11)),
                  ),
                ),
                // المشاهدات (يسار)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${s.views}',
                          style: const TextStyle(color: Colors.black, fontSize: 11)),
                        const SizedBox(width: 4),
                        const Icon(Icons.visibility, size: 12, color: Colors.black),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // اسم المعرض (تحت)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: Colors.white,
              child: Center(
                child: Text(s.name,
                  style: const TextStyle(color: Colors.black, fontSize: 14,
                    fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Showroom {
  final String id;
  final String name;
  final String description;
  final String phone;
  final int followers;
  final int following;
  final int adCount;
  final int views;
  final bool verified;
  final String logo;
  final String banner;

  const _Showroom({
    required this.id,
    required this.name,
    required this.description,
    required this.phone,
    required this.followers,
    required this.following,
    required this.adCount,
    required this.views,
    required this.verified,
    required this.logo,
    required this.banner,
  });
}
