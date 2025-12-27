import 'dart:convert';

import 'package:cuutrobaolu/core/constants/enums.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cuutrobaolu/data/repositories/chat_repository.dart';
import 'package:cuutrobaolu/core/popups/loaders.dart';
import 'package:cuutrobaolu/data/services/location_service.dart';
import 'package:cuutrobaolu/presentation/utils/help_request_mapper.dart';
import 'package:cuutrobaolu/presentation/features/shop/models/help_request_modal.dart';
import 'package:cuutrobaolu/domain/usecases/create_help_request_usecase.dart';

class ChatController extends GetxController {
  static ChatController get instance => Get.find();

  final ChatRepository _chatRepo = Get.put(ChatRepository());
  final CreateHelpRequestUseCase _createHelpRequestUseCase = Get.find<CreateHelpRequestUseCase>();
  LocationService? _locationService;

  final messages = <Map<String, dynamic>>[].obs;
  final textController = TextEditingController();
  final isLoading = false.obs;
  final isComplete = false.obs;
  final extractedData = <String, dynamic>{}.obs;
  final currentPosition = Rxn<Position>();
  final currentAddress = ''.obs;

  // Lưu trữ thông tin thu thập được từ chat
  final collectedInfo = <String, dynamic>{
    'type': '',
    'title': '',
    'description': '',
    'contact': '',
  }.obs;

  // Biến để kiểm soát việc hiển thị confirm dialog
  final showConfirmDialog = false.obs;

  // Flag để tránh hỏi nhiều lần
  bool _hasAskedForConfirmation = false;

  @override
  void onInit() {
    super.onInit();
    _initLocationService();
    getCurrentLocation();
    _addWelcomeMessage();
  }

  void _initLocationService() {
    try {
      _locationService = Get.find<LocationService>();
    } catch (e) {
      _locationService = Get.put(LocationService(), permanent: true);
    }
  }

  Future<void> getCurrentLocation() async {
    if (_locationService == null) {
      _initLocationService();
    }

    try {
      final position = await _locationService?.getCurrentLocation();
      if (position != null) {
        currentPosition.value = position;

        // Lấy địa chỉ từ tọa độ
        final address = await _locationService?.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (address != null && address.isNotEmpty) {
          currentAddress.value = address;

          // Thêm thông tin vị trí vào chat
          messages.add({
            'id': 'location_info',
            'text': '📍 Đã xác định vị trí của bạn',
            'isUser': false,
            'timestamp': DateTime.now(),
            'isSystem': true,
          });
        }
      }
    } catch (e) {
      print('Lỗi khi lấy vị trí: $e');
    }
  }

  void _addWelcomeMessage() {
    messages.add({
      'id': 'welcome',
      'text': 'Xin chào! Tôi là trợ lý cứu trợ. Vui lòng mô tả tình huống của bạn.',
      'isUser': false,
      'timestamp': DateTime.now(),
    });
  }

  Future<void> sendMessage() async {
    final message = textController.text.trim();
    if (message.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      MinhLoaders.errorSnackBar(title: 'Lỗi', message: 'Vui lòng đăng nhập');
      return;
    }

    // Thêm tin nhắn người dùng
    messages.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'text': message,
      'isUser': true,
      'timestamp': DateTime.now(),
    });

    textController.clear();
    isLoading.value = true;

    try {
      // Thêm tin nhắn loading
      final loadingId = (DateTime.now().millisecondsSinceEpoch + 1).toString();
      messages.add({
        'id': loadingId,
        'text': 'Đang xử lý...',
        'isUser': false,
        'timestamp': DateTime.now(),
        'isLoading': true,
      });

      // Gửi đến n8n
      final response = await _chatRepo.sendMessage(
        userId: user.uid,
        message: message,
      );

      // Xóa tin nhắn loading
      messages.removeWhere((msg) => msg['id'] == loadingId);

      // Parse response từ n8n
      final parsedResponse = _parseN8nResponse(response);

      // Thêm phản hồi từ AI
      messages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': parsedResponse['reply'] ?? 'Đã nhận được tin nhắn của bạn.',
        'isUser': false,
        'timestamp': DateTime.now(),
      });

      // Cập nhật trạng thái từ AI
      isComplete.value = (parsedResponse['isComplete'] ?? false);

      if (parsedResponse['dto'] != null) {
        extractedData.value = Map<String, dynamic>.from(parsedResponse['dto']);

        // Cập nhật collectedInfo
        _updateCollectedInfo(extractedData);

        // QUAN TRỌNG: Chỉ hỏi khi AI nói đã hoàn thành VÀ đủ thông tin
        if (isComplete.value && _checkIfInfoComplete() && !_hasAskedForConfirmation) {
          // Nếu đã đủ thông tin VÀ AI nói hoàn thành, hỏi người dùng
          _askToSubmitRequest();
        } else if (!isComplete.value && _checkIfInfoComplete()) {
          // // Nếu chưa hoàn thành nhưng đủ thông tin, thông báo cho AI biết
          // messages.add({
          //   'id': 'missing_info',
          //   'text': 'Tôi đã thu thập được: ${collectedInfo['type']}, ${collectedInfo['title']}, ${collectedInfo['description']}. '
          //       'Nhưng vẫn thiếu thông tin liên hệ.',
          //   'isUser': false,
          //   'timestamp': DateTime.now(),
          // });
        }

        // Debug log
        print('Debug - isComplete: ${isComplete.value}');
        print('Debug - Check info: ${_checkIfInfoComplete()}');
        print('Debug - Has asked: $_hasAskedForConfirmation');

      }

    } catch (e) {
      // Xóa tin nhắn loading nếu có lỗi
      messages.removeWhere((msg) => msg['isLoading'] == true);

      // Thêm tin nhắn lỗi
      messages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': 'Xin lỗi, có lỗi xảy ra. Vui lòng thử lại.',
        'isUser': false,
        'timestamp': DateTime.now(),
      });

      MinhLoaders.errorSnackBar(
          title: 'Lỗi',
          message: 'Không thể gửi tin nhắn: $e'
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Parse response từ n8n
  Map<String, dynamic> _parseN8nResponse(Map<String, dynamic> response) {
    try {
      print('Raw response: $response');

      // Nếu response đã được parse sẵn từ repository
      if (response.containsKey('reply') && response.containsKey('isComplete')) {
        print('Already parsed: isComplete = ${response['isComplete']}');
        return response;
      }

      // Nếu là raw output từ AI Agent
      final output = response['output']?.toString() ?? '';
      print('Raw output: $output');

      // Tìm JSON trong chuỗi output
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(output);

      if (jsonMatch != null) {
        try {
          final jsonStr = jsonMatch.group(0)!;
          print('Found JSON: $jsonStr');

          final jsonData = json.decode(jsonStr);
          print('Parsed JSON: $jsonData');

          // KIỂM TRA KỸ: isComplete phải là boolean true
          final bool isCompleteFromAI = jsonData['isComplete'] == true;
          print('isComplete from AI: $isCompleteFromAI');

          return {
            'reply': output.replaceAll(jsonStr, '').trim(),
            'isComplete': isCompleteFromAI, // Đảm bảo là boolean
            'dto': {
              'Type': jsonData['Type']?.toString() ?? '',
              'Title': jsonData['Title']?.toString() ?? '',
              'Description': jsonData['Description']?.toString() ?? '',
              'Contact': jsonData['Contact']?.toString() ?? '',
            }
          };
        } catch (e) {
          print('Lỗi parse JSON: $e');
        }
      }

      // Fallback
      print('Fallback response');
      return {
        'reply': output,
        'isComplete': false,
        'dto': null,
      };

    } catch (e) {
      print('Lỗi parse n8n response: $e');
      return {
        'reply': 'Đã nhận được tin nhắn của bạn.',
        'isComplete': false,
        'dto': null,
      };
    }
  }

  // Cập nhật thông tin đã thu thập
  void _updateCollectedInfo(Map<String, dynamic> newData) {
    bool updated = false;

    if (newData['Type'] != null && newData['Type'].toString().isNotEmpty) {
      collectedInfo['type'] = newData['Type'];
      updated = true;
    }
    if (newData['Title'] != null && newData['Title'].toString().isNotEmpty) {
      collectedInfo['title'] = newData['Title'];
      updated = true;
    }
    if (newData['Description'] != null && newData['Description'].toString().isNotEmpty) {
      collectedInfo['description'] = newData['Description'];
      updated = true;
    }
    if (newData['Contact'] != null && newData['Contact'].toString().isNotEmpty) {
      collectedInfo['contact'] = newData['Contact'];
      updated = true;
    }

    if (updated) {
      collectedInfo.refresh();
      print('Thông tin đã thu thập: $collectedInfo');
    }
  }

  // Kiểm tra xem đã đủ thông tin chưa
  bool _checkIfInfoComplete() {
    final contact = collectedInfo['contact'].toString();
    final hasValidContact = contact.isNotEmpty &&
        !contact.toLowerCase().contains('chưa') &&
        !contact.toLowerCase().contains('none') &&
        !contact.toLowerCase().contains('missing') &&
        !contact.toLowerCase().contains('chua') &&
        !contact.toLowerCase().contains('null');

    final hasType = collectedInfo['type'].toString().isNotEmpty;
    final hasTitle = collectedInfo['title'].toString().isNotEmpty;
    final hasDescription = collectedInfo['description'].toString().isNotEmpty;

    print('Check info - Type: $hasType, Title: $hasTitle, Desc: $hasDescription, Contact: $contact (valid: $hasValidContact)');

    return hasType && hasTitle && hasDescription && hasValidContact;
  }

  // Hỏi người dùng có muốn gửi yêu cầu không
  void _askToSubmitRequest() {
    // Chỉ hỏi 1 lần
    if (_hasAskedForConfirmation) return;

    _hasAskedForConfirmation = true;
    showConfirmDialog.value = true;

    // Thêm tin nhắn hỏi người dùng
    messages.add({
      'id': 'ask_submit',
      'text': '✅ Tôi đã thu thập đủ thông tin:\n'
          '• Loại: ${collectedInfo['type']}\n'
          '• Tiêu đề: ${collectedInfo['title']}\n'
          '• Mô tả: ${collectedInfo['description']}\n'
          '• Liên hệ: ${collectedInfo['contact']}\n\n'
          'Bạn có muốn gửi yêu cầu cứu trợ ngay bây giờ không?\n'
          '(Nhấn "Gửi yêu cầu" hoặc tiếp tục chat để chỉnh sửa)',
      'isUser': false,
      'timestamp': DateTime.now(),
      'hasActions': true,
    });
  }

  // Xác nhận gửi yêu cầu từ người dùng
  Future<void> confirmAndSendRequest() async {
    // Xóa tin nhắn hỏi
    messages.removeWhere((msg) => msg['id'] == 'ask_submit');
    showConfirmDialog.value = false;

    // Thêm tin nhắn đang xử lý
    messages.add({
      'id': 'processing_request',
      'text': '⏳ Đang gửi yêu cầu cứu trợ...',
      'isUser': false,
      'timestamp': DateTime.now(),
      'isSystem': true,
    });

    try {
      await _createHelpRequest();

      // Xóa tin nhắn đang xử lý
      messages.removeWhere((msg) => msg['id'] == 'processing_request');

      // Reset flag sau khi gửi thành công
      _hasAskedForConfirmation = false;

    } catch (e) {
      // Xóa tin nhắn đang xử lý
      messages.removeWhere((msg) => msg['id'] == 'processing_request');

      // Reset flag nếu lỗi để có thể hỏi lại
      _hasAskedForConfirmation = false;
      showConfirmDialog.value = true;

      rethrow;
    }
  }

  // Hủy gửi yêu cầu
  void cancelRequest() {
    // Xóa tin nhắn hỏi
    messages.removeWhere((msg) => msg['id'] == 'ask_submit');
    showConfirmDialog.value = false;
    _hasAskedForConfirmation = false; // Reset để có thể hỏi lại sau

    messages.add({
      'id': 'continue_chat',
      'text': 'Được rồi, bạn có thể tiếp tục mô tả thêm hoặc chỉnh sửa thông tin.',
      'isUser': false,
      'timestamp': DateTime.now(),
    });
  }

  // Tạo help request
  Future<void> _createHelpRequest() async {
    try {
      if (currentPosition.value == null) {
        await getCurrentLocation();

        if (currentPosition.value == null) {
          throw Exception('Không thể xác định vị trí');
        }
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      final requestType = _mapTypeToEnum(collectedInfo['type']);

      final helpRequest = HelpRequest(
        id: "${DateTime.now().millisecondsSinceEpoch}_${user.uid.substring(0, 8)}",
        title: collectedInfo['title'] ?? "Yêu cầu cứu trợ",
        description: collectedInfo['description'] ?? "",
        lat: currentPosition.value!.latitude,
        lng: currentPosition.value!.longitude,
        contact: collectedInfo['contact'] ?? user.phoneNumber ?? user.email ?? "",
        address: currentAddress.value.isNotEmpty
            ? currentAddress.value
            : "Vị trí GPS: ${currentPosition.value!.latitude.toStringAsFixed(6)}, ${currentPosition.value!.longitude.toStringAsFixed(6)}",
        imageUrl: null,
        userId: user.uid,
        severity: RequestSeverity.urgent,
        type: requestType,
        status: RequestStatus.pending,
        createdAt: DateTime.now(),
      );

      final helpRequestEntity = HelpRequestMapper.toEntity(helpRequest);
      await _createHelpRequestUseCase(helpRequestEntity);

      messages.add({
        'id': 'request_success',
        'text': '✅ Yêu cầu cứu trợ đã được gửi thành công!\n'
            'Mã yêu cầu: ${helpRequest.id}\n'
            'Đội cứu trợ sẽ liên hệ với bạn qua: ${collectedInfo['contact']}',
        'isUser': false,
        'timestamp': DateTime.now(),
      });

      // Reset sau khi gửi thành công
      _resetCollectedInfo();

    } catch (e) {
      messages.add({
        'id': 'request_error',
        'text': '❌ Không thể gửi yêu cầu: $e',
        'isUser': false,
        'timestamp': DateTime.now(),
      });

      showConfirmDialog.value = true;
      throw e;
    }
  }

  // Reset thông tin đã thu thập
  void _resetCollectedInfo() {
    collectedInfo.value = {
      'type': '',
      'title': '',
      'description': '',
      'contact': '',
    };
    extractedData.value = {};
    isComplete.value = false;
    showConfirmDialog.value = false;
    _hasAskedForConfirmation = false;
  }

  // Map type string sang enum
  RequestType _mapTypeToEnum(String type) {
    final typeStr = type.toLowerCase();

    if (typeStr.contains('rescue') || typeStr.contains('cứu hộ')) {
      return RequestType.rescue;
    } else if (typeStr.contains('medical') || typeStr.contains('y tế') || typeStr.contains('medicine')) {
      return RequestType.medicine;
    } else if (typeStr.contains('food') || typeStr.contains('lương thực') || typeStr.contains('thực phẩm')) {
      return RequestType.food;
    } else {
      return RequestType.other;
    }
  }

  // Refresh vị trí
  Future<void> refreshLocation() async {
    messages.add({
      'id': 'refreshing_location',
      'text': '🔄 Đang làm mới vị trí...',
      'isUser': false,
      'timestamp': DateTime.now(),
      'isSystem': true,
    });

    await getCurrentLocation();

    messages.removeWhere((msg) => msg['id'] == 'refreshing_location');
  }

  // HIỂN THỊ THÔNG TIN ĐÃ THU THẬP
  void showCollectedInfo() {
    Get.defaultDialog(
      title: '📊 Thông tin đã thu thập',
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thông tin cơ bản
            _buildInfoItem('📋 Loại yêu cầu', collectedInfo['type'].toString()),
            _buildInfoItem('🏷️ Tiêu đề', collectedInfo['title'].toString()),
            _buildInfoItem('📝 Mô tả', collectedInfo['description'].toString()),
            _buildInfoItem('📞 Liên hệ', collectedInfo['contact'].toString()),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // Thông tin vị trí
            Text(
              '📍 Thông tin vị trí',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(height: 8),

            if (currentAddress.value.isNotEmpty)
              _buildInfoItem('Địa chỉ', currentAddress.value),

            if (currentPosition.value != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoItem(
                    'Vĩ độ',
                    currentPosition.value!.latitude.toStringAsFixed(6),
                  ),
                  _buildInfoItem(
                    'Kinh độ',
                    currentPosition.value!.longitude.toStringAsFixed(6),
                  ),
                ],
              ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // Trạng thái
            Text(
              '📊 Trạng thái',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Icon(
                  isComplete.value ? Icons.check_circle : Icons.hourglass_empty,
                  color: isComplete.value ? Colors.green : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isComplete.value ? 'Đã hoàn thành thu thập' : 'Đang thu thập thông tin',
                  style: TextStyle(
                    color: isComplete.value ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Icon(
                  _checkIfInfoComplete() ? Icons.check_circle : Icons.warning,
                  color: _checkIfInfoComplete() ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _checkIfInfoComplete()
                      ? 'Đã đủ thông tin cần thiết'
                      : 'Thiếu thông tin bắt buộc',
                  style: TextStyle(
                    color: _checkIfInfoComplete() ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Đóng'),
        ),
        if (_checkIfInfoComplete() && !showConfirmDialog.value)
          ElevatedButton(
            onPressed: () {
              Get.back();
              _askToSubmitRequest();
            },
            child: const Text('Gửi yêu cầu'),
          ),
      ],
    );
  }

  // Helper method để tạo item thông tin
  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value.isNotEmpty ? value : '(Chưa có)',
            style: TextStyle(
              fontSize: 15,
              fontWeight: value.isNotEmpty ? FontWeight.w400 : FontWeight.w300,
              color: value.isNotEmpty ? Colors.black : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // THÊM PHƯƠNG THỨC ĐỂ XEM NHANH THÔNG TIN
  void quickViewInfo() {
    Get.snackbar(
      'Thông tin đã thu thập',
      '''
Loại: ${collectedInfo['type']}
Tiêu đề: ${collectedInfo['title']}
Mô tả: ${collectedInfo['description']}
Liên hệ: ${collectedInfo['contact']}
Vị trí: ${currentAddress.value.isNotEmpty ? currentAddress.value : 'Đang xác định'}
      ''',
      duration: const Duration(seconds: 5),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}