import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';
import 'cloudinary_service.dart';

class ServiceProviderService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// يجيب بروفايل المستخدم الحالي (إذا عندو)
  static Future<Map<String, dynamic>?> getMyProvider() async {
    final user = AuthService.currentUser;
    if (user == null) return null;
    try {
      final snap = await _db
          .collection('service_providers')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      final d = snap.docs.first;
      return {'id': d.id, ...d.data()};
    } catch (e) {
      print('GET_PROVIDER_ERR: $e');
      return null;
    }
  }

  /// ينشئ بروفايل جديد لصاحب الخدمة
  static Future<String?> createProvider({
    required String name,
    required String trade,
    required String bio,
    required String phone,
    required String wilaya,
    required String daira,
    File? cover,
    File? avatar,
  }) async {
    final user = AuthService.currentUser;
    if (user == null) return null;
    try {
      String coverUrl = '';
      if (cover != null) {
        final u = await CloudinaryService.uploadImage(cover);
        if (u != null) coverUrl = u;
      }
      String avatarUrl = '';
      if (avatar != null) {
        final u = await CloudinaryService.uploadImage(avatar);
        if (u != null) avatarUrl = u;
      }

      final ref = await _db.collection('service_providers').add({
        'userId': user.uid,
        'name': name.trim(),
        'trade': trade.trim(),
        'bio': bio.trim(),
        'phone': phone.trim(),
        'wilaya': wilaya.trim(),
        'daira': daira.trim(),
        'cover': coverUrl,
        'avatar': avatarUrl,
        'rating': 0.0,
        'ratingCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return ref.id;
    } catch (e) {
      print('CREATE_PROVIDER_ERR: $e');
      return null;
    }
  }

  /// يجيب بروفايل صانع خدمة بـ ID
  static Future<Map<String, dynamic>?> getProviderById(String id) async {
    try {
      final d = await _db.collection('service_providers').doc(id).get();
      if (!d.exists) return null;
      return {'id': d.id, ...d.data()!};
    } catch (e) {
      print('GET_PROVIDER_BY_ID_ERR: $e');
      return null;
    }
  }

  /// يحدث بروفايل صانع الخدمة
  static Future<bool> updateProvider({
    required String id,
    required String name,
    required String trade,
    required String bio,
    required String phone,
    required String wilaya,
    required String daira,
    File? newCover,
    File? newAvatar,
  }) async {
    try {
      final updates = <String, dynamic>{
        'name': name.trim(),
        'trade': trade.trim(),
        'bio': bio.trim(),
        'phone': phone.trim(),
        'wilaya': wilaya.trim(),
        'daira': daira.trim(),
      };

      if (newCover != null) {
        final u = await CloudinaryService.uploadImage(newCover);
        if (u != null) updates['cover'] = u;
      }
      if (newAvatar != null) {
        final u = await CloudinaryService.uploadImage(newAvatar);
        if (u != null) updates['avatar'] = u;
      }

      await _db.collection('service_providers').doc(id).update(updates);
      return true;
    } catch (e) {
      print('UPDATE_PROVIDER_ERR: $e');
      return false;
    }
  }
}
