import 'dart:convert';
import 'package:cuutrobaolu/data/repositories/MinhTest/sheltersRepository.dart';
import 'package:cuutrobaolu/domain/entities/shelter_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cuutrobaolu/data/repositories/chat_repository.dart';
import 'package:cuutrobaolu/core/popups/loaders.dart';
import 'package:cuutrobaolu/data/services/location_service.dart';
import 'package:cuutrobaolu/data/repositories/help/help_request_repository.dart';

class VolunteerSupportController extends GetxController {
  static VolunteerSupportController get instance => Get.find();

  // Repositories
  final ChatRepository _chatRepo = Get.put(ChatRepository());
  final SheltersRepository _shelterRepo = SheltersRepository();
  final HelpRequestRepository _helpRequestRepo = HelpRequestRepository();

  LocationService? _locationService;

  // Reactive state
  final messages = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final isComplete = false.obs;
  final extractedData = <String, dynamic>{}.obs;
  final currentPosition = Rxn<Position>();
  final currentAddress = ''.obs;

  // Lưu thông tin thu thập được
  final collectedInfo = <String, dynamic>{
    'type': '',
    'name': '',
    'address': '',
    'capacity': '',
    'contact': '',
    'description': '',
  }.obs;

  // Suggestions cho volunteer
  final suggestions = [
    'Tìm nhiệm vụ cứu trợ gần đây',
    'Hướng dẫn sơ cứu khẩn cấp',
    'Tôi muốn đăng ký nơi trú ẩn',
    'Thông tin thời tiết hiện tại',
  ];

  // Action flags
  final showConfirmDialog = false.obs;
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
    if (_locationService == null) _initLocationService();

    try {
      final position = await _locationService?.getCurrentLocation();
      if (position != null) {
        currentPosition.value = position;

        final address = await _locationService?.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (address != null && address.isNotEmpty) {
          currentAddress.value = address;
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
      print('Lỗi khi lấy vị trí volunteer: $e');
    }
  }

  void _addWelcomeMessage() {
    messages.add({
      'id': 'welcome',
      'text': '👋 **Xin chào Tình nguyện viên!**\n\n'
          'Tôi là trợ lý hỗ trợ cứu trợ. Bạn có thể:\n'
          '• Tìm nhiệm vụ cần giúp đỡ\n'
          '• Đăng ký địa điểm trú ẩn\n'
          '• Hỏi thông tin sơ cứu\n'
          '• Tra cứu thời tiết, tin tức',
      'isUser': false,
      'timestamp': DateTime.now(),
    });
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      MinhLoaders.errorSnackBar(title: 'Lỗi', message: 'Vui lòng đăng nhập');
      return;
    }

    // Thêm tin nhắn người dùng
    messages.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'text': message.trim(),
      'isUser': true,
      'timestamp': DateTime.now(),
    });

    isLoading.value = true;

    try {
      // Thêm tin nhắn loading
      final loadingId = (DateTime.now().millisecondsSinceEpoch + 1).toString();
      messages.add({
        'id': loadingId,
        'text': 'Đang tìm kiếm thông tin...',
        'isUser': false,
        'timestamp': DateTime.now(),
        'isLoading': true,
      });

      // Gửi đến n8n với userType volunteer
      print('🔄 [1] Calling ChatRepository.sendMessage...');
      final response = await _chatRepo.sendMessage(
        userId: user.uid,
        message: message.trim(),
      );

      // ========== THÊM DEBUG LOG QUAN TRỌNG ==========
      print('🔄 [2] Response FROM ChatRepository:');
      print('   - Type: ${response.runtimeType}');
      print('   - Keys: ${response.keys.toList()}');
      print('   - Has "intent" key? ${response.containsKey("intent")}');
      print('   - Full response: $response');
      print('   - intent value: ${response["intent"]}');
      // ===============================================

      // Xóa tin nhắn loading
      messages.removeWhere((msg) => msg['id'] == loadingId);

      // Parse response từ n8n
      print('🔄 [3] Calling _parseVolunteerResponse...');
      final parsedResponse = _parseVolunteerResponse(response);

      // ========== THÊM DEBUG SAU KHI PARSE ==========
      print('🔄 [4] Parsed Response:');
      print('   - intent: ${parsedResponse["intent"]}');
      print('   - isComplete: ${parsedResponse["isComplete"]}');
      print('   - has dto: ${parsedResponse["dto"] != null}');
      // ===============================================

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

        // ========== DEBUG INTENT ==========
        print('🔄 [5] Updating collectedInfo with intent: ${parsedResponse["intent"]}');
        // ==================================

        // Cập nhật collectedInfo tùy theo intent
        _updateCollectedInfo(extractedData, parsedResponse['intent']);

        // Nếu AI nói đã hoàn thành VÀ đủ thông tin
        if (isComplete.value &&
            _checkIfInfoComplete(parsedResponse['intent']) &&
            !_hasAskedForConfirmation) {
          print('🔄 [6] Asking to take action for intent: ${parsedResponse["intent"]}');
          _askToTakeAction(parsedResponse['intent']);
        }
      }
    } catch (e) {
      // Xóa tin nhắn loading
      messages.removeWhere((msg) => msg['isLoading'] == true);

      // Thêm tin nhắn lỗi
      messages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': '❌ **Xin lỗi**, có lỗi xảy ra. Vui lòng thử lại.',
        'isUser': false,
        'timestamp': DateTime.now(),
      });

      MinhLoaders.errorSnackBar(
        title: 'Lỗi',
        message: 'Không thể gửi tin nhắn: $e',
      );

      print('❌ Error in sendMessage: $e');
      print('❌ Stack trace: ${StackTrace.current}');
    } finally {
      isLoading.value = false;
    }
  }
  // Map<String, dynamic> _parseVolunteerResponse(Map<String, dynamic> response) {
  //   try {
  //     print('📥 Volunteer response: $response');
  //
  //     // FIX 1: Response đã có sẵn intent từ ChatRepository
  //     if (response.containsKey('reply') &&
  //         response.containsKey('isComplete')) {
  //       print('✅ Response có reply và isComplete');
  //       print('   - isComplete value: ${response['isComplete']}');
  //       print('   - intent value: ${response['intent']}');
  //       print('   - dto value: ${response['dto']}');
  //
  //       return {
  //         'reply': response['reply'] ?? '',
  //         'isComplete': response['isComplete'] == true,
  //         'intent': response['intent']?.toString() ?? 'guide', // Nếu không có intent, mặc định là 'guide'
  //         'dto': response['dto'] ?? {},
  //       };
  //     }
  //
  //     // FIX 2: Chỉ parse nếu response có output
  //     final output = response['output']?.toString() ?? '';
  //     if (output.isEmpty && response.containsKey('reply')) {
  //       return {
  //         'reply': response['reply'] ?? '',
  //         'isComplete': response['isComplete'] ?? false,
  //         'intent': response['intent'] ?? 'guide',
  //         'dto': response['dto'] ?? {},
  //       };
  //     }
  //
  //     // Chỉ parse JSON nếu có dấu hiệu của JSON trong output
  //     if (output.contains('{')) {
  //       final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(output);
  //       if (jsonMatch != null) {
  //         try {
  //           final jsonStr = jsonMatch.group(0)!;
  //           final jsonData = json.decode(jsonStr);
  //
  //           return {
  //             'reply': output.replaceAll(jsonStr, '').trim(),
  //             'isComplete': jsonData['isComplete'] == true,
  //             'intent': jsonData['intent']?.toString() ?? 'guide',
  //             'dto': {
  //               'Type': jsonData['Type']?.toString() ?? '',
  //               'Title': jsonData['Title']?.toString() ?? '',
  //               'Description': jsonData['Description']?.toString() ?? '',
  //               'Contact': jsonData['Contact']?.toString() ?? '',
  //               'Name': jsonData['Name']?.toString() ?? '',
  //               'Address': jsonData['Address']?.toString() ?? '',
  //               'Capacity': jsonData['Capacity']?.toString() ?? '',
  //               'ShelterContact': jsonData['ShelterContact']?.toString() ?? '',
  //             },
  //           };
  //         } catch (e) {
  //           print('❌ Lỗi parse JSON: $e');
  //         }
  //       }
  //     }
  //
  //     // Fallback
  //     return {
  //       'reply': response['reply'] ?? output,
  //       'isComplete': false,
  //       'intent': 'guide',
  //       'dto': null,
  //     };
  //
  //   } catch (e) {
  //     print('❌ Lỗi parse volunteer response: $e');
  //     return {
  //       'reply': 'Đã nhận được tin nhắn của bạn.',
  //       'isComplete': false,
  //       'intent': 'guide',
  //       'dto': null,
  //     };
  //   }
  // }

  Map<String, dynamic> _parseVolunteerResponse(Map<String, dynamic> response) {
    print('🔍 [PARSER START] =================================');
    print('🔍 Input response keys: ${response.keys.toList()}');
    print('🔍 Input response full: $response');

    try {
      // PHƯƠNG PHÁP ĐƠN GIẢN NHẤT: Trả về nguyên bản nếu có đủ keys
      if (response.containsKey('reply') &&
          response.containsKey('isComplete') &&
          response.containsKey('intent') &&
          response.containsKey('dto')) {

        print('✅ [PARSER] Direct mapping - intent found: ${response['intent']}');

        return {
          'reply': response['reply']?.toString() ?? '',
          'isComplete': response['isComplete'] == true,
          'intent': response['intent']?.toString() ?? 'guide',
          'dto': response['dto'] is Map ? Map<String, dynamic>.from(response['dto'] as Map) : {},
        };
      }

      // Nếu thiếu intent, nhưng có dto -> đoán intent
      if (response.containsKey('reply') && response.containsKey('isComplete')) {
        print('⚠️ [PARSER] Missing intent in response, trying to guess...');

        // Kiểm tra dto để đoán intent
        final dto = response['dto'] is Map ? Map<String, dynamic>.from(response['dto'] as Map) : {};
        String guessedIntent = 'guide';

        // Shelter intent thường có Name và Address
        if (dto.containsKey('Name') && dto.containsKey('Address')) {
          guessedIntent = 'shelter';
        }
        // SOS intent thường có Type và Title
        else if (dto.containsKey('Type') && dto.containsKey('Title')) {
          guessedIntent = 'sos';
        }

        print('🤔 [PARSER] Guessed intent: $guessedIntent');

        return {
          'reply': response['reply']?.toString() ?? '',
          'isComplete': response['isComplete'] == true,
          'intent': guessedIntent,
          'dto': dto,
        };
      }

      // Fallback
      print('⚠️ [PARSER] Fallback - minimal response');
      return {
        'reply': response['reply']?.toString() ?? response.toString(),
        'isComplete': false,
        'intent': 'guide',
        'dto': {},
      };

    } catch (e) {
      print('❌ [PARSER ERROR]: $e');
      return {
        'reply': 'Đã nhận được tin nhắn của bạn.',
        'isComplete': false,
        'intent': 'guide',
        'dto': {},
      };
    } finally {
      print('🔍 [PARSER END] ===================================');
    }
  }
  void _updateCollectedInfo(Map<String, dynamic> newData, String intent) {
    bool updated = false;

    if (intent == 'sos') {
      // Cập nhật thông tin SOS
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
    } else if (intent == 'shelter') {
      // Cập nhật thông tin Shelter
      if (newData['Name'] != null && newData['Name'].toString().isNotEmpty) {
        collectedInfo['name'] = newData['Name'];
        updated = true;
      }
      if (newData['Address'] != null && newData['Address'].toString().isNotEmpty) {
        collectedInfo['address'] = newData['Address'];
        updated = true;
      }
      if (newData['Capacity'] != null && newData['Capacity'].toString().isNotEmpty) {
        collectedInfo['capacity'] = newData['Capacity'];
        updated = true;
      }
      if (newData['ShelterContact'] != null && newData['ShelterContact'].toString().isNotEmpty) {
        collectedInfo['contact'] = newData['ShelterContact'];
        updated = true;
      }
    }

    if (updated) {
      collectedInfo.refresh();
      print('Volunteer collected info: $collectedInfo');
    }
  }

  bool _checkIfInfoComplete(String intent) {
    if (intent == 'sos') {
      final hasType = collectedInfo['type'].toString().isNotEmpty;
      final hasTitle = collectedInfo['title'].toString().isNotEmpty;
      final hasDescription = collectedInfo['description'].toString().isNotEmpty;
      final hasContact = collectedInfo['contact'].toString().isNotEmpty;

      return hasType && hasTitle && hasDescription && hasContact;
    } else if (intent == 'shelter') {
      final hasName = collectedInfo['name'].toString().isNotEmpty;
      final hasAddress = collectedInfo['address'].toString().isNotEmpty;

      // Chỉ cần Name và Address là đủ
      return hasName && hasAddress;
    }

    return false;
  }

  void _askToTakeAction(String intent) {
    if (_hasAskedForConfirmation) return;

    _hasAskedForConfirmation = true;
    showConfirmDialog.value = true;

    if (intent == 'sos') {
      messages.add({
        'id': 'ask_accept_sos',
        'text': '🚨 **YÊU CẦU CỨU TRỢ KHẨN CẤP**\n\n'
            '📋 Thông tin nhận được:\n'
            '• Loại: ${collectedInfo['type']}\n'
            '• Tiêu đề: ${collectedInfo['title']}\n'
            '• Mô tả: ${collectedInfo['description']}\n'
            '• Liên hệ: ${collectedInfo['contact']}\n\n'
            'Bạn có muốn nhận nhiệm vụ này không?\n'
            '(Nhấn "Nhận nhiệm vụ" hoặc tiếp tục chat)',
        'isUser': false,
        'timestamp': DateTime.now(),
        'hasActions': true,
        'actionType': 'accept_sos',
      });
    } else if (intent == 'shelter') {
      messages.add({
        'id': 'ask_confirm_shelter',
        'text': '🏠 **THÔNG TIN NƠI TRÚ ẨN**\n\n'
            '📋 Thông tin nhận được:\n'
            '• Tên: ${collectedInfo['name']}\n'
            '• Địa chỉ: ${collectedInfo['address']}\n'
            '• Sức chứa: ${collectedInfo['capacity']}\n'
            '• Liên hệ: ${collectedInfo['contact']}\n\n'
            'Bạn có muốn xác nhận địa điểm này không?\n'
            '(Nhấn "Xác nhận" hoặc tiếp tục chat)',
        'isUser': false,
        'timestamp': DateTime.now(),
        'hasActions': true,
        'actionType': 'confirm_shelter',
      });
    }
  }

  // VOLUNTEER ACTIONS

  Future<void> acceptSOSTask() async {
    messages.removeWhere((msg) => msg['id'] == 'ask_accept_sos');
    showConfirmDialog.value = false;

    messages.add({
      'id': 'accepting_task',
      'text': '⏳ Đang xác nhận nhận nhiệm vụ...',
      'isUser': false,
      'timestamp': DateTime.now(),
      'isSystem': true,
    });

    try {
      // TODO: Gọi API để volunteer nhận nhiệm vụ SOS
      // Ví dụ: await _helpRequestRepo.acceptSOSTask(collectedInfo, currentUser.id);

      await Future.delayed(Duration(seconds: 1)); // Mock API call

      messages.removeWhere((msg) => msg['id'] == 'accepting_task');
      _hasAskedForConfirmation = false;

      messages.add({
        'id': 'task_accepted',
        'text': '✅ **ĐÃ NHẬN NHIỆM VỤ THÀNH CÔNG!**\n\n'
            'Cảm ơn bạn đã sẵn sàng giúp đỡ.\n'
            'Thông tin liên hệ: ${collectedInfo['contact']}\n'
            'Vui lòng liên hệ ngay để hỗ trợ.',
        'isUser': false,
        'timestamp': DateTime.now(),
      });

      _resetCollectedInfo();
    } catch (e) {
      messages.removeWhere((msg) => msg['id'] == 'accepting_task');
      _hasAskedForConfirmation = false;
      showConfirmDialog.value = true;

      messages.add({
        'id': 'task_error',
        'text': '❌ Không thể nhận nhiệm vụ: $e',
        'isUser': false,
        'timestamp': DateTime.now(),
      });
    }
  }

  Future<void> confirmShelter() async {
    messages.removeWhere((msg) => msg['id'] == 'ask_confirm_shelter');
    showConfirmDialog.value = false;

    messages.add({
      'id': 'confirming_shelter',
      'text': '⏳ Đang xác nhận địa điểm trú ẩn...',
      'isUser': false,
      'timestamp': DateTime.now(),
      'isSystem': true,
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Chưa đăng nhập');

      // Tạo shelter object
      final shelter = ShelterEntity(
        id: 'shelter_${DateTime.now().millisecondsSinceEpoch}_${user.uid.substring(0, 8)}',
        name: collectedInfo['name'] ?? 'Nơi trú ẩn',
        address: collectedInfo['address'] ?? '',
        lat: currentPosition.value?.latitude ?? 0,
        lng: currentPosition.value?.longitude ?? 0,
        capacity: int.tryParse(collectedInfo['capacity'].toString()) ?? 0,
        currentOccupancy: 0,
        contactEmail: collectedInfo['contact'] ?? user.phoneNumber ?? user.email ?? '',
        amenities: [],
        isActive: true,
        createdBy: user.uid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _shelterRepo.createShelter(shelter);

      messages.removeWhere((msg) => msg['id'] == 'confirming_shelter');
      _hasAskedForConfirmation = false;

      messages.add({
        'id': 'shelter_confirmed',
        'text': '✅ **ĐÃ XÁC NHẬN ĐỊA ĐIỂM TRÚ ẨN!**\n\n'
            'Cảm ơn bạn đã đóng góp.\n'
            'Tên: ${shelter.name}\n'
            'Địa chỉ: ${shelter.address}\n'
            'Sức chứa: ${shelter.capacity} người',
        'isUser': false,
        'timestamp': DateTime.now(),
      });

      _resetCollectedInfo();
    } catch (e) {
      messages.removeWhere((msg) => msg['id'] == 'confirming_shelter');
      _hasAskedForConfirmation = false;
      showConfirmDialog.value = true;

      messages.add({
        'id': 'shelter_error',
        'text': '❌ Không thể xác nhận địa điểm: $e',
        'isUser': false,
        'timestamp': DateTime.now(),
      });
    }
  }

  void skipAction() {
    final messagesToRemove = ['ask_accept_sos', 'ask_confirm_shelter'];
    for (var id in messagesToRemove) {
      messages.removeWhere((msg) => msg['id'] == id);
    }

    showConfirmDialog.value = false;
    _hasAskedForConfirmation = false;

    messages.add({
      'id': 'continue_helping',
      'text': 'Tiếp tục hỗ trợ những người cần giúp đỡ khác nhé! 😊',
      'isUser': false,
      'timestamp': DateTime.now(),
    });
  }

  void _resetCollectedInfo() {
    collectedInfo.value = {
      'type': '',
      'name': '',
      'address': '',
      'capacity': '',
      'contact': '',
      'description': '',
      'title': '',
    };
    extractedData.value = {};
    isComplete.value = false;
    showConfirmDialog.value = false;
    _hasAskedForConfirmation = false;
  }

  Future<void> refreshLocation() async {
    messages.add({
      'id': 'refreshing_location',
      'text': '🔄 Đang cập nhật vị trí tình nguyện viên...',
      'isUser': false,
      'timestamp': DateTime.now(),
      'isSystem': true,
    });

    await getCurrentLocation();

    messages.removeWhere((msg) => msg['id'] == 'refreshing_location');
  }

  void showCollectedInfo() {
    Get.defaultDialog(
      title: '📊 Thông tin volunteer đã thu thập',
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (collectedInfo['type'].toString().isNotEmpty)
              _buildInfoItem('📋 Loại yêu cầu', collectedInfo['type']),
            if (collectedInfo['title'].toString().isNotEmpty)
              _buildInfoItem('🏷️ Tiêu đề', collectedInfo['title']),
            if (collectedInfo['name'].toString().isNotEmpty)
              _buildInfoItem('🏠 Tên địa điểm', collectedInfo['name']),
            if (collectedInfo['address'].toString().isNotEmpty)
              _buildInfoItem('📍 Địa chỉ', collectedInfo['address']),
            if (collectedInfo['capacity'].toString().isNotEmpty)
              _buildInfoItem('👥 Sức chứa', collectedInfo['capacity']),
            if (collectedInfo['description'].toString().isNotEmpty)
              _buildInfoItem('📝 Mô tả', collectedInfo['description']),
            if (collectedInfo['contact'].toString().isNotEmpty)
              _buildInfoItem('📞 Liên hệ', collectedInfo['contact']),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: Text('Đóng')),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 15)),
          SizedBox(height: 4),
        ],
      ),
    );
  }

  @override
  void onClose() {
    super.onClose();
  }
}