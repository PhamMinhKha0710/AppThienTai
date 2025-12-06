import 'package:cuutrobaolu/data/repositories/user/user_repository.dart';
import 'package:cuutrobaolu/features/personalization/controllers/user/user_controller.dart';
import 'package:cuutrobaolu/features/personalization/screens/profile/profile.dart';
import 'package:cuutrobaolu/util/constants/image_strings.dart';
import 'package:cuutrobaolu/util/helpers/exports.dart';
import 'package:cuutrobaolu/util/popups/exports.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class UpdateNameController extends GetxController
{
  static UpdateNameController get instance => Get.find();

  final firstName = TextEditingController();
  final lastName = TextEditingController();

  final userController = UserController.instance;
  final userRepository = Get.put(UserRepository());

  GlobalKey<FormState> updateNameFormKey =  GlobalKey<FormState>();

  @override
  void onInit() {
    initializeNames();
    super.onInit();
  }

  Future<void> initializeNames() async {
    firstName.text = userController.user.value.firstName;
    lastName.text = userController.user.value.lastName;
  }

  Future<void> updateUserName() async {
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


      // Check Form
      if(!updateNameFormKey.currentState!.validate())
      {
        MinhFullScreenLoader.stopLoading();
        return;
      }

      // Update User's first & last name in the Firebase
      Map<String, dynamic> name = {
        'FirstName' : firstName.text.trim(),
        'LastName' : lastName.text.trim(),
      };

      await userRepository.updateSingField(name);

      userController.user.value.firstName = firstName.text.trim();
      userController.user.value.lastName = lastName.text.trim();

      // Stop loading
      MinhFullScreenLoader.stopLoading();

      // Success
      MinhLoaders.successSnackBar(
          title: "Congratulations",
          message: "Your name has been updated"
      );

      // Chuyển Trang
      Get.off(() => ProfileScreen());


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