import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/entities/user_entity.dart';
import '../../models/user_dto.dart';
import 'package:cuutrobaolu/core/exceptions/exports.dart';

/// Adapter để bridge giữa UserRepository interface và UserEntity
/// Cung cấp các method cần thiết cho controllers
/// NOTE: Nên migrate sang sử dụng UserRepository interface trực tiếp
class UserRepositoryAdapter {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Lấy user hiện tại dưới dạng UserEntity
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
}






