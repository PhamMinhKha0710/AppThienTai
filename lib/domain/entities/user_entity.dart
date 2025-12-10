/// User Entity - Pure business object
/// Không có dependencies vào Firebase, Flutter, hay external packages
class UserEntity {
  final String id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String profilePicture;
  final UserType userType;
  final VolunteerStatus volunteerStatus;
  final bool active;
  final bool isVerified;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.profilePicture,
    required this.userType,
    required this.volunteerStatus,
    required this.active,
    required this.isVerified,
  });

  String get fullName => '$firstName $lastName';

  UserEntity copyWith({
    String? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profilePicture,
    UserType? userType,
    VolunteerStatus? volunteerStatus,
    bool? active,
    bool? isVerified,
  }) {
    return UserEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      userType: userType ?? this.userType,
      volunteerStatus: volunteerStatus ?? this.volunteerStatus,
      active: active ?? this.active,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

/// User Type Enum - Domain enum
enum UserType {
  victim,
  volunteer,
  admin;

  String get viName {
    switch (this) {
      case UserType.victim:
        return 'Nạn nhân';
      case UserType.volunteer:
        return 'Tình nguyện viên';
      case UserType.admin:
        return 'Quản trị viên';
    }
  }

  String get enName {
    switch (this) {
      case UserType.victim:
        return 'Victim';
      case UserType.volunteer:
        return 'Volunteer';
      case UserType.admin:
        return 'Admin';
    }
  }
}

/// Volunteer Status Enum - Domain enum
enum VolunteerStatus {
  available,
  unavailable,
  busy;

  String get viName {
    switch (this) {
      case VolunteerStatus.available:
        return 'Sẵn sàng';
      case VolunteerStatus.unavailable:
        return 'Không sẵn sàng';
      case VolunteerStatus.busy:
        return 'Đang bận';
    }
  }

  String get enName {
    switch (this) {
      case VolunteerStatus.available:
        return 'Available';
      case VolunteerStatus.unavailable:
        return 'Unavailable';
      case VolunteerStatus.busy:
        return 'Busy';
    }
  }
}







