import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class ProviderRatingService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<bool> submitRating({
    required String providerId,
    required int stars,
  }) async {
    final user = AuthService.currentUser;
    if (user == null) return false;
    try {
      final existing = await _db
          .collection('provider_ratings')
          .where('providerId', isEqualTo: providerId)
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        await _db.collection('provider_ratings').doc(existing.docs.first.id).update({
          'stars': stars,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await _db.collection('provider_ratings').add({
          'providerId': providerId,
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

  static Future<Map<String, dynamic>> getProviderRating(String providerId) async {
    try {
      final snap = await _db
          .collection('provider_ratings')
          .where('providerId', isEqualTo: providerId)
          .get();
      if (snap.docs.isEmpty) return {'avg': 0.0, 'count': 0};
      int sum = 0;
      for (final d in snap.docs) {
        sum += (d.data()['stars'] ?? 0) as int;
      }
      return {'avg': sum / snap.docs.length, 'count': snap.docs.length};
    } catch (_) {
      return {'avg': 0.0, 'count': 0};
    }
  }

  static Future<int> getMyRating(String providerId) async {
    final user = AuthService.currentUser;
    if (user == null) return 0;
    try {
      final snap = await _db
          .collection('provider_ratings')
          .where('providerId', isEqualTo: providerId)
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return 0;
      return (snap.docs.first.data()['stars'] ?? 0) as int;
    } catch (_) {
      return 0;
    }
  }

  static Future<bool> hasOrderedFromProvider(String providerId) async {
    final user = AuthService.currentUser;
    if (user == null) return false;
    try {
      final snap = await _db
          .collection('service_orders')
          .where('providerId', isEqualTo: providerId)
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();
      return snap.docs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
