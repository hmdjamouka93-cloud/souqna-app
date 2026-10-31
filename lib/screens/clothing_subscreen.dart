import 'package:flutter/material.dart';
import '../main.dart';
import '../widgets/ad_banner.dart';
import 'listings_screen.dart';

class ClothingSubscreen extends StatelessWidget {
  final String categoryName;
  const ClothingSubscreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'جميع الإعلانات'},
      {'name': 'ملابس رجالية'},
      {'name': 'ملابس نسائية'},
      {'name': 'ملابس اطفال'},
      {'name': 'اكسسوارات'},
    ];

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
          title:  Text(
            'الأقسام الفرعية',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 16),
            const AdBanner(),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, i) {
                  final catName = categories[i]['name']!;
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ListingsScreen(
                            subCategoryId: catName,
                            brandName: '',
                            categoryName: catName,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                      ),
                      child: Center(
                        child: Text(
                          catName,
                          textAlign: TextAlign.center,
                          style:  TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
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
