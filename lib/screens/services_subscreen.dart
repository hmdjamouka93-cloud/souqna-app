import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import 'listings_screen.dart';

class ServicesSubscreen extends StatefulWidget {
  const ServicesSubscreen({super.key});

  @override
  State<ServicesSubscreen> createState() => _ServicesSubscreenState();
}

class _ServicesSubscreenState extends State<ServicesSubscreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('SubCategories')
          .where('categoryId', isEqualTo: 'خدمات الصيانة')
          .get();

      final list = snap.docs.map((d) {
        final x = d.data();
        return {
          'name': (x['name'] ?? '').toString().trim(),
          'image': (x['image'] ?? '').toString(),
          'order': x['order'] ?? 0,
        };
      }).toList();

      list.sort((a, b) {
        final oa = a['order'] is num ? a['order'].toInt() : 0;
        final ob = b['order'] is num ? b['order'].toInt() : 0;
        return oa.compareTo(ob);
      });

      if (!mounted) return;
      setState(() {
        _items = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
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
            'خدمات الصيانة',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
        ),
        body: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.accent))
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _items.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, i) {
                  final name = _items[i]['name'] as String;
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ListingsScreen(
                            subCategoryId: name,
                            brandName: '',
                            categoryName: name,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.3)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            _items[i]['image'] as String,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                                color: AppColors.card,
                                child: const Icon(Icons.image_outlined,
                                    color: AppColors.iconInactive, size: 40)),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.8),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 8,
                            left: 8,
                            child: Text(
                              name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                        blurRadius: 6,
                                        color: Colors.black87),
                                  ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
