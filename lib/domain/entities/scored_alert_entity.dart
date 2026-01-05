import 'package:equatable/equatable.dart';
import 'alert_entity.dart';

/// Scored Alert Entity - Alert với điểm ưu tiên đã được tính toán
/// 
/// Entity này bọc [AlertEntity] và thêm điểm ưu tiên ([score]) được tính toán
/// dựa trên Multi-factor Severity Scoring Algorithm.
/// 
/// ## Các yếu tố ảnh hưởng đến score:
/// - Severity: Mức độ nghiêm trọng của cảnh báo (35%)
/// - Type: Loại cảnh báo (20%)
/// - Time Decay: Độ mới của cảnh báo (15%)
/// - Distance: Khoảng cách đến người dùng (20%)
/// - Audience: Đối tượng mục tiêu (10%)
/// 
/// ## Ví dụ sử dụng:
/// ```dart
/// final scoredAlert = ScoredAlert(
///   alert: myAlert,
///   score: 87.5,
///   distanceKm: 12.3,
/// );
/// ```
class ScoredAlert extends Equatable {
  /// Alert entity gốc
  final AlertEntity alert;
  
  /// Điểm ưu tiên (0-100), càng cao càng ưu tiên
  final double score;
  
  /// Khoảng cách từ người dùng đến vị trí cảnh báo (km)
  /// Null nếu không có thông tin vị trí
  final double? distanceKm;
  
  /// Thời gian tính điểm
  final DateTime calculatedAt;

  ScoredAlert({
    required this.alert,
    required this.score,
    this.distanceKm,
    DateTime? calculatedAt,
  }) : calculatedAt = calculatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  /// Factory constructor với timestamp hiện tại
  factory ScoredAlert.now({
    required AlertEntity alert,
    required double score,
    double? distanceKm,
  }) {
    return ScoredAlert(
      alert: alert,
      score: score,
      distanceKm: distanceKm,
      calculatedAt: DateTime.now(),
    );
  }

  /// Copy with new values
  ScoredAlert copyWith({
    AlertEntity? alert,
    double? score,
    double? distanceKm,
    DateTime? calculatedAt,
  }) {
    return ScoredAlert(
      alert: alert ?? this.alert,
      score: score ?? this.score,
      distanceKm: distanceKm ?? this.distanceKm,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  /// Kiểm tra xem điểm có được tính trong khoảng thời gian gần đây không
  /// (mặc định 5 phút)
  bool isScoreFresh([Duration maxAge = const Duration(minutes: 5)]) {
    return DateTime.now().difference(calculatedAt) <= maxAge;
  }

  /// Lấy mức độ ưu tiên dạng text
  String get priorityLevel {
    if (score >= 80) return 'Rất cao';
    if (score >= 60) return 'Cao';
    if (score >= 40) return 'Trung bình';
    if (score >= 20) return 'Thấp';
    return 'Rất thấp';
  }

  @override
  List<Object?> get props => [alert, score, distanceKm, calculatedAt];

  @override
  String toString() {
    return 'ScoredAlert(alert: ${alert.id}, score: ${score.toStringAsFixed(2)}, '
           'distance: ${distanceKm?.toStringAsFixed(2)}km, level: $priorityLevel)';
  }
}
