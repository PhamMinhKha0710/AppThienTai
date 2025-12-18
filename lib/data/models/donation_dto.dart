import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/donation_entity.dart';

/// Donation DTO (Data Transfer Object) - Dùng để serialize/deserialize từ Firebase
class DonationDto {
  final String id;
  final String type; // 'money', 'supplies', 'time'
  final String status; // 'pending', 'completed', 'cancelled'
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

  DonationDto({
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

  Map<String, dynamic> toJson() {
    return {
      'Type': type,
      'Status': status,
      'UserId': userId,
      'CreatedAt': Timestamp.fromDate(createdAt),
      'UpdatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'Amount': amount,
      'PaymentMethod': paymentMethod,
      'ItemName': itemName,
      'Quantity': quantity,
      'Description': description,
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
      amount: (json['Amount'] as num?)?.toDouble(),
      paymentMethod: json['PaymentMethod'],
      itemName: json['ItemName'],
      quantity: (json['Quantity'] as num?)?.toInt(),
      description: json['Description'],
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
      amount: amount,
      paymentMethod: paymentMethod,
      itemName: itemName,
      quantity: quantity,
      description: description,
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
      amount: entity.amount,
      paymentMethod: entity.paymentMethod,
      itemName: entity.itemName,
      quantity: entity.quantity,
      description: entity.description,
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


