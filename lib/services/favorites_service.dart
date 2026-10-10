import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class FavoritesService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// يضيف إعلان للمفضلة
  static Future<void> addFavorite(String listingId) async {
    final user = AuthService.currentUser;
    if (user == null) throw Exception('غير مسجل');
    await _db.collection('favorites').add({
      'userId': user.uid,
      'listingId': listingId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// يحيد من المفضلة
  static Future<void> removeFavorite(String listingId) async {
    final user = AuthService.currentUser;
    if (user == null) throw Exception('غير مسجل');
    final snap = await _db
        .collection('favorites')
        .where('userId', isEqualTo: user.uid)
        .where('listingId', isEqualTo: listingId)
        .get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  /// يحقق واش الإعلان في المفضلة
  static Future<bool> isFavorite(String listingId) async {
    final user = AuthService.currentUser;
    if (user == null) return false;
    final snap = await _db
        .collection('favorites')
        .where('userId', isEqualTo: user.uid)
        .where('listingId', isEqualTo: listingId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  /// Stream للمفضلة (باش نعرفو في real-time)
  static Stream<bool> favoriteStream(String listingId) {
    final user = AuthService.currentUser;
    if (user == null) return Stream.value(false);
    return _db
        .collection('favorites')
        .where('userId', isEqualTo: user.uid)
        .where('listingId', isEqualTo: listingId)
        .snapshots()
        .map((snap) => snap.docs.isNotEmpty);
  }

  /// يجيب كل الإعلانات المحفوظة
  static Future<List<Map<String, dynamic>>> getMyFavorites() async {
    final user = AuthService.currentUser;
    if (user == null) return [];

    final favSnap = await _db
        .collection('favorites')
        .where('userId', isEqualTo: user.uid)
        .get();

    final listingIds = favSnap.docs
        .map((d) => (d.data()['listingId'] ?? '').toString())
        .where((id) => id.isNotEmpty)
        .toList();

    if (listingIds.isEmpty) return [];

    final result = <Map<String, dynamic>>[];
    for (final id in listingIds) {
      try {
        final doc = await _db.collection('listings').doc(id).get();
        if (doc.exists) {
          final x = doc.data()!;
          result.add({
            'id': doc.id,
            'title': (x['title'] ?? '').toString(),
            'price': x['price'] ?? 0,
            'location': (x['location'] ?? '').toString(),
            'description': (x['description'] ?? '').toString(),
            'images': (x['images'] as List?)?.cast<String>() ?? <String>[],
            'userId': (x['userId'] ?? '').toString(),
            'commentsCount': (x['commentsCount'] ?? 0) as int,
          });
        }
      } catch (_) {}
    }
    return result;
  }
}
