import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class ChatService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// ينشئ محادثة جديدة أو يرجع ID المحادثة إذا كانت موجودة
  static Future<String?> getOrCreateChat({
    required String otherUserId,
    required String otherUserName,
    required String otherUserAvatar,
  }) async {
    final user = AuthService.currentUser;
    if (user == null) return null;
    if (user.uid == otherUserId) return null; // ما تقدرش تدردش مع روحك

    try {
      // نصنعو ID فريد للمحادثة (نرتبو الـ UIDs أبجدياً باش ما يتكررش)
      final ids = [user.uid, otherUserId]..sort();
      final chatId = '${ids[0]}_${ids[1]}';

      final chatDoc = await _db.collection('chats').doc(chatId).get();

      if (chatDoc.exists) {
        return chatId;
      }

      // إذا ماكانتش، نصنعوها
      final userData = await AuthService.getUserData();
      final myName = (userData?['name'] ?? 'مستخدم').toString();
      final myAvatar = ''; // نقدرو نزيدوه من بعد

      await _db.collection('chats').doc(chatId).set({
        'participants': [user.uid, otherUserId],
        'users': {
          user.uid: {'name': myName, 'avatar': myAvatar},
          otherUserId: {'name': otherUserName, 'avatar': otherUserAvatar},
        },
        'lastMessage': 'بدأت المحادثة',
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      return chatId;
    } catch (e) {
      print('CREATE_CHAT_ERR: $e');
      return null;
    }
  }

  /// يبعث رسالة
  static Future<bool> sendMessage(String chatId, String text) async {
    final user = AuthService.currentUser;
    if (user == null || text.trim().isEmpty) return false;

    try {
      final batch = _db.batch();
      
      final chatRef = _db.collection('chats').doc(chatId);
      final msgRef = chatRef.collection('messages').doc();

      // 1. نزيدو الرسالة
      batch.set(msgRef, {
        'senderId': user.uid,
        'text': text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. نحدثو آخر رسالة في المحادثة
      batch.update(chatRef, {
        'lastMessage': text.trim(),
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      return true;
    } catch (e) {
      print('SEND_MSG_ERR: $e');
      return false;
    }
  }

  /// يجيب رسائل محادثة معينة (Stream)
  static Stream<QuerySnapshot> getMessagesStream(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  /// يجيب لستة المحادثات متع المستخدم الحالي
  static Stream<QuerySnapshot> getMyChatsStream() {
    final user = AuthService.currentUser;
    if (user == null) return const Stream.empty();
    
    return _db
        .collection('chats')
        .where('participants', arrayContains: user.uid)
        .snapshots();
  }
}
