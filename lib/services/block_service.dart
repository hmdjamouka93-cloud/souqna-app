import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class BlockService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static Future<bool> blockUser({required String blockedId, required String blockedName}) async {
    final user = AuthService.currentUser;
    if (user == null || user.uid == blockedId) return false;
    try {
      await _db.collection('user_blocks').add({'blockerId': user.uid, 'blockedId': blockedId, 'blockedName': blockedName, 'createdAt': FieldValue.serverTimestamp()});
      return true;
    } catch (_) { return false; }
  }
  static Future<bool> unblockUser(String docId) async {
    try { await _db.collection('user_blocks').doc(docId).delete(); return true; } catch (_) { return false; }
  }
  static Future<List<Map<String, dynamic>>> getMyBlockedUsers() async {
    final user = AuthService.currentUser;
    if (user == null) return [];
    try {
      final snap = await _db.collection('user_blocks').where('blockerId', isEqualTo: user.uid).get();
      return snap.docs.map((d) => {'id': d.id, 'blockedId': (d.data()['blockedId'] ?? '').toString(), 'blockedName': (d.data()['blockedName'] ?? 'مستخدم').toString()}).toList();
    } catch (_) { return []; }
  }
}
