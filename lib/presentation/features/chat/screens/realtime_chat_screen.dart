import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cuutrobaolu/presentation/features/chat/controller/realtime_chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class RealtimeChatScreen extends StatelessWidget {
  final String targetUserId;
  final String targetUserName;

  const RealtimeChatScreen({
    super.key,
    required this.targetUserId,
    required this.targetUserName,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RealtimeChatController());
    
    // Init chat immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initChat(targetUserId, targetUserName);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(targetUserName),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.conversationId.value.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              
              return StreamBuilder<QuerySnapshot>(
                stream: controller.messagesStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Lỗi: ${snapshot.error}'));
                  }
                  
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];
                  
                  if (docs.isEmpty) {
                    return const Center(child: Text('Hãy bắt đầu cuộc trò chuyện!'));
                  }

                  return ListView.builder(
                    reverse: true,
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final isMe = data['senderId'] == controller.currentUserId;
                      return _buildMessageBubble(data, isMe);
                    },
                  );
                },
              );
            }),
          ),
          _buildInputArea(controller),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> data, bool isMe) {
    final timestamp = data['timestamp'] as Timestamp?;
    final timeStr = timestamp != null 
        ? DateFormat('HH:mm').format(timestamp.toDate()) 
        : '...';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              data['text'] ?? '',
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              timeStr,
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.black54,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(RealtimeChatController controller) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.textController,
              decoration: const InputDecoration(
                hintText: 'Nhập tin nhắn...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: controller.sendMessage,
            icon: const Icon(Icons.send, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
