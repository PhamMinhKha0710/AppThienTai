import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/banner_entity.dart';

/// Banner DTO (Data Transfer Object) - Dùng để serialize/deserialize từ Firebase
class BannerDto {
  final String id;
  final String imageUrl;
  final String targetScreen;
  final String name;
  final bool active;

  BannerDto({
    required this.id,
    required this.imageUrl,
    required this.targetScreen,
    required this.name,
    required this.active,
  });

  Map<String, dynamic> toJson() {
    return {
      'ImageUrl': imageUrl,
      'Active': active,
      'TargetScreen': targetScreen,
      'Name': name,
    };
  }

  factory BannerDto.fromJson(Map<String, dynamic> json, String id) {
    return BannerDto(
      id: id,
      name: json['Name'] ?? "",
      imageUrl: json['ImageUrl'] ?? "",
      active: json['Active'] ?? false,
      targetScreen: json['TargetScreen'] ?? "",
    );
  }

  factory BannerDto.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    if (data != null) {
      return BannerDto.fromJson(data, document.id);
    } else {
      return BannerDto(
        id: document.id,
        name: "",
        imageUrl: "",
        active: false,
        targetScreen: "",
      );
    }
  }

  /// Convert DTO to Entity
  BannerEntity toEntity() {
    return BannerEntity(
      id: id,
      imageUrl: imageUrl,
      targetScreen: targetScreen,
      name: name,
      active: active,
    );
  }

  /// Convert Entity to DTO
  factory BannerDto.fromEntity(BannerEntity entity) {
    return BannerDto(
      id: entity.id,
      imageUrl: entity.imageUrl,
      targetScreen: entity.targetScreen,
      name: entity.name,
      active: entity.active,
    );
  }

  /// Static method for empty banner (backward compatibility)
  static BannerDto empty() {
    return BannerDto(
      id: "",
      imageUrl: "",
      active: false,
      targetScreen: "",
      name: '',
    );
  }
}


