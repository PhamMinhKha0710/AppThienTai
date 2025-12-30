import 'package:cuutrobaolu/core/popups/exports.dart';
import 'package:cuutrobaolu/domain/entities/support_faq_entity.dart';
import 'package:cuutrobaolu/domain/entities/support_contact_entity.dart';
import 'package:cuutrobaolu/domain/repositories/support_repository.dart';
import 'package:cuutrobaolu/presentation/features/personalization/controllers/user/user_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Support Controller - Manages state for support features
class SupportController extends GetxController {
  static SupportController get instance => Get.find();

  // Dependencies
  SupportRepository? _repository;

  // FAQ state
  final faqs = <SupportFaqEntity>[].obs;
  final filteredFaqs = <SupportFaqEntity>[].obs;
  final isLoadingFaqs = false.obs;
  final searchQuery = ''.obs;
  final selectedCategory = Rxn<FaqCategory>();

  // Contact form state
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final messageController = TextEditingController();
  final selectedSubject = Rx<ContactSubject>(ContactSubject.general);
  final isSubmitting = false.obs;

  // App info state
  final appInfo = <String, dynamic>{}.obs;
  final isLoadingAppInfo = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initRepository();
    _loadFaqs();
    _loadAppInfo();
    _prefillUserInfo();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    messageController.dispose();
    super.onClose();
  }

  void _initRepository() {
    try {
      _repository = Get.find<SupportRepository>();
    } catch (e) {
      // Repository not registered, will use default data
      debugPrint('SupportRepository not found, using default data');
    }
  }

  void _prefillUserInfo() {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        emailController.text = user.email ?? '';
        
        // Try to get more user info from UserController
        try {
          final userController = Get.find<UserController>();
          nameController.text = userController.user.value.fullName;
        } catch (e) {
          nameController.text = user.displayName ?? '';
        }
      }
    } catch (e) {
      debugPrint('Error prefilling user info: $e');
    }
  }

  Future<void> _loadFaqs() async {
    isLoadingFaqs.value = true;
    try {
      if (_repository != null) {
        faqs.value = await _repository!.getFaqs();
      } else {
        faqs.value = _defaultFaqs;
      }
      filteredFaqs.value = faqs;
    } catch (e) {
      faqs.value = _defaultFaqs;
      filteredFaqs.value = faqs;
    } finally {
      isLoadingFaqs.value = false;
    }
  }

  Future<void> _loadAppInfo() async {
    isLoadingAppInfo.value = true;
    try {
      if (_repository != null) {
        appInfo.value = await _repository!.getAppInfo();
      } else {
        appInfo.value = _defaultAppInfo;
      }
    } catch (e) {
      appInfo.value = _defaultAppInfo;
    } finally {
      isLoadingAppInfo.value = false;
    }
  }

  void searchFaqs(String query) {
    searchQuery.value = query;
    _filterFaqs();
  }

  void selectCategory(FaqCategory? category) {
    selectedCategory.value = category;
    _filterFaqs();
  }

  void _filterFaqs() {
    var result = faqs.toList();

    // Filter by category
    if (selectedCategory.value != null) {
      result = result
          .where((faq) => faq.category == selectedCategory.value)
          .toList();
    }

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      final lowerQuery = searchQuery.value.toLowerCase();
      result = result
          .where((faq) =>
              faq.question.toLowerCase().contains(lowerQuery) ||
              faq.answer.toLowerCase().contains(lowerQuery))
          .toList();
    }

    filteredFaqs.value = result;
  }

  void selectSubject(ContactSubject subject) {
    selectedSubject.value = subject;
  }

  Future<bool> submitContact() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        messageController.text.isEmpty) {
      MinhLoaders.errorSnackBar(
        title: 'Lỗi',
        message: 'Vui lòng điền đầy đủ thông tin',
      );
      return false;
    }

    isSubmitting.value = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      final contact = SupportContactEntity(
        userId: user?.uid ?? 'anonymous',
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        subject: selectedSubject.value,
        message: messageController.text.trim(),
        createdAt: DateTime.now(),
      );

      if (_repository != null) {
        await _repository!.submitContactForm(contact);
      } else {
        // Simulate submission delay
        await Future.delayed(const Duration(seconds: 1));
      }

      // Clear form
      messageController.clear();
      selectedSubject.value = ContactSubject.general;

      return true;
    } catch (e) {
      MinhLoaders.errorSnackBar(
        title: 'Lỗi',
        message: 'Không thể gửi yêu cầu. Vui lòng thử lại.',
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // Default FAQs when repository is not available
  List<SupportFaqEntity> get _defaultFaqs => [
        const SupportFaqEntity(
          id: '1',
          question: 'Làm thế nào để gửi yêu cầu cứu trợ?',
          answer:
              'Bạn có thể gửi yêu cầu cứu trợ bằng cách vào màn hình chính, nhấn nút "Tạo yêu cầu cứu trợ" và điền đầy đủ thông tin cần thiết.',
          category: FaqCategory.general,
          order: 1,
        ),
        const SupportFaqEntity(
          id: '2',
          question: 'Nút SOS hoạt động như thế nào?',
          answer:
              'Khi nhấn nút SOS, ứng dụng sẽ gửi thông báo khẩn cấp kèm vị trí của bạn đến các tình nguyện viên và đội cứu hộ gần nhất.',
          category: FaqCategory.emergency,
          order: 2,
        ),
        const SupportFaqEntity(
          id: '3',
          question: 'Làm sao để xem các điểm sơ tán?',
          answer:
              'Vào phần "Bản đồ" trong ứng dụng, bạn sẽ thấy các điểm sơ tán được đánh dấu trên bản đồ. Nhấn vào điểm để xem chi tiết.',
          category: FaqCategory.features,
          order: 3,
        ),
        const SupportFaqEntity(
          id: '4',
          question: 'Làm sao để thay đổi mật khẩu?',
          answer:
              'Vào Cài đặt > Đổi mật khẩu, nhập mật khẩu hiện tại và mật khẩu mới để thay đổi.',
          category: FaqCategory.account,
          order: 4,
        ),
        const SupportFaqEntity(
          id: '5',
          question: 'Ứng dụng có thông báo khi có thiên tai không?',
          answer:
              'Có, ứng dụng sẽ gửi thông báo tự động khi có cảnh báo thiên tai trong khu vực của bạn. Đảm bảo bật thông báo trong cài đặt.',
          category: FaqCategory.features,
          order: 5,
        ),
        const SupportFaqEntity(
          id: '6',
          question: 'Làm sao để đăng ký làm tình nguyện viên?',
          answer:
              'Liên hệ với chúng tôi qua form hỗ trợ hoặc gọi đường dây nóng để đăng ký. Chúng tôi sẽ xác minh và cấp quyền tình nguyện viên cho bạn.',
          category: FaqCategory.account,
          order: 6,
        ),
        const SupportFaqEntity(
          id: '7',
          question: 'Tôi có thể xem lại các yêu cầu đã gửi không?',
          answer:
              'Có, vào Cài đặt > Yêu cầu của tôi để xem tất cả các yêu cầu bạn đã gửi và trạng thái của chúng.',
          category: FaqCategory.features,
          order: 7,
        ),
        const SupportFaqEntity(
          id: '8',
          question: 'Khi nào nên sử dụng nút SOS?',
          answer:
              'Chỉ sử dụng nút SOS trong trường hợp khẩn cấp thực sự như đang bị mắc kẹt, cần cứu hộ y tế, hoặc gặp nguy hiểm tính mạng. Việc lạm dụng SOS có thể ảnh hưởng đến người cần giúp đỡ thực sự.',
          category: FaqCategory.emergency,
          order: 8,
        ),
      ];

  Map<String, dynamic> get _defaultAppInfo => {
        'appName': 'Cứu trợ Thiên tai',
        'version': '1.0.0',
        'buildNumber': '1',
        'description':
            'Ứng dụng hỗ trợ cứu trợ thiên tai, kết nối người cần giúp đỡ với tình nguyện viên và các tổ chức cứu trợ.',
        'developer': 'Development Team',
        'email': 'support@cuutrobaolu.vn',
        'phone': '1900-xxxx',
        'website': 'https://cuutrobaolu.vn',
        'termsUrl': 'https://cuutrobaolu.vn/terms',
        'privacyUrl': 'https://cuutrobaolu.vn/privacy',
        'copyright': '© 2025 Cứu trợ Thiên tai. All rights reserved.',
      };
}

