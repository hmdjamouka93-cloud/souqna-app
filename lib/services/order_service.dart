import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class OrderService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// ينشئ طلب جديد
  static Future<String?> createOrder({
    required String storeId,
    required String productId,
    required String productName,
    required int productPrice,
    required String productImage,
    required String firstName,
    required String lastName,
    required String phone,
    required String wilaya,
    required String daira,
    required String color,
    required String size,
    required int quantity,
  }) async {
    final user = AuthService.currentUser;
    if (user == null) return null;
    try {
      final ref = await _db.collection('orders').add({
        'storeId': storeId,
        'productId': productId,
        'productName': productName.trim(),
        'productPrice': productPrice,
        'productImage': productImage,
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'phone': phone.trim(),
        'wilaya': wilaya.trim(),
        'daira': daira.trim(),
        'color': color,
        'size': size,
        'quantity': quantity,
        'userId': user.uid,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return ref.id;
    } catch (e) {
      print('CREATE_ORDER_ERR: $e');
      rethrow;
    }
  }

  /// يجيب طلبات متجر معين
  static Future<List<Map<String, dynamic>>> getStoreOrders(String storeId) async {
    try {
      final snap = await _db
          .collection('orders')
          .where('storeId', isEqualTo: storeId)
          .get();
      final list = snap.docs.map((d) {
        final x = d.data();
        return {
          'id': d.id,
          'storeId': (x['storeId'] ?? '').toString(),
          'productId': (x['productId'] ?? '').toString(),
          'productName': (x['productName'] ?? '').toString(),
          'productPrice': x['productPrice'] ?? 0,
          'productImage': (x['productImage'] ?? '').toString(),
          'firstName': (x['firstName'] ?? '').toString(),
          'lastName': (x['lastName'] ?? '').toString(),
          'phone': (x['phone'] ?? '').toString(),
          'wilaya': (x['wilaya'] ?? '').toString(),
          'daira': (x['daira'] ?? '').toString(),
          'color': (x['color'] ?? '').toString(),
          'size': (x['size'] ?? '').toString(),
          'quantity': x['quantity'] ?? 1,
          'status': (x['status'] ?? 'pending').toString(),
          'createdAt': x['createdAt'],
        };
      }).toList();
      // رتب client-side
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
      print('GET_ORDERS_ERR: $e');
      return [];
    }
  }

  /// يحدث حالة الطلب
  static Future<bool> updateStatus(String orderId, String status) async {
    try {
      await _db.collection('orders').doc(orderId).update({'status': status});
      return true;
    } catch (_) {
      return false;
    }
  }


  /// صاحب المتجر يحذف طلب منتهي
  static Future<bool> deleteOrder(String orderId) async {
    try {
      await _db.collection('orders').doc(orderId).delete();
      return true;
    } catch (e) {
      print('DELETE_ORDER_ERR: $e');
      return false;
    }
  }

  /// يجيب طلبات المستخدم الحالي (الزبون)
  static Future<List<Map<String, dynamic>>> getMyOrders() async {
    final user = AuthService.currentUser;
    if (user == null) return [];
    try {
      final snap = await _db
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .get();
      final list = snap.docs.map((d) {
        final x = d.data();
        return {
          'id': d.id,
          'storeId': (x['storeId'] ?? '').toString(),
          'productName': (x['productName'] ?? '').toString(),
          'productPrice': x['productPrice'] ?? 0,
          'productImage': (x['productImage'] ?? '').toString(),
          'quantity': x['quantity'] ?? 1,
          'color': (x['color'] ?? '').toString(),
          'size': (x['size'] ?? '').toString(),
          'status': (x['status'] ?? 'pending').toString(),
          'createdAt': x['createdAt'],
        };
      }).toList();
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
      print('GET_MY_ORDERS_ERR: $e');
      return [];
    }
  }

  /// يتحقق إذا المستخدم الحالي طلب من هذا المتجر من قبل
  static Future<bool> hasOrderedFromStore(String storeId) async {
    final user = AuthService.currentUser;
    if (user == null) return false;
    try {
      final snap = await _db
          .collection('orders')
          .where('storeId', isEqualTo: storeId)
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();
      return snap.docs.isNotEmpty;
    } catch (e) {
      print('CHECK_ORDER_ERR: $e');
      return false;
    }
  }
}
