import 'dart:io';
import 'dart:typed_data';

import 'package:cuutrobaolu/core/exceptions/exports.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class MinhFirebaseStorageService extends GetxController
{
  static MinhFirebaseStorageService get instance => Get.find();

  final _firebaseStorage = FirebaseStorage.instance;

  Future<Uint8List>  getImageDataFromAssets(String path) async{
    try{
      final byteData = await rootBundle.load(path);
      final imageData = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
      return imageData;
    }
    catch(e){
      throw 'ERROR LOADING IMAGE DATA: $e';
    }

  }

  Future<String>  upLoadImageData(String path, Uint8List image, String name) async{
    try{
      final ref = _firebaseStorage.ref(path).child(name);
      await ref.putData(image);

      final url = await ref.getDownloadURL();
      return url;
    }
    on FirebaseException catch (e) {
      throw MinhFirebaseException(e.code).message;
    } on FormatException catch(_) {
      throw MinhFormatException();
    } on PlatformException catch (e) {
      throw MinhPlatformException(e.code).message;
    } catch (e) {
      throw "Sometime went wrong! Please try again";
    }

  }

  Future<String>  upLoadImageFile(String path, XFile image) async{
    try{
      final ref = _firebaseStorage.ref(path).child(image.name);
      await ref.putFile(File(image.path));

      final url = await ref.getDownloadURL();
      return url;
    }
    on FirebaseException catch (e) {
      throw MinhFirebaseException(e.code).message;
    } on FormatException catch(_) {
      throw MinhFormatException();
    } on PlatformException catch (e) {
      throw MinhPlatformException(e.code).message;
    } catch (e) {
      throw "Sometime went wrong! Please try again";
    }

  }
}