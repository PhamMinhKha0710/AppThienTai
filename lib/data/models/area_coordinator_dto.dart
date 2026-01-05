import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/area_coordinator_entity.dart';

/// Area Coordinator DTO (Data Transfer Object)
class AreaCoordinatorDto {
  final String id;
  final String userId;
  final String province;
  final String? district;
  final String status;
  final DateTime appliedAt;
  final DateTime? approvedAt;
  final String? approvedBy;
  final String? rejectionReason;

  AreaCoordinatorDto({
    required this.id,
    required this.userId,
    required this.province,
    this.district,
    required this.status,
    required this.appliedAt,
    this.approvedAt,
    this.approvedBy,
    this.rejectionReason,
  });

  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'Province': province,
      'District': district,
      'Status': status,
      'AppliedAt': Timestamp.fromDate(appliedAt),
      'ApprovedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'ApprovedBy': approvedBy,
      'RejectionReason': rejectionReason,
    };
  }

  factory AreaCoordinatorDto.fromJson(Map<String, dynamic> json, String id) {
    return AreaCoordinatorDto(
      id: id,
      userId: json['UserId'] ?? '',
      province: json['Province'] ?? '',
      district: json['District'],
      status: json['Status'] ?? 'pending',
      appliedAt: (json['AppliedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      approvedAt: (json['ApprovedAt'] as Timestamp?)?.toDate(),
      approvedBy: json['ApprovedBy'],
      rejectionReason: json['RejectionReason'],
    );
  }

  factory AreaCoordinatorDto.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    if (data != null) {
      return AreaCoordinatorDto.fromJson(data, document.id);
    } else {
      throw Exception('Area coordinator data is null');
    }
  }

  AreaCoordinatorEntity toEntity() {
    return AreaCoordinatorEntity(
      id: id,
      userId: userId,
      province: province,
      district: district,
      status: _parseStatus(status),
      appliedAt: appliedAt,
      approvedAt: approvedAt,
      approvedBy: approvedBy,
      rejectionReason: rejectionReason,
    );
  }

  factory AreaCoordinatorDto.fromEntity(AreaCoordinatorEntity entity) {
    return AreaCoordinatorDto(
      id: entity.id,
      userId: entity.userId,
      province: entity.province,
      district: entity.district,
      status: entity.status.name,
      appliedAt: entity.appliedAt,
      approvedAt: entity.approvedAt,
      approvedBy: entity.approvedBy,
      rejectionReason: entity.rejectionReason,
    );
  }

  AreaCoordinatorStatus _parseStatus(String value) {
    return AreaCoordinatorStatus.values.firstWhere(
      (status) => status.name.toLowerCase() == value.toLowerCase(),
      orElse: () => AreaCoordinatorStatus.pending,
    );
  }
}
















