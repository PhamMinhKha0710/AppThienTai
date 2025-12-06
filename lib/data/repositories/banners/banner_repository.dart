import 'package:cuutrobaolu/presentation/features/shop/models/banner_model.dart';
import 'package:cuutrobaolu/service/CloudinaryService.dart';
import 'package:cuutrobaolu/core/exceptions/exports.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class BannerRepository extends GetxController
{
  static BannerRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;


  // Lấy all các Categories

  Future<List<BannerModel>> getAllBanner() async {
    try {
      final snapshot = await _db.collection("Banners").get();
      final list = snapshot.docs
          .map((document) => BannerModel.fromSnapshot(document))
          .where((i) => i.active == true)
          .toList();
      return list;
    } on FirebaseException catch (e) {
      throw MinhFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw MinhPlatformException(e.code).message;
    } catch (e) {
      throw e.toString();
    }
  }

  // UploadBanner from Asset

  Future<void> uploadDummyDataCloudinary(List<BannerModel> banners) async
  {
    try{
      //

      for(var banner in banners)
      {
        final url = await CloudinaryService.uploadAssetImage(
            banner.imageUrl,
            preset: "banners",
            folder: "banners/test",


        );

        banner.imageUrl = url ?? "";

        await _db.collection("Banners").add(banner.toJson());

      }

    }
    on FirebaseException catch (e) {
      throw MinhFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw MinhPlatformException(e.code).message;
    } catch (e) {
      throw e.toString();
    }
  }
}