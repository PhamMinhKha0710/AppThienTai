import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

/// User DTO (Data Transfer Object) - Dùng để serialize/deserialize từ Firebase
class UserDto {
  final String id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String profilePicture;
  final String userType;
  final String? volunteerStatus;
  final bool active;
  final bool isVerified;

  UserDto({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.profilePicture,
    required this.userType,
    this.volunteerStatus,
    required this.active,
    required this.isVerified,
  });

  Map<String, dynamic> toJson() {
    return {
      'FirstName': firstName,
      'LastName': lastName,
      'Username': username,
      'Email': email,
      'PhoneNumber': phoneNumber,
      'ProfilePicture': profilePicture,
      'UserType': userType,
      'VolunteerStatus': volunteerStatus,
      'Active': active,
      'IsVerified': isVerified,
    };
  }

  factory UserDto.fromJson(Map<String, dynamic> json, String id) {
    return UserDto(
      id: id,
      firstName: json['FirstName'] ?? "",
      lastName: json['LastName'] ?? "",
      username: json['Username'] ?? "",
      email: json['Email'] ?? "",
      phoneNumber: json['PhoneNumber'] ?? "",
      profilePicture: json['ProfilePicture'] ?? "",
      userType: json['UserType'] ?? 'victim',
      volunteerStatus: json['VolunteerStatus'],
      active: json['Active'] ?? true,
      isVerified: json['IsVerified'] ?? false,
    );
  }

  factory UserDto.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return UserDto.fromJson(data, document.id);
  }

  /// Convert DTO to Entity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      username: username,
      email: email,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      profilePicture: profilePicture,
      userType: _parseUserType(userType),
      volunteerStatus: _parseVolunteerStatus(volunteerStatus),
      active: active,
      isVerified: isVerified,
    );
  }

  /// Convert Entity to DTO
  factory UserDto.fromEntity(UserEntity entity) {
    return UserDto(
      id: entity.id,
      username: entity.username,
      email: entity.email,
      firstName: entity.firstName,
      lastName: entity.lastName,
      phoneNumber: entity.phoneNumber,
      profilePicture: entity.profilePicture,
      userType: entity.userType.name,
      volunteerStatus: entity.volunteerStatus.name,
      active: entity.active,
      isVerified: entity.isVerified,
    );
  }

  UserType _parseUserType(String value) {
    return UserType.values.firstWhere(
      (type) => type.name.toLowerCase() == value.toLowerCase(),
      orElse: () => UserType.victim,
    );
  }

  VolunteerStatus _parseVolunteerStatus(String? value) {
    if (value == null) return VolunteerStatus.available;
    return VolunteerStatus.values.firstWhere(
      (status) => status.name.toLowerCase() == value.toLowerCase(),
      orElse: () => VolunteerStatus.available,
    );
  }
}

