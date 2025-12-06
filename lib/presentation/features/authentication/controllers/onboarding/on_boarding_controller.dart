import 'package:cuutrobaolu/presentation/features/authentication/screens/login/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class OnBoardingController extends GetxController
{
  static OnBoardingController get instance => Get.find();

  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;


  void updatePageIndicator(index){
    currentPageIndex.value = index;
  }

  void dotNavigationClick(index){
    currentPageIndex.value = index;
    // pageController.jumpToPage(index); // không hiệu ứng


    pageController.animateToPage( // chuyển trang có hiệu ứng
        currentPageIndex.value,
        duration: Duration(seconds: 1),
        curve: Curves.easeInOut
    );
  }

  void nextPage(){
    if(currentPageIndex.value == 2)
    {
      final storage = GetStorage();
      storage.write("IsFirstTime", false);

      Get.offAll(
              () => LoginScreen(),
          duration: Duration(seconds: 1),
          curve: Curves.easeInOut
      );


    }
    else
    {
      int page = currentPageIndex.value + 1;
      dotNavigationClick(page);
    }
  }

  void skipPage(){ // tới cuối cùng do c 2 trang
    // currentPageIndex.value = 2;
    // pageController.jumpToPage(2);

    dotNavigationClick(2);
  }
}
