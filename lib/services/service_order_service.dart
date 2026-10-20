import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class ServiceOrderService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// ينشئ طلب خدمة جديد
  static Future<String?> createOrder({
    required String providerId,
    required String serviceId,
    required String serviceTitle,
    required String clientName,
    required String clientPhone,
    required String wilaya,
    required String daira,
  }) async {
    final user = AuthService.currentUser;
    if (user == null) return null;

    try {
      final ref = await _db.collection('service_orders').add({
        'providerId': providerId,
        'serviceId': serviceId,
        'serviceTitle': serviceTitle.trim(),
        'clientId': user.uid,
        'clientName': clientName.trim(),
        'clientPhone': clientPhone.trim(),
        'wilaya': wilaya.trim(),
        'daira': daira.trim(),
        'status': 'pending', // pending, accepted, rejected, completed
        'createdAt': FieldValue.serverTimestamp(),
      });
      return ref.id;
    } catch (e) {
      print('CREATE_SERVICE_ORDER_ERR: $e');
      return null;
    }
  }

  /// يجيب طلبات صانع الخدمة
  static Future<List<Map<String, dynamic>>> getProviderOrders(String providerId) async {
    try {
      final snap = await _db
          .collection('service_orders')
          .where('providerId', isEqualTo: providerId)
          .get();
      final list = snap.docs.map((d) {
        final x = d.data();
        return {
          'id': d.id,
          'serviceTitle': (x['serviceTitle'] ?? '').toString(),
          'clientName': (x['clientName'] ?? '').toString(),
          'clientPhone': (x['clientPhone'] ?? '').toString(),
          'wilaya': (x['wilaya'] ?? '').toString(),
          'daira': (x['daira'] ?? '').toString(),
          'status': (x['status'] ?? 'pending').toString(),
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
      return list;
    } catch (e) {
      print('GET_PROVIDER_ORDERS_ERR: $e');
      return [];
    }
  }

  /// يحدث حالة الطلب
  static Future<bool> updateStatus(String orderId, String status) async {
    try {
      await _db.collection('service_orders').doc(orderId).update({'status': status});
      return true;
    } catch (e) {
      print('UPDATE_ORDER_STATUS_ERR: $e');
      return false;
    }
  }
}
