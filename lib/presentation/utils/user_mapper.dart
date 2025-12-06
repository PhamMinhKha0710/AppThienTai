import '../../domain/entities/user_entity.dart' as domain;
import '../features/personalization/models/user_model.dart';
import '../../core/constants/enums.dart' as core;

/// Mapper để convert giữa UserEntity (domain) và UserModel (presentation)
class UserMapper {
  /// Convert UserEntity to UserModel
  static UserModel toModel(domain.UserEntity entity) {
    return UserModel(
      id: entity.id,
      username: entity.username,
      email: entity.email,
      firstName: entity.firstName,
      lastName: entity.lastName,
      phoneNumber: entity.phoneNumber,
      profilePicture: entity.profilePicture,
      userType: _convertUserType(entity.userType),
      volunteerStatus: _convertVolunteerStatus(entity.volunteerStatus),
      active: entity.active,
      isVerified: entity.isVerified,
    );
  }

  /// Convert UserModel to UserEntity
  static domain.UserEntity toEntity(UserModel model) {
    return domain.UserEntity(
      id: model.id,
      username: model.username,
      email: model.email,
      firstName: model.firstName,
      lastName: model.lastName,
      phoneNumber: model.phoneNumber,
      profilePicture: model.profilePicture,
      userType: _convertUserTypeToDomain(model.userType),
      volunteerStatus: _convertVolunteerStatusToDomain(model.volunteerStatus),
      active: model.active,
      isVerified: model.isVerified,
    );
  }

  static core.UserType _convertUserType(domain.UserType type) {
    switch (type) {
      case domain.UserType.victim:
        return core.UserType.victim;
      case domain.UserType.volunteer:
        return core.UserType.volunteer;
      case domain.UserType.admin:
        return core.UserType.admin;
    }
  }

  static domain.UserType _convertUserTypeToDomain(core.UserType type) {
    switch (type) {
      case core.UserType.victim:
        return domain.UserType.victim;
      case core.UserType.volunteer:
        return domain.UserType.volunteer;
      case core.UserType.admin:
        return domain.UserType.admin;
    }
  }

  static core.VolunteerStatus _convertVolunteerStatus(domain.VolunteerStatus status) {
    switch (status) {
      case domain.VolunteerStatus.available:
        return core.VolunteerStatus.available;
      case domain.VolunteerStatus.unavailable:
        return core.VolunteerStatus.unavailable;
      case domain.VolunteerStatus.busy:
        return core.VolunteerStatus.busy;
    }
  }

  static domain.VolunteerStatus _convertVolunteerStatusToDomain(core.VolunteerStatus status) {
    switch (status) {
      case core.VolunteerStatus.available:
        return domain.VolunteerStatus.available;
      case core.VolunteerStatus.unavailable:
        return domain.VolunteerStatus.unavailable;
      case core.VolunteerStatus.busy:
        return domain.VolunteerStatus.busy;
    }
  }
}

