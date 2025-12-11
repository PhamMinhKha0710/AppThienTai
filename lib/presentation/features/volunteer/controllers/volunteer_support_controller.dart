import 'package:get/get.dart';

class VolunteerSupportController extends GetxController {
  final messages = <Map<String, dynamic>>[].obs; // {isUser: bool, text: String}
  final suggestions = const [
    'Gợi ý nhiệm vụ gần',
    'Hướng dẫn sơ cứu',
    'Đóng góp trú ẩn',
  ];

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    messages.add({'isUser': true, 'text': text.trim()});
    // Mock AI reply
    messages.add({'isUser': false, 'text': 'Tôi sẽ tìm thông tin và phản hồi cho bạn.'});
    // TODO: integrate real chatbot API
  }
}







