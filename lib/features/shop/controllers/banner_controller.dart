import 'package:cuutrobaolu/NavigationController.dart';
import 'package:cuutrobaolu/data/DummyData/MinhDummyData.dart';
import 'package:cuutrobaolu/data/repositories/banners/banner_repository.dart';
import 'package:cuutrobaolu/features/personalization/screens/settings/settings.dart';
import 'package:cuutrobaolu/features/shop/models/banner_model.dart';
import 'package:cuutrobaolu/navigation_menu.dart';
import 'package:cuutrobaolu/util/constants/image_strings.dart';
import 'package:cuutrobaolu/util/helpers/exports.dart';
import 'package:cuutrobaolu/util/popups/exports.dart';
import 'package:get/get.dart';

class BannerController extends GetxController
{
  static BannerController get instance => Get.find();

  final isLoading = false.obs;

  final carousalCurrentIndex = 0.obs;


  RxList<BannerModel> allBanner = <BannerModel>[].obs;


  @override
  void onInit() {
    fetchBanner();
    super.onInit();
  }

  void updatePageIndicator(index)
  {
    carousalCurrentIndex.value = index;
  }

  // Load Banner
  Future<void> fetchBanner() async {
    try {
      // Show load
      isLoading.value = true;

      final bannerRepository = Get.put(BannerRepository());

      // Fetch banners from data source (Firestore, API, etc,    )
      final banners = await bannerRepository.getAllBanner();

      // Update the banners list
      allBanner.assignAll(banners);


    } catch (e) {
      MinhLoaders.errorSnackBar(title: "Oh Snap !!!!", message: e.toString());
    }
    finally{
      isLoading.value = false;
    }
  }

  Future<void> uploadBannerFromAsset() async
  {

    try{

      //Show load
      MinhFullScreenLoader.openLoadingDialog(
        "We are updating your information .....",
        MinhImages.docerAnimation,
      );

      // Check Connect Internet
      final isConnect = await NetworkManager.instance.isConnected();
      if(isConnect == false)
      {
        MinhFullScreenLoader.stopLoading();
        return;
      }

      final bannerRepository = Get.put(BannerRepository());

      final data = MinhDummyData.banners;

      await bannerRepository.uploadDummyDataCloudinary(data);


      // Stop loading
      MinhFullScreenLoader.stopLoading();

      // Success
      MinhLoaders.successSnackBar(
          title: "Congratulations",
          message: "Your name has been updated"
      );

      // Chuyển Trang
      NavigationController.selectedIndex.value = 3;
      Get.off(() => NavigationMenu());


    }
    catch(e)
    {
      MinhLoaders.errorSnackBar(
        title: "Oh Snap !!!!!!!",
        message: e.toString(),
      );

    }

  }
}