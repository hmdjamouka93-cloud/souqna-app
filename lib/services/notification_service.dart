import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'order_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);
  }

  static Future<void> showNotification(int id, String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'orders_channel',
      'إشعارات الطلبات',
      channelDescription: 'إشعارات حالة الطلبات',
      importance: Importance.max,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(id, title, body, details);
  }

  static Future<void> checkOrderStatusChanges() async {
    try {
      final orders = await OrderService.getMyOrders();
      final prefs = await SharedPreferences.getInstance();

      for (final order in orders) {
        final id = order['id'];
        final currentStatus = order['status'];
        final productName = order['productName'];
        
        final lastStatus = prefs.getString('order_status_$id');

        if (lastStatus != null && lastStatus != currentStatus) {
          // Status changed!
          String body = '';
          if (currentStatus == 'confirmed') {
            body = 'تم تأكيد طلبك: $productName';
          } else if (currentStatus == 'rejected') {
            body = 'تم رفض طلبك: $productName';
          } else if (currentStatus == 'delivered') {
            body = 'تم تسليم طلبك: $productName';
          }

          if (body.isNotEmpty) {
            await showNotification(
              id.hashCode,
              'تحديث حالة الطلب',
              body,
            );
          }
        }
        
        // Always update to the latest status
        await prefs.setString('order_status_$id', currentStatus);
      }
    } catch (e) {
      print('NOTIF_ERR: $e');
    }
  }
}
