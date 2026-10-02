import 'package:flutter/material.dart';
import '../main.dart';

class ShowroomDetailScreen extends StatelessWidget {
  final String showroomId;
  const ShowroomDetailScreen({super.key, required this.showroomId});

  // بيانات تجريبية (تتبدل بـ Firestore)
  Map<String, dynamic> get _data => _allData[showroomId] ?? _allData['sv_motors']!;

  static const Map<String, dynamic> _allData = {
    'sv_motors': {
      'name': 'أس في موتورز',
      'description': 'بيع وشراء وعرض جميع انواع السيارات',
      'phone': '+97470466633',
      'followers': 50,
      'following': 5,
      'adCount': 26,
      'views': 19162,
      'verified': true,
      'logo': 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=200&q=80',
    },
    'al_hazem': {
      'name': 'معرض الحزم للسيارات',
      'description': 'معرض متخصص في بيع السيارات الجديدة والمستعملة',
      'phone': '60099934',
      'followers': 120,
      'following': 15,
      'adCount': 46,
      'views': 74492,
      'verified': true,
      'logo': 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=200&q=80',
    },
    'deals_on_wheels': {
      'name': 'ديلز أون ويلز',
      'description': 'أفضل العروض على السيارات',
      'phone': '33774443',
      'followers': 85,
      'following': 8,
      'adCount': 137,
      'views': 137577,
      'verified': true,
      'logo': 'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=200&q=80',
    },
    'premium_motors': {
      'name': 'بريميوم موتورز',
      'description': 'سيارات فاخرة ومستعملة بحالة ممتازة',
      'phone': '55512345',
      'followers': 45,
      'following': 3,
      'adCount': 18,
      'views': 8663,
      'verified': true,
      'logo': 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=200&q=80',
    },
    'royal_cars': {
      'name': 'رويال كارز',
      'description': 'معرض السيارات الفاخرة والرياضية',
      'phone': '66677888',
      'followers': 200,
      'following': 25,
      'adCount': 52,
      'views': 95420,
      'verified': true,
      'logo': 'https://images.unsplash.com/photo-1544636331-e26879cd4d9b?w=200&q=80',
    },
  };

  static const List<Map<String, String>> _ads = [
    {'title': 'دودج رام ار تي 2025', 'price': '328000 ر.ق',
     'image': 'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=400&q=80'},
    {'title': 'تويوتا شاص 2021', 'price': '97000 ر.ق',
     'image': 'https://images.unsplash.com/photo-1594502184342-2e12f877aa73?w=400&q=80'},
    {'title': 'فورد إف 150 لاريت 2020', 'price': '83000 ر.ق',
     'image': 'https://images.unsplash.com/photo-1605893477799-b99e3b8b93fe?w=400&q=80'},
    {'title': 'بيجو 3008 جي تي لاين 2020', 'price': '95000 ر.ق',
     'image': 'https://images.unsplash.com/photo-1609521263047-f8f205293f24?w=400&q=80'},
  ];

  @override
  Widget build(BuildContext context) {
    final data = _data;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context, data['name']),
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 8),
            _buildShowroomInfo(data),
            const SizedBox(height: 12),
            _buildActionButtons(context, data['phone']),
            const SizedBox(height: 16),
            _buildSectionTitle('إعلانات المعرض'),
            _buildAdsGrid(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, String name) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(name,
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildShowroomInfo(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الشعار (دائري)
          Stack(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.card,
                  border: Border.all(color: Colors.white24, width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(data['logo'], fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.storefront,
                    color: Colors.white38, size: 32)),
              ),
              if (data['verified'] == true)
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // المعلومات
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الإحصائيات
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _statItem('${data['adCount']}', 'إعلانات'),
                    _statItem('${data['following']}', 'متابع لهم'),
                    _statItem('${data['followers']}', 'المتابعون'),
                  ],
                ),
                const SizedBox(height: 8),
                Text(data['name'],
                  style: const TextStyle(color: Colors.white, fontSize: 16,
                    fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(data['description'],
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(data['phone'],
                  style: const TextStyle(color: Colors.white, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(value,
          style: const TextStyle(color: Colors.white, fontSize: 16,
            fontWeight: FontWeight.bold)),
        Text(label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, String phone) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // زر متابِع (أساسي، عنابي)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم المتابعة +1')),
                );
              },
              icon: const Icon(Icons.person_add, color: Colors.white, size: 18),
              label: const Text('متابع',
                style: TextStyle(color: Colors.white, fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _actionIcon(Icons.location_on_outlined),
          const SizedBox(width: 8),
          _actionIcon(Icons.phone_outlined),
          const SizedBox(width: 8),
          _actionIcon(Icons.share_outlined),
        ],
      ),
    );
  }

  Widget _actionIcon(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white54, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.white, size: 22),
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

  Widget _buildAdsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: _ads.length,
      itemBuilder: (context, i) => _adCard(_ads[i]),
    );
  }

  Widget _adCard(Map<String, String> ad) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.network(
              ad['image']!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.black26,
                child: const Icon(Icons.directions_car,
                  color: Colors.white24, size: 40),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ad['title']!,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(ad['price']!,
                  style: const TextStyle(color: Colors.white, fontSize: 13,
                    fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Icon(Icons.chat_bubble_outline, color: AppColors.textSecondary, size: 12),
                    SizedBox(width: 4),
                    Text('0',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
