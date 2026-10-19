import 'package:flutter/material.dart';
import '../main.dart';
import 'listings_screen.dart';

class ClothingSubscreen extends StatelessWidget {
  const ClothingSubscreen({super.key});

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
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'الأقسام الفرعية',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
        ),
        body: GridView.builder(
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
                  border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text(
                    catName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
