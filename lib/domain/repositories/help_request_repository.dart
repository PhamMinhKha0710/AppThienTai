import '../entities/help_request_entity.dart' as domain;

/// Help Request Repository Interface
/// Định nghĩa contract cho help request operations
abstract class HelpRequestRepository {
  /// Tạo help request mới
  Future<String> createHelpRequest(domain.HelpRequestEntity request);

  /// Cập nhật help request
  Future<void> updateHelpRequest(domain.HelpRequestEntity request);

  /// Lấy help request theo ID
  Future<domain.HelpRequestEntity?> getRequestById(String requestId);

  /// Lấy tất cả help requests
  Stream<List<domain.HelpRequestEntity>> getAllRequests();

  /// Lấy help requests theo user ID
  Stream<List<domain.HelpRequestEntity>> getRequestsByUserId(String userId);

  /// Lấy help requests theo status
  Stream<List<domain.HelpRequestEntity>> getRequestsByStatus(domain.RequestStatus status);

  /// Lấy help requests theo severity
  Stream<List<domain.HelpRequestEntity>> getRequestsBySeverity(domain.RequestSeverity severity);

  /// Cập nhật status của help request
  Future<void> updateRequestStatus(String requestId, domain.RequestStatus status);

  /// Xóa help request
  Future<void> deleteRequest(String requestId);
}

