import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import 'add_listing_screen.dart';

class PostAdChooserScreen extends StatefulWidget {
  const PostAdChooserScreen({super.key});

  @override
  State<PostAdChooserScreen> createState() => _PostAdChooserScreenState();
}

class _PostAdChooserScreenState extends State<PostAdChooserScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('Categories')
          .get();

      final list = snap.docs.map((d) {
        final x = d.data();
        return {
          'id': d.id,
          'name': (x['name'] ?? '').toString().trim(),
          'image': (x['image'] ?? '').toString(),
          'order': x['order'] ?? 0,
          'type': (x['type'] ?? 'general').toString(),
        };
      }).toList();

      list.sort((a, b) =>
          (a['order'] as num).compareTo(b['order'] as num));

      if (!mounted) return;
      setState(() {
        _categories = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _pickCategory(Map<String, dynamic> cat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddListingScreen(
          categoryId: cat['id'],
          categoryName: cat['name'],
        ),
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
            'اختر القسم',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
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
    if (_categories.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد أقسام',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (_, i) => _categoryCard(_categories[i]),
    );
  }

  Widget _categoryCard(Map<String, dynamic> cat) {
    final imageUrl = cat['image'] as String;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _pickCategory(cat),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.25),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imageUrl.isNotEmpty)
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: Colors.black26,
                    child: const Icon(Icons.category_outlined,
                        color: Colors.white24, size: 50),
                  ),
                )
              else
                Container(
                  color: Colors.black26,
                  child: const Icon(Icons.category_outlined,
                      color: Colors.white24, size: 50),
                ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                left: 12,
                child: Text(
                  cat['name'],
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(blurRadius: 6, color: Colors.black87),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
