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

      // Gửi đến n8n - CHỈ gửi userId và message
      final response = await _chatRepo.sendMessage(
        userId: user.uid,
        message: message,
      );

      // Xóa tin nhắn loading
      messages.removeWhere((msg) => msg['id'] == loadingId);

      // Parse response từ n8n (có JavaScript)
      final parsedResponse = _parseN8nResponse(response);

      // Thêm phản hồi từ AI
      messages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': parsedResponse['reply'] ?? 'Đã nhận được tin nhắn của bạn.',
        'isUser': false,
        'timestamp': DateTime.now(),
      });

      // Cập nhật trạng thái
      isComplete.value = parsedResponse['isComplete'] ?? false;

      if (parsedResponse['dto'] != null) {
        extractedData.value = Map<String, dynamic>.from(parsedResponse['dto']);

        // Cập nhật collectedInfo
        _updateCollectedInfo(extractedData);

        // Kiểm tra xem đã đủ thông tin chưa
        if (_checkIfInfoComplete()) {
          // Nếu đã đủ thông tin, hỏi người dùng có muốn gửi không
          _askToSubmitRequest();
        }

        // Nếu đã hoàn thành từ phía AI
        if (isComplete.value) {
          MinhLoaders.successSnackBar(
              title: 'Thành công',
              message: 'Đã thu thập đủ thông tin.'
          );

          // Tự động tạo request nếu đã có đủ thông tin
          if (_checkIfInfoComplete()) {
            await _createHelpRequest();
          }
        }
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

  // Parse response từ n8n (có chứa JavaScript trong output)
  Map<String, dynamic> _parseN8nResponse(Map<String, dynamic> response) {
    try {
      // Nếu response đã được parse sẵn từ repository
      if (response.containsKey('reply') && response.containsKey('isComplete')) {
        return response;
      }

      // Nếu là raw output từ AI Agent
      final output = response['output']?.toString() ?? '';

      // Tìm JSON trong chuỗi output (theo format của n8n)
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(output);

      if (jsonMatch != null) {
        try {
          final jsonStr = jsonMatch.group(0)!;
          final jsonData = json.decode(jsonStr);

          return {
            'reply': output.replaceAll(jsonStr, '').trim(),
            'isComplete': jsonData['isComplete'] ?? false,
            'dto': {
              'Type': jsonData['Type'] ?? 'other',
              'Title': jsonData['Title'] ?? '',
              'Description': jsonData['Description'] ?? '',
              'Contact': jsonData['Contact'] ?? '',
            }
          };
        } catch (e) {
          print('Lỗi parse JSON: $e');
        }
      }

      // Fallback
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
    if (newData['Type'] != null && newData['Type'].toString().isNotEmpty) {
      collectedInfo['type'] = newData['Type'];
    }
    if (newData['Title'] != null && newData['Title'].toString().isNotEmpty) {
      collectedInfo['title'] = newData['Title'];
    }
    if (newData['Description'] != null && newData['Description'].toString().isNotEmpty) {
      collectedInfo['description'] = newData['Description'];
    }
    if (newData['Contact'] != null && newData['Contact'].toString().isNotEmpty) {
      collectedInfo['contact'] = newData['Contact'];
    }

    collectedInfo.refresh();
    print('Thông tin đã thu thập: $collectedInfo');
  }

  // Kiểm tra xem đã đủ thông tin chưa
  bool _checkIfInfoComplete() {
    return collectedInfo['type'].toString().isNotEmpty &&
        collectedInfo['title'].toString().isNotEmpty &&
        collectedInfo['description'].toString().isNotEmpty &&
        collectedInfo['contact'].toString().isNotEmpty;
  }

  // Hỏi người dùng có muốn gửi yêu cầu không
  void _askToSubmitRequest() {
    // Thêm tin nhắn hỏi người dùng
    messages.add({
      'id': 'ask_submit',
      'text': '✅ Tôi đã thu thập đủ thông tin:\n'
          '• Loại: ${collectedInfo['type']}\n'
          '• Tiêu đề: ${collectedInfo['title']}\n'
          '• Mô tả: ${collectedInfo['description']}\n'
          '• Liên hệ: ${collectedInfo['contact']}\n\n'
          'Bạn có muốn gửi yêu cầu cứu trợ ngay bây giờ không?',
      'isUser': false,
      'timestamp': DateTime.now(),
      'hasActions': true,
    });
  }

  // Xử lý khi người dùng đồng ý gửi
  Future<void> handleUserConfirmation(bool confirmed) async {
    // Xóa tin nhắn hỏi
    messages.removeWhere((msg) => msg['id'] == 'ask_submit');

    if (confirmed) {
      await _createHelpRequest();
    } else {
      messages.add({
        'id': 'continue_chat',
        'text': 'Được rồi, hãy tiếp tục mô tả thêm nếu cần.',
        'isUser': false,
        'timestamp': DateTime.now(),
      });
    }
  }

  // Tạo help request từ thông tin đã thu thập
  Future<void> _createHelpRequest() async {
    try {
      // Kiểm tra vị trí
      if (currentPosition.value == null) {
        MinhLoaders.warningSnackBar(
          title: 'Đang lấy vị trí',
          message: 'Vui lòng đợi hệ thống xác định vị trí',
        );
        await getCurrentLocation();
      }

      if (currentPosition.value == null) {
        throw Exception('Không thể xác định vị trí');
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      // Map type từ chat sang enum
      final requestType = _mapTypeToEnum(collectedInfo['type']);

      // Tạo help request
      final helpRequest = HelpRequest(
        id: "",
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

      // Convert to Entity và gửi
      final helpRequestEntity = HelpRequestMapper.toEntity(helpRequest);
      await _createHelpRequestUseCase(helpRequestEntity);

      // Thông báo thành công
      messages.add({
        'id': 'request_success',
        'text': '✅ Yêu cầu cứu trợ đã được gửi thành công! Đội cứu trợ sẽ liên hệ với bạn sớm nhất.',
        'isUser': false,
        'timestamp': DateTime.now(),
      });

      // Đóng màn hình sau 3 giây
      // Future.delayed(const Duration(seconds: 3), () {
      //   Get.back();
      //   MinhLoaders.successSnackBar(
      //     title: 'Thành công',
      //     message: 'Yêu cầu SOS đã được gửi thành công',
      //   );
      // });

    } catch (e) {
      messages.add({
        'id': 'request_error',
        'text': '❌ Không thể gửi yêu cầu: $e',
        'isUser': false,
        'timestamp': DateTime.now(),
      });

      MinhLoaders.errorSnackBar(
        title: 'Lỗi',
        message: 'Không thể gửi yêu cầu: $e',
      );
    }
  }

  // Map type string sang enum
  RequestType _mapTypeToEnum(String type) {
    switch (type.toLowerCase()) {
      case 'rescue':
        return RequestType.rescue;
      case 'medical':
        return RequestType.medicine;
      case 'food':
        return RequestType.food;
      default:
        return RequestType.other;
    }
  }

  // Hàm refresh vị trí
  Future<void> refreshLocation() async {
    messages.add({
      'id': 'refreshing_location',
      'text': '🔄 Đang làm mới vị trí...',
      'isUser': false,
      'timestamp': DateTime.now(),
      'isSystem': true,
    });

    await getCurrentLocation();

    // Xóa thông báo refreshing
    messages.removeWhere((msg) => msg['id'] == 'refreshing_location');
  }

  // Hiển thị thông tin đã thu thập
  void showCollectedInfo() {
    Get.defaultDialog(
      title: 'Thông tin đã thu thập',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Loại: ${collectedInfo["type"]}'),
          Text('Tiêu đề: ${collectedInfo["title"]}'),
          Text('Mô tả: ${collectedInfo["description"]}'),
          Text('Liên hệ: ${collectedInfo["contact"]}'),
          const SizedBox(height: 10),
          Text('Vị trí: ${currentAddress.value}'),
          if (currentPosition.value != null)
            Text('Tọa độ: ${currentPosition.value!.latitude.toStringAsFixed(6)}, ${currentPosition.value!.longitude.toStringAsFixed(6)}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Đóng'),
        ),
      ],
    );
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}