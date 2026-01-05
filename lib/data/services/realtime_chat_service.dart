import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class RealtimeChatService extends GetxService {
  static RealtimeChatService get to => Get.find();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lấy dòng chat (conversation) giữa 2 người
  // Nếu chưa có thì tạo mới
  Future<String> getOrCreateConversation(String otherUserId) async {
    final currentUserId = _auth.currentUser!.uid;
    
    // Check if conversation exists
    // Note: This query logic is simple, might need optimization for scale
    // We look for conversations where participants array contains both IDs
    final querySnapshot = await _firestore.collection('conversations')
        .where('participants', arrayContains: currentUserId)
        .get();
        
    for (var doc in querySnapshot.docs) {
      final participants = List<String>.from(doc['participants']);
      if (participants.contains(otherUserId)) {
        return doc.id;
      }
    }
    
    // Create new
    final docRef = await _firestore.collection('conversations').add({
      'participants': [currentUserId, otherUserId],
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'participant1': currentUserId, // Helper for easier queries
      'participant2': otherUserId,   // Helper for easier queries
    });
    
    return docRef.id;
  }

  // Gửi tin nhắn
  Future<void> sendMessage(String conversationId, String text, {String type = 'text'}) async {
    final currentUserId = _auth.currentUser!.uid;
    
    await _firestore.collection('conversations').doc(conversationId).collection('messages').add({
      'senderId': currentUserId,
      'text': text,
      'type': type,
      'timestamp': FieldValue.serverTimestamp(),
    });
    
    // Update last message
    await _firestore.collection('conversations').doc(conversationId).update({
      'lastMessage': type == 'text' ? text : '[Hình ảnh]',
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  // Stream tin nhắn
  Stream<QuerySnapshot> getMessagesStream(String conversationId) {
    return _firestore.collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
  
  // Lấy danh sách chat của user hiện tại
  Stream<QuerySnapshot> getUserConversationsStream() {
    final currentUserId = _auth.currentUser!.uid;
    return _firestore.collection('conversations')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }
}
