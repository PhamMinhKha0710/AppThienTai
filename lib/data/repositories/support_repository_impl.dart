import 'package:cuutrobaolu/domain/entities/support_faq_entity.dart';
import 'package:cuutrobaolu/domain/entities/support_contact_entity.dart';
import 'package:cuutrobaolu/domain/repositories/support_repository.dart';
import 'package:cuutrobaolu/data/datasources/remote/support_remote_data_source.dart';
import 'package:cuutrobaolu/data/datasources/local/support_local_data_source.dart';
import 'package:cuutrobaolu/data/models/support_faq_dto.dart';
import 'package:cuutrobaolu/data/models/support_contact_dto.dart';

/// Support Repository Implementation
class SupportRepositoryImpl implements SupportRepository {
  final SupportRemoteDataSource remoteDataSource;
  final SupportLocalDataSource localDataSource;

  SupportRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<SupportFaqEntity>> getFaqs() async {
    try {
      // Try to get from cache first
      final cachedFaqs = await localDataSource.getCachedFaqs();
      if (cachedFaqs.isNotEmpty) {
        return cachedFaqs.map((dto) => dto.toEntity()).toList();
      }

      // Fetch from remote
      final remoteFaqs = await remoteDataSource.getFaqs();
      
      // Cache the results
      await localDataSource.cacheFaqs(remoteFaqs);
      
      return remoteFaqs.map((dto) => dto.toEntity()).toList();
    } catch (e) {
      // If remote fails, try cache even if expired
      final cachedFaqs = await localDataSource.getCachedFaqs();
      if (cachedFaqs.isNotEmpty) {
        return cachedFaqs.map((dto) => dto.toEntity()).toList();
      }
      
      // Return default FAQs if everything fails
      return _defaultFaqs;
    }
  }

  @override
  Future<List<SupportFaqEntity>> getFaqsByCategory(FaqCategory category) async {
    final allFaqs = await getFaqs();
    return allFaqs.where((faq) => faq.category == category).toList();
  }

  @override
  Future<List<SupportFaqEntity>> searchFaqs(String query) async {
    final allFaqs = await getFaqs();
    final lowerQuery = query.toLowerCase();
    return allFaqs
        .where((faq) =>
            faq.question.toLowerCase().contains(lowerQuery) ||
            faq.answer.toLowerCase().contains(lowerQuery))
        .toList();
  }

  @override
  Future<String> submitContactForm(SupportContactEntity contact) async {
    final dto = SupportContactDto.fromEntity(contact);
    return await remoteDataSource.submitContactForm(dto);
  }

  @override
  Future<List<SupportContactEntity>> getContactHistory(String userId) async {
    final dtos = await remoteDataSource.getContactHistory(userId);
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<Map<String, dynamic>> getAppInfo() async {
    try {
      // Try cache first
      final cachedInfo = await localDataSource.getCachedAppInfo();
      if (cachedInfo != null) {
        return cachedInfo;
      }

      // Fetch from remote
      final appInfo = await remoteDataSource.getAppInfo();
      
      // Cache the results
      await localDataSource.cacheAppInfo(appInfo);
      
      return appInfo;
    } catch (e) {
      // Return default info if everything fails
      return _defaultAppInfo;
    }
  }

  /// Default FAQs for when Firestore is unavailable
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
      ];

  Map<String, dynamic> get _defaultAppInfo => {
        'appName': 'Cứu trợ Thiên tai',
        'version': '1.0.0',
        'buildNumber': '1',
        'description': 'Ứng dụng hỗ trợ cứu trợ thiên tai',
        'developer': 'Development Team',
        'email': 'support@cuutrobaolu.vn',
        'phone': '1900-xxxx',
        'website': 'https://cuutrobaolu.vn',
        'termsUrl': 'https://cuutrobaolu.vn/terms',
        'privacyUrl': 'https://cuutrobaolu.vn/privacy',
        'copyright': '© 2025 Cứu trợ Thiên tai. All rights reserved.',
      };
}

