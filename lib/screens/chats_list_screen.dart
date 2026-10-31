import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import 'chat_room_screen.dart';

class ChatsListScreen extends StatelessWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = AuthService.currentUser?.uid;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
                appBar: AppBar(
                    elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon:  Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title:  Text(
            'الرسائل',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: ChatService.getMyChatsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.accent));
            }

            if (snapshot.hasError) {
              return  Center(
                child: Text('حدث خطأ أثناء تحميل الرسائل',
                    style: TextStyle(color: AppColors.textSecondary)),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return  Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 60, color: AppColors.textSecondary),
                    SizedBox(height: 16),
                    Text('لا توجد رسائل بعد',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                  ],
                ),
              );
            }

            final chats = List<QueryDocumentSnapshot>.from(snapshot.data!.docs);
            
            // نرتبو حسب آخر رسالة (Client-side)
            chats.sort((a, b) {
              final aData = a.data() as Map<String, dynamic>;
              final bData = b.data() as Map<String, dynamic>;
              final aTime = aData['lastMessageTime'] as Timestamp?;
              final bTime = bData['lastMessageTime'] as Timestamp?;
              if (aTime == null && bTime == null) return 0;
              if (aTime == null) return 1;
              if (bTime == null) return -1;
              return bTime.compareTo(aTime);
            });

            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: chats.length,
              itemBuilder: (context, i) {
                final chatData = chats[i].data() as Map<String, dynamic>;
                final chatId = chats[i].id;
                
                // نلقاو الطرف الأخر
                final participants = List<String>.from(chatData['participants'] ?? []);
                final otherUserId = participants.firstWhere((id) => id != currentUserId, orElse: () => '');
                
                final usersMap = chatData['users'] as Map<String, dynamic>? ?? {};
                final otherUserData = usersMap[otherUserId] as Map<String, dynamic>? ?? {};
                
                final otherName = (otherUserData['name'] ?? 'مستخدم').toString();
                final otherAvatar = (otherUserData['avatar'] ?? '').toString();
                final lastMessage = (chatData['lastMessage'] ?? '').toString();
                
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.card,
                    backgroundImage: otherAvatar.isNotEmpty ? NetworkImage(otherAvatar) : null,
                    child: otherAvatar.isEmpty
                        ? const Icon(Icons.person, color: AppColors.accent, size: 30)
                        : null,
                  ),
                  title: Text(
                    otherName,
                    style:  TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:  TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ),
                  trailing:  Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary.withValues(alpha: 0.24), size: 14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatRoomScreen(
                          chatId: chatId,
                          otherUserName: otherName,
                          otherUserAvatar: otherAvatar,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
