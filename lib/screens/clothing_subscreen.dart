import 'package:flutter/material.dart';
import '../services/language_service.dart';
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
      textDirection: LanguageService.currentLocale.value.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
                appBar: AppBar(
                    elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon:  Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title:  Text(
            LanguageService.trCategory('الأقسام الفرعية'),
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
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.0),
                itemBuilder: (context, i) {
                  final catName = categories[i]['name']!;
                  if (catName == 'جميع الإعلانات') {
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ListingsScreen(
                            subCategoryId: catName,
                            brandName: '',
                            categoryName: catName,
                          ),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                        ),
                        child: Center(
                          child: Text(
                            LanguageService.trCategory(catName),
                            textAlign: TextAlign.center,
                            style:  TextStyle(
                              color: AppColors.accent,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
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
                        child: Text(LanguageService.trCategory(catName),
                          textAlign: TextAlign.center,
                          style:  TextStyle(color: catName == 'جميع الإعلانات' ? AppColors.accent : AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
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
