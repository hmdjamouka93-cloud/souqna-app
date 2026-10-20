import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class ProviderLikeService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<Map<String, dynamic>> getLikesStatus(String providerId) async {
    try {
      final snap = await _db
          .collection('provider_likes')
          .where('providerId', isEqualTo: providerId)
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
      print('GET_PROVIDER_LIKES_ERR: $e');
      return {'likes': 0, 'dislikes': 0, 'myReaction': null};
    }
  }

  static Future<bool> toggleReaction({
    required String providerId,
    required bool isLike,
  }) async {
    final user = AuthService.currentUser;
    if (user == null) return false;

    try {
      final snap = await _db
          .collection('provider_likes')
          .where('providerId', isEqualTo: providerId)
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        final doc = snap.docs.first;
        final currentIsLike = doc.data()['isLike'] as bool? ?? false;

        if (currentIsLike == isLike) {
          await doc.reference.delete();
        } else {
          await doc.reference.update({
            'isLike': isLike,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      } else {
        await _db.collection('provider_likes').add({
          'providerId': providerId,
          'userId': user.uid,
          'isLike': isLike,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return true;
    } catch (e) {
      print('TOGGLE_PROVIDER_LIKE_ERR: $e');
      return false;
    }
  }
}
