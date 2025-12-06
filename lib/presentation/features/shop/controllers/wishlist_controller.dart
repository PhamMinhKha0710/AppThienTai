import 'package:cuutrobaolu/NavigationController.dart';
import 'package:get/get.dart';


class WishListController extends GetxController
{

  static WishListController get instance => Get.find();

  void backPageHome()
  {
    NavigationController.selectedIndex.value = 0;


  }

  void backPageHome2()
  {
    // NavigationCotroller.selectedIndex.value = 0;


  }
}
