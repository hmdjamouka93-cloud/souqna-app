import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import '../services/firestore_notification_service.dart';
import '../services/language_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await FirestoreNotificationService.getMyNotifications();
    if (mounted) {
      setState(() {
        _notifications = list;
        _loading = false;
      });
    }
  }

  String _timeAgo(Timestamp? ts) {
    if (ts == null) return '';
    final now = DateTime.now();
    final diff = now.difference(ts.toDate());
    if (diff.inMinutes < 1) return LanguageService.trCategory('دوك');
    if (diff.inMinutes < 60) return '${LanguageService.trCategory('قبل')} ${diff.inMinutes} ${LanguageService.trCategory('دقيقة')}';
    if (diff.inHours < 24) return '${LanguageService.trCategory('قبل')} ${diff.inHours} ${LanguageService.trCategory('ساعة')}';
    if (diff.inDays < 30) return '${LanguageService.trCategory('قبل')} ${diff.inDays} ${LanguageService.trCategory('يوم')}';
    return '${LanguageService.trCategory('قبل')} ${(diff.inDays / 30).floor()} ${LanguageService.trCategory('شهر')}';
  }

  IconData _iconForType(String? type) {
    switch (type) {
      case 'order':
        return Icons.shopping_bag_outlined;
      case 'comment':
        return Icons.chat_bubble_outline;
      case 'admin':
        return Icons.campaign_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LanguageService.trCategory('الإشعارات'), style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.card,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        actions: [
          if (_notifications.any((n) => n['isRead'] == false))
            TextButton(
              onPressed: () async {
                await FirestoreNotificationService.markAllAsRead();
                _load();
              },
              child: Text(LanguageService.trCategory('تحديد الكل كمقروء'), style: TextStyle(color: AppColors.accent)),
            ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_outlined,
                          size: 80, color: AppColors.iconInactive),
                      const SizedBox(height: 16),
                      Text(LanguageService.tr('no_notifications'),
                          style: TextStyle(
                              color: AppColors.textPrimary, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _notifications.length,
                  itemBuilder: (context, i) {
                    final n = _notifications[i];
                    final isRead = n['isRead'] == true;
                    return GestureDetector(
                      onTap: () async {
                        if (!isRead) {
                          await FirestoreNotificationService.markAsRead(n['id']);
                          _load();
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: isRead
                              ? null
                              : Border.all(color: AppColors.accent, width: 1.5),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _iconForType(n['type']?.toString()),
                                color: AppColors.accent,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (n['title'] ?? '').toString(),
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: isRead
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    (n['body'] ?? '').toString(),
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _timeAgo(n['createdAt'] as Timestamp?),
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
