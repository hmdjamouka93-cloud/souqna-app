import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../services/auth_service.dart';
import 'create_store_screen.dart';
import '../services/store_service.dart';
import '../services/auth_gate.dart';
import '../services/rating_service.dart';
import '../services/product_service.dart';
import 'create_product_screen.dart';
import 'product_detail_screen.dart';
import 'orders_screen.dart';

class StoreDetailScreen extends StatefulWidget {
  final Map<String, dynamic> store;
  const StoreDetailScreen({super.key, required this.store});

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen> {
  List<Map<String, dynamic>> _products = [];
  bool _loadingProducts = true;
  double _avgRating = 0.0;
  int _ratingCount = 0;
  int _myRating = 0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadRating();
  }

  Future<void> _loadRating() async {
    final id = (widget.store['id'] ?? '').toString();
    final r = await RatingService.getStoreRating(id);
    final mine = await RatingService.getMyRating(id);
    if (!mounted) return;
    setState(() {
      _avgRating = (r['avg'] ?? 0.0) as double;
      _ratingCount = (r['count'] ?? 0) as int;
      _myRating = mine;
    });
  }

  Future<void> _openRatingDialog() async {
    if (_isOwner) return;
    if (!AuthService.isLoggedIn) {
      await requireAuth(context, _openRatingDialog,
          message: 'يجب تسجيل الدخول للتقييم.');
      return;
    }
    int temp = _myRating == 0 ? 5 : _myRating;
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (ctx, setD) => AlertDialog(
            backgroundColor: AppColors.card,
            title: const Text('قيّم المتجر',
                style: TextStyle(color: Colors.white)),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final n = i + 1;
                return IconButton(
                  onPressed: () => setD(() => temp = n),
                  icon: Icon(
                    n <= temp ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                );
              }),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إلغاء',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent),
                onPressed: () => Navigator.pop(ctx, temp),
                child: const Text('إرسال',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
    if (result == null) return;
    final ok = await RatingService.submitRating(
      storeId: (widget.store['id'] ?? '').toString(),
      stars: result,
    );
    if (!mounted) return;
    if (ok) {
      _loadRating();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال تقييمك، شكراً لك')),
      );
    }
  }

  Future<void> _loadProducts() async {
    final id = (widget.store['id'] ?? '').toString();
    final list = await ProductService.getStoreProducts(id);
    if (!mounted) return;
    setState(() {
      _products = list;
      _loadingProducts = false;
    });
  }

  bool get _isOwner =>
      AuthService.currentUser?.uid == (widget.store['userId'] ?? '').toString();

  Future<void> _call() async {
    final phone = (widget.store['phone'] ?? '').toString();
    if (phone.isEmpty) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _whatsapp() async {
    final phone = (widget.store['phone'] ?? '').toString();
    if (phone.isEmpty) return;
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text('حذف المتجر',
              style: TextStyle(color: Colors.white)),
          content: const Text(
            'هل أنت متأكد من حذف متجرك؟\n\n'
            'يمكنك استرجاعه خلال 7 أيام من خلال التواصل معنا.\n'
            'بعد 7 أيام سيتم حذفه نهائياً.',
            style: TextStyle(color: Colors.white70, height: 1.6),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('حذف',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;
    final id = (widget.store['id'] ?? '').toString();
    final done = await StoreService.deleteStore(id);
    if (!mounted) return;
    if (done) {
      Navigator.pop(context, 'deleted');
    }
  }

  Future<void> _openEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateStoreScreen(
          categoryName: (widget.store['categoryName'] ?? '').toString(),
          existing: widget.store,
        ),
      ),
    );
    if (result == true && mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final cover = (widget.store['cover'] ?? '').toString();
    final logo = (widget.store['logo'] ?? '').toString();
    final name = (widget.store['name'] ?? '').toString();
    final bio = (widget.store['bio'] ?? '').toString();
    final wilaya = (widget.store['wilaya'] ?? '').toString();
    final daira = (widget.store['daira'] ?? '').toString();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        floatingActionButton: _isOwner
            ? FloatingActionButton.extended(
                backgroundColor: AppColors.accent,
                onPressed: () async {
                  final r = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateProductScreen(
                        storeId: (widget.store['id'] ?? '').toString(),
                      ),
                    ),
                  );
                  if (r == true) setState(() {});
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('أضف منتج',
                    style: TextStyle(color: Colors.white)),
              )
            : null,
        body: CustomScrollView(
          slivers: [
            // غلاف
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: AppColors.background,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                if (_isOwner) ...[
                  IconButton(
                    icon: const Icon(Icons.receipt_long_outlined,
                        color: Colors.white, size: 22),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrdersScreen(
                          storeId: (widget.store['id'] ?? '').toString(),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        color: Colors.white, size: 22),
                    onPressed: _openEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.white, size: 22),
                    onPressed: _confirmDelete,
                  ),
                ],
                if (!_isOwner)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    color: AppColors.card,
                    onSelected: (v) {
                      if (v == 'report') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('تم إرسال الإبلاغ، شكراً لك')),
                        );
                      } else if (v == 'block') {
                        showDialog(
                          context: context,
                          builder: (ctx) => Directionality(
                            textDirection: TextDirection.rtl,
                            child: AlertDialog(
                              backgroundColor: AppColors.card,
                              title: const Text('حظر المتجر',
                                  style: TextStyle(color: Colors.white)),
                              content: const Text(
                                  'هل أنت متأكد من حظر هذا المتجر؟',
                                  style: TextStyle(color: Colors.white70)),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('إلغاء',
                                      style: TextStyle(
                                          color: AppColors.textSecondary)),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('حظر',
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else if (v == 'share') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('مشاركة المتجر قريباً')),
                        );
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'report',
                        child: Text('إبلاغ',
                            style: TextStyle(color: Colors.white)),
                      ),
                      PopupMenuItem(
                        value: 'block',
                        child: Text('حظر',
                            style: TextStyle(color: Colors.white)),
                      ),
                      PopupMenuItem(
                        value: 'share',
                        child: Text('نشر المتجر',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: cover.isNotEmpty
                    ? Image.network(cover,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            Container(color: AppColors.card))
                    : Container(color: AppColors.card),
              ),
            ),

            // معلومات المتجر
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.background,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.accent, width: 2),
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
                                  Flexible(
                                    child: Text(name,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                              if (bio.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(bio,
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13)),
                              ],
                              const SizedBox(height: 6),
                              if (wilaya.isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined,
                                        color: AppColors.textSecondary,
                                        size: 14),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        daira.isEmpty
                                            ? wilaya
                                            : '$wilaya - $daira',
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
                      ],
                    ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text('${_products.length}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 2),
                                const Text('منتج',
                                    style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 11)),
                              ],
                            ),
                            Container(
                                width: 1,
                                height: 30,
                                color: Colors.white12),
                            GestureDetector(
                              onTap: _openRatingDialog,
                              behavior: HitTestBehavior.opaque,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star,
                                          color: Colors.amber, size: 16),
                                      const SizedBox(width: 2),
                                      Text(
                                          _avgRating.toStringAsFixed(1),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                      if (_ratingCount > 0)
                                        Text(' ($_ratingCount)',
                                            style: const TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 11)),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                      _myRating > 0 ? 'تقييمك: $_myRating' : 'التقييم',
                                      style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 11)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _actionBtn(
                              Icons.phone_outlined, 'اتصال', _call,
                              isPrimary: true),
                        ),
                    if (!['ملابس نسائية', 'ملابس رجالية', 'ملابس اطفال']
                        .contains((widget.store['categoryName'] ?? '').toString())) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: _actionBtn(
                          Icons.chat_outlined, 'واتساب', _whatsapp,
                          isPrimary: false),
                      ),
                    ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // عنوان "المنتجات"
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Text('المنتجات',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold)),
              ),
            ),

            // المنتجات
            if (_loadingProducts)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  ),
                ),
              )
            else if (_products.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 60, color: AppColors.iconInactive),
                        SizedBox(height: 12),
                        Text('لا توجد منتجات بعد',
                            style: TextStyle(
                                color: Colors.white, fontSize: 15)),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final p = _products[i];
                      final img = (p['images'] as List).isNotEmpty
                          ? (p['images'] as List).first.toString()
                          : '';
                      return Stack(children: [InkWell(
                        onTap: () async {
                          final r = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(
                                product: p,
                                store: widget.store,
                              ),
                            ),
                          );
                          if (r == true) _loadProducts();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: img.isEmpty
                                    ? Container(color: AppColors.card)
                                    : Image.network(img,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) =>
                                            Container(color: AppColors.card)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (p['name'] ?? '').toString(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${p['price']} دج',
                                      style: const TextStyle(
                                          color: AppColors.accent,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_isOwner) Positioned(
                        top: 6, left: 6,
                        child: GestureDetector(
                          onTap: () async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => Directionality(
                                textDirection: TextDirection.rtl,
                                child: AlertDialog(
                                  backgroundColor: AppColors.card,
                                  title: const Text('حذف المنتج', style: TextStyle(color: Colors.white)),
                                  content: const Text('هل أنت متأكد من حذف هذا المنتج؟', style: TextStyle(color: Colors.white70)),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary))),
                                    ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف', style: TextStyle(color: Colors.white))),
                                  ],
                                ),
                              ),
                            );
                            if (ok == true) {
                              final id = (p['id'] ?? '').toString();
                              await ProductService.deleteProduct(id);
                              _loadProducts();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                            child: const Icon(Icons.delete_outline, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                      ],);
                    },
                    childCount: _products.length,
                  ),
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
