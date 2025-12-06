import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class UploadBannerController extends GetxController
{
  static UploadBannerController get instance => Get.find();

  final targetScreenController = TextEditingController();
  final activeBanner = true.obs;

  Future<void> UploadBannerInAsset() async{

  }

}
