import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/alert_entity.dart';

/// Alert DTO (Data Transfer Object) - Dùng để serialize/deserialize từ Firebase
class AlertDto {
  final String id;
  final String title;
  final String content;
  final String severity; // Store as string for Firebase
  final String alertType; // Store as string for Firebase
  final String targetAudience; // Store as string for Firebase
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
  final String? volunteerId;
  final String? safetyGuide;
  final List<String>? imageUrls;

  AlertDto({
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
  });

  Map<String, dynamic> toJson() {
    return {
      'Title': title,
      'Content': content,
      'Severity': severity,
      'AlertType': alertType,
      'TargetAudience': targetAudience,
      'Lat': lat,
      'Lng': lng,
      'Location': location,
      'RadiusKm': radiusKm,
      'Province': province,
      'District': district,
      'IsActive': isActive,
      'CreatedAt': Timestamp.fromDate(createdAt),
      'UpdatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'ExpiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'VolunteerId': volunteerId,
      'SafetyGuide': safetyGuide,
      'ImageUrls': imageUrls,
    };
  }

  factory AlertDto.fromJson(Map<String, dynamic> json, String id) {
    return AlertDto(
      id: id,
      title: json['Title'] ?? "",
      content: json['Content'] ?? "",
      severity: _toStringSafe(json['Severity'], 'medium'),
      alertType: _toStringSafe(json['AlertType'], 'general'),
      targetAudience: _toStringSafe(json['TargetAudience'], 'all'),
      lat: (json['Lat'] as num?)?.toDouble(),
      lng: (json['Lng'] as num?)?.toDouble(),
      location: json['Location'],
      radiusKm: (json['RadiusKm'] as num?)?.toDouble(),
      province: json['Province'],
      district: json['District'],
      isActive: json['IsActive'] ?? true,
      createdAt: (json['CreatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['UpdatedAt'] as Timestamp?)?.toDate(),
      expiresAt: (json['ExpiresAt'] as Timestamp?)?.toDate(),
      volunteerId: json['VolunteerId'],
      safetyGuide: json['SafetyGuide'],
      imageUrls: (json['ImageUrls'] as List?)?.cast<String>(),
    );
  }

  factory AlertDto.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    if (data != null) {
      return AlertDto.fromJson(data, document.id);
    } else {
      throw Exception('Alert data is null');
    }
  }

  /// Convert DTO to Entity
  AlertEntity toEntity() {
    return AlertEntity(
      id: id,
      title: title,
      content: content,
      severity: _parseSeverity(severity),
      alertType: _parseAlertType(alertType),
      targetAudience: _parseTargetAudience(targetAudience),
      lat: lat,
      lng: lng,
      location: location,
      radiusKm: radiusKm,
      province: province,
      district: district,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      expiresAt: expiresAt,
      volunteerId: volunteerId,
      safetyGuide: safetyGuide,
      imageUrls: imageUrls,
    );
  }

  /// Convert Entity to DTO
  factory AlertDto.fromEntity(AlertEntity entity) {
    return AlertDto(
      id: entity.id,
      title: entity.title,
      content: entity.content,
      severity: entity.severity.name,
      alertType: entity.alertType.name,
      targetAudience: entity.targetAudience.name,
      lat: entity.lat,
      lng: entity.lng,
      location: entity.location,
      radiusKm: entity.radiusKm,
      province: entity.province,
      district: entity.district,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      expiresAt: entity.expiresAt,
      volunteerId: entity.volunteerId,
      safetyGuide: entity.safetyGuide,
      imageUrls: entity.imageUrls,
    );
  }

  // Helper method to safely convert enum or string to string
  /// Handles both String and enum types from Firebase
  /// Ensures backward compatibility with existing string data
  static String _toStringSafe(dynamic value, String defaultValue) {
    if (value == null) return defaultValue;
    if (value is String) return value;
    if (value is AlertSeverity) return value.name;
    if (value is AlertType) return value.name;
    if (value is TargetAudience) return value.name;
    // Fallback: try to convert to string
    return value.toString();
  }

  // Helper methods to parse enums from strings
  AlertSeverity _parseSeverity(String value) {
    try {
      return AlertSeverity.values.firstWhere(
        (e) => e.name.toLowerCase() == value.toLowerCase(),
        orElse: () => AlertSeverity.medium,
      );
    } catch (e) {
      return AlertSeverity.medium;
    }
  }

  AlertType _parseAlertType(String value) {
    try {
      return AlertType.values.firstWhere(
        (e) => e.name.toLowerCase() == value.toLowerCase(),
        orElse: () => AlertType.general,
      );
    } catch (e) {
      return AlertType.general;
    }
  }

  TargetAudience _parseTargetAudience(String value) {
    try {
      return TargetAudience.values.firstWhere(
        (e) => e.name.toLowerCase() == value.toLowerCase(),
        orElse: () => TargetAudience.all,
      );
    } catch (e) {
      return TargetAudience.all;
    }
  }
}
