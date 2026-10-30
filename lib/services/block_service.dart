import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class BlockService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// يحظر مستخدم
  static Future<bool> blockUser({
    required String blockedId,
    required String blockedName,
  }) async {
    final user = AuthService.currentUser;
    if (user == null || user.uid == blockedId) return false;

    try {
      await _db.collection('user_blocks').add({
        'blockerId': user.uid,
        'blockedId': blockedId,
        'blockedName': blockedName,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('BLOCK_ERR: $e');
      return false;
    }
  }

  /// ينحي الحظر
  static Future<bool> unblockUser(String docId) async {
    try {
      await _db.collection('user_blocks').doc(docId).delete();
      return true;
    } catch (e) {
      print('UNBLOCK_ERR: $e');
      return false;
    }
  }

  /// يجيب لستة المحظورين متع المستخدم الحالي
  static Future<List<Map<String, dynamic>>> getMyBlockedUsers() async {
    final user = AuthService.currentUser;
    if (user == null) return [];

    try {
      final snap = await _db
          .collection('user_blocks')
          .where('blockerId', isEqualTo: user.uid)
          .get();

      final list = snap.docs.map((d) {
        final x = d.data();
        return {
          'id': d.id,
          'blockedId': (x['blockedId'] ?? '').toString(),
          'blockedName': (x['blockedName'] ?? 'مستخدم').toString(),
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
      print('GET_BLOCKS_ERR: $e');
      return [];
    }
  }
}
