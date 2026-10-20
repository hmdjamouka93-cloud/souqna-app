import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';
import 'cloudinary_service.dart';

class ServiceListingService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// ينشئ خدمة جديدة لصانع الخدمة
  static Future<String?> createService({
    required String providerId,
    required String title,
    required String description,
    required int price,
    required File image,
  }) async {
    final user = AuthService.currentUser;
    if (user == null) return null;
    try {
      final imgUrl = await CloudinaryService.uploadImage(image);
      if (imgUrl == null) return null;

      final ref = await _db.collection('service_listings').add({
        'providerId': providerId,
        'userId': user.uid,
        'title': title.trim(),
        'description': description.trim(),
        'price': price,
        'image': imgUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return ref.id;
    } catch (e) {
      print('CREATE_SERVICE_LISTING_ERR: $e');
      return null;
    }
  }

  /// يجيب خدمات صانع خدمة معين
  static Future<List<Map<String, dynamic>>> getProviderServices(String providerId) async {
    try {
      final snap = await _db
          .collection('service_listings')
          .where('providerId', isEqualTo: providerId)
          .get();
      
      final list = snap.docs.map((d) {
        final x = d.data();
        return {
          'id': d.id,
          'providerId': (x['providerId'] ?? '').toString(),
          'title': (x['title'] ?? '').toString(),
          'description': (x['description'] ?? '').toString(),
          'price': x['price'] ?? 0,
          'image': (x['image'] ?? '').toString(),
        };
      }).toList();

      // ترتيب حسب الأحدث (Client-side)
      list.sort((a, b) {
        final ta = a['createdAt'] as Timestamp?;
        final tb = b['createdAt'] as Timestamp?;
        if (ta == null && tb == null) return 0;
        if (ta == null) return 1;
        if (tb == null) return -1;
        return tb.compareTo(ta);
      });

      return list;
    } catch (e) {
      print('GET_SERVICES_ERR: $e');
      return [];
    }
  }

  /// يحذف خدمة
  static Future<bool> deleteService(String id) async {
    try {
      await _db.collection('service_listings').doc(id).delete();
      return true;
    } catch (e) {
      print('DELETE_SERVICE_ERR: $e');
      return false;
    }
  }
}
