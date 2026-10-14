import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cloudinary_service.dart';

class ProductService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// يجيب منتجات متجر معين
  static Future<List<Map<String, dynamic>>> getStoreProducts(
      String storeId) async {
    try {
      final snap = await _db
          .collection('store_products')
          .where('storeId', isEqualTo: storeId)
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs.map((d) {
        final x = d.data();
        return {
          'id': d.id,
          'storeId': (x['storeId'] ?? '').toString(),
          'name': (x['name'] ?? '').toString(),
          'description': (x['description'] ?? '').toString(),
          'price': x['price'] ?? 0,
          'images': (x['images'] as List?)?.cast<String>() ?? <String>[],
          'colors': (x['colors'] as List?)?.cast<String>() ?? <String>[],
          'sizes': (x['sizes'] as List?)?.cast<String>() ?? <String>[],
          'quantity': x['quantity'] ?? 0,
        };
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// يجيب منتج بـ ID
  static Future<Map<String, dynamic>?> getProductById(String id) async {
    try {
      final d = await _db.collection('store_products').doc(id).get();
      if (!d.exists) return null;
      return {'id': d.id, ...d.data()!};
    } catch (_) {
      return null;
    }
  }

  /// ينشئ منتج جديد
  static Future<String?> createProduct({
    required String storeId,
    required String name,
    required String description,
    required int price,
    required List<File> images,
    required List<String> colors,
    required List<String> sizes,
    required int quantity,
  }) async {
    if (images.isEmpty) return null;
    try {
      final urls = await CloudinaryService.uploadImages(images);
      if (urls.isEmpty) return null;

      final ref = await _db.collection('store_products').add({
        'storeId': storeId,
        'name': name.trim(),
        'description': description.trim(),
        'price': price,
        'images': urls,
        'colors': colors,
        'sizes': sizes,
        'quantity': quantity,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return ref.id;
    } catch (_) {
      return null;
    }
  }

  /// يحدث منتج
  static Future<bool> updateProduct({
    required String id,
    required String name,
    required String description,
    required int price,
    required List<String> colors,
    required List<String> sizes,
    required int quantity,
    List<File>? newImages,
    List<String>? existingImages,
  }) async {
    try {
      final updates = <String, dynamic>{
        'name': name.trim(),
        'description': description.trim(),
        'price': price,
        'colors': colors,
        'sizes': sizes,
        'quantity': quantity,
      };

      final allImages = <String>[];
      if (existingImages != null) allImages.addAll(existingImages);

      if (newImages != null && newImages.isNotEmpty) {
        final urls = await CloudinaryService.uploadImages(newImages);
        allImages.addAll(urls);
      }

      if (allImages.isNotEmpty) {
        updates['images'] = allImages;
      }

      await _db.collection('store_products').doc(id).update(updates);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// يحذف منتج
  static Future<bool> deleteProduct(String id) async {
    try {
      await _db.collection('store_products').doc(id).delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// ينقص الكمية بعد طلب
  static Future<void> decrementQuantity(String productId, int qty) async {
    try {
      await _db.collection('store_products').doc(productId).update({
        'quantity': FieldValue.increment(-qty),
      });
    } catch (_) {}
  }
}
