import 'package:cuutrobaolu/core/constants/enums.dart';
import 'package:cuutrobaolu/core/utils/helper_functions.dart';
import 'package:cuutrobaolu/core/utils/formatter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String id;
  String username;
  String email;
  String firstName;
  String lastName;
  String phoneNumber;
  String profilePicture;
  UserType userType;
  VolunteerStatus volunteerStatus;
  bool active;
  bool isVerified;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.profilePicture,

    this.userType = UserType.victim,
    this.volunteerStatus = VolunteerStatus.available,
    this.active = true,
    this.isVerified = false,
  });

  String get fullName => '$firstName $lastName';

  String get formattedPhoneNumber =>
      MinhFormatter.formatPhoneNumber(phoneNumber);

  static List<String> nameParts(fullName) => fullName.split(" ");

  static String generateUsername(fullName) {
    List<String> nameParts = fullName.split(" ");
    String firstName = nameParts[0].toLowerCase();
    String lastName = nameParts.length > 1 ? nameParts[1].toLowerCase() : "";

    String camelCaseUsername =
        "$firstName$lastName"; // Combine first and last name
    String usernameWithPrefix = "cwt_$camelCaseUsername"; // Add "cwt_" prefix
    return usernameWithPrefix;
  }

  // Static function to create an empty user model.
  static UserModel empty() => UserModel(
    id: "",
    firstName: "",
    lastName: "",
    username: "",
    email: "",
    phoneNumber: "",
    profilePicture: "",

    userType: UserType.victim,
    active: true,
    isVerified: false,
    volunteerStatus: VolunteerStatus.available,
  );

  // Convert model to JSON structure for storing data in Firebase.
  Map<String, dynamic> toJson() {
    return {
      'FirstName': firstName,
      'LastName': lastName,
      'Username': username,
      'Email': email,
      'PhoneNumber': phoneNumber,
      'ProfilePicture': profilePicture,

      'UserType': userType.name,
      'VolunteerStatus': volunteerStatus?.name,
      'Active': active,
      'IsVerified': isVerified,
    };
  }

  // Factory method to create a UserModel from a Firebase document snapshot.
  factory UserModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;
    return UserModel(
      id: document.id,
      firstName: data['FirstName'] ?? "",
      lastName: data['LastName'] ?? "",
      username: data['Username'] ?? "",
      email: data['Email'] ?? "",
      phoneNumber: data['PhoneNumber'] ?? "",
      profilePicture: data['ProfilePicture'] ?? "",

      isVerified: data['IsVerified'] ?? false,
      userType: data['UserType'] != null
          ? UserType.values.firstWhere(
              (type) =>
                  type.name.toLowerCase() ==
                  data['UserType'].toString().toLowerCase(),
            )
          : UserType.victim,

      volunteerStatus: data['VolunteerStatus'] != null
          ? VolunteerStatus.values.firstWhere(
              // (status) => status.name == data['VolunteerStatus'],
              (status) =>
                  status.name.toLowerCase() ==
                  data['VolunteerStatus'].toString().toLowerCase(),
            )
          : VolunteerStatus.available,
      active: data['Active'] ?? true,
    );
  }
}
