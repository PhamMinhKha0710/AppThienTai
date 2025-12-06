import 'dart:io';

import 'package:cuutrobaolu/data/repositories/authentication/authentication_repository.dart';
import 'package:cuutrobaolu/features/personalization/models/user_model.dart';
import 'package:cuutrobaolu/service/CloudinaryService.dart';
import 'package:cuutrobaolu/util/exceptions/exports.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUserFireRecord(UserModel user) async {
    try {
      await _db.collection("Users").doc(user.id).set(user.toJson());
    } on FirebaseException catch (e) {
      print("Lỗi: "+ e.message.toString());
      throw MinhFirebaseException(e.code).message;
    } on FormatException catch(_) {
      throw MinhFormatException();
    } on PlatformException catch (e) {
      print("Lỗi: "+ e.message.toString());
      throw MinhPlatformException(e.code).message;
    } catch (e) {
      throw "Sometime went wrong! Please try again";
    }
  }

  // Lấy user đang đăng nhập // C1
  Future<UserModel?> getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final snapshot = await _db.collection("Users").doc(user.uid).get();

    if (snapshot.exists) {
      return UserModel.fromSnapshot(snapshot);
    }
    return null;
  }

  // Lấy user đang đăng nhập // C2
  Future<UserModel?> fetchUserDetails() async {
    try {
      final documentSnapshot = await _db
          .collection("Users")
          .doc(
            AuthenticationRepository.instance.authUser?.uid,
          ) // có id thì tìm theo id, ko có thì tạo id random ,
          .get();
      if (documentSnapshot.exists) {
        // khi có id
        return UserModel.fromSnapshot(documentSnapshot);
      } else {
        // khi ko có id
        return UserModel.empty();
      }
    } on FirebaseException catch (e) {
      throw MinhFirebaseException(e.code).message;
    } on FormatException catch(_) {
      throw MinhFormatException();
    } on PlatformException catch (e) {
      throw MinhPlatformException(e.code).message;
    } catch (e) {
      throw "Sometime went wrong! Please try again";
    }
  }

  // Update User
  Future<void> updateUserDetails(UserModel userUpdate) async {
    try {
      await _db
          .collection("Users")
          .doc(userUpdate.id) // Theo id ,
          .update(userUpdate.toJson());

    } on FirebaseException catch (e) {
      throw MinhFirebaseException(e.code).message;
    } on FormatException catch(_) {
      throw MinhFormatException();
    } on PlatformException catch (e) {
      throw MinhPlatformException(e.code).message;
    } catch (e) {
      throw "Sometime went wrong! Please try again";
    }
  }

  // Update User với json
  Future<void> updateSingField(Map<String, dynamic> json) async {
    try {
      await _db
          .collection("Users")
          .doc(AuthenticationRepository.instance.authUser?.uid)
          .update(json);

    } on FirebaseException catch (e) {
      throw MinhFirebaseException(e.code).message;
    } on FormatException catch(_) {
      throw MinhFormatException();
    } on PlatformException catch (e) {
      throw MinhPlatformException(e.code).message;
    } catch (e) {
      throw "Sometime went wrong! Please try again";
    }
  }

  // Remove User

  Future<void> removeUserRecord(String idUser) async {
    try {
      await _db
          .collection("Users")
          .doc(idUser)
          .delete();

    } on FirebaseException catch (e) {
      throw MinhFirebaseException(e.code).message;
    } on FormatException catch(_) {
      throw MinhFormatException();
    } on PlatformException catch (e) {
      throw MinhPlatformException(e.code).message;
    } catch (e) {
      throw "Sometime went wrong! Please try again";
    }
  }

  // Upload Image

  Future<String> upLoadImage(String path, XFile image) async{
    try {
      final ref = FirebaseStorage.instance.ref(path).child(image.name);
      await ref.putFile(File(image.path));

      final url = await ref.getDownloadURL();

      return url;


    } on FirebaseException catch (e) {
      throw MinhFirebaseException(e.code).message;
    } on FormatException catch(_) {
      throw MinhFormatException();
    } on PlatformException catch (e) {
      throw MinhPlatformException(e.code).message;
    } catch (e) {
      throw "Sometime went wrong! Please try again";
    }
  }

  // Upload Image bằng Cloudinary
  Future<String?> upLoadImageCloudinary(String folder, XFile image) async {
    return await CloudinaryService.uploadImage(image, folder: folder);
  }


}
