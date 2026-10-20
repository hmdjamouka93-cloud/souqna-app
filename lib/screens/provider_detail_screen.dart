import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../services/service_provider_service.dart';
import 'create_provider_screen.dart';

class ProviderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> provider;
  const ProviderDetailScreen({super.key, required this.provider});

  @override
  State<ProviderDetailScreen> createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends State<ProviderDetailScreen> {
  bool get _isOwner =>
      AuthService.currentUser?.uid == (widget.provider['userId'] ?? '').toString();

  Future<void> _call() async {
    final phone = (widget.provider['phone'] ?? '').toString();
    if (phone.isEmpty) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
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
              child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary)),
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
                    ? Image.network(cover, fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(color: AppColors.card))
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
                              ? Image.network(avatar, fit: BoxFit.cover)
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
                                      const Icon(Icons.location_on, color: AppColors.textSecondary, size: 14),
                                      const SizedBox(width: 4),
                                      Text('$wilaya - $daira', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
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
                    SizedBox(
                      width: double.infinity,
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
