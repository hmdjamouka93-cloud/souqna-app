import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import 'car_detail_screen.dart';
import 'store_detail_screen.dart';
import 'product_detail_screen.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _reports = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _loading = true);
    try {
      final snap = await FirebaseFirestore.instance.collection('reports').get();
      final list = snap.docs.map((d) {
        final x = d.data();
        return {
          'id': d.id,
          'productId': (x['productId'] ?? '').toString(),
          'userId': (x['userId'] ?? '').toString(),
          'reason': (x['reason'] ?? 'بدون سبب').toString(),
          'createdAt': x['createdAt'],
        };
      }).toList();

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
        _reports = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _viewAd(String itemId) async {
    if (itemId.isEmpty) return;
    setState(() => _loading = true);
    try {
      // 1. نقلبو في الإعلانات العادية (سيارات، عقارات...)
      final docListing = await FirebaseFirestore.instance.collection('listings').doc(itemId).get();
      if (docListing.exists) {
        final adData = {'id': docListing.id, ...(docListing.data() as Map<String, dynamic>)};
        if (!mounted) return;
        setState(() => _loading = false);
        Navigator.push(context, MaterialPageRoute(builder: (_) => CarDetailScreen(ad: adData)));
        return;
      }

      // 2. نقلبو في المتاجر (إذا كان التبليغ على متجر)
      final docStore = await FirebaseFirestore.instance.collection('stores').doc(itemId).get();
      if (docStore.exists) {
        final storeData = {'id': docStore.id, ...(docStore.data() as Map<String, dynamic>)};
        if (!mounted) return;
        setState(() => _loading = false);
        Navigator.push(context, MaterialPageRoute(builder: (_) => StoreDetailScreen(store: storeData)));
        return;
      }

      // 3. إذا مالقيش، نقلبو في منتجات المتاجر
      final docProduct = await FirebaseFirestore.instance.collection('store_products').doc(itemId).get();
      if (docProduct.exists) {
        final pData = docProduct.data() as Map<String, dynamic>;
        // منتجات المتاجر كتحتاج Store كـ parameter
        final storeId = (pData['storeId'] ?? '').toString();
        final storeDoc = await FirebaseFirestore.instance.collection('stores').doc(storeId).get();
        final storeData = storeDoc.exists ? {'id': storeDoc.id, ...(storeDoc.data() as Map<String, dynamic>)} : <String, dynamic>{};
        
        if (!mounted) return;
        setState(() => _loading = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(
              product: {'id': docProduct.id, ...pData},
              store: storeData,
            ),
          ),
        );
        return;
      }

      // إذا ما لقى حتى حاجة
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('هذا الإعلان محذوف مسبقاً')));
      setState(() => _loading = false);

    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _deleteItemAndReport(String itemId, String reportId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          title:  Text('حذف الإعلان', style: TextStyle(color: AppColors.textPrimary)),
          content:  Text('هل أنت متأكد من حذف الإعلان المبلغ عنه نهائياً؟', style: TextStyle(color: AppColors.textSecondary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child:  Text('إلغاء', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child:  Text('حذف', style: TextStyle(color: AppColors.textPrimary)),
            ),
          ],
        ),
      ),
    );

    if (ok == true) {
      setState(() => _loading = true);
      try {
        await FirebaseFirestore.instance.collection('listings').doc(itemId).delete();
        await FirebaseFirestore.instance.collection('reports').doc(reportId).delete();
        _loadReports();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حدث خطأ أثناء الحذف')));
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _dismissReport(String reportId) async {
    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance.collection('reports').doc(reportId).delete();
      _loadReports();
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
          title:  Text(
            'البلاغات',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
            : _reports.isEmpty
                ?  Center(
                    child: Text('لا توجد بلاغات حالياً.', style: TextStyle(color: AppColors.textSecondary)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reports.length,
                    itemBuilder: (context, i) {
                      final r = _reports[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.report_problem, color: Colors.redAccent),
                                const SizedBox(width: 8),
                                 Text('بلاغ جديد',
                                    style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('السبب: ${r['reason']}',
                                style:  TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                            const SizedBox(height: 4),
                            Text('رقم الإعلان: ${r['productId']}',
                                style:  TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            const SizedBox(height: 12),
                            Wrap(
                              alignment: WrapAlignment.end,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.accent),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                  onPressed: () => _viewAd(r['productId']),
                                  icon: const Icon(Icons.visibility, color: AppColors.accent, size: 18),
                                  label: const Text('عرض الإعلان', style: TextStyle(color: AppColors.accent)),
                                ),
                                TextButton(
                                  onPressed: () => _dismissReport(r['id']),
                                  child:  Text('تجاهل', style: TextStyle(color: AppColors.textSecondary)),
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                  onPressed: () => _deleteItemAndReport(r['productId'], r['id']),
                                  icon:  Icon(Icons.delete, color: AppColors.textPrimary, size: 18),
                                  label:  Text('حذف', style: TextStyle(color: AppColors.textPrimary)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
