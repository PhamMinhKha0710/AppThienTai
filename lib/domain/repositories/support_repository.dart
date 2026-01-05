import '../entities/support_faq_entity.dart';
import '../entities/support_contact_entity.dart';

/// Support Repository Interface
/// Định nghĩa contract cho support operations
abstract class SupportRepository {
  /// Lấy danh sách FAQ
  Future<List<SupportFaqEntity>> getFaqs();

  /// Lấy FAQ theo category
  Future<List<SupportFaqEntity>> getFaqsByCategory(FaqCategory category);

  /// Tìm kiếm FAQ
  Future<List<SupportFaqEntity>> searchFaqs(String query);

  /// Gửi liên hệ/feedback
  Future<String> submitContactForm(SupportContactEntity contact);

  /// Lấy lịch sử liên hệ của user
  Future<List<SupportContactEntity>> getContactHistory(String userId);

  /// Lấy thông tin ứng dụng (version, terms, etc.)
  Future<Map<String, dynamic>> getAppInfo();
}





















