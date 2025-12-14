import '../entities/alert_entity.dart';

/// Alert Repository Interface
/// Định nghĩa contract cho alert operations
abstract class AlertRepository {
  /// Lấy tất cả alerts
  Stream<List<AlertEntity>> getAllAlerts();

  /// Lấy active alerts (chưa hết hạn)
  Stream<List<AlertEntity>> getActiveAlerts();

  /// Lấy alerts theo severity
  Stream<List<AlertEntity>> getAlertsBySeverity(String severity);

  /// Lấy alerts gần vị trí
  Future<List<AlertEntity>> getNearbyAlerts(
    double lat,
    double lng,
    double radiusKm,
  );

  /// Lấy alerts liên quan đến task cho volunteer
  Stream<List<AlertEntity>> getTaskRelatedAlerts(String? volunteerId);
}


