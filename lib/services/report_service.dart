import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class ReportService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// يرسل تبليغ على منتج
  static Future<bool> submitReport({
    required String productId,
    required String reason,
  }) async {
    final user = AuthService.currentUser;
    if (user == null) return false;
    
    try {
      await _db.collection('reports').add({
        'productId': productId,
        'userId': user.uid,
        'reason': reason.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('REPORT_ERR: $e');
      return false;
    }
  }
}
