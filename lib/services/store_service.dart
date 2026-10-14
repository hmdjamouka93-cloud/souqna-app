import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';
import 'cloudinary_service.dart';

class StoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ============ المتاجر ============

  /// يجيب متجر المستخدم الحالي (حسب القسم)
  static Future<Map<String, dynamic>?> getMyStore(String categoryName) async {
    final user = AuthService.currentUser;
    if (user == null) return null;
    try {
      final snap = await _db
          .collection('stores')
          .where('userId', isEqualTo: user.uid)
          .where('categoryName', isEqualTo: categoryName)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      final d = snap.docs.first;
      return {'id': d.id, ...d.data()};
    } catch (_) {
      return null;
    }
  }

  /// ينشئ متجر جديد
  static Future<String?> createStore({
    required String name,
    required String categoryName,
    required File cover,
    File? logo,
    String? bio,
    required String phone,
    required String wilaya,
    required String daira,
  }) async {
    final user = AuthService.currentUser;
    if (user == null) return null;

    try {
      final coverUrl = await CloudinaryService.uploadImage(cover);
      if (coverUrl == null) return null;

      String logoUrl = '';
      if (logo != null) {
        final l = await CloudinaryService.uploadImage(logo);
        if (l != null) logoUrl = l;
      }

      final ref = await _db.collection('stores').add({
        'userId': user.uid,
        'name': name.trim(),
        'cover': coverUrl,
        'logo': logoUrl,
        'bio': (bio ?? '').trim(),
        'phone': phone.trim(),
        'wilaya': wilaya.trim(),
        'daira': daira.trim(),
        'categoryName': categoryName,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return ref.id;
    } catch (e) { print("CREATE_STORE_ERR: $e");
      return null;
    }
  }

  /// يحدث متجر
  static Future<bool> updateStore({
    required String id,
    required String name,
    String? bio,
    required String phone,
    required String wilaya,
    required String daira,
    File? newCover,
    File? newLogo,
  }) async {
    try {
      final updates = <String, dynamic>{
        'name': name.trim(),
        'bio': (bio ?? '').trim(),
        'phone': phone.trim(),
        'wilaya': wilaya.trim(),
        'daira': daira.trim(),
      };
      if (newCover != null) {
        final u = await CloudinaryService.uploadImage(newCover);
        if (u != null) updates['cover'] = u;
      }
      if (newLogo != null) {
        final u = await CloudinaryService.uploadImage(newLogo);
        if (u != null) updates['logo'] = u;
      }
      await _db.collection('stores').doc(id).update(updates);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// يجيب كل متاجر قسم معين
  static Future<List<Map<String, dynamic>>> getStores(String categoryName) async {
    try {
      final snap = await _db
          .collection('stores')
          .where('categoryName', isEqualTo: categoryName)
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs.map((d) {
        final x = d.data();
        return {
          'id': d.id,
          'userId': (x['userId'] ?? '').toString(),
          'name': (x['name'] ?? '').toString(),
          'cover': (x['cover'] ?? '').toString(),
          'logo': (x['logo'] ?? '').toString(),
          'bio': (x['bio'] ?? '').toString(),
          'phone': (x['phone'] ?? '').toString(),
          'wilaya': (x['wilaya'] ?? '').toString(),
          'daira': (x['daira'] ?? '').toString(),
        };
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// يجيب متجر بـ ID
  static Future<Map<String, dynamic>?> getStoreById(String id) async {
    try {
      final d = await _db.collection('stores').doc(id).get();
      if (!d.exists) return null;
      return {'id': d.id, ...d.data()!};
    } catch (_) {
      return null;
    }
  }
}
