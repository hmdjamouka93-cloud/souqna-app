import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../main.dart';

class CarDetailScreen extends StatelessWidget {
  final Map<String, dynamic> ad;
  const CarDetailScreen({super.key, required this.ad});

  static const List<String> _gallery = [
    'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=800&q=80',
    'https://images.unsplash.com/photo-1594502184342-2e12f877aa73?w=800&q=80',
    'https://images.unsplash.com/photo-1605893477799-b99e3b8b93fe?w=800&q=80',
    'https://images.unsplash.com/photo-1609521263047-f8f205293f24?w=800&q=80',
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
            _buildGallery(),
            const SizedBox(height: 12),
            _buildTitlePrice(),
            const SizedBox(height: 12),
            _buildSpecs(),
            const SizedBox(height: 16),
            _buildDescription(),
            const SizedBox(height: 16),
            _buildActionButtons(context),
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
      title: const Text('تفاصيل السيارة',
        style: TextStyle(color: Colors.white, fontSize: 16,
          fontWeight: FontWeight.bold)),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined, color: Colors.white, size: 22),
          onPressed: () => Share.share('شوف هذه السيارة: ${ad['title']}'),
        ),
      ],
    );
  }

  Widget _buildGallery() {
    return SizedBox(
      height: 240,
      child: PageView.builder(
        itemCount: _gallery.length,
        itemBuilder: (context, i) => Image.network(_gallery[i],
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.black26,
            child: const Icon(Icons.directions_car,
              color: Colors.white24, size: 60),
          )),
      ),
    );
  }

  Widget _buildTitlePrice() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ad['title'],
            style: const TextStyle(color: Colors.white, fontSize: 18,
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(ad['price'],
            style: const TextStyle(color: AppColors.accent, fontSize: 20,
              fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSpecs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            _specRow('سنة الصنع', ad['year'] ?? ''),
            const Divider(color: Colors.white12),
            _specRow('الكيلومترات', '${ad['km'] ?? ''} كم'),
            const Divider(color: Colors.white12),
            _specRow('نوع الوقود', ad['fuel'] ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _specRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary,
            fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13,
            fontWeight: FontWeight.bold)),
        ],
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
          Text('سيارة بحالة ممتازة، استعمال نظيف، صيانة دورية. '
               'للتواصل يرجى استخدام الأزرار في الأسفل.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                final uri = Uri.parse('tel:+21370466633');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
              icon: const Icon(Icons.phone, color: Colors.white, size: 18),
              label: const Text('اتصال',
                style: TextStyle(color: Colors.white, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              final uri = Uri.parse('https://wa.me/21370466633');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white54),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.chat, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
