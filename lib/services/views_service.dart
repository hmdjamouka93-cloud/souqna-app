import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewsService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// يزيد عدد المشاهدات مرة وحدة فقط لكل مستخدم/جهاز
  static Future<void> trackView(String listingId) async {
    if (listingId.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'viewed_$listingId';
      final alreadyViewed = prefs.getBool(key) ?? false;
      if (alreadyViewed) return;

      await _db.collection('listings').doc(listingId).update({
        'views': FieldValue.increment(1),
      });
      await prefs.setBool(key, true);
    } catch (_) {}
  }
}
