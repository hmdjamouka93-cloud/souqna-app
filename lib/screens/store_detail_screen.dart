import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../services/auth_service.dart';
import 'create_store_screen.dart';

class StoreDetailScreen extends StatefulWidget {
  final Map<String, dynamic> store;
  const StoreDetailScreen({super.key, required this.store});

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen> {
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
                if (_isOwner)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        color: Colors.white, size: 22),
                    onPressed: _openEdit,
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
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _actionBtn(
                              Icons.phone_outlined, 'اتصال', _call,
                              isPrimary: true),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _actionBtn(
                              Icons.chat_outlined, 'واتساب', _whatsapp,
                              isPrimary: false),
                        ),
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

            // رسالة "لا توجد منتجات"
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
