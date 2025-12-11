import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cuutrobaolu/presentation/features/personalization/models/user_model.dart';
import 'package:cuutrobaolu/core/exceptions/exports.dart';

/// Adapter để bridge giữa UserRepository interface và UserModel
/// Cung cấp các method cần thiết cho controllers
class UserRepositoryAdapter {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Lấy user hiện tại dưới dạng UserModel
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final snapshot = await _db.collection("Users").doc(user.uid).get();

      if (snapshot.exists) {
        return UserModel.fromSnapshot(snapshot);
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
  Future<void> updateUserDetails(UserModel userUpdate) async {
    try {
      await _db
          .collection("Users")
          .doc(userUpdate.id)
          .update(userUpdate.toJson());
    } on FirebaseException catch (e) {
      throw MinhFirebaseException(e.code).message;
    } catch (e) {
      throw "Something went wrong! Please try again";
    }
  }

  /// Save user record
  Future<void> saveUserFireRecord(UserModel user) async {
    try {
      await _db.collection("Users").doc(user.id).set(user.toJson());
    } on FirebaseException catch (e) {
      print("Lỗi: ${e.message}");
      throw MinhFirebaseException(e.code).message;
    } catch (e) {
      throw "Something went wrong! Please try again";
    }
  }
}



