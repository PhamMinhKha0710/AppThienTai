import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../models/user_dto.dart';
import '../../../core/exceptions/exports.dart';
import '../../../domain/failures/failures.dart';

/// Remote Data Source cho User - Tương tác trực tiếp với Firebase
abstract class UserRemoteDataSource {
  Future<UserDto?> getCurrentUser();
  Future<void> saveUser(UserDto user);
  Future<void> updateUser(UserDto user);
  Future<void> deleteUser(String userId);
  Future<String> uploadProfileImage(String path, XFile image);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Future<UserDto?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final snapshot = await _db.collection("Users").doc(user.uid).get();

      if (snapshot.exists) {
        return UserDto.fromSnapshot(snapshot);
      }
      return null;
    } on FirebaseException catch (e) {
      throw MinhFirebaseException(e.code);
    } catch (e) {
      throw UnknownFailure('Failed to get current user: ${e.toString()}');
    }
  }

  @override
  Future<void> saveUser(UserDto user) async {
    try {
      await _db.collection("Users").doc(user.id).set(user.toJson());
    } on FirebaseException catch (e) {
      throw MinhFirebaseException(e.code);
    } catch (e) {
      throw UnknownFailure('Failed to save user: ${e.toString()}');
    }
  }

  @override
  Future<void> updateUser(UserDto user) async {
    try {
      await _db.collection("Users").doc(user.id).update(user.toJson());
    } on FirebaseException catch (e) {
      throw MinhFirebaseException(e.code);
    } catch (e) {
      throw UnknownFailure('Failed to update user: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      await _db.collection("Users").doc(userId).delete();
    } on FirebaseException catch (e) {
      throw MinhFirebaseException(e.code);
    } catch (e) {
      throw UnknownFailure('Failed to delete user: ${e.toString()}');
    }
  }

  @override
  Future<String> uploadProfileImage(String path, XFile image) async {
    try {
      final ref = _storage.ref(path).child(image.name);
      await ref.putFile(File(image.path));
      final url = await ref.getDownloadURL();
      return url;
    } on FirebaseException catch (e) {
      throw MinhFirebaseException(e.code);
    } catch (e) {
      throw UnknownFailure('Failed to upload image: ${e.toString()}');
    }
  }
}

