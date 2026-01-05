/// Area Coordinator Status Enum
enum AreaCoordinatorStatus {
  pending,
  approved,
  rejected;

  String get viName {
    switch (this) {
      case AreaCoordinatorStatus.pending:
        return 'Chờ duyệt';
      case AreaCoordinatorStatus.approved:
        return 'Đã duyệt';
      case AreaCoordinatorStatus.rejected:
        return 'Đã từ chối';
    }
  }
}

/// Area Coordinator Entity - Người điều phối khu vực
class AreaCoordinatorEntity {
  final String id;
  final String userId;
  final String province;
  final String? district;
  final AreaCoordinatorStatus status;
  final DateTime appliedAt;
  final DateTime? approvedAt;
  final String? approvedBy;
  final String? rejectionReason;

  const AreaCoordinatorEntity({
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

  AreaCoordinatorEntity copyWith({
    String? id,
    String? userId,
    String? province,
    String? district,
    AreaCoordinatorStatus? status,
    DateTime? appliedAt,
    DateTime? approvedAt,
    String? approvedBy,
    String? rejectionReason,
  }) {
    return AreaCoordinatorEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      province: province ?? this.province,
      district: district ?? this.district,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  bool get isApproved => status == AreaCoordinatorStatus.approved;
  bool get isPending => status == AreaCoordinatorStatus.pending;
  bool get isRejected => status == AreaCoordinatorStatus.rejected;
}



















