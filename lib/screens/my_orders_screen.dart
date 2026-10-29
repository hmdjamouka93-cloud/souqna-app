import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../services/order_service.dart';
import '../services/notification_service.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _load();
    // نفحصو تغييرات الطلبات
    NotificationService.checkOrderStatusChanges();
  }

  Future<void> _load() async {
    final list = await OrderService.getMyOrders();
    if (!mounted) return;
    setState(() {
      _orders = list;
      _loading = false;
    });
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
            'طلباتي',
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
                    child: Text('لا توجد طلبات',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 15)),
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    color: AppColors.accent,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _orders.length,
                      itemBuilder: (_, i) => _orderCard(_orders[i]),
                    ),
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
                    : CachedNetworkImage(imageUrl: img,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) => Container(
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
          if ((o['color'] ?? '').toString().isNotEmpty ||
              (o['size'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                if ((o['color'] ?? '').toString().isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(left: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('اللون: ${o['color']}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 11)),
                  ),
                if ((o['size'] ?? '').toString().isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('المقاس: ${o['size']}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 11)),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
