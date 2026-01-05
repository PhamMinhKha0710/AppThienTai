import '../entities/donation_plan_entity.dart';

/// Donation Plan Repository Interface
/// Định nghĩa contract cho donation plan operations
abstract class DonationPlanRepository {
  /// Tạo kế hoạch quyên góp mới
  Future<String> createPlan(DonationPlanEntity plan);

  /// Cập nhật kế hoạch quyên góp
  Future<void> updatePlan(DonationPlanEntity plan);

  /// Lấy kế hoạch theo ID
  Future<DonationPlanEntity?> getPlanById(String planId);

  /// Lấy danh sách kế hoạch theo khu vực
  Future<List<DonationPlanEntity>> getPlansByArea(
    String province,
    String? district,
  );

  /// Lấy danh sách kế hoạch theo alert
  Future<List<DonationPlanEntity>> getPlansByAlert(String alertId);

  /// Lấy danh sách kế hoạch của coordinator
  Future<List<DonationPlanEntity>> getPlansByCoordinator(String coordinatorId);

  /// Xóa kế hoạch quyên góp
  Future<void> deletePlan(String planId);

  /// Stream kế hoạch theo khu vực
  Stream<List<DonationPlanEntity>> streamPlansByArea(
    String province,
    String? district,
  );
}



















