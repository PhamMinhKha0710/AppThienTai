import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/alert_entity.dart';

/// Alert DTO (Data Transfer Object) - Dùng để serialize/deserialize từ Firebase
class AlertDto {
  final String id;
  final String title;
  final String content;
  final String severity;
  final double? lat;
  final double? lng;
  final String? location;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? expiresAt;
  final String? type;
  final String? volunteerId;

  AlertDto({
    required this.id,
    required this.title,
    required this.content,
    required this.severity,
    this.lat,
    this.lng,
    this.location,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
    this.expiresAt,
    this.type,
    this.volunteerId,
  });

  Map<String, dynamic> toJson() {
    return {
      'Title': title,
      'Content': content,
      'Severity': severity,
      'Lat': lat,
      'Lng': lng,
      'Location': location,
      'IsActive': isActive,
      'CreatedAt': Timestamp.fromDate(createdAt),
      'UpdatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'ExpiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'Type': type,
      'VolunteerId': volunteerId,
    };
  }

  factory AlertDto.fromJson(Map<String, dynamic> json, String id) {
    return AlertDto(
      id: id,
      title: json['Title'] ?? "",
      content: json['Content'] ?? "",
      severity: json['Severity'] ?? 'medium',
      lat: (json['Lat'] as num?)?.toDouble(),
      lng: (json['Lng'] as num?)?.toDouble(),
      location: json['Location'],
      isActive: json['IsActive'] ?? true,
      createdAt: (json['CreatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['UpdatedAt'] as Timestamp?)?.toDate(),
      expiresAt: (json['ExpiresAt'] as Timestamp?)?.toDate(),
      type: json['Type'],
      volunteerId: json['VolunteerId'],
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
      severity: severity,
      lat: lat,
      lng: lng,
      location: location,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      expiresAt: expiresAt,
      type: type,
      volunteerId: volunteerId,
    );
  }

  /// Convert Entity to DTO
  factory AlertDto.fromEntity(AlertEntity entity) {
    return AlertDto(
      id: entity.id,
      title: entity.title,
      content: entity.content,
      severity: entity.severity,
      lat: entity.lat,
      lng: entity.lng,
      location: entity.location,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      expiresAt: entity.expiresAt,
      type: entity.type,
      volunteerId: entity.volunteerId,
    );
  }
}


