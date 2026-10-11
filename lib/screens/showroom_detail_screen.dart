import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../services/showroom_service.dart';
import 'car_detail_screen.dart';

class ShowroomDetailScreen extends StatefulWidget {
  final Map<String, dynamic> showroom;
  const ShowroomDetailScreen({super.key, required this.showroom});

  @override
  State<ShowroomDetailScreen> createState() => _ShowroomDetailScreenState();
}

class _ShowroomDetailScreenState extends State<ShowroomDetailScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _listings = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final id = (widget.showroom['id'] ?? '').toString();
    final list = await ShowroomService.getShowroomListings(id);
    if (!mounted) return;
    setState(() {
      _listings = list;
      _loading = false;
    });
  }

  void _openListing(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CarDetailScreen(ad: item)),
    );
  }

  Future<void> _call() async {
    final phone = (widget.showroom['phone'] ?? '').toString();
    if (phone.isEmpty) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _whatsapp() async {
    final phone = (widget.showroom['phone'] ?? '').toString();
    if (phone.isEmpty) return;
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final logo = (widget.showroom['logo'] ?? '').toString();
    final name = (widget.showroom['name'] ?? '').toString();
    final location = (widget.showroom['location'] ?? '').toString();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            name,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: Column(
          children: [
            // معلومات المعرض
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(35),
                          border: Border.all(
                              color:
                                  AppColors.accent.withValues(alpha: 0.5),
                              width: 2),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: logo.isNotEmpty
                            ? Image.network(logo,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const Icon(
                                    Icons.storefront,
                                    color: AppColors.accent,
                                    size: 36))
                            : const Icon(Icons.storefront,
                                color: AppColors.accent, size: 36),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.verified,
                                    color: AppColors.accent, size: 18),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined,
                                    color: AppColors.textSecondary,
                                    size: 14),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    location,
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_listings.length} سيارة',
                              style: const TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _actionBtn(
                          Icons.phone_outlined,
                          'اتصال',
                          _call,
                          isPrimary: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _actionBtn(
                          Icons.chat_outlined,
                          'واتساب',
                          _whatsapp,
                          isPrimary: false,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // الإعلانات
            Expanded(child: _buildListings()),
          ],
        ),
      ),
    );
  }

  Widget _buildListings() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }
    if (_listings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_car,
                size: 80, color: AppColors.iconInactive),
            SizedBox(height: 16),
            Text('لا توجد سيارات بعد',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.accent,
      backgroundColor: AppColors.card,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _listings.length,
        itemBuilder: (context, i) => _listingCard(_listings[i]),
      ),
    );
  }

  Widget _listingCard(Map<String, dynamic> item) {
    final images = item['images'] as List<String>;
    final img = images.isNotEmpty ? images.first : '';
    return GestureDetector(
      onTap: () => _openListing(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: img.isEmpty
                  ? Container(
                      color: Colors.black26,
                      child: const Icon(Icons.directions_car,
                          color: Colors.white24, size: 60),
                    )
                  : Container(
                      color: Colors.black26,
                      child: Image.network(img,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Center(
                                child: Icon(Icons.directions_car,
                                    color: Colors.white24, size: 60),
                              )),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['title'],
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text('${item['price']} د.ج',
                      style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: AppColors.textSecondary, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(item['location'],
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
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

  Widget _actionBtn(IconData icon, String label, VoidCallback onTap,
      {bool isPrimary = false}) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? AppColors.accent : AppColors.card,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isPrimary
                ? AppColors.accent
                : AppColors.accent.withValues(alpha: 0.5),
          ),
        ),
      ),
      icon: Icon(icon,
          color: isPrimary ? Colors.white : AppColors.accent, size: 18),
      label: Text(
        label,
        style: TextStyle(
            color: isPrimary ? Colors.white : AppColors.accent,
            fontSize: 13,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}
