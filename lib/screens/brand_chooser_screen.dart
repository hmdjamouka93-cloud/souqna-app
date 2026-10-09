import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import 'add_listing_screen.dart';

class BrandChooserScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  const BrandChooserScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<BrandChooserScreen> createState() => _BrandChooserScreenState();
}

class _BrandChooserScreenState extends State<BrandChooserScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _items = [];
  int _totalSubs = 0;
  String _debugMsg = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('SubCategories')
          .get();

      _totalSubs = snap.size;

      final list = <Map<String, dynamic>>[];
      for (final d in snap.docs) {
        final x = d.data();
        final catId = (x['categoryId'] ?? '').toString().trim();
        if (catId == widget.categoryName.trim()) {
          list.add({
            'id': d.id,
            'name': (x['name'] ?? '').toString().trim(),
            'image': (x['image'] ?? '').toString(),
            'order': x['order'] ?? 0,
          });
        }
      }

      // نرتبو بأمان (order ممكن يكون String ولا num)
      list.sort((a, b) {
        final oa = a['order'];
        final ob = b['order'];
        final na = oa is num ? oa.toInt() : int.tryParse(oa.toString()) ?? 0;
        final nb = ob is num ? ob.toInt() : int.tryParse(ob.toString()) ?? 0;
        return na.compareTo(nb);
      });

      _debugMsg = 'Category: "${widget.categoryName}" | Total: $_totalSubs | Matched: ${list.length}';

      if (!mounted) return;
      setState(() {
        _items = list;
        _loading = false;
      });
    } catch (e) {
      _debugMsg = 'ERROR: $e';
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _pickBrand(Map<String, dynamic> brand) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddListingScreen(
          categoryId: widget.categoryId,
          categoryName: widget.categoryName,
          subCategoryId: brand['id'],
          subCategoryName: brand['name'],
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
          title: Text(
            'اختر النوع - ${widget.categoryName}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
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
    if (_items.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد أنواع',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (_, i) => _brandCard(_items[i]),
    );
  }

  Widget _brandCard(Map<String, dynamic> brand) {
    final imageUrl = brand['image'] as String;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _pickBrand(brand),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.2),
            ),
          ),
          padding: const EdgeInsets.all(6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.zero,
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.directions_car,
                            color: Colors.white24,
                            size: 40,
                          ),
                        )
                      : const Icon(
                          Icons.directions_car,
                          color: Colors.white24,
                          size: 40,
                        ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                brand['name'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
