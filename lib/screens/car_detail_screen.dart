import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../main.dart';
import '../widgets/comments_section.dart';

class CarDetailScreen extends StatefulWidget {
  final Map<String, dynamic> ad;
  const CarDetailScreen({super.key, required this.ad});
  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {
  bool _isLiked = false;
  int _likes = 24;
  int _currentPage = 0;

  static const List<String> _gallery = [
    'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=800&q=80',
    'https://images.unsplash.com/photo-1594502184342-2e12f877aa73?w=800&q=80',
    'https://images.unsplash.com/photo-1605893477799-b99e3b8b93fe?w=800&q=80',
    'https://images.unsplash.com/photo-1609521263047-f8f205293f24?w=800&q=80',
  ];

  static const List<Map<String, String>> _similarAds = [
    {'title': 'تويوتا برادو 2005', 'price': '330000 د.ج',
     'img': 'https://images.unsplash.com/photo-1594502184342-2e12f877aa73?w=400&q=80'},
    {'title': 'نيسان اكس تريل 2016', 'price': '240000 د.ج',
     'img': 'https://images.unsplash.com/photo-1609521263047-f8f205293f24?w=400&q=80'},
  ];

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
            const SizedBox(height: 10),
            _buildHeader(),
            const SizedBox(height: 12),
            _buildSellerCard(),
            const SizedBox(height: 16),
            _buildSpecsGrid(),
            const SizedBox(height: 16),
            _buildDescription(),
            const SizedBox(height: 16),
            _buildReactions(),
            const SizedBox(height: 16),
            _buildAdBanner(),
            const SizedBox(height: 16),
            const CommentsSection(),
            const SizedBox(height: 16),
            _buildSimilarAds('إعلانات ذات صلة'),
            const SizedBox(height: 12),
            _buildSimilarAds('إعلانات أخرى لنفس البائع'),
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
      title: const Text('تفاصيل السيارة',
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
          Row(
            children: [
              const Icon(Icons.access_time, color: AppColors.textSecondary, size: 14),
              const SizedBox(width: 4),
              const Text('منذ 3 أيام',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const Spacer(),
              const Text('28',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(width: 4),
              const Icon(Icons.visibility, color: AppColors.textSecondary, size: 14),
            ],
          ),
          const SizedBox(height: 6),
          Text(widget.ad['title'],
            style: const TextStyle(color: Colors.white, fontSize: 18,
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(widget.ad['price'],
            style: const TextStyle(color: AppColors.accent, fontSize: 20,
              fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSellerCard() {
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
            radius: 24,
            backgroundColor: Colors.black26,
            child: Icon(Icons.storefront, color: Colors.white54, size: 24),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('أس في موتورز',
                  style: TextStyle(color: Colors.white, fontSize: 14,
                    fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                Text('50 متابع',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          _smallBtn('تابع', () {}),
          const SizedBox(width: 6),
          _smallBtn('اتصال', () async {
            final uri = Uri.parse('tel:+21370466633');
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

  Widget _buildSpecsGrid() {
    final specs = [
      ['القسم', 'سيارات'],
      ['نوع الإعلان', 'للبيع'],
      ['الفئة', 'رام'],
      ['الموديل', '1500'],
      ['المتور', 'دودج'],
      ['سنة الصنع', '2025'],
      ['نوع القير', 'اوتوماتيك'],
      ['نوع المركبة', 'بيكاب'],
      ['كم', '20000'],
      ['نوع الوقود', 'بنزين'],
      ['عدد الأسطوانات', '6'],
      ['سعة المحرك', '3000 سي سي'],
      ['الحالة', 'مستعمل - ممتازة'],
      ['تحت الضمان', 'نعم'],
      ['اللون', 'أبيض'],
      ['المدينة', 'الدوحة'],
    ];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.5,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: specs.length,
        itemBuilder: (context, i) => Container(
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(specs[i][0],
                style: const TextStyle(color: AppColors.textSecondary,
                  fontSize: 10)),
              const SizedBox(height: 4),
              Text(specs[i][1],
                style: const TextStyle(color: Colors.white, fontSize: 12,
                  fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('الوصف',
            style: TextStyle(color: Colors.white, fontSize: 15,
              fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(
            'دودج رام ار تي 2025\n'
            'الموديل: 2025\n'
            'الممشى: 20.000 كم فقط\n'
            'وارد الدوحة تحت الضمان سرفس مجاني\n'
            'السعر: 328.000 د.ج\n\n'
            'المواصفات:\n'
            'محرك بنزول 6 سلندر ناقل حركة أوتوماتيك دفع رباعي '
            'شاشة كاميرا خلفية وحساسات 5 مقاعد جلد فتحة سقف '
            'بانوراما تشغيل عن بعد سيارة قوية ومناسبة للاستخدام اليومي والسفر والبر.',
            style: TextStyle(color: Colors.white, fontSize: 13, height: 1.7),
          ),
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
            Share.share('شوف هذه السيارة: ${widget.ad['title']} - ${widget.ad['price']}');
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

  Widget _buildSimilarAds(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(title,
            style: const TextStyle(color: Colors.white, fontSize: 14,
              fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _similarAds.length,
            itemBuilder: (context, i) => _similarAdCard(_similarAds[i]),
          ),
        ),
      ],
    );
  }

  Widget _similarAdCard(Map<String, String> ad) {
    return Container(
      width: 150,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.network(ad['img']!, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.black26,
                child: const Icon(Icons.directions_car,
                  color: Colors.white24, size: 32),
              )),
          ),
          Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ad['title']!,
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(ad['price']!,
                  style: const TextStyle(color: AppColors.accent, fontSize: 12,
                    fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
