import 'package:flutter/material.dart';
import '../main.dart';
import '../services/order_service.dart';

class OrdersScreen extends StatefulWidget {
  final String storeId;
  const OrdersScreen({super.key, required this.storeId});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await OrderService.getStoreOrders(widget.storeId);
    if (!mounted) return;
    setState(() {
      _orders = list;
      _loading = false;
    });
  }

  Future<void> _setStatus(String id, String status) async {
    await OrderService.updateStatus(id, status);
    _load();
  }

  Color _statusColor(String s) {
    if (s == 'confirmed') return Colors.green;
    if (s == 'rejected') return Colors.red;
    if (s == 'delivered') return Colors.blue;
    return AppColors.accent;
  }

  String _statusLabel(String s) {
    if (s == 'confirmed') return 'مؤكد';
    if (s == 'rejected') return 'مرفوض';
    if (s == 'delivered') return 'تم التسليم';
    return 'قيد الانتظار';
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
            'الطلبات',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
        ),
        body: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.accent))
            : _orders.isEmpty
                ? const Center(
                    child: Text('لا توجد طلبات بعد',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 15)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    itemBuilder: (_, i) => _orderCard(_orders[i]),
                  ),
      ),
    );
  }

  Widget _orderCard(Map<String, dynamic> o) {
    final status = (o['status'] ?? 'pending').toString();
    final img = (o['productImage'] ?? '').toString();
    final qty = o['quantity'] ?? 1;
    final price = o['productPrice'] ?? 0;
    final total = (price is int ? price : int.tryParse('$price') ?? 0) *
        (qty is int ? qty : int.tryParse('$qty') ?? 1);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: img.isEmpty
                    ? Container(
                        width: 60,
                        height: 60,
                        color: AppColors.background,
                        child: const Icon(Icons.image_not_supported,
                            color: AppColors.iconInactive))
                    : Image.network(img,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                            width: 60,
                            height: 60,
                            color: AppColors.background)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text((o['productName'] ?? '').toString(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text('$total دج',
                        style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(status).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_statusLabel(status),
                    style: TextStyle(
                        color: _statusColor(status),
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 10),
          _infoRow('الاسم', '${o['firstName']} ${o['lastName']}'),
          _infoRow('الهاتف', (o['phone'] ?? '').toString()),
          _infoRow('الولاية',
              '${o['wilaya']} - ${o['daira']}'),
          if ((o['color'] ?? '').toString().isNotEmpty)
            _infoRow('اللون', (o['color'] ?? '').toString()),
          if ((o['size'] ?? '').toString().isNotEmpty)
            _infoRow('المقاس', (o['size'] ?? '').toString()),
          _infoRow('الكمية', '$qty'),
          const SizedBox(height: 10),
          if (status == 'pending')
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green),
                    onPressed: () => _setStatus(o['id'], 'confirmed'),
                    child: const Text('تأكيد',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red),
                    onPressed: () => _setStatus(o['id'], 'rejected'),
                    child: const Text('رفض',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          if (status == 'confirmed')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: () => _setStatus(o['id'], 'delivered'),
                child: const Text('تم التسليم',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => Directionality(
                      textDirection: TextDirection.rtl,
                      child: AlertDialog(
                        backgroundColor: AppColors.card,
                        title: const Text('حذف الطلب',
                            style: TextStyle(color: Colors.white)),
                        content: const Text(
                            'هل أنت متأكد من حذف هذا الطلب نهائياً؟',
                            style: TextStyle(color: Colors.white70)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('إلغاء',
                                style: TextStyle(
                                    color: AppColors.textSecondary)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('حذف',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  );
                  if (ok == true) {
                    await OrderService.deleteOrder(o['id']);
                    _load();
                  }
                },
                icon: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 18),
                label: const Text('حذف الطلب',
                    style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text('$label: ',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
          Expanded(
            child: Text(value,
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
