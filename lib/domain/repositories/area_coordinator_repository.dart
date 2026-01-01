import '../entities/area_coordinator_entity.dart';

/// Area Coordinator Repository Interface
/// Định nghĩa contract cho area coordinator operations
abstract class AreaCoordinatorRepository {
  /// Đăng ký làm điều phối khu vực
  Future<String> applyAsCoordinator({
    required String userId,
    required String province,
    String? district,
  });

  /// Duyệt đơn đăng ký điều phối
  Future<void> approveCoordinator(
    String coordinatorId,
    String approvedBy,
  );

  /// Từ chối đơn đăng ký điều phối
  Future<void> rejectCoordinator(
    String coordinatorId,
    String approvedBy,
    String? rejectionReason,
  );

  /// Lấy thông tin điều phối theo khu vực
  Future<AreaCoordinatorEntity?> getCoordinatorByArea(
    String province,
    String? district,
  );

  /// Lấy thông tin điều phối theo user
  Future<AreaCoordinatorEntity?> getCoordinatorByUser(String userId);

  /// Lấy danh sách tất cả điều phối
  Future<List<AreaCoordinatorEntity>> getAllCoordinators();

  /// Kiểm tra user có phải là điều phối của khu vực không
  Future<bool> isCoordinatorOfArea(
    String userId,
    String province,
    String? district,
  );
}


