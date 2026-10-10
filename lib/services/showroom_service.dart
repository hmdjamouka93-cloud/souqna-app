import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';
import 'cloudinary_service.dart';

class ShowroomService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// يجيب معرض المستخدم الحالي (إذا عندو واحد)
  static Future<Map<String, dynamic>?> getMyShowroom() async {
    final user = AuthService.currentUser;
    if (user == null) return null;
    try {
      final snap = await _db
          .collection('showrooms')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      final d = snap.docs.first;
      return {'id': d.id, ...d.data()};
    } catch (_) {
      return null;
    }
  }

  /// ينشئ معرض جديد
  static Future<String?> createShowroom({
    required String name,
    required String location,
    required String phone,
    required File logo,
  }) async {
    final user = AuthService.currentUser;
    if (user == null) return null;

    try {
      // 1. نرفعو الشعار
      final logoUrl = await CloudinaryService.uploadImage(logo);
      if (logoUrl == null) return null;

      // 2. ننشئو المعرض
      final ref = await _db.collection('showrooms').add({
        'userId': user.uid,
        'name': name.trim(),
        'location': location.trim(),
        'phone': phone.trim(),
        'logo': logoUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return ref.id;
    } catch (_) {
      return null;
    }
  }

  /// يحدث معرض
  static Future<bool> updateShowroom({
    required String id,
    required String name,
    required String location,
    required String phone,
    File? newLogo,
  }) async {
    try {
      final updates = <String, dynamic>{
        'name': name.trim(),
        'location': location.trim(),
        'phone': phone.trim(),
      };
      if (newLogo != null) {
        final url = await CloudinaryService.uploadImage(newLogo);
        if (url != null) updates['logo'] = url;
      }
      await _db.collection('showrooms').doc(id).update(updates);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// يجيب كل المعارض (للجمهور)
  static Future<List<Map<String, dynamic>>> getAllShowrooms() async {
    try {
      final snap = await _db
          .collection('showrooms')
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs.map((d) {
        final x = d.data();
        return {
          'id': d.id,
          'userId': (x['userId'] ?? '').toString(),
          'name': (x['name'] ?? '').toString(),
          'location': (x['location'] ?? '').toString(),
          'phone': (x['phone'] ?? '').toString(),
          'logo': (x['logo'] ?? '').toString(),
        };
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// يجيب معرض بالـ ID
  static Future<Map<String, dynamic>?> getShowroomById(String id) async {
    try {
      final d = await _db.collection('showrooms').doc(id).get();
      if (!d.exists) return null;
      return {'id': d.id, ...d.data()!};
    } catch (_) {
      return null;
    }
  }

  /// يجيب سيارات معرض معين
  static Future<List<Map<String, dynamic>>> getShowroomListings(
      String showroomId) async {
    try {
      final snap = await _db
          .collection('listings')
          .where('showroomId', isEqualTo: showroomId)
          .get();
      final list = snap.docs.map((d) {
        final x = d.data();
        return {
          'id': d.id,
          'title': (x['title'] ?? '').toString(),
          'price': x['price'] ?? 0,
          'location': (x['location'] ?? '').toString(),
          'description': (x['description'] ?? '').toString(),
          'images': (x['images'] as List?)?.cast<String>() ?? <String>[],
          'userId': (x['userId'] ?? '').toString(),
          'commentsCount': (x['commentsCount'] ?? 0) as int,
          'views': (x['views'] ?? 0) as int,
          'storeName': (x['storeName'] ?? '').toString(),
          'isPro': (x['isPro'] ?? false) as bool,
        };
      }).toList();
      return list;
    } catch (_) {
      return [];
    }
  }
}
