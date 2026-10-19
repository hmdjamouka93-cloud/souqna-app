import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';

class ProvidersListScreen extends StatefulWidget {
  final String tradeName;
  const ProvidersListScreen({super.key, required this.tradeName});

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
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('service_providers');
      if (widget.tradeName != 'جميع الإعلانات') {
        query = query.where('trade', isEqualTo: widget.tradeName);
      }
      final snap = await query.get();

      final list = snap.docs.map((d) {
        final x = d.data();
        return {
          'id': d.id,
          'name': (x['name'] ?? '').toString(),
          'trade': (x['trade'] ?? '').toString(),
          'wilaya': (x['wilaya'] ?? '').toString(),
          'daira': (x['daira'] ?? '').toString(),
          'avatar': (x['avatar'] ?? '').toString(),
          'cover': (x['cover'] ?? '').toString(),
          'rating': x['rating'] ?? 0.0,
        };
      }).toList();

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
