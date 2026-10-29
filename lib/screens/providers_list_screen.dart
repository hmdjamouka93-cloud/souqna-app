import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import 'provider_detail_screen.dart';

class ProvidersListScreen extends StatefulWidget {
  final String tradeName;
  final String parentCategory;
  const ProvidersListScreen({super.key, required this.tradeName, this.parentCategory = ''});

  @override
  State<ProvidersListScreen> createState() => _ProvidersListScreenState();
}

class _ProvidersListScreenState extends State<ProvidersListScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _providers = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      List<Map<String, dynamic>> list = [];

      if (widget.tradeName == 'جميع الإعلانات') {
        if (widget.parentCategory.isNotEmpty) {
          // نجيبو الأقسام الفرعية متع القسم الأب
          final subSnap = await FirebaseFirestore.instance
              .collection('SubCategories')
              .where('categoryId', isEqualTo: widget.parentCategory)
              .get();
          
          final validTrades = subSnap.docs.map((e) => (e.data()['name'] ?? '').toString().trim()).toList();

          // نجيبو كل مقدمي الخدمات ونفلتروهم
          final snap = await FirebaseFirestore.instance.collection('service_providers').get();
          list = snap.docs.where((d) {
            final trade = (d.data()['trade'] ?? '').toString().trim();
            return validTrades.contains(trade);
          }).map((d) {
            final x = d.data();
            return {
              'id': d.id,
              'userId': (x['userId'] ?? '').toString(),
              'name': (x['name'] ?? '').toString(),
              'trade': (x['trade'] ?? '').toString(),
              'wilaya': (x['wilaya'] ?? '').toString(),
              'daira': (x['daira'] ?? '').toString(),
              'avatar': (x['avatar'] ?? '').toString(),
              'cover': (x['cover'] ?? '').toString(),
              'rating': x['rating'] ?? 0.0,
            };
          }).toList();
        } else {
          // إذا ماكانش parentCategory، نجيبو الكل (حالة احتياطية)
          final snap = await FirebaseFirestore.instance.collection('service_providers').get();
          list = snap.docs.map((d) {
            final x = d.data();
            return {
              'id': d.id,
              'userId': (x['userId'] ?? '').toString(),
              'name': (x['name'] ?? '').toString(),
              'trade': (x['trade'] ?? '').toString(),
              'wilaya': (x['wilaya'] ?? '').toString(),
              'daira': (x['daira'] ?? '').toString(),
              'avatar': (x['avatar'] ?? '').toString(),
              'cover': (x['cover'] ?? '').toString(),
              'rating': x['rating'] ?? 0.0,
            };
          }).toList();
        }
      } else {
        // قسم فرعي محدد (كيما سباكة)
        final snap = await FirebaseFirestore.instance
            .collection('service_providers')
            .where('trade', isEqualTo: widget.tradeName)
            .get();
        
        list = snap.docs.map((d) {
          final x = d.data();
          return {
            'id': d.id,
            'userId': (x['userId'] ?? '').toString(),
            'name': (x['name'] ?? '').toString(),
            'trade': (x['trade'] ?? '').toString(),
            'wilaya': (x['wilaya'] ?? '').toString(),
            'daira': (x['daira'] ?? '').toString(),
            'avatar': (x['avatar'] ?? '').toString(),
            'cover': (x['cover'] ?? '').toString(),
            'rating': x['rating'] ?? 0.0,
          };
        }).toList();
      }

      if (!mounted) return;
      setState(() {
        _providers = list;
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
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.tradeName,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
            : _providers.isEmpty
                ? const Center(
                    child: Text('لا يوجد صانعو خدمات في هذا القسم بعد',
                        style: TextStyle(color: Colors.white70, fontSize: 15)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _providers.length,
                    itemBuilder: (context, i) {
                      final p = _providers[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          onTap: () async {
                            final r = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProviderDetailScreen(provider: p),
                              ),
                            );
                            if (r == true) _load();
                          },
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundColor: AppColors.background,
                            backgroundImage: (p['avatar'] as String).isNotEmpty
                                ? NetworkImage(p['avatar'])
                                : null,
                            child: (p['avatar'] as String).isEmpty
                                ? const Icon(Icons.person, color: AppColors.accent)
                                : null,
                          ),
                          title: Text(p['name'],
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text('${p['wilaya']} - ${p['daira']}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
