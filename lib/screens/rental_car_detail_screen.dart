import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../main.dart';
import '../widgets/comments_section.dart';

class RentalCarDetailScreen extends StatefulWidget {
  final String carId;
  const RentalCarDetailScreen({super.key, required this.carId});
  @override
  State<RentalCarDetailScreen> createState() => _RentalCarDetailScreenState();
}

class _RentalCarDetailScreenState extends State<RentalCarDetailScreen> {
  bool _isLiked = false;
  int _likes = 18;
  int _currentPage = 0;

  static const Map<String, Map<String, dynamic>> _allCars = {
    'r1': {
      'name': 'تويوتا كامري 2024',
      'pricePerDay': '8,000 د.ج',
      'pricePerWeek': '50,000 د.ج',
      'pricePerMonth': '180,000 د.ج',
      'owner': 'أس في موتورز',
      'phone': '+21370466633',
      'city': 'الجزائر العاصمة',
      'description': 'سيارة نظيفة ومريحة، مناسبة للسفر والاستخدام اليومي. تأمين شامل، صيانة دورية، تكييف، GPS.',
    },
    'r2': {
      'name': 'هيونداي إلنترا 2023',
      'pricePerDay': '7,000 د.ج',
      'pricePerWeek': '42,000 د.ج',
      'pricePerMonth': '150,000 د.ج',
      'owner': 'معرض الحزم',
      'phone': '+21360099934',
      'city': 'وهران',
      'description': 'سيارة اقتصادية حديثة، استهلاك وقود منخفض، مناسبة للاستخدام اليومي.',
    },
    'r3': {
      'name': 'كيا سبورتاج 2024',
      'pricePerDay': '12,000 د.ج',
      'pricePerWeek': '70,000 د.ج',
      'pricePerMonth': '250,000 د.ج',
      'owner': 'ديلز أون ويلز',
      'phone': '+21333774443',
      'city': 'قسنطينة',
      'description': 'سيارة SUV فاخرة، 5 مقاعد، مساحة كبيرة، مثالية للعائلات.',
    },
    'r4': {
      'name': 'رونو كليو 2023',
      'pricePerDay': '5,500 د.ج',
      'pricePerWeek': '33,000 د.ج',
      'pricePerMonth': '120,000 د.ج',
      'owner': 'بريميوم موتورز',
      'phone': '+21355512345',
      'city': 'عنابة',
      'description': 'سيارة صغيرة اقتصادية، سهلة القيادة والتنقل، مناسبة للاستخدام اليومي.',
    },
    'r5': {
      'name': 'بيجو 208 2024',
      'pricePerDay': '6,500 د.ج',
      'pricePerWeek': '38,000 د.ج',
      'pricePerMonth': '135,000 د.ج',
      'owner': 'رويال كارز',
      'phone': '+21366677888',
      'city': 'سطيف',
      'description': 'سيارة حديثة بأناقة فرنسية، داخلية عصرية، اقتصادية في الوقود.',
    },
  };

  static const List<String> _gallery = [
    'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=800&q=80',
    'https://images.unsplash.com/photo-1617469767053-d3b523a0b982?w=800&q=80',
    'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=800&q=80',
  ];

  Map<String, dynamic> get _data =>
      _allCars[widget.carId] ?? _allCars['r1']!;

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
            _buildGallery(),
            const SizedBox(height: 12),
            _buildHeader(),
            const SizedBox(height: 12),
            _buildRentalPrices(),
            const SizedBox(height: 12),
            _buildOwnerCard(),
            const SizedBox(height: 16),
            _buildDescription(),
            const SizedBox(height: 16),
            _buildReactions(),
            const SizedBox(height: 16),
            _buildAdBanner(),
            const SizedBox(height: 16),
            const CommentsSection(listingId: ''),
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
      title: const Text('تفاصيل التأجير',
        style: TextStyle(color: Colors.white, fontSize: 16,
          fontWeight: FontWeight.bold)),
      actions: [
        IconButton(
          icon: const Icon(Icons.star_border, color: Colors.white, size: 22),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildGallery() {
    return Stack(
      children: [
        SizedBox(
          height: 240,
          child: PageView.builder(
            itemCount: _gallery.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, i) => Image.network(_gallery[i],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.black26,
                child: const Icon(Icons.directions_car,
                  color: Colors.white24, size: 60),
              )),
          ),
        ),
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_gallery.length, (i) => Container(
              width: 8, height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == i ? Colors.white : Colors.white38,
              ),
            )),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_data['name'],
            style: const TextStyle(color: Colors.white, fontSize: 18,
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                color: AppColors.textSecondary, size: 14),
              const SizedBox(width: 4),
              Text(_data['city'],
                style: const TextStyle(color: AppColors.textSecondary,
                  fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRentalPrices() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('أسعار التأجير',
            style: TextStyle(color: Colors.white, fontSize: 14,
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              _priceItem('اليوم', _data['pricePerDay']),
              const SizedBox(width: 8),
              _priceItem('الأسبوع', _data['pricePerWeek']),
              const SizedBox(width: 8),
              _priceItem('الشهر', _data['pricePerMonth']),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceItem(String label, String price) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(label,
              style: const TextStyle(color: AppColors.textSecondary,
                fontSize: 11)),
            const SizedBox(height: 4),
            Text(price,
              style: const TextStyle(color: AppColors.accent, fontSize: 12,
                fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: Colors.black26,
            child: Icon(Icons.storefront, color: Colors.white54, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(_data['owner'],
              style: const TextStyle(color: Colors.white, fontSize: 14,
                fontWeight: FontWeight.bold)),
          ),
          _smallBtn('تابع', () {}),
          const SizedBox(width: 6),
          _smallBtn('اتصال', () async {
            final uri = Uri.parse('tel:${_data['phone']}');
            if (await canLaunchUrl(uri)) await launchUrl(uri);
          }),
        ],
      ),
    );
  }

  Widget _smallBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.accent, width: 1.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
          style: const TextStyle(color: AppColors.accent, fontSize: 12,
            fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('الوصف',
            style: TextStyle(color: Colors.white, fontSize: 15,
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(_data['description'],
            style: const TextStyle(color: Colors.white, fontSize: 13,
              height: 1.7)),
        ],
      ),
    );
  }

  Widget _buildReactions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _reactionBtn(
            _isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
            'إعجاب ($_likes)',
            () => setState(() {
              _isLiked = !_isLiked;
              _likes += _isLiked ? 1 : -1;
            }),
            active: _isLiked,
          )),
          const SizedBox(width: 8),
          Expanded(child: _reactionBtn(Icons.share, 'مشاركة', () {
            Share.share('شوف هذه السيارة للتأجير: ${_data['name']}');
          })),
          const SizedBox(width: 8),
          Expanded(child: _reactionBtn(Icons.report_problem_outlined, 'تبليغ', () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم إرسال التبليغ')));
          })),
        ],
      ),
    );
  }

  Widget _reactionBtn(IconData icon, String label, VoidCallback onTap,
      {bool active = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border.all(
            color: active ? AppColors.accent : Colors.white24, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
              color: active ? AppColors.accent : Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(label,
              style: TextStyle(
                color: active ? AppColors.accent : Colors.white,
                fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildAdBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
}
