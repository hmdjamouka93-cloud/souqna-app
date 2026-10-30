import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import '../widgets/ad_banner.dart';
import 'car_detail_screen.dart';

class ListingsScreen extends StatefulWidget {
  final String subCategoryId;
  final String brandName;
  final String? categoryName;

  const ListingsScreen({
    super.key,
    required this.subCategoryId,
    required this.brandName,
    this.categoryName,
  });

  @override
  State<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _allItems = [];
  String _sortBy = 'newest';
  double? _minPrice;
  double? _maxPrice;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final query = (widget.subCategoryId.isEmpty ||
              widget.subCategoryId == 'جميع الإعلانات' ||
              widget.subCategoryId == '__all__')
          ? FirebaseFirestore.instance
              .collection('listings')
              .where('categoryName', isEqualTo: widget.categoryName)
          : FirebaseFirestore.instance
              .collection('listings')
              .where('subCategoryId', isEqualTo: widget.subCategoryId);

      final snap = await query.get();
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
          'phone': (x['phone'] ?? '').toString(),
          'commentsCount': (x['commentsCount'] ?? 0) as int,
          'views': (x['views'] ?? 0) as int,
          'storeName': (x['storeName'] ?? '').toString(),
          'isPro': (x['isPro'] ?? false) as bool,
          'details': x['details'],
          'createdAt': x['createdAt'],
        };
      }).toList();

      // ترتيب أولي حسب الأحدث
      list.sort((a, b) {
        final ta = a['createdAt'] as Timestamp?;
        final tb = b['createdAt'] as Timestamp?;
        if (ta == null && tb == null) return 0;
        if (ta == null) return 1;
        if (tb == null) return -1;
        return tb.compareTo(ta);
      });

      if (!mounted) return;
      setState(() {
        _allItems = list;
        _loading = false;
      });
      _applyFilters();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_allItems);

    if (_minPrice != null) {
      filtered = filtered.where((item) {
        final p = item['price'] ?? 0;
        return (p is int ? p : int.tryParse(p.toString()) ?? 0) >= _minPrice!;
      }).toList();
    }

    if (_maxPrice != null) {
      filtered = filtered.where((item) {
        final p = item['price'] ?? 0;
        return (p is int ? p : int.tryParse(p.toString()) ?? 0) <= _maxPrice!;
      }).toList();
    }

    if (_sortBy == 'price_asc') {
      filtered.sort((a, b) =>
          (int.tryParse(a['price'].toString()) ?? 0)
              .compareTo(int.tryParse(b['price'].toString()) ?? 0));
    } else if (_sortBy == 'price_desc') {
      filtered.sort((a, b) =>
          (int.tryParse(b['price'].toString()) ?? 0)
              .compareTo(int.tryParse(a['price'].toString()) ?? 0));
    } else {
      filtered.sort((a, b) {
        final ta = a['createdAt'] as Timestamp?;
        final tb = b['createdAt'] as Timestamp?;
        if (ta == null && tb == null) return 0;
        if (ta == null) return 1;
        if (tb == null) return -1;
        return tb.compareTo(ta);
      });
    }

    setState(() {
      _items = filtered;
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom,
                  left: 16,
                  right: 16,
                  top: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('الفلترة بالسعر',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: _sheetTextField('من (د.ج)', _minPrice, (v) {
                        _minPrice = double.tryParse(v);
                      })),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _sheetTextField('إلى (د.ج)', _maxPrice, (v) {
                        _maxPrice = double.tryParse(v);
                      })),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _applyFilters();
                    },
                    child: const Text('تطبيق الفلترة',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _sheetTextField(
      String hint, double? initialValue, Function(String) onChanged) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.card, borderRadius: BorderRadius.circular(10)),
      child: TextField(
        onChanged: onChanged,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }

  void _openDetail(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CarDetailScreen(ad: item)),
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
          title: Text(widget.brandName,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.accent));
    }

    if (_items.isEmpty) {
      return Column(
        children: [
          const SizedBox(height: 16),
          const AdBanner(),
          const SizedBox(height: 16),
          const Expanded(
            child: Center(
              child: Text('لا توجد إعلانات',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      );
    }

    final int chunkSize = 14;
    final List<Widget> slivers = [
      const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 16, bottom: 8),
          child: AdBanner(),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('الأحدث',
                            style: TextStyle(fontSize: 12)),
                        selected: _sortBy == 'newest',
                        selectedColor: AppColors.accent,
                        labelStyle: TextStyle(
                            color: _sortBy == 'newest'
                                ? Colors.white
                                : Colors.white70),
                        onSelected: (v) {
                          setState(() => _sortBy = 'newest');
                          _applyFilters();
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('الأرخص',
                            style: TextStyle(fontSize: 12)),
                        selected: _sortBy == 'price_asc',
                        selectedColor: AppColors.accent,
                        labelStyle: TextStyle(
                            color: _sortBy == 'price_asc'
                                ? Colors.white
                                : Colors.white70),
                        onSelected: (v) {
                          setState(() => _sortBy = 'price_asc');
                          _applyFilters();
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('الأغلى',
                            style: TextStyle(fontSize: 12)),
                        selected: _sortBy == 'price_desc',
                        selectedColor: AppColors.accent,
                        labelStyle: TextStyle(
                            color: _sortBy == 'price_desc'
                                ? Colors.white
                                : Colors.white70),
                        onSelected: (v) {
                          setState(() => _sortBy = 'price_desc');
                          _applyFilters();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _showFilterSheet,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      const Icon(Icons.tune, color: AppColors.accent, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    ];

    for (int i = 0; i < _items.length; i += chunkSize) {
      final int end =
          (i + chunkSize < _items.length) ? i + chunkSize : _items.length;
      final int count = end - i;

      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _listingCard(_items[i + index]),
              childCount: count,
            ),
          ),
        ),
      );

      if (end < _items.length) {
        slivers.add(
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: AdBanner(),
            ),
          ),
        );
      }
    }

    return CustomScrollView(
      slivers: slivers,
    );
  }

  Widget _listingCard(Map<String, dynamic> item) {
    final images = item['images'] as List<String>;
    final img = images.isNotEmpty ? images.first : '';

    return GestureDetector(
      onTap: () => _openDetail(item),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  img.isEmpty
                      ? Container(
                          color: Colors.black26,
                          child: const Icon(Icons.directions_car,
                              color: Colors.white24, size: 40),
                        )
                      : CachedNetworkImage(
                          imageUrl: img,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) => Container(
                            color: Colors.black26,
                            child: const Icon(Icons.directions_car,
                                color: Colors.white24, size: 40),
                          ),
                        ),
                  if (item['isPro'] == true &&
                      (item['storeName'] ?? '').toString().isNotEmpty)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified,
                                color: AppColors.accent, size: 12),
                            SizedBox(width: 3),
                            Text('Pro',
                                style: TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item['title'],
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item['price']} د.ج',
                    style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: AppColors.textSecondary, size: 12),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          item['location'],
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 10),
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
      ),
    );
  }
}
