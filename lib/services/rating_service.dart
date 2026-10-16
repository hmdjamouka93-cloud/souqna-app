import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class RatingService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// المستخدم الحالي يعطي تقييم لمتجر
  static Future<bool> submitRating({
    required String storeId,
    required int stars,
  }) async {
    final user = AuthService.currentUser;
    if (user == null) return false;
    try {
      // نشوفو إذا عندو تقييم قبل
      final existing = await _db
          .collection('ratings')
          .where('storeId', isEqualTo: storeId)
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        // نحدثو
        await _db
            .collection('ratings')
            .doc(existing.docs.first.id)
            .update({
          'stars': stars,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        // نزيدو جديد
        await _db.collection('ratings').add({
          'storeId': storeId,
          'userId': user.uid,
          'stars': stars,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return true;
    } catch (e) {
      print('RATING_ERR: $e');
      return false;
    }
  }

  /// معدل التقييمات + عدد
  static Future<Map<String, dynamic>> getStoreRating(String storeId) async {
    try {
      final snap = await _db
          .collection('ratings')
          .where('storeId', isEqualTo: storeId)
          .get();
      if (snap.docs.isEmpty) {
        return {'avg': 0.0, 'count': 0};
      }
      int sum = 0;
      for (final d in snap.docs) {
        sum += (d.data()['stars'] ?? 0) as int;
      }
      return {
        'avg': sum / snap.docs.length,
        'count': snap.docs.length,
      };
    } catch (e) {
      print('GET_RATING_ERR: $e');
      return {'avg': 0.0, 'count': 0};
    }
  }

  /// تقييم المستخدم الحالي (إذا كاين)
  static Future<int> getMyRating(String storeId) async {
    final user = AuthService.currentUser;
    if (user == null) return 0;
    try {
      final snap = await _db
          .collection('ratings')
          .where('storeId', isEqualTo: storeId)
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return 0;
      return (snap.docs.first.data()['stars'] ?? 0) as int;
    } catch (_) {
      return 0;
    }
  }
}
