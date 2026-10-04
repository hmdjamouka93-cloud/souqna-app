import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';

class CarsScreen extends StatefulWidget {
  const CarsScreen({super.key});
  @override
  State<CarsScreen> createState() => _CarsScreenState();
}

class _CarsScreenState extends State<CarsScreen> {
  bool _loading = true;
  String _status = 'INIT';
  List<Map<String, dynamic>> _brands = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _status = 'LOADING';
    });
    try {
      final snap = await FirebaseFirestore.instance
          .collection('SubCategories')
          .where('categoryId', isEqualTo: 'سيارات')
          .get();
      final list = snap.docs.map((d) {
        final x = d.data();
        return {
          'name': (x['name'] ?? '').toString(),
          'image': (x['image'] ?? '').toString(),
          'order': (x['order'] ?? 0) is int ? x['order'] : 0,
        };
      }).toList();
      list.sort((a, b) => (a['order'] as int).compareTo(b['order'] as int));
      if (!mounted) return;
      setState(() {
        _brands = list;
        _loading = false;
        _status = 'OK: ${list.length}';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _status = 'ERR: $e';
      });
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
          title: const Text('سيارات',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              color: Colors.yellow,
              padding: const EdgeInsets.all(12),
              child: Text(
                _status,
                style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
              )
            else if (_brands.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text('لا توجد ماركات',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              )
            else
              GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.0,
                ),
                itemCount: _brands.length,
                itemBuilder: (context, i) => _card(_brands[i]),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _card(Map<String, dynamic> b) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 6),
          Text(b['name'],
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(8),
            child: SizedBox(
              height: 40,
              width: double.infinity,
              child: (b['image'] as String).isEmpty
                  ? const Icon(Icons.directions_car, color: Colors.white24, size: 32)
                  : Image.network(
                      b['image'],
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.directions_car, color: Colors.white24, size: 32),
                    ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
