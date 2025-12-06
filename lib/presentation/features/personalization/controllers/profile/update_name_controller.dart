import 'package:cuutrobaolu/domain/usecases/get_current_user_usecase.dart';
import 'package:cuutrobaolu/domain/usecases/update_user_usecase.dart';
import 'package:cuutrobaolu/presentation/features/personalization/controllers/user/user_controller.dart';
import 'package:cuutrobaolu/presentation/features/personalization/screens/profile/profile.dart';
import 'package:cuutrobaolu/core/constants/image_strings.dart';
import 'package:cuutrobaolu/core/utils/exports.dart';
import 'package:cuutrobaolu/core/popups/exports.dart';
import 'package:cuutrobaolu/domain/failures/failures.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class UpdateNameController extends GetxController
{
  static UpdateNameController get instance => Get.find();

  final firstName = TextEditingController();
  final lastName = TextEditingController();

  final userController = UserController.instance;

  // Use Cases - Clean Architecture
  late final GetCurrentUserUseCase _getCurrentUserUseCase;
  late final UpdateUserUseCase _updateUserUseCase;

  GlobalKey<FormState> updateNameFormKey =  GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    // Initialize Use Cases
    _getCurrentUserUseCase = Get.find<GetCurrentUserUseCase>();
    _updateUserUseCase = Get.find<UpdateUserUseCase>();
    
    initializeNames();
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

      // Get current user entity
      final currentUserEntity = await _getCurrentUserUseCase();
      if (currentUserEntity == null) {
        MinhFullScreenLoader.stopLoading();
        MinhLoaders.errorSnackBar(
          title: "Lỗi",
          message: "Không tìm thấy thông tin người dùng",
        );
        return;
      }

      // Update user entity using Use Case
      final updatedEntity = currentUserEntity.copyWith(
        firstName: firstName.text.trim(),
        lastName: lastName.text.trim(),
      );

      await _updateUserUseCase(updatedEntity);

      // Update local model
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
    on Failure catch (failure) {
      MinhFullScreenLoader.stopLoading();
      MinhLoaders.errorSnackBar(
        title: "Lỗi",
        message: failure.message,
      );
    }
    catch(e)
    {
      MinhFullScreenLoader.stopLoading();
      MinhLoaders.errorSnackBar(
        title: "Lỗi",
        message: e.toString(),
      );
    }
  }

}
