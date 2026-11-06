import 'package:cached_network_image/cached_network_image.dart';
import '../services/language_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import 'chat_room_screen.dart';
import '../services/report_service.dart';
import '../services/favorites_service.dart';
import '../services/views_service.dart';
import 'add_listing_screen.dart';
import '../widgets/comments_section.dart';

class CarDetailScreen extends StatefulWidget {
  final Map<String, dynamic> ad;
  const CarDetailScreen({super.key, required this.ad});
  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {
  bool _isLiked = false;
  int _likes = 0;
  int _currentPage = 0;

  List<String> get _images {
    final imgs = widget.ad['images'];
    if (imgs is List && imgs.isNotEmpty) {
      return imgs.map((e) => e.toString()).toList();
    }
    return <String>[];
  }

  @override
  void initState() {
    super.initState();
    _loadLikes();
    ViewsService.trackView((widget.ad['id'] ?? '').toString());
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
      return LanguageService.trCategory('${buf.toString()} د.ج');
    }
    return LanguageService.trCategory('$p د.ج');
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
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
            _buildCarDetails(),
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

  Future<void> _toggleFavorite(bool isFav) async {
    if (AuthService.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LanguageService.tr('login_to_fav'))),
      );
      return;
    }
    final id = (widget.ad['id'] ?? '').toString();
    if (id.isEmpty) return;

    try {
      if (isFav) {
        await FavoritesService.removeFavorite(id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LanguageService.tr('removed_from_fav'))),
        );
      } else {
        await FavoritesService.addFavorite(id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LanguageService.tr('added_to_fav'))),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LanguageService.tr('failed_try_again'))),
      );
    }
  }

  Future<void> _editListing() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddListingScreen(
          categoryId: (widget.ad['categoryName'] ?? '').toString(),
          categoryName: (widget.ad['categoryName'] ?? '').toString(),
          existingListing: widget.ad,
        ),
      ),
    );
    if (result == true && mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title:  Text(LanguageService.tr('delete_ad'),
              style: TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          content:  Text(LanguageService.tr('confirm_delete_ad'),
              style: TextStyle(color: AppColors.textSecondary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child:  Text(LanguageService.tr('cancel'),
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent),
              onPressed: () => Navigator.pop(ctx, true),
              child:  Text(LanguageService.tr('delete'),
                  style: TextStyle(color: AppColors.textPrimary)),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;

    final id = (widget.ad['id'] ?? '').toString();
    if (id.isEmpty) return;

    try {
      final comments = await FirebaseFirestore.instance
          .collection('comments')
          .where('listingId', isEqualTo: id)
          .get();
      for (final c in comments.docs) {
        await c.reference.delete();
      }
      await FirebaseFirestore.instance
          .collection('listings')
          .doc(id)
          .delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LanguageService.tr('ad_deleted'))),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LanguageService.tr('ad_delete_failed'))),
      );
    }
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
            elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon:  Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title:  Text(LanguageService.tr('ad_details'),
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
      actions: [
        StreamBuilder<bool>(
          stream: FavoritesService.favoriteStream(
              (widget.ad['id'] ?? '').toString()),
          builder: (context, snapshot) {
            final isFav = snapshot.data ?? false;
            return IconButton(
              icon: Icon(
                isFav ? Icons.star : Icons.star_border,
                color: isFav ? AppColors.accent : AppColors.textPrimary,
                size: 22,
              ),
              onPressed: () => _toggleFavorite(isFav),
            );
          },
        ),
        if (AuthService.currentUser?.uid ==
            (widget.ad['userId'] ?? '').toString()) ...[
          IconButton(
            icon:  Icon(Icons.edit_outlined,
                color: AppColors.textPrimary, size: 22),
            onPressed: _editListing,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: Colors.redAccent, size: 22),
            onPressed: _confirmDelete,
          ),
          ],
      ],
    );
  }

  Widget _buildGallery() {
    if (_images.isEmpty) {
      return Container(
        height: 240,
        color: AppColors.card,
        child:  Center(
          child: Icon(Icons.directions_car, color: AppColors.textSecondary.withValues(alpha: 0.24), size: 80),
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
            itemBuilder: (context, i) => Container(
              color: Colors.black,
              child: CachedNetworkImage(imageUrl: 
                _images[i],
                fit: BoxFit.contain,
                errorWidget: (_, _, _) => Container(
                  color: AppColors.card,
                  child:  Icon(Icons.directions_car,
                      color: AppColors.textSecondary.withValues(alpha: 0.24), size: 60),
                ),
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
                  color: _currentPage == i ? AppColors.textPrimary : AppColors.textSecondary.withValues(alpha: 0.38),
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
              style:  TextStyle(color: AppColors.textPrimary, fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          if (_location.isNotEmpty)
            Row(
              children: [
                 Icon(Icons.location_on_outlined,
                    color: AppColors.textSecondary, size: 14),
                const SizedBox(width: 4),
                Text(_location,
                    style:  TextStyle(color: AppColors.textSecondary,
                        fontSize: 12)),
              ],
            ),
          const SizedBox(height: 8),
          Text(_price,
              style: const TextStyle(color: AppColors.accent, fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('listings')
                .doc((widget.ad['id'] ?? '').toString())
                .snapshots(),
            builder: (context, snapshot) {
              final data = snapshot.data?.data() as Map<String, dynamic>?;
              final views = (data?['views'] ?? 0) as int;
              final comments = (data?['commentsCount'] ?? 0) as int;
              return Row(
                children: [
                   Icon(Icons.visibility_outlined,
                      color: AppColors.textSecondary, size: 14),
                  const SizedBox(width: 4),
                  Text('$views ${LanguageService.tr('views')}',
                      style:  TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(width: 14),
                   Icon(Icons.chat_bubble_outline,
                      color: AppColors.textSecondary, size: 14),
                  const SizedBox(width: 4),
                  Text('$comments ${LanguageService.tr('comments')}',
                      style:  TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                ],
              );
            },
          ),
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
           CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.card,
            child: Icon(Icons.storefront, color: AppColors.textSecondary, size: 24),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(LanguageService.tr('seller'),
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 14,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                Row(
                  children: [
                    if ((widget.ad['isPro'] ?? false) == true)
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(Icons.verified,
                            color: AppColors.accent, size: 12),
                      ),
                    Flexible(
                      child: Text(
                        (widget.ad['isPro'] == true &&
                                (widget.ad['storeName'] ?? '').toString().isNotEmpty)
                            ? widget.ad['storeName'].toString()
                            : LanguageService.trCategory('مستخدم سوقنا'),
                        style:  TextStyle(
                            color: AppColors.textSecondary, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.end,
            children: [
              _smallBtn(LanguageService.trCategory('دردشة'), _openChat),
              _smallBtn(LanguageService.trCategory('اتصال'), () async {
                final phone = (widget.ad['phone'] ?? '').toString();
                if (phone.isEmpty) return;
                final uri = Uri.parse('tel:$phone');
                if (await canLaunchUrl(uri)) await launchUrl(uri);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openChat() async {
    if (AuthService.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(LanguageService.tr('login_to_chat'))));
      return;
    }
    final otherUserId = (widget.ad['userId'] ?? '').toString();
    if (otherUserId.isEmpty) return;
    final otherName = ((widget.ad['storeName'] ?? '').toString().isNotEmpty) 
        ? widget.ad['storeName'].toString() 
        : LanguageService.trCategory('مستخدم سوقنا');
    final otherAvatar = '';

    final chatId = await ChatService.getOrCreateChat(
      otherUserId: otherUserId,
      otherUserName: otherName,
      otherUserAvatar: otherAvatar,
    );

    if (chatId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(LanguageService.tr('cannot_chat_self'))));
      return;
    }
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatRoomScreen(
          chatId: chatId,
          otherUserName: otherName,
          otherUserAvatar: otherAvatar,
        ),
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

  Widget _buildCarDetails() {
    final details = widget.ad['details'] as Map<String, dynamic>?;
    if (details == null || details.isEmpty) return const SizedBox.shrink();

    // قاموس الترجمة
    final labels = {
      'brand': LanguageService.trCategory('الماركة'),
      'category': LanguageService.trCategory('الفئة'),
      'gear': LanguageService.trCategory('نوع القير'),
      'color': LanguageService.trCategory('اللون'),
      'fuel': LanguageService.trCategory('الوقود'),
      'condition': LanguageService.trCategory('الحالة'),
      'warranty': LanguageService.trCategory('تحت الضمان'),
      'year': LanguageService.trCategory('سنة الصنع'),
      'mileage': LanguageService.trCategory('العداد'),
      'operation': LanguageService.trCategory('نوع العملية'),
      'propertyType': LanguageService.trCategory('نوع العقار'),
      'area': LanguageService.trCategory('المساحة'),
      'rooms': LanguageService.trCategory('عدد الغرف'),
      'floor': LanguageService.trCategory('الطابق'),
      'furnished': LanguageService.trCategory('مفروش'),
      'wilaya': LanguageService.trCategory('الولاية'),
      'daira': LanguageService.trCategory('الدائرة'),
      'payload': LanguageService.trCategory('الحمولة'),
      'seats': LanguageService.trCategory('عدد المقاعد'),
      'engineCC': LanguageService.trCategory('سعة المحرك'),
    };

    final items = <MapEntry<String, String>>[];
    details.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        final label = labels[key] ?? key;
        String displayValue = value.toString();
        if (key == 'mileage') displayValue += ' كم';
        if (key == 'area') displayValue += ' م²';
        items.add(MapEntry(label, displayValue));
      }
    });

    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(LanguageService.tr('ad_details'),
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...items.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: AppColors.accent, size: 18),
                          const SizedBox(width: 8),
                          Text(e.key,
                              style:  TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14)),
                        ],
                      ),
                      Text(e.value,
                          style:  TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                )),
          ],
        ),
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
           Text(LanguageService.tr('description'),
              style: TextStyle(color: AppColors.textPrimary, fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(_description,
              style:  TextStyle(color: AppColors.textPrimary, fontSize: 13,
                  height: 1.7)),
        ],
      ),
    );
  }

  Future<void> _loadLikes() async {
    final id = (widget.ad['id'] ?? '').toString();
    if (id.isEmpty) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('listings')
          .doc(id)
          .get();
      final likes = (doc.data()?['likes'] ?? 0) as int;
      if (mounted) setState(() => _likes = likes);
    } catch (_) {}
  }

  Future<void> _toggleLike() async {
    final user = AuthService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LanguageService.tr('login_to_like'))),
      );
      return;
    }
    final id = (widget.ad['id'] ?? '').toString();
    if (id.isEmpty) return;

    final newLiked = !_isLiked;
    final newLikes = _likes + (newLiked ? 1 : -1);
    setState(() {
      _isLiked = newLiked;
      _likes = newLikes < 0 ? 0 : newLikes;
    });
    try {
      await FirebaseFirestore.instance
          .collection('listings')
          .doc(id)
          .update({'likes': _likes});
    } catch (_) {}
  }

  Widget _buildReactions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _reactionBtn(
            _isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
            '${LanguageService.trCategory('إعجاب')} ($_likes)',
            _toggleLike,
            active: _isLiked,
          )),
          const SizedBox(width: 8),
          Expanded(child: _reactionBtn(Icons.share, LanguageService.trCategory('مشاركة'), () {
            Share.share('${LanguageService.trCategory('شوف هذه السيارة:')} $_title - $_price');
          })),
          const SizedBox(width: 8),
          Expanded(child: _reactionBtn(Icons.report_problem_outlined, LanguageService.trCategory('تبليغ'), () async {
            if (AuthService.currentUser == null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(LanguageService.tr('login_to_report'))));
              return;
            }
            final reasonCtrl = TextEditingController();
            final ok = await showDialog<bool>(
              context: context,
              builder: (ctx) => Directionality(
                textDirection: TextDirection.rtl,
                child: AlertDialog(
                  backgroundColor: AppColors.card,
                  title:  Text(LanguageService.tr('report_ad'), style: TextStyle(color: AppColors.textPrimary)),
                  content: TextField(
                    controller: reasonCtrl,
                    maxLines: 3,
                    style:  TextStyle(color: AppColors.textPrimary),
                    decoration:  InputDecoration(
                      hintText: LanguageService.tr('report_reason_hint'),
                      hintStyle: TextStyle(color: AppColors.textSecondary),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.24))),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.accent)),
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child:  Text(LanguageService.tr('cancel'), style: TextStyle(color: AppColors.textSecondary))),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => Navigator.pop(ctx, true),
                      child:  Text(LanguageService.tr('report'), style: TextStyle(color: AppColors.textPrimary)),
                    ),
                  ],
                ),
              ),
            );
            if (ok == true && reasonCtrl.text.trim().isNotEmpty) {
              final done = await ReportService.submitReport(
                productId: (widget.ad['id'] ?? '').toString(),
                reason: reasonCtrl.text.trim(),
              );
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(done ? LanguageService.tr('report_sent') : LanguageService.tr('error_try_again')),
              ));
            }
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
              color: active ? AppColors.accent : AppColors.textSecondary.withValues(alpha: 0.24), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: active ? AppColors.accent : AppColors.textPrimary, size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: active ? AppColors.accent : AppColors.textPrimary,
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
      child:  Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.campaign_outlined, color: AppColors.accent, size: 30),
            SizedBox(height: 6),
            Text(LanguageService.tr('ad_space'),
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
