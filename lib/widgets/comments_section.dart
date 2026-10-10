import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../services/auth_gate.dart';

class CommentsSection extends StatefulWidget {
  final String listingId;
  const CommentsSection({super.key, required this.listingId});

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  final TextEditingController _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    requireAuth(context, () async {
      final user = AuthService.currentUser;
      if (user == null) return;
      final userData = await AuthService.getUserData();
      final name = (userData?['name'] ?? 'مستخدم').toString();

      setState(() => _sending = true);
      try {
        await FirebaseFirestore.instance.collection('comments').add({
          'listingId': widget.listingId,
          'userId': user.uid,
          'name': name,
          'text': text,
          'createdAt': FieldValue.serverTimestamp(),
        });
        // نزيدو عدد التعليقات
        try {
          await FirebaseFirestore.instance
              .collection('listings')
              .doc(widget.listingId)
              .update({'commentsCount': FieldValue.increment(1)});
        } catch (_) {}
        _controller.clear();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('فشل إرسال التعليق')),
          );
        }
      } finally {
        if (mounted) setState(() => _sending = false);
      }
    }, message: 'يجب تسجيل الدخول للتعليق');
  }

  Future<void> _deleteComment(String commentId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text('حذف التعليق',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text('هل أنت متأكد؟',
              style: TextStyle(color: AppColors.textSecondary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('حذف',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;
    try {
      await FirebaseFirestore.instance
          .collection('comments')
          .doc(commentId)
          .delete();
      try {
        await FirebaseFirestore.instance
            .collection('listings')
            .doc(widget.listingId)
            .update({'commentsCount': FieldValue.increment(-1)});
      } catch (_) {}
    } catch (_) {}
  }

  Future<void> _editComment(String commentId, String oldText) async {
    final ctrl = TextEditingController(text: oldText);
    final newText = await showDialog<String>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text('تعديل التعليق',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: ctrl,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'اكتب التعديل...',
              hintStyle: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('حفظ',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
    if (newText == null || newText.isEmpty) return;
    try {
      await FirebaseFirestore.instance
          .collection('comments')
          .doc(commentId)
          .update({'text': newText});
    } catch (_) {}
  }

  String _timeAgo(Timestamp? ts) {
    if (ts == null) return 'الآن';
    final diff = DateTime.now().difference(ts.toDate());
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'قبل ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'قبل ${diff.inHours} ساعة';
    if (diff.inDays < 30) return 'قبل ${diff.inDays} يوم';
    return 'قبل ${(diff.inDays / 30).floor()} شهر';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text('التعليقات',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'اكتب تعليقك',
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    border: InputBorder.none,
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: _sending ? null : _addComment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _sending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('إرسال',
                            style: TextStyle(
                                color: Colors.white, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('comments')
                .where('listingId', isEqualTo: widget.listingId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(
                        color: AppColors.accent),
                  ),
                );
              }
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text('لا توجد تعليقات',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ),
                );
              }

              final list = docs.toList()
                ..sort((a, b) {
                  final ta =
                      (a.data() as Map)['createdAt'] as Timestamp?;
                  final tb =
                      (b.data() as Map)['createdAt'] as Timestamp?;
                  if (ta == null && tb == null) return 0;
                  if (ta == null) return 1;
                  if (tb == null) return -1;
                  return tb.compareTo(ta);
                });

              return Column(
                children: list.map((d) {
                  final x = d.data() as Map<String, dynamic>;
                  return _commentItem(d.id, x);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _commentItem(String commentId, Map<String, dynamic> x) {
    final isOwner =
        AuthService.currentUser?.uid == (x['userId'] ?? '').toString();
    final name = (x['name'] ?? 'مستخدم').toString();
    final text = (x['text'] ?? '').toString();
    final time = _timeAgo(x['createdAt'] as Timestamp?);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.accent,
                child: Icon(Icons.person, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 8),
              Text(name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(time,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11)),
              if (isOwner) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => _editComment(commentId, text),
                  child: const Icon(Icons.edit_outlined,
                      color: AppColors.textSecondary, size: 16),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => _deleteComment(commentId),
                  child: const Icon(Icons.delete_outline,
                      color: Colors.redAccent, size: 16),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(text,
              style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }
}
