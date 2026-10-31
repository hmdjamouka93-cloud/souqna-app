import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import '../widgets/ad_banner.dart';
import 'listings_screen.dart';
import 'providers_list_screen.dart';

class ServicesSubscreen extends StatefulWidget {
  final String categoryName;
  const ServicesSubscreen({super.key, required this.categoryName});

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
          .where('categoryId', isEqualTo: widget.categoryName)
          .get();

      final list = snap.docs.map((d) {
        final x = d.data();
        return {
          'id': d.id,
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
            icon:  Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.categoryName,
            style:  TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
        ),
        body: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.accent))
            : Column(
                children: [
                  const SizedBox(height: 16),
                  const AdBanner(),
                   Padding(
                    padding: EdgeInsets.only(top: 16, right: 16, left: 16),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text('الأقسام الفرعية',
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
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
                        final id = _items[i]['id'] as String;

                        return InkWell(
                          onTap: () {
                            if (widget.categoryName == 'المناسبات والأعراس' || widget.categoryName == 'المأكولات والمشروبات' || widget.categoryName == 'التعليم والدروس الخصوصية' || widget.categoryName == 'الرياضة واللياقة البدنية' || widget.categoryName == 'الصحة والجمال' || widget.categoryName == 'السفر والسياحة' || widget.categoryName == 'خدمات السيارات' || widget.categoryName == 'النظافة ومكافحة الحشرات' || widget.categoryName == 'الخدمات القانونية والإدارية' || widget.categoryName == 'الفلاحة والثروة الحيوانية' || widget.categoryName == 'الدعاية والإعلان والطباعة' || widget.categoryName == 'الأمن والحراسة' || widget.categoryName == 'رعاية الأطفال والمسنين' || widget.categoryName == 'الطاقة الشمسية' || widget.categoryName == 'كلاب وقطط' || widget.categoryName == 'طيور' || widget.categoryName == 'مواشي ودواب' || widget.categoryName == 'حيوانات أخرى' || widget.categoryName == 'التبرع' || widget.categoryName == 'دراجات هوائية وسكوتر' || widget.categoryName == 'بحري') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ListingsScreen(
                                    subCategoryId: name == 'جميع الإعلانات' ? 'جميع الإعلانات' : id,
                                    brandName: '',
                                    categoryName: widget.categoryName,
                                  ),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProvidersListScreen(
                                    tradeName: name,
                                    parentCategory: widget.categoryName,
                                  ),
                                ),
                              );
                            }
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
                                if (name == 'جميع الإعلانات')
                                  Container(
                                    color: AppColors.card,
                                    child: const Center(
                                      child: Icon(Icons.list_alt,
                                          color: AppColors.accent, size: 50),
                                    ),
                                  )
                                else
                                  CachedNetworkImage(imageUrl: 
                                    _items[i]['image'] as String,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, _, _) => Container(
                                      color: AppColors.card,
                                      child:  Icon(Icons.image_outlined,
                                          color: AppColors.iconInactive, size: 40),
                                    ),
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
                                    style:  TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 6,
                                          color: Colors.black87,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
