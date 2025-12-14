import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/shelter_entity.dart';

/// Shelter DTO (Data Transfer Object) - Dùng để serialize/deserialize từ Firebase
class ShelterDto {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final String? description;
  final int capacity;
  final int currentOccupancy;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? contactPhone;
  final String? contactEmail;
  final List<String>? amenities;
  final String? distributionTime;

  ShelterDto({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    this.description,
    required this.capacity,
    required this.currentOccupancy,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.contactPhone,
    this.contactEmail,
    this.amenities,
    this.distributionTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'Address': address,
      'Lat': lat,
      'Lng': lng,
      'Description': description,
      'Capacity': capacity,
      'CurrentOccupancy': currentOccupancy,
      'IsActive': isActive,
      'CreatedAt': Timestamp.fromDate(createdAt),
      'UpdatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'CreatedBy': createdBy,
      'ContactPhone': contactPhone,
      'ContactEmail': contactEmail,
      'Amenities': amenities,
      'DistributionTime': distributionTime,
    };
  }

  factory ShelterDto.fromJson(Map<String, dynamic> json, String id) {
    return ShelterDto(
      id: id,
      name: json['Name'] ?? "",
      address: json['Address'] ?? "",
      lat: (json['Lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['Lng'] as num?)?.toDouble() ?? 0.0,
      description: json['Description'],
      capacity: (json['Capacity'] as num?)?.toInt() ?? 0,
      currentOccupancy: (json['CurrentOccupancy'] as num?)?.toInt() ?? 0,
      isActive: json['IsActive'] ?? true,
      createdAt: (json['CreatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['UpdatedAt'] as Timestamp?)?.toDate(),
      createdBy: json['CreatedBy'],
      contactPhone: json['ContactPhone'],
      contactEmail: json['ContactEmail'],
      amenities: json['Amenities'] != null
          ? List<String>.from(json['Amenities'])
          : null,
      distributionTime: json['DistributionTime'],
    );
  }

  factory ShelterDto.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    if (data != null) {
      return ShelterDto.fromJson(data, document.id);
    } else {
      throw Exception('Shelter data is null');
    }
  }

  /// Convert DTO to Entity
  ShelterEntity toEntity() {
    return ShelterEntity(
      id: id,
      name: name,
      address: address,
      lat: lat,
      lng: lng,
      description: description,
      capacity: capacity,
      currentOccupancy: currentOccupancy,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      contactPhone: contactPhone,
      contactEmail: contactEmail,
      amenities: amenities,
      distributionTime: distributionTime,
    );
  }

  /// Convert Entity to DTO
  factory ShelterDto.fromEntity(ShelterEntity entity) {
    return ShelterDto(
      id: entity.id,
      name: entity.name,
      address: entity.address,
      lat: entity.lat,
      lng: entity.lng,
      description: entity.description,
      capacity: entity.capacity,
      currentOccupancy: entity.currentOccupancy,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      createdBy: entity.createdBy,
      contactPhone: entity.contactPhone,
      contactEmail: entity.contactEmail,
      amenities: entity.amenities,
      distributionTime: entity.distributionTime,
    );
  }
}


