import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../widgets/ad_banner.dart';
import '../services/showroom_service.dart';
import '../services/auth_gate.dart';
import 'showroom_detail_screen.dart';
import 'create_showroom_screen.dart';

class RentalsListScreen extends StatefulWidget {
  const RentalsListScreen({super.key});

  @override
  State<RentalsListScreen> createState() => _RentalsListScreenState();
}

class _RentalsListScreenState extends State<RentalsListScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await ShowroomService.getAllShowrooms(type: 'rental');
    if (!mounted) return;
    setState(() {
      _items = list;
      _loading = false;
    });
  }

  Future<void> _openCreateShowroom() async {
    requireAuth(context, () async {
      if (!mounted) return;
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => const CreateShowroomScreen(type: 'rental')),
      );
      if (result == true) _load();
    }, message: 'يجب تسجيل الدخول لإنشاء وكالة');
  }

  void _openShowroom(Map<String, dynamic> showroom) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShowroomDetailScreen(showroom: showroom),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          title: const Text(
            'إيجار السيارات',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_business_outlined,
                  color: AppColors.accent),
              onPressed: _openCreateShowroom,
            ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.accent,
      backgroundColor: AppColors.card,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const AdBanner(),
          const SizedBox(height: 12),
          // بانر "أنت صاحب معرض؟"
          GestureDetector(
            onTap: _openCreateShowroom,
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFA0285A), Color(0xFF6E1A3D)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.storefront,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('أنت صاحب وكالة إيجار؟',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 3),
                        Text('أنشئ وكالتك واعرض سياراتك للكراء',
                            style: TextStyle(
                                color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 16),
                ],
              ),
            ),
          ),

          if (_items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.storefront_outlined,
                        size: 80, color: AppColors.iconInactive),
                    SizedBox(height: 16),
                    Text('لا توجد وكالات إيجار بعد',
                        style:
                            TextStyle(color: Colors.white, fontSize: 16)),
                    SizedBox(height: 8),
                    Text('كن أول وكالة إيجار!',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
            )
          else
            ..._items.map((s) => _showroomCard(s)),
        ],
      ),
    );
  }

  Widget _showroomCard(Map<String, dynamic> showroom) {
    final logo = (showroom['logo'] ?? '').toString();
    return GestureDetector(
      onTap: () => _openShowroom(showroom),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.4),
                    width: 2),
              ),
              clipBehavior: Clip.antiAlias,
              child: logo.isNotEmpty
                  ? CachedNetworkImage(imageUrl: logo,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => const Icon(
                          Icons.storefront,
                          color: AppColors.accent,
                          size: 30))
                  : const Icon(Icons.storefront,
                      color: AppColors.accent, size: 30),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified,
                          color: AppColors.accent, size: 16),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          (showroom['name'] ?? '').toString(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: AppColors.textSecondary, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          (showroom['location'] ?? '').toString(),
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_back_ios_new,
                color: AppColors.textSecondary, size: 14),
          ],
        ),
      ),
    );
  }
}
