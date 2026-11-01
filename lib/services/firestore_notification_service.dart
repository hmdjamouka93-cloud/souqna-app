import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreNotificationService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<List<Map<String, dynamic>>> getMyNotifications() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _db
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .get();

    final list = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();

    // Sort client-side (تجنب composite index)
    list.sort((a, b) {
      final t1 = a['createdAt'] as Timestamp?;
      final t2 = b['createdAt'] as Timestamp?;
      if (t1 == null || t2 == null) return 0;
      return t2.compareTo(t1); // الأحدث أولاً
    });

    return list;
  }

  static Future<int> getUnreadCount() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    final snapshot = await _db
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .get();

    return snapshot.docs.length;
  }

  static Future<void> markAsRead(String docId) async {
    await _db.collection('notifications').doc(docId).update({'isRead': true});
  }

  static Future<void> markAllAsRead() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _db
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _db.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  static Stream<int> unreadCountStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(0);

    return _db
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
