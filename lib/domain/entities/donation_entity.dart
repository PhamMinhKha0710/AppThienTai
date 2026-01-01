import '../../core/constants/supply_categories.dart';

/// Donation Entity - Pure business object
class DonationEntity {
  final String id;
  final DonationType type;
  final DonationStatus status;
  final String? userId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Linking fields
  final String? alertId;
  final String? province;
  final String? district;

  // Money donation fields
  final double? amount;
  final String? paymentMethod;

  // Supplies donation fields
  final String? itemName;
  final int? quantity;
  final String? description;
  final SupplyCategory? category;
  final String? customCategory;

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
    this.alertId,
    this.province,
    this.district,
    this.amount,
    this.paymentMethod,
    this.itemName,
    this.quantity,
    this.description,
    this.category,
    this.customCategory,
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
    String? alertId,
    String? province,
    String? district,
    double? amount,
    String? paymentMethod,
    String? itemName,
    int? quantity,
    String? description,
    SupplyCategory? category,
    String? customCategory,
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
      alertId: alertId ?? this.alertId,
      province: province ?? this.province,
      district: district ?? this.district,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
      category: category ?? this.category,
      customCategory: customCategory ?? this.customCategory,
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


