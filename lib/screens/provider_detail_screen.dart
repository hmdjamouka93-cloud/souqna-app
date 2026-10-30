import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../services/service_provider_service.dart';
import 'create_provider_screen.dart';
import 'create_service_screen.dart';
import '../services/service_listing_service.dart';
import 'service_detail_screen.dart';
import 'service_orders_screen.dart';
import 'chat_room_screen.dart';
import '../services/chat_service.dart';
import '../services/provider_like_service.dart';
import '../services/provider_rating_service.dart';
import '../widgets/comments_section.dart';
import '../services/auth_gate.dart';

class ProviderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> provider;
  const ProviderDetailScreen({super.key, required this.provider});

  @override
  State<ProviderDetailScreen> createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends State<ProviderDetailScreen> {
  int _likes = 0;
  int _dislikes = 0;
  String? _myReaction;
  double _avgRating = 0.0;
  int _ratingCount = 0;
  int _myRating = 0;

  List<Map<String, dynamic>> _services = [];
  bool _loadingServices = true;

  Future<void> _loadServices() async {
    final id = (widget.provider['id'] ?? '').toString();
    final list = await ServiceListingService.getProviderServices(id);
    if (!mounted) return;
    setState(() {
      _services = list;
      _loadingServices = false;
    });
  }

  bool get _isOwner =>
      AuthService.currentUser?.uid == (widget.provider['userId'] ?? '').toString();

  @override
  void initState() {
    super.initState();
    _loadServices();
    _loadLikes();
    _loadRating();
  }

  Future<void> _loadRating() async {
    final id = (widget.provider['id'] ?? '').toString();
    final r = await ProviderRatingService.getProviderRating(id);
    final mine = await ProviderRatingService.getMyRating(id);
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
      await requireAuth(context, _openRatingDialog, message: 'يجب تسجيل الدخول للتقييم.');
      return;
    }
    
    final hasOrdered = await ProviderRatingService.hasOrderedFromProvider((widget.provider['id'] ?? '').toString());
    if (!hasOrdered) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب عليك طلب خدمة أولاً لتتمكن من تقييمه.'), backgroundColor: Colors.redAccent),
      );
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
            title: const Text('قيّم مقدم الخدمة', style: TextStyle(color: Colors.white)),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final n = i + 1;
                return IconButton(
                  onPressed: () => setD(() => temp = n),
                  icon: Icon(n <= temp ? Icons.star : Icons.star_border, color: Colors.amber, size: 32),
                );
              }),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child:  Text('إلغاء', style: TextStyle(color: AppColors.textSecondary))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                onPressed: () => Navigator.pop(ctx, temp),
                child: const Text('إرسال', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
    if (result == null) return;
    final ok = await ProviderRatingService.submitRating(providerId: (widget.provider['id'] ?? '').toString(), stars: result);
    if (!mounted) return;
    if (ok) {
      _loadRating();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال تقييمك، شكراً لك')));
    }
  }

  Future<void> _loadLikes() async {
    final status = await ProviderLikeService.getLikesStatus((widget.provider['id'] ?? '').toString());
    if (!mounted) return;
    setState(() {
      _likes = status['likes'] ?? 0;
      _dislikes = status['dislikes'] ?? 0;
      _myReaction = status['myReaction'];
    });
  }

  Future<void> _toggleReaction(bool isLike) async {
    if (!AuthService.isLoggedIn) {
      await requireAuth(context, () => _toggleReaction(isLike),
          message: 'يجب تسجيل الدخول للتفاعل مع البروفايل.');
      return;
    }
    final ok = await ProviderLikeService.toggleReaction(
      providerId: (widget.provider['id'] ?? '').toString(),
      isLike: isLike,
    );
    if (ok) _loadLikes();
  }

  Widget _statsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Likes/Dislikes
          Row(
            children: [
              GestureDetector(
                onTap: () => _toggleReaction(true),
                child: Row(
                  children: [
                    Icon(_myReaction == 'like' ? Icons.thumb_up : Icons.thumb_up_outlined, color: _myReaction == 'like' ? AppColors.accent : Colors.white, size: 18),
                    const SizedBox(width: 4),
                    Text('$_likes', style: TextStyle(color: _myReaction == 'like' ? AppColors.accent : Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => _toggleReaction(false),
                child: Row(
                  children: [
                    Icon(_myReaction == 'dislike' ? Icons.thumb_down : Icons.thumb_down_outlined, color: _myReaction == 'dislike' ? Colors.red : Colors.white, size: 18),
                    const SizedBox(width: 4),
                    Text('$_dislikes', style: TextStyle(color: _myReaction == 'dislike' ? Colors.red : Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          
          Container(width: 1, height: 30, color: Colors.white12),
          
          // Rating
          GestureDetector(
            onTap: _openRatingDialog,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(_avgRating.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                if (_ratingCount > 0)
                  Text(' ($_ratingCount)', style:  TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openChat() async {
    final otherUserId = (widget.provider['userId'] ?? '').toString();
    final otherName = (widget.provider['name'] ?? '').toString();
    final otherAvatar = (widget.provider['avatar'] ?? '').toString();

    final chatId = await ChatService.getOrCreateChat(
      otherUserId: otherUserId,
      otherUserName: otherName,
      otherUserAvatar: otherAvatar,
    );

    if (chatId == null || !mounted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا يمكن بدء محادثة مع نفسك')),
        );
      }
      return;
    }

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

  Future<void> _call() async {
    final phone = (widget.provider['phone'] ?? '').toString().trim();
    if (phone.isEmpty) return;
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openEdit() async {
    final r = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateProviderScreen(existing: widget.provider),
      ),
    );
    if (r == true) Navigator.pop(context, true);
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text('حذف البروفايل', style: TextStyle(color: Colors.white)),
          content: const Text('هل أنت متأكد من حذف بروفايل الخدمات نهائياً؟', style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child:  Text('إلغاء', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('حذف', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
    if (ok == true) {
      final id = (widget.provider['id'] ?? '').toString();
      await ServiceProviderService.deleteProvider(id);
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.provider;
    final cover = (p['cover'] ?? '').toString();
    final avatar = (p['avatar'] ?? '').toString();
    final name = (p['name'] ?? '').toString();
    final trade = (p['trade'] ?? '').toString();
    final bio = (p['bio'] ?? '').toString();
    final wilaya = (p['wilaya'] ?? '').toString();
    final daira = (p['daira'] ?? '').toString();

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
                      builder: (_) => CreateServiceScreen(
                        providerId: (widget.provider['id'] ?? '').toString(),
                      ),
                    ),
                  );
                  if (r == true) _loadServices();
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('أضف خدمة', style: TextStyle(color: Colors.white)),
              )
            : null,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: AppColors.background,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                if (_isOwner) ...[
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('service_orders')
                        .where('providerId', isEqualTo: (widget.provider['id'] ?? '').toString())
                        .where('status', isEqualTo: 'pending')
                        .snapshots(),
                    builder: (context, snapshot) {
                      int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                      return Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.receipt_long_outlined, color: Colors.white),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ServiceOrdersScreen(
                                    providerId: (widget.provider['id'] ?? '').toString(),
                                  ),
                                ),
                              );
                            },
                          ),
                          if (count > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$count',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.white),
                    onPressed: _openEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                    onPressed: _confirmDelete,
                  ),
                ]
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: cover.isNotEmpty
                    ? CachedNetworkImage(imageUrl: cover, fit: BoxFit.cover,
                        errorWidget: (_, _, _) => Container(color: AppColors.card))
                    : Container(color: AppColors.card),
              ),
            ),
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
                            border: Border.all(color: AppColors.accent, width: 2),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: avatar.isNotEmpty
                              ? CachedNetworkImage(imageUrl: avatar, fit: BoxFit.cover)
                              : const Icon(Icons.person, color: AppColors.accent, size: 40),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(trade, style: const TextStyle(color: AppColors.accent, fontSize: 14, fontWeight: FontWeight.bold)),
                              if (wilaya.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    children: [
                                       Icon(Icons.location_on, color: AppColors.textSecondary, size: 14),
                                      const SizedBox(width: 4),
                                      Text('$wilaya - $daira', style:  TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (bio.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
                        child: Text(bio, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5)),
                      ),
                    ],
                    const SizedBox(height: 16),
                    _statsRow(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _call,
                              icon: const Icon(Icons.phone, color: Colors.white),
                              label: const Text('اتصال', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        if (!_isOwner) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.accent, width: 2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: _openChat,
                                icon: const Icon(Icons.chat_bubble_outline, color: AppColors.accent),
                                label: const Text('دردشة', style: TextStyle(color: AppColors.accent, fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: const Text('الخدمات المقدمة',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            if (_loadingServices)
              const SliverToBoxAdapter(
                  child: Center(
                      child:
                          CircularProgressIndicator(color: AppColors.accent)))
            else if (_services.isEmpty)
              const SliverToBoxAdapter(
                  child: Center(
                      child: Text('لا توجد خدمات مضافة',
                          style: TextStyle(color: Colors.white54))))
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final s = _services[i];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ServiceDetailScreen(
                                service: s,
                                provider: widget.provider,
                              ),
                            ),
                          );
                        },
                        child: Container(
                        decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(12)),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: CachedNetworkImage(imageUrl: 
                                (s['image'] ?? '').toString(),
                                fit: BoxFit.cover,
                                errorWidget: (_, _, _) =>
                                    Container(color: AppColors.card),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text((s['title'] ?? '').toString(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text('${s['price']} د.ج',
                                      style: const TextStyle(
                                          color: AppColors.accent,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      );
                    },
                    childCount: _services.length,
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text(
                      'التعليقات',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  CommentsSection(
                    listingId: (widget.provider['id'] ?? '').toString(),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
