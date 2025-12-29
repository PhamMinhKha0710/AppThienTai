import 'package:cuutrobaolu/domain/usecases/get_current_user_usecase.dart';
import 'package:cuutrobaolu/domain/usecases/update_user_usecase.dart';
import 'package:cuutrobaolu/presentation/features/personalization/controllers/user/user_controller.dart';
import 'package:cuutrobaolu/presentation/features/personalization/screens/profile/profile.dart';
import 'package:cuutrobaolu/core/popups/exports.dart';
import 'package:cuutrobaolu/core/constants/image_strings.dart';
import 'package:cuutrobaolu/domain/failures/failures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdateContactController extends GetxController {
  static UpdateContactController get instance => Get.find();

  final phoneController = TextEditingController();

  final userController = UserController.instance;

  GetCurrentUserUseCase get _getCurrentUserUseCase =>
      Get.find<GetCurrentUserUseCase>();
  UpdateUserUseCase get _updateUserUseCase => Get.find<UpdateUserUseCase>();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  void initialize() {
    phoneController.text = userController.user.value.phoneNumber;
  }

  Future<void> updateContact() async {
    try {
      MinhFullScreenLoader.openLoadingDialog(
        "Updating",
        MinhImages.docerAnimation,
      );
      if (!formKey.currentState!.validate()) {
        MinhFullScreenLoader.stopLoading();
        return;
      }

      final currentUserEntity = await _getCurrentUserUseCase();
      if (currentUserEntity == null) {
        MinhFullScreenLoader.stopLoading();
        MinhLoaders.errorSnackBar(
          title: "Lỗi",
          message: "Không tìm thấy người dùng",
        );
        return;
      }

      final updated = currentUserEntity.copyWith(
        phoneNumber: phoneController.text.trim(),
      );

      await _updateUserUseCase(updated);

      // Update local model
      userController.user.value.phoneNumber = phoneController.text.trim();
      userController.user.refresh();

      MinhFullScreenLoader.stopLoading();
<<<<<<< Updated upstream
      MinhLoaders.successSnackBar(title: "Thành công", message: "Thông tin liên hệ đã được cập nhật");
=======
      MinhLoaders.successSnackBar(
        title: "Thành công",
        message: "Thông tin liên hệ đã được cập nhật",
      );
>>>>>>> Stashed changes
      Get.off(() => ProfileScreen());
    } on Failure catch (f) {
      MinhFullScreenLoader.stopLoading();
      MinhLoaders.errorSnackBar(title: "Lỗi", message: f.message);
    } catch (e) {
      MinhFullScreenLoader.stopLoading();
      MinhLoaders.errorSnackBar(title: "Lỗi", message: e.toString());
    }
  }
}
<<<<<<< Updated upstream



=======
>>>>>>> Stashed changes
