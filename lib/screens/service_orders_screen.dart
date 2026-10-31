import 'package:flutter/material.dart';
import '../main.dart';
import '../services/service_order_service.dart';

class ServiceOrdersScreen extends StatefulWidget {
  final String providerId;
  const ServiceOrdersScreen({super.key, required this.providerId});

  @override
  State<ServiceOrdersScreen> createState() => _ServiceOrdersScreenState();
}

class _ServiceOrdersScreenState extends State<ServiceOrdersScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await ServiceOrderService.getProviderOrders(widget.providerId);
    if (!mounted) return;
    setState(() {
      _orders = list;
      _loading = false;
    });
  }

  Future<void> _setStatus(String id, String status) async {
    await ServiceOrderService.updateStatus(id, status);
    _load();
  }

  Color _statusColor(String s) {
    if (s == 'accepted') return Colors.green;
    if (s == 'rejected') return Colors.red;
    if (s == 'completed') return Colors.blue;
    return AppColors.accent;
  }

  String _statusLabel(String s) {
    if (s == 'accepted') return 'مقبول';
    if (s == 'rejected') return 'مرفوض';
    if (s == 'completed') return 'مكتمل';
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
            icon:  Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title:  Text(
            'طلبات الخدمة',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
            : _orders.isEmpty
                ?  Center(
                    child: Text('لا توجد طلبات بعد',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
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
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  (o['serviceTitle'] ?? '').toString(),
                  style:  TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(status).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel(status),
                  style: TextStyle(color: _statusColor(status), fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
           Divider(color: AppColors.textSecondary.withValues(alpha: 0.12), height: 1),
          const SizedBox(height: 12),
          _infoRow('الاسم', (o['clientName'] ?? '').toString()),
          _infoRow('الهاتف', (o['clientPhone'] ?? '').toString()),
          _infoRow('الموقع', '${o['wilaya']} - ${o['daira']}'),
          const SizedBox(height: 12),
          
          if (status == 'pending')
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () => _setStatus(o['id'], 'accepted'),
                    child:  Text('قبول', style: TextStyle(color: AppColors.textPrimary)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () => _setStatus(o['id'], 'rejected'),
                    child:  Text('رفض', style: TextStyle(color: AppColors.textPrimary)),
                  ),
                ),
              ],
            ),
          if (status == 'accepted')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: () => _setStatus(o['id'], 'completed'),
                child:  Text('تم الإنجاز', style: TextStyle(color: AppColors.textPrimary)),
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
          Text('$label: ', style:  TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Expanded(
            child: Text(value, style:  TextStyle(color: AppColors.textPrimary, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
