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
}
