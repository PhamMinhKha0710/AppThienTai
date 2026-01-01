import '../../core/constants/supply_categories.dart';

/// Donation Plan Item - Item trong kế hoạch quyên góp
class DonationPlanItem {
  final SupplyCategory? category;
  final String? customCategory;
  final int quantity;
  final String? description;
  final int? receivedQuantity; // Số lượng đã nhận được

  const DonationPlanItem({
    this.category,
    this.customCategory,
    required this.quantity,
    this.description,
    this.receivedQuantity,
  });

  DonationPlanItem copyWith({
    SupplyCategory? category,
    String? customCategory,
    int? quantity,
    String? description,
    int? receivedQuantity,
  }) {
    return DonationPlanItem(
      category: category ?? this.category,
      customCategory: customCategory ?? this.customCategory,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
      receivedQuantity: receivedQuantity ?? this.receivedQuantity,
    );
  }

  String get categoryName {
    if (category != null && category != SupplyCategory.other) {
      return category!.viName;
    }
    return customCategory ?? 'Khác';
  }
}

/// Donation Plan Status Enum
enum DonationPlanStatus {
  draft,
  active,
  completed,
  cancelled;

  String get viName {
    switch (this) {
      case DonationPlanStatus.draft:
        return 'Nháp';
      case DonationPlanStatus.active:
        return 'Đang hoạt động';
      case DonationPlanStatus.completed:
        return 'Hoàn thành';
      case DonationPlanStatus.cancelled:
        return 'Đã hủy';
    }
  }
}

/// Donation Plan Entity - Kế hoạch quyên góp của khu vực
class DonationPlanEntity {
  final String id;
  final String coordinatorId;
  final String province;
  final String? district;
  final String title;
  final String? description;
  final List<DonationPlanItem> requiredItems;
  final DonationPlanStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? expiresAt;
  final String? alertId; // Optional: link to specific alert

  const DonationPlanEntity({
    required this.id,
    required this.coordinatorId,
    required this.province,
    this.district,
    required this.title,
    this.description,
    required this.requiredItems,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.expiresAt,
    this.alertId,
  });

  DonationPlanEntity copyWith({
    String? id,
    String? coordinatorId,
    String? province,
    String? district,
    String? title,
    String? description,
    List<DonationPlanItem>? requiredItems,
    DonationPlanStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expiresAt,
    String? alertId,
  }) {
    return DonationPlanEntity(
      id: id ?? this.id,
      coordinatorId: coordinatorId ?? this.coordinatorId,
      province: province ?? this.province,
      district: district ?? this.district,
      title: title ?? this.title,
      description: description ?? this.description,
      requiredItems: requiredItems ?? this.requiredItems,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      alertId: alertId ?? this.alertId,
    );
  }
}


