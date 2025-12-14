/// Donation Entity - Pure business object
class DonationEntity {
  final String id;
  final DonationType type;
  final DonationStatus status;
  final String? userId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Money donation fields
  final double? amount;
  final String? paymentMethod;

  // Supplies donation fields
  final String? itemName;
  final int? quantity;
  final String? description;

  // Time donation fields
  final double? hours;
  final DateTime? date;

  const DonationEntity({
    required this.id,
    required this.type,
    required this.status,
    this.userId,
    required this.createdAt,
    this.updatedAt,
    this.amount,
    this.paymentMethod,
    this.itemName,
    this.quantity,
    this.description,
    this.hours,
    this.date,
  });

  DonationEntity copyWith({
    String? id,
    DonationType? type,
    DonationStatus? status,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? amount,
    String? paymentMethod,
    String? itemName,
    int? quantity,
    String? description,
    double? hours,
    DateTime? date,
  }) {
    return DonationEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
      hours: hours ?? this.hours,
      date: date ?? this.date,
    );
  }
}

/// Donation Type Enum
enum DonationType {
  money,
  supplies,
  time;

  String get viName {
    switch (this) {
      case DonationType.money:
        return 'Tiền';
      case DonationType.supplies:
        return 'Vật phẩm';
      case DonationType.time:
        return 'Thời gian';
    }
  }
}

/// Donation Status Enum
enum DonationStatus {
  pending,
  completed,
  cancelled;

  String get viName {
    switch (this) {
      case DonationStatus.pending:
        return 'Chờ xử lý';
      case DonationStatus.completed:
        return 'Hoàn thành';
      case DonationStatus.cancelled:
        return 'Đã hủy';
    }
  }
}


