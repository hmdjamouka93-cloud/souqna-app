import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'my_orders_screen.dart';
import 'chats_list_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import 'cars_screen.dart';
import 'search_screen.dart';
import 'clothing_subscreen.dart';
import 'services_subscreen.dart';
import 'listings_screen.dart';
import 'brand_chooser_screen.dart';
import 'stores_list_screen.dart';
import 'showrooms_list_screen.dart';
import 'rentals_list_screen.dart';

/// الشاشة الرئيسية
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                _buildBanner(),
                _buildSearchBar(context),
                const SizedBox(height: 16),
                _buildSectionTitle('المركبات'),
                _buildVehiclesGrid(),
                const SizedBox(height: 24),
                _buildSectionTitle('العقارات'),
                _buildRealEstateGrid(),
                const SizedBox(height: 24),
                _buildSectionTitle('الإلكترونيات'),
                _buildElectronicsGrid(),
                const SizedBox(height: 24),
                _buildSectionTitle('الملابس'),
                _buildClothingGrid(),
                const SizedBox(height: 24),
                _buildSectionTitle('الخدمات'),
                _buildServicesGrid(),
                const SizedBox(height: 24),
                _buildSectionTitle('الحيوانات'),
                _buildPetsGrid(),
                const SizedBox(height: 24),
                _buildSectionTitle('الوظائف'),
                _buildJobsGrid(),
                const SizedBox(height: 24),
                _buildSectionTitle('التبرعات والعمل الخيري'),
                _buildCharityGrid(),
                const SizedBox(height: 20),
              ],
                ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon:  Icon(Icons.menu, color: AppColors.textPrimary, size: 26),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Souqna',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          IconButton(
            icon:  Icon(Icons.chat_bubble_outline, color: AppColors.textPrimary, size: 26),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatsListScreen()),
            ),
          ),
          IconButton(
            icon:  Icon(Icons.shopping_cart_outlined, color: AppColors.textPrimary, size: 26),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
            ),
          ),
          IconButton(
            icon:  Icon(Icons.notifications_none, color: AppColors.textPrimary, size: 26),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3), width: 1),
      ),
      child:  Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.campaign_outlined, color: AppColors.accent, size: 32),
            SizedBox(height: 6),
            Text(
              'مساحة إعلانية',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchScreen()),
        ),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
          ),
          child:  Row(
            children: [
              SizedBox(width: 14),
              Icon(Icons.search, color: AppColors.textSecondary),
              SizedBox(width: 10),
              Text('ابحث في السوق...', style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        textAlign: TextAlign.right,
        style:  TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildVehiclesGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Categories')
          .where('type', isEqualTo: 'vehicle')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          );
        }
        if (snapshot.hasError) {
          return  Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                'حدث خطأ أثناء تحميل الأقسام',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
          );
        }
        final docs = List<QueryDocumentSnapshot>.from(snapshot.data?.docs ?? [])
          ..sort((a, b) {
            final ao = (a.data() as Map)['order'] ?? 0;
            final bo = (b.data() as Map)['order'] ?? 0;
            return (ao as int).compareTo(bo as int);
          });
        if (docs.isEmpty) {
          return  Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                'لا توجد أقسام',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
          );
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 50) / 2;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: docs.map((d) {
                  final data = d.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString();
                  final image = (data['image'] ?? '').toString();
                  return SizedBox(
                    width: cardWidth,
                    height: cardWidth / 1.4,
                    child: _vehicleCard(context, name, image),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }


  Widget _buildRealEstateGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Categories')
          .where('mainCategoryId', isEqualTo: 'real_estate')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          );
        }
        if (snapshot.hasError) {
          return  Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                'حدث خطأ أثناء تحميل الأقسام',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
          );
        }
        final docs = List<QueryDocumentSnapshot>.from(snapshot.data?.docs ?? [])
          ..sort((a, b) {
            final ao = (a.data() as Map)['order'] ?? 0;
            final bo = (b.data() as Map)['order'] ?? 0;
            return (ao as int).compareTo(bo as int);
          });
        if (docs.isEmpty) {
          return  Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                'لا توجد أقسام',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
          );
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 50) / 2;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: docs.map((d) {
                  final data = d.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString();
                  final image = (data['image'] ?? '').toString();
                  return SizedBox(
                    width: cardWidth,
                    height: cardWidth / 1.4,
                    child: _vehicleCard(context, name, image),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }


  Widget _buildElectronicsGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Categories')
          .where('mainCategoryId', isEqualTo: 'electronics')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          );
        }
        if (snapshot.hasError) {
          return  Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                'حدث خطأ أثناء تحميل الأقسام',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
          );
        }
        final docs = List<QueryDocumentSnapshot>.from(snapshot.data?.docs ?? [])
          ..sort((a, b) {
            final ao = (a.data() as Map)['order'] ?? 0;
            final bo = (b.data() as Map)['order'] ?? 0;
            return (ao as int).compareTo(bo as int);
          });
        if (docs.isEmpty) {
          return  Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                'لا توجد أقسام',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
          );
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 50) / 2;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: docs.map((d) {
                  final data = d.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString();
                  final image = (data['image'] ?? '').toString();
                  return SizedBox(
                    width: cardWidth,
                    height: cardWidth / 1.4,
                    child: _vehicleCard(context, name, image),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }


  Widget _buildClothingGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Categories')
          .where('mainCategoryId', isEqualTo: 'clothing')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          );
        }
        if (snapshot.hasError) {
          return  Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                'حدث خطأ أثناء تحميل الأقسام',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
          );
        }
        final docs = List<QueryDocumentSnapshot>.from(snapshot.data?.docs ?? [])
          ..sort((a, b) {
            final ao = (a.data() as Map)['order'] ?? 0;
            final bo = (b.data() as Map)['order'] ?? 0;
            return (ao as int).compareTo(bo as int);
          });
        if (docs.isEmpty) {
          return  Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                'لا توجد أقسام',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
          );
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 50) / 2;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: docs.map((d) {
                  final data = d.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString();
                  final image = (data['image'] ?? '').toString();
                  return SizedBox(
                    width: cardWidth,
                    height: cardWidth / 1.4,
                    child: _vehicleCard(context, name, image),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildServicesGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Categories')
          .where('mainCategoryId', isEqualTo: 'services')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          );
        }
        if (snapshot.hasError) {
          return  Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                'حدث خطأ أثناء تحميل الأقسام',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
          );
        }
        final docs = List<QueryDocumentSnapshot>.from(snapshot.data?.docs ?? [])
          ..sort((a, b) {
            final ao = (a.data() as Map)['order'] ?? 0;
            final bo = (b.data() as Map)['order'] ?? 0;
            return (ao as int).compareTo(bo as int);
          });
        if (docs.isEmpty) {
          return  Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                'لا توجد أقسام',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
          );
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 50) / 2;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: docs.map((d) {
                  final data = d.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString();
                  final image = (data['image'] ?? '').toString();
                  return SizedBox(
                    width: cardWidth,
                    height: cardWidth / 1.4,
                    child: _vehicleCard(context, name, image),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPetsGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Categories')
          .where('mainCategoryId', isEqualTo: 'animals')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          );
        }
        if (snapshot.hasError) {
          return  Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                'حدث خطأ أثناء تحميل الأقسام',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
          );
        }
        final docs = List<QueryDocumentSnapshot>.from(snapshot.data?.docs ?? [])
          ..sort((a, b) {
            final ao = (a.data() as Map)['order'] ?? 0;
            final bo = (b.data() as Map)['order'] ?? 0;
            return (ao as int).compareTo(bo as int);
          });
        if (docs.isEmpty) {
          return  Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                'لا توجد أقسام',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
          );
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 50) / 2;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: docs.map((d) {
                  final data = d.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString();
                  final image = (data['image'] ?? '').toString();
                  return SizedBox(
                    width: cardWidth,
                    height: cardWidth / 1.4,
                    child: _vehicleCard(context, name, image),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildJobsGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Categories')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          );
        }
        if (snapshot.hasError) {
          return  Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                'حدث خطأ أثناء تحميل الأقسام',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
          );
        }
        final allDocs = snapshot.data?.docs ?? [];
      final docs = List<QueryDocumentSnapshot>.from(allDocs.where((d) {
        final m = (d.data() as Map)['mainCategoryId'] ?? '';
        return m.toString().trim() == 'الوظائف';
      }))
          ..sort((a, b) {
            final ao = (a.data() as Map)['order'] ?? 0;
            final bo = (b.data() as Map)['order'] ?? 0;
            return (ao as int).compareTo(bo as int);
          });
        if (docs.isEmpty) {
          return  Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                'لا توجد أقسام',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
          );
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 50) / 2;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: docs.map((d) {
                  final data = d.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString();
                  final image = (data['image'] ?? '').toString();
                  return SizedBox(
                    width: cardWidth,
                    height: cardWidth / 1.4,
                    child: _vehicleCard(context, name, image),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCharityGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Categories')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          );
        }
        if (snapshot.hasError) {
          return  Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                'حدث خطأ أثناء تحميل الأقسام',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
          );
        }
        final allDocs = snapshot.data?.docs ?? [];
      final docs = List<QueryDocumentSnapshot>.from(allDocs.where((d) {
        final m = (d.data() as Map)['mainCategoryId'] ?? '';
        return m.toString().trim() == 'التبرعات والعمل الخيري';
      }))
          ..sort((a, b) {
            final ao = (a.data() as Map)['order'] ?? 0;
            final bo = (b.data() as Map)['order'] ?? 0;
            return (ao as int).compareTo(bo as int);
          });
        if (docs.isEmpty) {
          return  Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                'لا توجد أقسام',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
          );
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 50) / 2;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: docs.map((d) {
                  final data = d.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString();
                  final image = (data['image'] ?? '').toString();
                  return SizedBox(
                    width: cardWidth,
                    height: cardWidth / 1.4,
                    child: _vehicleCard(context, name, image),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  Widget _vehicleCard(BuildContext context, String name, String image) {
    return GestureDetector(
      onTap: () => navigateToCategory(context, name),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(imageUrl: 
              image,
              fit: BoxFit.cover,
              
              errorWidget: (context, error, stack) => Container(
                color: AppColors.card,
                child:  Icon(
                  Icons.image_outlined,
                  color: AppColors.textSecondary.withValues(alpha: 0.24),
                  size: 40,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.75),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 10,
              left: 10,
              child: Text(
                name,
                textAlign: TextAlign.center,
                style:  TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black87,
                      blurRadius: 4,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void navigateToCategory(BuildContext context, String name) {
    if (name == 'سيارات') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const CarsScreen()));
    } else if (name == 'حافلات') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CarsScreen(
            categoryName: 'حافلات',
            screenTitle: 'حافلات',
          ),
        ),
      );
    } else if (name == 'شاحنات') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CarsScreen(
            categoryName: 'شاحنات',
            screenTitle: 'شاحنات',
          ),
        ),
      );
    } else if (name == 'دراجات') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CarsScreen(
            categoryName: 'دراجات',
            screenTitle: 'دراجات',
          ),
        ),
      );
    } else if (name == 'معارض السيارات') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ShowroomsListScreen()),
      );
    } else if (name == 'ايجار السيارات') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RentalsListScreen()),
      );
    } else if (name == 'معدات ثقيلة') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CarsScreen(
            categoryName: 'معدات ثقيلة',
            screenTitle: 'معدات ثقيلة',
          ),
        ),
      );
    } else if (name == 'قطع غيار') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CarsScreen(
            categoryName: 'قطع غيار',
            screenTitle: 'قطع غيار',
          ),
        ),
      );
    } else if (name == 'ملابس نسائية' ||
        name == 'ملابس رجالية' ||
        name == 'ملابس اطفال' ||
        name == 'اكسسوارات') {
      // أقسام الملابس → نظام المتاجر
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StoresListScreen(categoryName: name),
        ),
      );
    } else if (name == 'الحيوانات') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ServicesSubscreen(categoryName: name),
        ),
      );
    } else if (name == 'ملابس اخرى') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ClothingSubscreen(categoryName: name),
        ),
      );
    } else if (name == 'الخياطة والأزياء') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ServicesSubscreen(categoryName: name),
        ),
      );
    } else if (name == 'خدمات الصيانة' || name == 'خدمات' || name == 'خدمات البناء' || name == 'الخدمات الرقمية' || name == 'النقل والتوصيل' || name == 'المناسبات والأعراس' || name == 'المأكولات والمشروبات' || name == 'التعليم والدروس الخصوصية' || name == 'الرياضة واللياقة البدنية' || name == 'الصحة والجمال' || name == 'السفر والسياحة' || name == 'خدمات السيارات' || name == 'النظافة ومكافحة الحشرات' || name == 'الخدمات القانونية والإدارية' || name == 'الفلاحة والثروة الحيوانية' || name == 'الدعاية والإعلان والطباعة' || name == 'الأمن والحراسة' || name == 'رعاية الأطفال والمسنين' || name == 'الطاقة الشمسية' || name == 'الطاقة الشمسية' || name == 'كلاب وقطط' || name == 'طيور' || name == 'مواشي ودواب' || name == 'حيوانات أخرى') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ServicesSubscreen(categoryName: name),
        ),
      );
    } else if (name == 'وظائف متاحة' || name == 'الباحثين عن عمل' || name == 'المفقودات') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ListingsScreen(
            subCategoryId: '',
            brandName: '',
            categoryName: name,
          ),
        ),
      );
    } else if (name == 'التبرع') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ServicesSubscreen(categoryName: name),
        ),
      );
    } else if (name == 'دراجات هوائية وسكوتر' || name == 'بحري') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ServicesSubscreen(categoryName: name),
        ),
      );
    } else if (name == 'دراجات رباعية الدفع') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ListingsScreen(
            subCategoryId: '',
            brandName: 'جميع الإعلانات',
            categoryName: 'دراجات رباعية الدفع',
          ),
        ),
      );
    } else if (name == 'سكن للايجار' ||
        name == 'سكن للبيع' ||
        name == 'اثاث' ||
        name == 'محلات للايجار' ||
        name == 'محلات للبيع' ||
        name == 'اراضي' ||
        name == 'هواتف' ||
        name == 'حواسيب' ||
        name == 'اجهزة منزلية' ||
        name == 'العاب فيديو' ||
        name == 'كاميرات' ||
        name == 'اجهزة ذكية') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BrandChooserScreen(
            categoryId: '',
            categoryName: name,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name - قريباً')),
      );
    }
  }
}
