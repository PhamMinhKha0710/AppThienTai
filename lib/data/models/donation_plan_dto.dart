import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/donation_plan_entity.dart';
import '../../core/constants/supply_categories.dart';

/// Donation Plan DTO (Data Transfer Object)
class DonationPlanDto {
  final String id;
  final String coordinatorId;
  final String province;
  final String? district;
  final String title;
  final String? description;
  final List<Map<String, dynamic>> requiredItems;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? expiresAt;
  final String? alertId;

  DonationPlanDto({
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

  Map<String, dynamic> toJson() {
    return {
      'CoordinatorId': coordinatorId,
      'Province': province,
      'District': district,
      'Title': title,
      'Description': description,
      'RequiredItems': requiredItems,
      'Status': status,
      'CreatedAt': Timestamp.fromDate(createdAt),
      'UpdatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'ExpiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'AlertId': alertId,
    };
  }

  factory DonationPlanDto.fromJson(Map<String, dynamic> json, String id) {
    return DonationPlanDto(
      id: id,
      coordinatorId: json['CoordinatorId'] ?? '',
      province: json['Province'] ?? '',
      district: json['District'],
      title: json['Title'] ?? '',
      description: json['Description'],
      requiredItems: (json['RequiredItems'] as List<dynamic>?)
              ?.map((item) => item as Map<String, dynamic>)
              .toList() ??
          [],
      status: json['Status'] ?? 'draft',
      createdAt: (json['CreatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['UpdatedAt'] as Timestamp?)?.toDate(),
      expiresAt: (json['ExpiresAt'] as Timestamp?)?.toDate(),
      alertId: json['AlertId'],
    );
  }

  factory DonationPlanDto.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    if (data != null) {
      return DonationPlanDto.fromJson(data, document.id);
    } else {
      throw Exception('Donation plan data is null');
    }
  }

  DonationPlanEntity toEntity() {
    return DonationPlanEntity(
      id: id,
      coordinatorId: coordinatorId,
      province: province,
      district: district,
      title: title,
      description: description,
      requiredItems: requiredItems.map((item) {
        return DonationPlanItem(
          category: SupplyCategory.fromString(item['Category']),
          customCategory: item['CustomCategory'],
          quantity: (item['Quantity'] as num?)?.toInt() ?? 0,
          description: item['Description'],
          receivedQuantity: (item['ReceivedQuantity'] as num?)?.toInt(),
        );
      }).toList(),
      status: _parseStatus(status),
      createdAt: createdAt,
      updatedAt: updatedAt,
      expiresAt: expiresAt,
      alertId: alertId,
    );
  }

  factory DonationPlanDto.fromEntity(DonationPlanEntity entity) {
    return DonationPlanDto(
      id: entity.id,
      coordinatorId: entity.coordinatorId,
      province: entity.province,
      district: entity.district,
      title: entity.title,
      description: entity.description,
      requiredItems: entity.requiredItems.map((item) {
        return {
          'Category': item.category?.name,
          'CustomCategory': item.customCategory,
          'Quantity': item.quantity,
          'Description': item.description,
          'ReceivedQuantity': item.receivedQuantity,
        };
      }).toList(),
      status: entity.status.name,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      expiresAt: entity.expiresAt,
      alertId: entity.alertId,
    );
  }

  DonationPlanStatus _parseStatus(String value) {
    return DonationPlanStatus.values.firstWhere(
      (status) => status.name.toLowerCase() == value.toLowerCase(),
      orElse: () => DonationPlanStatus.draft,
    );
  }
}


