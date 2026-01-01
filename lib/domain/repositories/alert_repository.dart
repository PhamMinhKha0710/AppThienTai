import '../entities/alert_entity.dart';

/// Alert Repository Interface
/// Định nghĩa contract cho alert operations
abstract class AlertRepository {
  /// Lấy tất cả alerts
  Stream<List<AlertEntity>> getAllAlerts();

  /// Lấy active alerts (chưa hết hạn)
  Stream<List<AlertEntity>> getActiveAlerts();

  /// Lấy alerts theo severity
  Stream<List<AlertEntity>> getAlertsBySeverity(AlertSeverity severity);

  /// Lấy alerts theo type
  Stream<List<AlertEntity>> getAlertsByType(AlertType type);

  /// Lấy alerts theo target audience
  Stream<List<AlertEntity>> getAlertsByTargetAudience(TargetAudience audience);

  /// Lấy alerts gần vị trí
  Future<List<AlertEntity>> getNearbyAlerts(
    double lat,
    double lng,
    double radiusKm,
  );

  /// Lấy alerts liên quan đến task cho volunteer
  Stream<List<AlertEntity>> getTaskRelatedAlerts(String? volunteerId);

  /// Tạo alert mới
  Future<void> createAlert(AlertEntity alert);

  /// Cập nhật alert
  Future<void> updateAlert(AlertEntity alert);

  /// Xóa alert
  Future<void> deleteAlert(String alertId);

  /// Vô hiệu hóa alert (set isActive = false)
  Future<void> deactivateAlert(String alertId);

  /// Lấy alert theo ID
  Future<AlertEntity?> getAlertById(String alertId);

  /// Lấy alert theo ID với real-time updates (stream)
  Stream<AlertEntity?> getAlertByIdStream(String alertId);
}


