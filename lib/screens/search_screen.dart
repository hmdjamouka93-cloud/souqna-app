import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../main.dart';
import 'car_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _loading = true;
  List<Map<String, dynamic>> _allItems = [];
  List<Map<String, dynamic>> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _loadAllListings();
  }

  Future<void> _loadAllListings() async {
    try {
      final snap = await FirebaseFirestore.instance.collection('listings').get();
      final list = snap.docs.map((d) {
        final x = d.data();
        return {
          'id': d.id,
          'title': (x['title'] ?? '').toString(),
          'price': x['price'] ?? 0,
          'location': (x['location'] ?? '').toString(),
          'description': (x['description'] ?? '').toString(),
          'images': (x['images'] as List?)?.cast<String>() ?? <String>[],
          'userId': (x['userId'] ?? '').toString(),
          'storeName': (x['storeName'] ?? '').toString(),
          'isPro': (x['isPro'] ?? false) as bool,
          'details': x['details'],
        };
      }).toList();

      if (!mounted) return;
      setState(() {
        _allItems = list;
        _filteredItems = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _applySearch(String query) {
    if (query.isEmpty) {
      setState(() => _filteredItems = _allItems);
      return;
    }
    final q = query.toLowerCase();
    final results = _allItems.where((item) {
      final title = (item['title'] ?? '').toString().toLowerCase();
      final desc = (item['description'] ?? '').toString().toLowerCase();
      final loc = (item['location'] ?? '').toString().toLowerCase();
      return title.contains(q) || desc.contains(q) || loc.contains(q);
    }).toList();
    setState(() => _filteredItems = results);
  }

  void _openDetail(Map<String, dynamic> item) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => CarDetailScreen(ad: item)));
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Container(
            height: 45,
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              onChanged: _applySearch,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'ابحث بالاسم، الوصف، أو الولاية...',
                hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 12),
              ),
            ),
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
            : _filteredItems.isEmpty
                ? const Center(child: Text('لا توجد نتائج مطابقة', style: TextStyle(color: Colors.white70)))
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _filteredItems.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.75,
                    ),
                    itemBuilder: (context, i) => _itemCard(_filteredItems[i]),
                  ),
      ),
    );
  }

  Widget _itemCard(Map<String, dynamic> item) {
    final images = item['images'] as List<String>;
    final img = images.isNotEmpty ? images.first : '';
    return GestureDetector(
      onTap: () => _openDetail(item),
      child: Container(
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: img.isEmpty
                  ? Container(color: Colors.black26, child: const Icon(Icons.directions_car, color: Colors.white24, size: 40))
                  : CachedNetworkImage(imageUrl: img, fit: BoxFit.cover, errorWidget: (_, _, _) => Container(color: Colors.black26, child: const Icon(Icons.directions_car, color: Colors.white24, size: 40))),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
                children: [
                  Text(item['title'], style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('${item['price']} د.ج', style: const TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(item['location'], style: const TextStyle(color: AppColors.textSecondary, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
