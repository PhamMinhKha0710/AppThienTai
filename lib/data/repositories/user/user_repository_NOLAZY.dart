import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../domain/entities/user_entity.dart';
import '../../models/user_dto.dart';
import 'package:cuutrobaolu/core/exceptions/exports.dart';


class UserRepositoryNOLAZY extends GetxController{

  static UserRepositoryNOLAZY get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;


  Future<UserEntity?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final snapshot = await _db.collection("Users").doc(user.uid).get();

      if (snapshot.exists && snapshot.data() != null) {
        final dto = UserDto.fromSnapshot(snapshot);
        return dto.toEntity();
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  /// Update một field đơn lẻ trong user document
  Future<void> updateSingField(Map<String, dynamic> json) async {
    try {
      await _db
          .collection("Users")
          .doc(_auth.currentUser?.uid)
          .update(json);
    } on FirebaseException catch (e) {
      print("Lỗi: ${e.message}");
      throw MinhFirebaseException(e.code).message;
    } catch (e) {
      throw "Something went wrong! Please try again";
    }
  }

  /// Update user details
  Future<void> updateUserDetails(UserEntity userUpdate) async {
    try {
      final dto = UserDto.fromEntity(userUpdate);
      await _db
          .collection("Users")
          .doc(userUpdate.id)
          .update(dto.toJson());
    } on FirebaseException catch (e) {
      throw MinhFirebaseException(e.code).message;
    } catch (e) {
      throw "Something went wrong! Please try again";
    }
  }

  /// Save user record
  Future<void> saveUserFireRecord(UserEntity user) async {
    try {
      final dto = UserDto.fromEntity(user);
      await _db.collection("Users").doc(user.id).set(dto.toJson());
    } on FirebaseException catch (e) {
      print("Lỗi: ${e.message}");
      throw MinhFirebaseException(e.code).message;
    } catch (e) {
      throw "Something went wrong! Please try again";
    }
  }

  Future<void> deleteAccount(String userId) async {
    try {
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser;
      if (user == null) throw 'User not logged in';

      final providerId = user.providerData.first.providerId;

      // 1️⃣ Re-authenticate theo provider
      if (providerId == 'password') {
        throw 'REQUIRE_PASSWORD'; // UI yêu cầu nhập mật khẩu
      }

      if (providerId == 'google.com') {
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) throw 'Google sign in cancelled';

        final googleAuth = await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await user.reauthenticateWithCredential(credential);
      }

      // 2️⃣ Xoá Auth
      await user.delete();

      // 3️⃣ Xoá Firestore
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .delete();

      // 4️⃣ Logout
      await auth.signOut();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw 'Vui lòng đăng nhập lại để xoá tài khoản';
      }
      throw e.message ?? 'Auth error';
    }
  }


}






