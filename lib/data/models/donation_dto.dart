import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/donation_entity.dart';
import '../../core/constants/supply_categories.dart';

/// Donation DTO (Data Transfer Object) - Dùng để serialize/deserialize từ Firebase
class DonationDto {
  final String id;
  final String type; // 'money', 'supplies', 'time'
  final String status; // 'pending', 'completed', 'cancelled'
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
  final String? category;
  final String? customCategory;

  // Time donation fields
  final double? hours;
  final DateTime? date;

  DonationDto({
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

  Map<String, dynamic> toJson() {
    return {
      'Type': type,
      'Status': status,
      'UserId': userId,
      'CreatedAt': Timestamp.fromDate(createdAt),
      'UpdatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'AlertId': alertId,
      'Province': province,
      'District': district,
      'Amount': amount,
      'PaymentMethod': paymentMethod,
      'ItemName': itemName,
      'Quantity': quantity,
      'Description': description,
      'Category': category,
      'CustomCategory': customCategory,
      'Hours': hours,
      'Date': date != null ? Timestamp.fromDate(date!) : null,
    };
  }

  factory DonationDto.fromJson(Map<String, dynamic> json, String id) {
    return DonationDto(
      id: id,
      type: json['Type'] ?? 'money',
      status: json['Status'] ?? 'pending',
      userId: json['UserId'],
      createdAt: (json['CreatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['UpdatedAt'] as Timestamp?)?.toDate(),
      alertId: json['AlertId'],
      province: json['Province'],
      district: json['District'],
      amount: (json['Amount'] as num?)?.toDouble(),
      paymentMethod: json['PaymentMethod'],
      itemName: json['ItemName'],
      quantity: (json['Quantity'] as num?)?.toInt(),
      description: json['Description'],
      category: json['Category'],
      customCategory: json['CustomCategory'],
      hours: (json['Hours'] as num?)?.toDouble(),
      date: (json['Date'] as Timestamp?)?.toDate(),
    );
  }

  factory DonationDto.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    if (data != null) {
      return DonationDto.fromJson(data, document.id);
    } else {
      throw Exception('Donation data is null');
    }
  }

  /// Convert DTO to Entity
  DonationEntity toEntity() {
    return DonationEntity(
      id: id,
      type: _parseDonationType(type),
      status: _parseDonationStatus(status),
      userId: userId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      alertId: alertId,
      province: province,
      district: district,
      amount: amount,
      paymentMethod: paymentMethod,
      itemName: itemName,
      quantity: quantity,
      description: description,
      category: SupplyCategory.fromString(category),
      customCategory: customCategory,
      hours: hours,
      date: date,
    );
  }

  /// Convert Entity to DTO
  factory DonationDto.fromEntity(DonationEntity entity) {
    return DonationDto(
      id: entity.id,
      type: entity.type.name,
      status: entity.status.name,
      userId: entity.userId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      alertId: entity.alertId,
      province: entity.province,
      district: entity.district,
      amount: entity.amount,
      paymentMethod: entity.paymentMethod,
      itemName: entity.itemName,
      quantity: entity.quantity,
      description: entity.description,
      category: entity.category?.name,
      customCategory: entity.customCategory,
      hours: entity.hours,
      date: entity.date,
    );
  }

  DonationType _parseDonationType(String value) {
    return DonationType.values.firstWhere(
      (type) => type.name.toLowerCase() == value.toLowerCase(),
      orElse: () => DonationType.money,
    );
  }

  DonationStatus _parseDonationStatus(String value) {
    return DonationStatus.values.firstWhere(
      (status) => status.name.toLowerCase() == value.toLowerCase(),
      orElse: () => DonationStatus.pending,
    );
  }
}


