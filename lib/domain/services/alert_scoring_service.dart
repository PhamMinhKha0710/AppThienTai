import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../entities/alert_entity.dart';
import '../entities/scored_alert_entity.dart';

/// Service tính điểm ưu tiên cho cảnh báo sử dụng thuật toán Multi-factor Scoring.
/// 
/// Thuật toán kết hợp 5 yếu tố:
/// - **Severity**: Mức độ nghiêm trọng của cảnh báo (35%)
/// - **Type**: Loại cảnh báo (thiên tai, thời tiết, sơ tán...) (20%)
/// - **Time Decay**: Độ mới của cảnh báo (sử dụng Exponential Decay) (15%)
/// - **Distance**: Khoảng cách từ người dùng đến vị trí cảnh báo (20%)
/// - **Audience**: Độ phù hợp với đối tượng người dùng (10%)
/// 
/// ## Công thức
/// ```
/// FinalScore = sum(Wi * Scorei) for i in [Severity, Type, TimeDecay, Distance, Audience]
/// ```
/// 
/// ## Ví dụ sử dụng
/// ```dart
/// final service = AlertScoringService();
/// final scoredAlert = service.calculateScoredAlert(
///   alert: alert,
///   userLat: 10.762622,
///   userLng: 106.660172,
///   userRole: 'victim',
/// );
/// print('Priority Score: ${scoredAlert.score}'); // Output: Priority Score: 78.5
/// ```
/// 
/// ## Tham khảo
/// - [Multi-criteria Decision Analysis](https://en.wikipedia.org/wiki/Multi-criteria_decision_analysis)
/// - [Exponential Decay](https://en.wikipedia.org/wiki/Exponential_decay)
/// - [Haversine Formula](https://en.wikipedia.org/wiki/Haversine_formula)
class AlertScoringService {
  // ========== Configurable Weights ==========
  /// Trọng số cho Severity (mức độ nghiêm trọng)
  final double weightSeverity;
  
  /// Trọng số cho Type (loại cảnh báo)
  final double weightType;
  
  /// Trọng số cho Time Decay (độ mới)
  final double weightTimeDecay;
  
  /// Trọng số cho Distance (khoảng cách)
  final double weightDistance;
  
  /// Trọng số cho Audience (đối tượng)
  final double weightAudience;
  
  /// Hệ số suy giảm cho Time Decay (lambda)
  final double timeDecayLambda;
  
  /// Bán kính tối đa để tính điểm khoảng cách (km)
  final double maxDistanceRadius;

  /// Constructor với các trọng số mặc định
  const AlertScoringService({
    this.weightSeverity = 0.35,
    this.weightType = 0.20,
    this.weightTimeDecay = 0.15,
    this.weightDistance = 0.20,
    this.weightAudience = 0.10,
    this.timeDecayLambda = 0.05,
    this.maxDistanceRadius = 50.0,
  });

  // ========== Public Methods ==========

  /// Tính điểm ưu tiên cuối cùng cho một cảnh báo
  /// 
  /// Trả về giá trị từ 0-100, càng cao càng ưu tiên.
  /// 
  /// ## Parameters
  /// - [alert]: Cảnh báo cần tính điểm
  /// - [userLat]: Vĩ độ người dùng (null nếu không có)
  /// - [userLng]: Kinh độ người dùng (null nếu không có)
  /// - [userRole]: Vai trò người dùng ('victim', 'volunteer', 'admin')
  /// 
  /// ## Returns
  /// Điểm ưu tiên từ 0-100
  double calculatePriorityScore({
    required AlertEntity alert,
    required double? userLat,
    required double? userLng,
    required String userRole,
  }) {
    final severityScore = _getSeverityScore(alert.severity);
    final typeScore = _getTypeScore(alert.alertType);
    final timeDecayScore = _calculateTimeDecay(alert.createdAt, alert.expiresAt);
    final distanceScore = _calculateDistanceScore(alert, userLat, userLng);
    final audienceScore = _getAudienceScore(alert.targetAudience, userRole);

    final finalScore = (weightSeverity * severityScore) +
        (weightType * typeScore) +
        (weightTimeDecay * timeDecayScore) +
        (weightDistance * distanceScore) +
        (weightAudience * audienceScore);

    debugPrint('[AlertScoring] ${alert.title}: '
        'S=${severityScore.toStringAsFixed(1)} '
        'T=${typeScore.toStringAsFixed(1)} '
        'TD=${timeDecayScore.toStringAsFixed(1)} '
        'D=${distanceScore.toStringAsFixed(1)} '
        'A=${audienceScore.toStringAsFixed(1)} '
        '=> ${finalScore.toStringAsFixed(2)}');

    return finalScore.clamp(0.0, 100.0);
  }

  /// Tạo ScoredAlert object với điểm đã tính
  /// 
  /// Tiện lợi hơn [calculatePriorityScore] khi cần cả điểm và khoảng cách.
  ScoredAlert calculateScoredAlert({
    required AlertEntity alert,
    required double? userLat,
    required double? userLng,
    required String userRole,
  }) {
    final score = calculatePriorityScore(
      alert: alert,
      userLat: userLat,
      userLng: userLng,
      userRole: userRole,
    );

    double? distance;
    if (userLat != null && userLng != null && 
        alert.lat != null && alert.lng != null) {
      distance = _haversineDistance(
        userLat, userLng,
        alert.lat!, alert.lng!,
      );
    }

    return ScoredAlert.now(
      alert: alert,
      score: score,
      distanceKm: distance,
    );
  }

  /// Tính điểm cho nhiều cảnh báo cùng lúc
  /// 
  /// Hiệu quả hơn khi cần tính điểm cho nhiều cảnh báo.
  List<ScoredAlert> calculateMultipleScores({
    required List<AlertEntity> alerts,
    required double? userLat,
    required double? userLng,
    required String userRole,
  }) {
    return alerts.map((alert) {
      return calculateScoredAlert(
        alert: alert,
        userLat: userLat,
        userLng: userLng,
        userRole: userRole,
      );
    }).toList();
  }

  // ========== Severity Scoring ==========

  /// Tính điểm dựa trên mức độ nghiêm trọng
  /// 
  /// ## Bảng điểm:
  /// - Critical: 100
  /// - High: 75
  /// - Medium: 50
  /// - Low: 25
  double _getSeverityScore(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return 100.0;
      case AlertSeverity.high:
        return 75.0;
      case AlertSeverity.medium:
        return 50.0;
      case AlertSeverity.low:
        return 25.0;
    }
  }

  // ========== Type Scoring ==========

  /// Tính điểm dựa trên loại cảnh báo
  /// 
  /// ## Bảng điểm:
  /// - Disaster (Thiên tai): 100
  /// - Evacuation (Sơ tán): 90
  /// - Weather (Thời tiết): 70
  /// - Resource (Cứu trợ): 50
  /// - General (Chung): 30
  double _getTypeScore(AlertType type) {
    switch (type) {
      case AlertType.disaster:
        return 100.0;
      case AlertType.evacuation:
        return 90.0;
      case AlertType.weather:
        return 70.0;
      case AlertType.resource:
        return 50.0;
      case AlertType.general:
        return 30.0;
    }
  }

  // ========== Time Decay Algorithm ==========

  /// Time Decay sử dụng Exponential Decay Formula
  /// 
  /// ## Công thức:
  /// ```
  /// TimeDecayScore = 100 * e^(-lambda * hoursElapsed)
  /// ```
  /// 
  /// Trong đó:
  /// - lambda = [timeDecayLambda] (mặc định 0.05)
  /// - hoursElapsed = số giờ từ khi tạo cảnh báo
  /// 
  /// ## Phân tích:
  /// - Sau 12 giờ: Score giảm còn ~55%
  /// - Sau 24 giờ: Score giảm còn ~30%
  /// - Sau 48 giờ: Score giảm còn ~9%
  /// 
  /// ## Returns
  /// Điểm từ 0-100, càng mới càng cao
  double _calculateTimeDecay(DateTime createdAt, DateTime? expiresAt) {
    final now = DateTime.now();

    // Nếu đã hết hạn, trả về 0
    if (expiresAt != null && now.isAfter(expiresAt)) {
      return 0.0;
    }

    // Tính số giờ đã trôi qua
    final hoursElapsed = now.difference(createdAt).inMinutes / 60.0;

    // Exponential decay: score = 100 * e^(-lambda * hours)
    final decayScore = 100 * math.exp(-timeDecayLambda * hoursElapsed);

    // Clamp giữa 0 và 100
    return decayScore.clamp(0.0, 100.0);
  }

  // ========== Location-based Priority Boost ==========

  /// Location-based Priority sử dụng Inverse Distance Weighting
  /// 
  /// ## Công thức:
  /// ```
  /// DistanceScore = 100 * (1 - (distance / maxRadius))^2
  /// ```
  /// 
  /// Trong đó:
  /// - distance = khoảng cách từ người dùng đến cảnh báo (km)
  /// - maxRadius = [maxDistanceRadius] (mặc định 50km)
  /// 
  /// ## Ngưỡng khoảng cách:
  /// - 0-5km: 100 (Khẩn cấp ngay)
  /// - 5-15km: 75-90
  /// - 15-30km: 50-75
  /// - 30-50km: 25-50
  /// - >50km: 0-25
  /// 
  /// ## Returns
  /// Điểm từ 0-100, càng gần càng cao
  double _calculateDistanceScore(
    AlertEntity alert,
    double? userLat,
    double? userLng,
  ) {
    // Nếu không có thông tin vị trí, trả về điểm trung bình
    if (userLat == null || userLng == null) return 50.0;
    if (alert.lat == null || alert.lng == null) return 50.0;

    // Tính khoảng cách sử dụng Haversine
    final distance = _haversineDistance(
      userLat,
      userLng,
      alert.lat!,
      alert.lng!,
    );

    // Nếu quá xa, trả về 0
    if (distance >= maxDistanceRadius) return 0.0;

    // Inverse distance weighting với quadratic falloff
    // Công thức: 100 * (1 - d/r)^2
    // Điều này tạo ra sự suy giảm nhanh hơn khi càng xa
    final ratio = 1 - (distance / maxDistanceRadius);
    return 100 * ratio * ratio;
  }

  /// Haversine Formula để tính khoảng cách giữa 2 tọa độ
  /// 
  /// ## Công thức:
  /// ```
  /// a = sin²(Δlat/2) + cos(lat1) * cos(lat2) * sin²(Δlng/2)
  /// c = 2 * atan2(√a, √(1-a))
  /// distance = R * c
  /// ```
  /// 
  /// Trong đó R = bán kính Trái Đất (6371 km)
  /// 
  /// ## Returns
  /// Khoảng cách tính bằng km
  double _haversineDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const double earthRadius = 6371.0; // km

    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  /// Chuyển đổi độ sang radian
  double _toRadians(double degrees) => degrees * (math.pi / 180);

  // ========== Audience Scoring ==========

  /// Tính điểm dựa trên độ phù hợp với đối tượng
  /// 
  /// ## Logic:
  /// - Nếu targetAudience là 'all': 100
  /// - Nếu targetAudience khớp với userRole: 100
  /// - Nếu targetAudience là 'locationBased': 80 (phụ thuộc vào vị trí)
  /// - Ngược lại: 50 (vẫn hiển thị nhưng ưu tiên thấp)
  double _getAudienceScore(TargetAudience targetAudience, String userRole) {
    // All audience - điểm cao nhất
    if (targetAudience == TargetAudience.all) {
      return 100.0;
    }

    // Check perfect match
    final roleMap = {
      'victim': TargetAudience.victims,
      'volunteer': TargetAudience.volunteers,
    };

    if (roleMap[userRole.toLowerCase()] == targetAudience) {
      return 100.0;
    }

    // Location-based alerts - điểm cao vì có geofencing
    if (targetAudience == TargetAudience.locationBased) {
      return 80.0;
    }

    // Không khớp nhưng vẫn cho xem
    return 50.0;
  }

  // ========== Utility Methods ==========

  /// Tạo cấu hình tùy chỉnh với trọng số khác
  AlertScoringService copyWith({
    double? weightSeverity,
    double? weightType,
    double? weightTimeDecay,
    double? weightDistance,
    double? weightAudience,
    double? timeDecayLambda,
    double? maxDistanceRadius,
  }) {
    return AlertScoringService(
      weightSeverity: weightSeverity ?? this.weightSeverity,
      weightType: weightType ?? this.weightType,
      weightTimeDecay: weightTimeDecay ?? this.weightTimeDecay,
      weightDistance: weightDistance ?? this.weightDistance,
      weightAudience: weightAudience ?? this.weightAudience,
      timeDecayLambda: timeDecayLambda ?? this.timeDecayLambda,
      maxDistanceRadius: maxDistanceRadius ?? this.maxDistanceRadius,
    );
  }

  /// Kiểm tra tổng trọng số có bằng 1.0 không (để đảm bảo chính xác)
  bool isWeightValid() {
    final total = weightSeverity +
        weightType +
        weightTimeDecay +
        weightDistance +
        weightAudience;
    return (total - 1.0).abs() < 0.001; // Allow small floating point error
  }

  @override
  String toString() {
    return 'AlertScoringService('
        'severity:$weightSeverity, '
        'type:$weightType, '
        'decay:$weightTimeDecay, '
        'distance:$weightDistance, '
        'audience:$weightAudience'
        ')';
  }
}
