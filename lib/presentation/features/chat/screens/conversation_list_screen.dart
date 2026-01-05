import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cuutrobaolu/data/services/realtime_chat_service.dart';
import 'package:cuutrobaolu/presentation/features/chat/screens/realtime_chat_screen.dart';
import 'package:cuutrobaolu/presentation/features/chat/screens/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ConversationListScreen extends StatelessWidget {
  const ConversationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatService = Get.find<RealtimeChatService>();
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tin nhắn cứu trợ'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const ChatScreen()),
        icon: const Icon(Icons.smart_toy),
        label: const Text('AI Hỗ trợ'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // AI Assistant Card
          _buildAIAssistantCard(context),
          
          // Conversation list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: chatService.getUserConversationsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                         SizedBox(height: 16),
                         Text('Chưa có cuộc trò chuyện nào'),
                         SizedBox(height: 8),
                         Text('Nhấn nút AI Hỗ trợ để bắt đầu!', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final participants = List<String>.from(data['participants'] ?? []);
                    
                    // Xác định ID người kia
                    final otherId = participants.firstWhere(
                      (id) => id != currentUserId,
                      orElse: () => 'Unknown',
                    );

                    final timestamp = data['lastMessageTime'] as Timestamp?;
                    final timeStr = timestamp != null 
                        ? DateFormat('dd/MM HH:mm').format(timestamp.toDate()) 
                        : '';

                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text('User: ${otherId.substring(0, 5)}...'), // Tạm thời hiện ID rút gọn
                      subtitle: Text(
                        data['lastMessage'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(timeStr, style: const TextStyle(fontSize: 12)),
                      onTap: () {
                        Get.to(() => RealtimeChatScreen(
                          targetUserId: otherId,
                          targetUserName: 'User ${otherId.substring(0, 5)}...',
                        ));
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAIAssistantCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () => Get.to(() => const ChatScreen()),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade400, Colors.purple.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.smart_toy, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI Trợ lý cứu trợ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hỗ trợ yêu cầu cứu trợ 24/7',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

