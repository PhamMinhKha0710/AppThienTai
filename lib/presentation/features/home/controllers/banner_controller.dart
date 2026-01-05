import 'package:cuutrobaolu/domain/usecases/get_all_banners_usecase.dart';
import 'package:cuutrobaolu/domain/usecases/upload_banners_usecase.dart';
import 'package:cuutrobaolu/domain/failures/failures.dart';
import 'package:cuutrobaolu/NavigationController.dart';
import 'package:cuutrobaolu/data/DummyData/MinhDummyData.dart';
import 'package:cuutrobaolu/presentation/features/home/models/banner_model.dart';
import 'package:cuutrobaolu/presentation/features/home/navigation_menu.dart';
import 'package:cuutrobaolu/core/constants/image_strings.dart';
import 'package:cuutrobaolu/core/utils/exports.dart';
import 'package:cuutrobaolu/core/popups/exports.dart';
import 'package:get/get.dart';

class BannerController extends GetxController
{
  static BannerController get instance => Get.find();

  final isLoading = false.obs;

  final carousalCurrentIndex = 0.obs;

  RxList<BannerModel> allBanner = <BannerModel>[].obs;

  // Use Cases - Clean Architecture (lazy getters để tránh LateInitializationError)
  GetAllBannersUseCase get _getAllBannersUseCase => Get.find<GetAllBannersUseCase>();
  UploadBannersUseCase get _uploadBannersUseCase => Get.find<UploadBannersUseCase>();

  @override
  void onInit() {
    super.onInit();
    fetchBanner();
  }

  void updatePageIndicator(index)
  {
    carousalCurrentIndex.value = index;
  }

  // Load Banner using Use Case
  Future<void> fetchBanner() async {
    try {
      // Show load
      isLoading.value = true;

      // Fetch banners using Use Case
      final bannersData = await _getAllBannersUseCase();

      // Convert BannerEntity to BannerModel
      final banners = bannersData.map((entity) {
        return BannerModel(
          name: entity.name,
          imageUrl: entity.imageUrl,
          active: entity.active,
          targetScreen: entity.targetScreen,
        );
      }).toList();

      // Update the banners list
      allBanner.assignAll(banners);

    } on Failure catch (failure) {
      MinhLoaders.errorSnackBar(title: "Lỗi", message: failure.message);
    } catch (e) {
      MinhLoaders.errorSnackBar(title: "Lỗi", message: e.toString());
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

      // Upload using Use Case (MinhDummyData.banners is already List<BannerEntity>)
      await _uploadBannersUseCase(MinhDummyData.banners);


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
    on Failure catch (failure) {
      MinhLoaders.errorSnackBar(
        title: "Lỗi",
        message: failure.message,
      );
    }
    catch(e)
    {
      MinhLoaders.errorSnackBar(
        title: "Lỗi",
        message: e.toString(),
      );
    }

  }
}
