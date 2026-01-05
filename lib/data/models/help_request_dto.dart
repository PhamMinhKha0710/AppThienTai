import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/help_request_entity.dart';

/// Help Request DTO (Data Transfer Object)
class HelpRequestDto {
  final String id;
  final String title;
  final String description;
  final double lat;
  final double lng;
  final String contact;
  final String severity;
  final String status;
  final String type;
  final String address;
  final String? imageUrl;
  final String? userId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? province;
  final String? district;
  final String? ward;
  final String? detailedAddress;

  HelpRequestDto({
    required this.id,
    required this.title,
    required this.description,
    required this.lat,
    required this.lng,
    required this.contact,
    required this.severity,
    required this.status,
    required this.type,
    required this.address,
    this.imageUrl,
    this.userId,
    required this.createdAt,
    this.updatedAt,
    this.province,
    this.district,
    this.ward,
    this.detailedAddress,
  });

  Map<String, dynamic> toJson({bool includeId = false}) {
    final map = <String, dynamic>{
      'Title': title,
      'Description': description,
      'Lat': lat,
      'Lng': lng,
      'Contact': contact,
      'Severity': severity,
      'Status': status,
      'Type': type,
      'Address': address,
      'UserId': userId,
      'ImageUrl': imageUrl,
      'CreatedAt': Timestamp.fromDate(createdAt),
      'UpdatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'Province': province,
      'District': district,
      'Ward': ward,
      'DetailedAddress': detailedAddress,
    };

    if (includeId) map['Id'] = id;
    map.removeWhere((key, value) => value == null);
    return map;
  }

  HelpRequestDto copyWith({
    String? id,
    String? title,
    String? description,
    double? lat,
    double? lng,
    String? contact,
    String? severity,
    String? status,
    String? type,
    String? address,
    String? imageUrl,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? province,
    String? district,
    String? ward,
    String? detailedAddress,
  }) {
    return HelpRequestDto(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      contact: contact ?? this.contact,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      type: type ?? this.type,
      address: address ?? this.address,
      imageUrl: imageUrl ?? this.imageUrl,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      province: province ?? this.province,
      district: district ?? this.district,
      ward: ward ?? this.ward,
      detailedAddress: detailedAddress ?? this.detailedAddress,
    );
  }

  factory HelpRequestDto.fromJson(Map<String, dynamic> json, [String? id]) {
    DateTime parseDT(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      return DateTime.now();
    }

    return HelpRequestDto(
      id: id ?? json['Id'] ?? "",
      title: json['Title'] ?? "",
      description: json['Description'] ?? "",
      lat: (json['Lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['Lng'] as num?)?.toDouble() ?? 0.0,
      contact: json['Contact'] ?? "",
      severity: _toStringSafe(json['Severity'], 'medium'),
      status: _toStringSafe(json['Status'], 'pending'),
      type: _toStringSafe(json['Type'], 'other'),
      address: json['Address'] ?? "",
      userId: json['UserId'],
      imageUrl: json['ImageUrl'],
      createdAt: parseDT(json['CreatedAt']),
      updatedAt: json['UpdatedAt'] != null ? parseDT(json['UpdatedAt']) : null,
      province: json['Province'],
      district: json['District'],
      ward: json['Ward'],
      detailedAddress: json['DetailedAddress'],
    );
  }

  factory HelpRequestDto.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      return HelpRequestDto(
        id: doc.id,
        title: "",
        description: "",
        lat: 0,
        lng: 0,
        contact: "",
        severity: 'medium',
        status: 'pending',
        type: 'other',
        address: "",
        createdAt: DateTime.now(),
      );
    }

    return HelpRequestDto.fromJson({
      ...data,
      'Id': doc.id,
    });
  }

  /// Convert DTO to Entity
  HelpRequestEntity toEntity() {
    return HelpRequestEntity(
      id: id,
      title: title,
      description: description,
      lat: lat,
      lng: lng,
      contact: contact,
      severity: _parseSeverity(severity),
      status: _parseStatus(status),
      type: _parseType(type),
      address: address,
      imageUrl: imageUrl,
      userId: userId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      province: province,
      district: district,
      ward: ward,
      detailedAddress: detailedAddress,
    );
  }

  /// Convert Entity to DTO
  factory HelpRequestDto.fromEntity(HelpRequestEntity entity) {
    return HelpRequestDto(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      lat: entity.lat,
      lng: entity.lng,
      contact: entity.contact,
      severity: entity.severity.name,
      status: entity.status.name,
      type: entity.type.name,
      address: entity.address,
      imageUrl: entity.imageUrl,
      userId: entity.userId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      province: entity.province,
      district: entity.district,
      ward: entity.ward,
      detailedAddress: entity.detailedAddress,
    );
  }

  // Helper method to safely convert enum or string to string
  /// Handles both String and enum types from Firebase
  /// Ensures backward compatibility with existing string data
  static String _toStringSafe(dynamic value, String defaultValue) {
    if (value == null) return defaultValue;
    if (value is String) return value;
    if (value is RequestSeverity) return value.name;
    if (value is RequestStatus) return value.name;
    if (value is RequestType) return value.name;
    // Fallback: try to convert to string
    return value.toString();
  }

  RequestSeverity _parseSeverity(String value) {
    try {
      return RequestSeverity.values.firstWhere(
        (severity) => severity.name.toLowerCase() == value.toLowerCase(),
        orElse: () => RequestSeverity.medium,
      );
    } catch (e) {
      return RequestSeverity.medium;
    }
  }

  RequestStatus _parseStatus(String value) {
    try {
      return RequestStatus.values.firstWhere(
        (status) => status.name.toLowerCase() == value.toLowerCase(),
        orElse: () => RequestStatus.pending,
      );
    } catch (e) {
      return RequestStatus.pending;
    }
  }

  RequestType _parseType(String value) {
    try {
      return RequestType.values.firstWhere(
        (type) => type.name.toLowerCase() == value.toLowerCase(),
        orElse: () => RequestType.other,
      );
    } catch (e) {
      return RequestType.other;
    }
  }
}

