import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../main.dart';
import 'car_detail_screen.dart';

class ShowroomDetailScreen extends StatefulWidget {
  final String showroomId;
  const ShowroomDetailScreen({super.key, required this.showroomId});

  @override
  State<ShowroomDetailScreen> createState() => _ShowroomDetailScreenState();
}

class _ShowroomDetailScreenState extends State<ShowroomDetailScreen> {
  bool _isFollowing = false;
  int _followers = 0;

  static const Map<String, Map<String, dynamic>> _allData = {
    'sv_motors': {
      'name': 'أس في موتورز',
      'description': 'بيع وشراء وعرض جميع انواع السيارات',
      'phone': '+21370466633',
      'location': 'الجزائر العاصمة',
      'followers': 50, 'following': 5, 'adCount': 26, 'views': 19162,
      'verified': true,
      'logo': 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=200&q=80',
    },
    'al_hazem': {
      'name': 'معرض الحزم للسيارات',
      'description': 'معرض متخصص في بيع السيارات الجديدة والمستعملة',
      'phone': '+21360099934',
      'location': 'وهران',
      'followers': 120, 'following': 15, 'adCount': 46, 'views': 74492,
      'verified': true,
      'logo': 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=200&q=80',
    },
    'deals_on_wheels': {
      'name': 'ديلز أون ويلز',
      'description': 'أفضل العروض على السيارات',
      'phone': '+21333774443',
      'location': 'قسنطينة',
      'followers': 85, 'following': 8, 'adCount': 137, 'views': 137577,
      'verified': true,
      'logo': 'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=200&q=80',
    },
    'premium_motors': {
      'name': 'بريميوم موتورز',
      'description': 'سيارات فاخرة ومستعملة بحالة ممتازة',
      'phone': '+21355512345',
      'location': 'عنابة',
      'followers': 45, 'following': 3, 'adCount': 18, 'views': 8663,
      'verified': true,
      'logo': 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=200&q=80',
    },
    'royal_cars': {
      'name': 'رويال كارز',
      'description': 'معرض السيارات الفاخرة والرياضية',
      'phone': '+21366677888',
      'location': 'سطيف',
      'followers': 200, 'following': 25, 'adCount': 52, 'views': 95420,
      'verified': true,
      'logo': 'https://images.unsplash.com/photo-1544636331-e26879cd4d9b?w=200&q=80',
    },
  };

  static const List<Map<String, dynamic>> _ads = [
    {
      'title': 'دودج رام ار تي 2025', 'price': '3280000 د.ج',
      'year': '2025', 'km': '19000', 'fuel': 'بنزين',
      'image': 'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=400&q=80',
    },
    {
      'title': 'تويوتا شاص 2021', 'price': '970000 د.ج',
      'year': '2021', 'km': '45000', 'fuel': 'ديزل',
      'image': 'https://images.unsplash.com/photo-1594502184342-2e12f877aa73?w=400&q=80',
    },
    {
      'title': 'فورد إف 150 لاريت 2020', 'price': '830000 د.ج',
      'year': '2020', 'km': '80000', 'fuel': 'بنزين',
      'image': 'https://images.unsplash.com/photo-1605893477799-b99e3b8b93fe?w=400&q=80',
    },
    {
      'title': 'بيجو 3008 جي تي لاين 2020', 'price': '950000 د.ج',
      'year': '2020', 'km': '60000', 'fuel': 'ديزل',
      'image': 'https://images.unsplash.com/photo-1609521263047-f8f205293f24?w=400&q=80',
    },
  ];

  Map<String, dynamic> get _data =>
      _allData[widget.showroomId] ?? _allData['sv_motors']!;

  @override
  void initState() {
    super.initState();
    _followers = _data['followers'];
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 8),
            _buildShowroomInfo(),
            const SizedBox(height: 12),
            _buildActionButtons(),
            const SizedBox(height: 16),
            _buildSectionTitle('إعلانات المعرض'),
            _buildAdsGrid(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(_data['name'],
        style: const TextStyle(color: Colors.white, fontSize: 16,
          fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildShowroomInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: 70, height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.card,
                  border: Border.all(color: Colors.white24, width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(_data['logo'], fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.storefront,
                    color: Colors.white38, size: 32)),
              ),
              if (_data['verified'] == true)
                Positioned(
                  bottom: 0, left: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.accent, shape: BoxShape.circle),
                    child: const Icon(Icons.check, color: Colors.white, size: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _statItem('${_data['adCount']}', 'إعلانات'),
                    _statItem('${_data['following']}', 'متابع لهم'),
                    _statItem('$_followers', 'المتابعون'),
                  ],
                ),
                const SizedBox(height: 8),
                Text(_data['name'],
                  style: const TextStyle(color: Colors.white, fontSize: 16,
                    fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(_data['description'],
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(_data['phone'],
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
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16,
          fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: AppColors.textSecondary,
          fontSize: 11)),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // زر المتابعة (يتغير عند الضغط)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isFollowing = !_isFollowing;
                  _followers += _isFollowing ? 1 : -1;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(_isFollowing
                    ? 'تم المتابعة ✓' : 'تم إلغاء المتابعة')),
                );
              },
              icon: Icon(
                _isFollowing ? Icons.person_remove : Icons.person_add,
                color: Colors.white, size: 18),
              label: Text(_isFollowing ? 'متابعة' : 'متابع',
                style: const TextStyle(color: Colors.white, fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // زر الموقع
          _actionIcon(Icons.location_on_outlined, _openLocation),
          const SizedBox(width: 8),
          // زر الاتصال
          _actionIcon(Icons.phone_outlined, _callPhone),
          const SizedBox(width: 8),
          // زر المشاركة
          _actionIcon(Icons.share_outlined, _shareShowroom),
        ],
      ),
    );
  }

  Widget _actionIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white54, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Future<void> _callPhone() async {
    final phone = _data['phone'] as String;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ما قدرناش نفتحو الاتصال: $phone')));
      }
    }
  }

  Future<void> _openLocation() async {
    final location = _data['location'] as String;
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _shareShowroom() async {
    final name = _data['name'] as String;
    final phone = _data['phone'] as String;
    await Share.share(
      'شوف هذا المعرض على سوقنا:\n$name\nالهاتف: $phone\n\nحمّل تطبيق سوقنا الآن!',
      subject: name,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Text(title, style: const TextStyle(color: Colors.white,
        fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildAdsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: _ads.length,
      itemBuilder: (context, i) => _adCard(_ads[i]),
    );
  }

  Widget _adCard(Map<String, dynamic> ad) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CarDetailScreen(ad: ad)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.network(ad['image'], fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.black26,
                  child: const Icon(Icons.directions_car,
                    color: Colors.white24, size: 40),
                )),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ad['title'],
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(ad['price'],
                    style: const TextStyle(color: Colors.white, fontSize: 13,
                      fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: const [
                      Icon(Icons.chat_bubble_outline,
                        color: AppColors.textSecondary, size: 12),
                      SizedBox(width: 4),
                      Text('0', style: TextStyle(color: AppColors.textSecondary,
                        fontSize: 11)),
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
}
