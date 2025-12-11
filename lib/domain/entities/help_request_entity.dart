/// Help Request Entity - Pure business object
class HelpRequestEntity {
  final String id;
  final String title;
  final String description;
  final double lat;
  final double lng;
  final String contact;
  final RequestSeverity severity;
  final RequestStatus status;
  final RequestType type;
  final String address;
  final String? imageUrl;
  final String? userId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? province;
  final String? district;
  final String? ward;
  final String? detailedAddress;

  const HelpRequestEntity({
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

  HelpRequestEntity copyWith({
    String? id,
    String? title,
    String? description,
    double? lat,
    double? lng,
    String? contact,
    RequestSeverity? severity,
    RequestStatus? status,
    RequestType? type,
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
    return HelpRequestEntity(
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
}

/// Request Type Enum
enum RequestType {
  food,
  water,
  medicine,
  shelter,
  rescue,
  clothes,
  other;

  String get viName {
    switch (this) {
      case RequestType.food:
        return 'Thực phẩm';
      case RequestType.water:
        return 'Nước uống';
      case RequestType.medicine:
        return 'Thuốc men';
      case RequestType.shelter:
        return 'Nơi trú ẩn';
      case RequestType.rescue:
        return 'Cứu hộ';
      case RequestType.clothes:
        return 'Quần áo';
      case RequestType.other:
        return 'Khác';
    }
  }

  String get enName {
    switch (this) {
      case RequestType.food:
        return 'Food';
      case RequestType.water:
        return 'Water';
      case RequestType.medicine:
        return 'Medicine';
      case RequestType.shelter:
        return 'Shelter';
      case RequestType.rescue:
        return 'Rescue';
      case RequestType.clothes:
        return 'Clothes';
      case RequestType.other:
        return 'Other';
    }
  }
}

/// Request Severity Enum
enum RequestSeverity {
  low,
  medium,
  high,
  urgent;

  String get viName {
    switch (this) {
      case RequestSeverity.low:
        return 'Thấp';
      case RequestSeverity.medium:
        return 'Trung bình';
      case RequestSeverity.high:
        return 'Cao';
      case RequestSeverity.urgent:
        return 'Khẩn cấp';
    }
  }

  String get enName {
    switch (this) {
      case RequestSeverity.low:
        return 'Low';
      case RequestSeverity.medium:
        return 'Medium';
      case RequestSeverity.high:
        return 'High';
      case RequestSeverity.urgent:
        return 'Urgent';
    }
  }
}

/// Request Status Enum
enum RequestStatus {
  pending,
  inProgress,
  completed,
  cancelled;

  String get viName {
    switch (this) {
      case RequestStatus.pending:
        return 'Đang chờ';
      case RequestStatus.inProgress:
        return 'Đang xử lý';
      case RequestStatus.completed:
        return 'Hoàn thành';
      case RequestStatus.cancelled:
        return 'Đã hủy';
    }
  }

  String get enName {
    switch (this) {
      case RequestStatus.pending:
        return 'Pending';
      case RequestStatus.inProgress:
        return 'In Progress';
      case RequestStatus.completed:
        return 'Completed';
      case RequestStatus.cancelled:
        return 'Cancelled';
    }
  }
}











