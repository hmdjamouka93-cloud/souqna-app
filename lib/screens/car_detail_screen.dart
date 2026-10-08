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

  List<String> get _images {
    final imgs = widget.ad['images'];
    if (imgs is List && imgs.isNotEmpty) {
      return imgs.map((e) => e.toString()).toList();
    }
    return <String>[];
  }

  String get _title => (widget.ad['title'] ?? '').toString();
  String get _location => (widget.ad['location'] ?? '').toString();
  String get _description => (widget.ad['description'] ?? '').toString();
  String get _price {
    final p = widget.ad['price'] ?? 0;
    if (p is int) {
      final s = p.toString();
      final buf = StringBuffer();
      for (int i = 0; i < s.length; i++) {
        buf.write(s[i]);
        final rem = s.length - 1 - i;
        if (rem > 0 && rem % 3 == 0) buf.write(',');
      }
      return '${buf.toString()} د.ج';
    }
    return '$p د.ج';
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
            _buildGallery(),
            const SizedBox(height: 10),
            _buildHeader(),
            const SizedBox(height: 12),
            _buildSellerCard(),
            const SizedBox(height: 16),
            _buildDescription(),
            const SizedBox(height: 16),
            _buildReactions(),
            const SizedBox(height: 16),
            _buildAdBanner(),
            const SizedBox(height: 16),
            CommentsSection(listingId: (widget.ad['id'] ?? '').toString()),
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
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      actions: [
        IconButton(
          icon: const Icon(Icons.star_border, color: Colors.white, size: 22),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildGallery() {
    if (_images.isEmpty) {
      return Container(
        height: 240,
        color: Colors.black26,
        child: const Center(
          child: Icon(Icons.directions_car, color: Colors.white24, size: 80),
        ),
      );
    }
    return Stack(
      children: [
        SizedBox(
          height: 240,
          child: PageView.builder(
            itemCount: _images.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, i) => Image.network(
              _images[i],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.black26,
                child: const Icon(Icons.directions_car,
                    color: Colors.white24, size: 60),
              ),
            ),
          ),
        ),
        if (_images.length > 1)
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_images.length, (i) => Container(
                width: 8,
                height: 8,
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
          Text(_title,
              style: const TextStyle(color: Colors.white, fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          if (_location.isNotEmpty)
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    color: AppColors.textSecondary, size: 14),
                const SizedBox(width: 4),
                Text(_location,
                    style: const TextStyle(color: AppColors.textSecondary,
                        fontSize: 12)),
              ],
            ),
          const SizedBox(height: 8),
          Text(_price,
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
                Text('البائع',
                    style: TextStyle(color: Colors.white, fontSize: 14,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                Text('مستخدم سوقنا',
                    style: TextStyle(color: AppColors.textSecondary,
                        fontSize: 11)),
              ],
            ),
          ),
          _smallBtn('تابع', () {}),
          const SizedBox(width: 6),
          _smallBtn('اتصال', () async {
            final uri = Uri.parse('tel:+213000000000');
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
    if (_description.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('الوصف',
              style: TextStyle(color: Colors.white, fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(_description,
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
            Share.share('شوف هذه السيارة: $_title - $_price');
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
