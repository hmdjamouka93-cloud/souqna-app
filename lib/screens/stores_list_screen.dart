import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../widgets/ad_banner.dart';
import '../services/store_service.dart';
import '../services/auth_service.dart';
import '../services/auth_gate.dart';
import 'create_store_screen.dart';
import 'store_detail_screen.dart';

class StoresListScreen extends StatefulWidget {
  final String categoryName;
  const StoresListScreen({super.key, required this.categoryName});

  @override
  State<StoresListScreen> createState() => _StoresListScreenState();
}

class _StoresListScreenState extends State<StoresListScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _stores = [];
  Map<String, dynamic>? _myStore;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final stores = await StoreService.getStores(widget.categoryName);
    final user = AuthService.currentUser;
    Map<String, dynamic>? mine;
    if (user != null) {
      mine = await StoreService.getMyStore(widget.categoryName);
    }
    if (!mounted) return;
    setState(() {
      _stores = stores;
      _myStore = mine;
      _loading = false;
    });
  }

  Future<void> _openCreateStore() async {
    requireAuth(context, () async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              CreateStoreScreen(categoryName: widget.categoryName),
        ),
      );
      if (result == true) _load();
    }, message: 'يجب تسجيل الدخول لإنشاء متجر');
  }

  void _openStore(Map<String, dynamic> store) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoreDetailScreen(store: store),
      ),
    ).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
                appBar: AppBar(
                    elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon:  Icon(Icons.arrow_back_ios_new,
                color: AppColors.textPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.categoryName,
            style:  TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
        ),
        body: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.accent))
            : RefreshIndicator(
                onRefresh: _load,
                color: AppColors.accent,
                backgroundColor: AppColors.card,
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
            const AdBanner(),
            const SizedBox(height: 12),
                    _buildMyStoreBanner(),
                    const SizedBox(height: 12),
                    if (_stores.isEmpty)
                       Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.storefront_outlined,
                                  size: 80, color: AppColors.iconInactive),
                              SizedBox(height: 16),
                              Text('لا توجد متاجر بعد',
                                  style: TextStyle(
                                      color: AppColors.textPrimary, fontSize: 16)),
                              SizedBox(height: 8),
                              Text('كن أول من يفتح متجر!',
                                  style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._stores.map((s) => _storeCard(s)),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildMyStoreBanner() {
    final hasStore = _myStore != null;
    return GestureDetector(
      onTap: hasStore
          ? () => _openStore(_myStore!)
          : _openCreateStore,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFA0285A), Color(0xFF6E1A3D)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.textPrimary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(hasStore ? Icons.storefront : Icons.add_business,
                  color: AppColors.textPrimary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hasStore ? 'متجري' : 'أنشئ متجرك',
                      style:  TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 3),
                  Text(
                    hasStore
                        ? (_myStore!['name'] ?? '').toString()
                        : 'اعرض منتجاتك في سوقنا',
                    style:  TextStyle(
                        color: AppColors.textPrimary, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
             Icon(Icons.arrow_back_ios_new,
                color: AppColors.textPrimary, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _storeCard(Map<String, dynamic> store) {
    final cover = (store['cover'] ?? '').toString();
    final logo = (store['logo'] ?? '').toString();
    final name = (store['name'] ?? '').toString();
    final bio = (store['bio'] ?? '').toString();
    final wilaya = (store['wilaya'] ?? '').toString();

    return GestureDetector(
      onTap: () => _openStore(store),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // غلاف
            AspectRatio(
              aspectRatio: 16 / 7,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (cover.isNotEmpty)
                    CachedNetworkImage(imageUrl: cover,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) =>
                            Container(color: AppColors.card))
                  else
                    Container(color: AppColors.card),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // الشعار + الاسم
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Transform.translate(
                    offset: const Offset(0, -20),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.accent, width: 2),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: logo.isNotEmpty
                          ? CachedNetworkImage(imageUrl: logo,
                              fit: BoxFit.cover,
                              errorWidget: (_, _, _) => const Icon(
                                  Icons.storefront,
                                  color: AppColors.accent))
                          : const Icon(Icons.storefront,
                              color: AppColors.accent),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Transform.translate(
                      offset: const Offset(0, -10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style:  TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          if (bio.isNotEmpty)
                            Text(bio,
                                style:  TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          if (wilaya.isNotEmpty)
                            Row(
                              children: [
                                 Icon(Icons.location_on_outlined,
                                    color: AppColors.textSecondary,
                                    size: 12),
                                const SizedBox(width: 2),
                                Text(wilaya,
                                    style:  TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 11)),
                              ],
                            ),
                        ],
                      ),
                    ),
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
