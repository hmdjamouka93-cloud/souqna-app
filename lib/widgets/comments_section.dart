import 'package:flutter/material.dart';
import '../main.dart';

class CommentsSection extends StatefulWidget {
  const CommentsSection({super.key});
  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _comments = [
    {'name': 'أحمد', 'text': 'سيارة نظيفة، الله يبارك', 'time': 'قبل ساعتين'},
    {'name': 'محمد', 'text': 'السعر قابل للتفاوض؟', 'time': 'قبل 5 ساعات'},
  ];

  void _addComment() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _comments.insert(0, {
        'name': 'أنت',
        'text': _controller.text.trim(),
        'time': 'الآن',
      });
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text('التعليقات',
            style: TextStyle(color: Colors.white, fontSize: 15,
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
                  onPressed: _addComment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('تعليقات',
                    style: TextStyle(color: Colors.white, fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_comments.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text('لا يوجد تعليقات',
                style: TextStyle(color: AppColors.textSecondary)),
            ),
          )
        else
          ..._comments.map((c) => _commentItem(c)).toList(),
      ],
    );
  }

  Widget _commentItem(Map<String, String> c) {
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
              Text(c['name']!,
                style: const TextStyle(color: Colors.white, fontSize: 13,
                  fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(c['time']!,
                style: const TextStyle(color: AppColors.textSecondary,
                  fontSize: 11)),
            ],
          ),
          const SizedBox(height: 6),
          Text(c['text']!,
            style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }
}
