/// Alert Type Enum
enum AlertType {
  disaster,   // Thiên tai
  weather,    // Thời tiết xấu
  evacuation, // Sơ tán khẩn cấp
  resource,   // Nguồn cứu trợ
  general;    // Thông báo chung

  String get viName {
    switch (this) {
      case AlertType.disaster:
        return 'Thiên tai';
      case AlertType.weather:
        return 'Thời tiết xấu';
      case AlertType.evacuation:
        return 'Sơ tán khẩn cấp';
      case AlertType.resource:
        return 'Nguồn cứu trợ';
      case AlertType.general:
        return 'Thông báo chung';
    }
  }

  String get enName {
    switch (this) {
      case AlertType.disaster:
        return 'Disaster';
      case AlertType.weather:
        return 'Weather';
      case AlertType.evacuation:
        return 'Evacuation';
      case AlertType.resource:
        return 'Resource';
      case AlertType.general:
        return 'General';
    }
  }
}

/// Alert Severity Enum
enum AlertSeverity {
  low,      // Thấp
  medium,   // Trung bình
  high,     // Cao
  critical; // Cực kỳ nghiêm trọng

  String get viName {
    switch (this) {
      case AlertSeverity.low:
        return 'Thấp';
      case AlertSeverity.medium:
        return 'Trung bình';
      case AlertSeverity.high:
        return 'Cao';
      case AlertSeverity.critical:
        return 'Cực kỳ nghiêm trọng';
    }
  }

  String get enName {
    switch (this) {
      case AlertSeverity.low:
        return 'Low';
      case AlertSeverity.medium:
        return 'Medium';
      case AlertSeverity.high:
        return 'High';
      case AlertSeverity.critical:
        return 'Critical';
    }
  }
}

/// Target Audience Enum
enum TargetAudience {
  all,           // Tất cả
  victims,       // Nạn nhân
  volunteers,    // Tình nguyện viên
  locationBased; // Theo vị trí

  String get viName {
    switch (this) {
      case TargetAudience.all:
        return 'Tất cả';
      case TargetAudience.victims:
        return 'Nạn nhân';
      case TargetAudience.volunteers:
        return 'Tình nguyện viên';
      case TargetAudience.locationBased:
        return 'Theo vị trí';
    }
  }

  String get enName {
    switch (this) {
      case TargetAudience.all:
        return 'All';
      case TargetAudience.victims:
        return 'Victims';
      case TargetAudience.volunteers:
        return 'Volunteers';
      case TargetAudience.locationBased:
        return 'Location Based';
    }
  }
}

/// Alert Entity - Pure business object
class AlertEntity {
  final String id;
  final String title;
  final String content;
  final AlertSeverity severity;
  final AlertType alertType;
  final TargetAudience targetAudience;
  final double? lat;
  final double? lng;
  final String? location;
  final double? radiusKm;
  final String? province;
  final String? district;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? expiresAt;
  final String? volunteerId; // For task-related alerts
  final String? safetyGuide;
  final List<String>? imageUrls;
  
  /// Điểm ưu tiên đã tính (0-100) - được cập nhật bởi AlertScoringService
  final double? priorityScore;
  
  /// Khoảng cách đến người dùng (km) - được cập nhật khi tính điểm
  final double? distanceKm;

  const AlertEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.severity,
    required this.alertType,
    required this.targetAudience,
    this.lat,
    this.lng,
    this.location,
    this.radiusKm,
    this.province,
    this.district,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
    this.expiresAt,
    this.volunteerId,
    this.safetyGuide,
    this.imageUrls,
    this.priorityScore,
    this.distanceKm,
  });

  AlertEntity copyWith({
    String? id,
    String? title,
    String? content,
    AlertSeverity? severity,
    AlertType? alertType,
    TargetAudience? targetAudience,
    double? lat,
    double? lng,
    String? location,
    double? radiusKm,
    String? province,
    String? district,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expiresAt,
    String? volunteerId,
    String? safetyGuide,
    List<String>? imageUrls,
    double? priorityScore,
    double? distanceKm,
  }) {
    return AlertEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      severity: severity ?? this.severity,
      alertType: alertType ?? this.alertType,
      targetAudience: targetAudience ?? this.targetAudience,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      location: location ?? this.location,
      radiusKm: radiusKm ?? this.radiusKm,
      province: province ?? this.province,
      district: district ?? this.district,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      volunteerId: volunteerId ?? this.volunteerId,
      safetyGuide: safetyGuide ?? this.safetyGuide,
      imageUrls: imageUrls ?? this.imageUrls,
      priorityScore: priorityScore ?? this.priorityScore,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }
}

