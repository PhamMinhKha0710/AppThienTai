import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cuutrobaolu/data/services/realtime_chat_service.dart';

class RealtimeChatController extends GetxController {
  final RealtimeChatService _chatService = RealtimeChatService.to;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final textController = TextEditingController();
  final conversationId = ''.obs;
  final otherUserId = ''.obs;
  final otherUserName = ''.obs;
  
  // Khởi tạo chat với user khác
  Future<void> initChat(String targetUserId, String targetUserName) async {
    otherUserId.value = targetUserId;
    otherUserName.value = targetUserName;
    
    try {
      final id = await _chatService.getOrCreateConversation(targetUserId);
      conversationId.value = id;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể khởi tạo cuộc trò chuyện: $e');
    }
  }

  void sendMessage() {
    final text = textController.text.trim();
    if (text.isEmpty || conversationId.value.isEmpty) return;
    
    _chatService.sendMessage(conversationId.value, text);
    textController.clear();
  }
  
  Stream<QuerySnapshot> get messagesStream {
    if (conversationId.value.isEmpty) return const Stream.empty();
    return _chatService.getMessagesStream(conversationId.value);
  }
  
  String get currentUserId => _auth.currentUser?.uid ?? '';
}
