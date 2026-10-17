import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class ProductLikeService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// يجيب عدد اللايكات والديسلايكات وتفاعل المستخدم الحالي
  static Future<Map<String, dynamic>> getLikesStatus(String productId) async {
    try {
      final snap = await _db
          .collection('product_likes')
          .where('productId', isEqualTo: productId)
          .get();

      int likes = 0;
      int dislikes = 0;
      String? myReaction;
      final user = AuthService.currentUser;

      for (final doc in snap.docs) {
        final data = doc.data();
        if (data['isLike'] == true) {
          likes++;
        } else {
          dislikes++;
        }

        if (user != null && data['userId'] == user.uid) {
          myReaction = data['isLike'] == true ? 'like' : 'dislike';
        }
      }

      return {
        'likes': likes,
        'dislikes': dislikes,
        'myReaction': myReaction,
      };
    } catch (e) {
      print('GET_LIKES_ERR: $e');
      return {'likes': 0, 'dislikes': 0, 'myReaction': null};
    }
  }

  /// يضيف أو يحدث أو يحذف تفاعل المستخدم
  static Future<bool> toggleReaction({
    required String productId,
    required bool isLike,
  }) async {
    final user = AuthService.currentUser;
    if (user == null) return false;

    try {
      final snap = await _db
          .collection('product_likes')
          .where('productId', isEqualTo: productId)
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        final doc = snap.docs.first;
        final currentIsLike = doc.data()['isLike'] as bool? ?? false;

        if (currentIsLike == isLike) {
          // نفس التفاعل -> حذف (إلغاء اللايك)
          await doc.reference.delete();
        } else {
          // تغيير التفاعل (من لايك لديسلايك أو العكس)
          await doc.reference.update({
            'isLike': isLike,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      } else {
        // تفاعل جديد
        await _db.collection('product_likes').add({
          'productId': productId,
          'userId': user.uid,
          'isLike': isLike,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return true;
    } catch (e) {
      print('TOGGLE_LIKE_ERR: $e');
      return false;
    }
  }
}
