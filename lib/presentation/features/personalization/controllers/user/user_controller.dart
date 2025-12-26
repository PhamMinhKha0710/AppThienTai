import 'package:cuutrobaolu/domain/usecases/get_current_user_usecase.dart';
import 'package:cuutrobaolu/domain/usecases/save_user_usecase.dart';
import 'package:cuutrobaolu/domain/usecases/update_user_usecase.dart';
import 'package:cuutrobaolu/domain/usecases/upload_image_usecase.dart';
import 'package:cuutrobaolu/domain/usecases/re_authenticate_usecase.dart';
import 'package:cuutrobaolu/domain/usecases/delete_account_usecase.dart';
import 'package:cuutrobaolu/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:cuutrobaolu/domain/entities/user_entity.dart' as domain;
import 'package:cuutrobaolu/presentation/utils/user_mapper.dart';
import 'package:cuutrobaolu/presentation/features/authentication/screens/login/login.dart';
import 'package:cuutrobaolu/presentation/features/personalization/models/user_model.dart';
import 'package:cuutrobaolu/presentation/features/personalization/screens/profile/widgets/ReAuthLoginForm.dart';
import 'package:cuutrobaolu/core/constants/image_strings.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/utils/exports.dart';
import 'package:cuutrobaolu/core/popups/loaders.dart';
import 'package:cuutrobaolu/core/popups/full_screen_loader.dart';
import 'package:cuutrobaolu/domain/failures/failures.dart';
import 'package:cuutrobaolu/service/CloudinaryService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cuutrobaolu/service/CloudinaryService.dart';

import '../../../../../data/repositories/user/user_repository_NOLAZY.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  final userRepository = Get.put(UserRepositoryNOLAZY());

  final profileLoading = false.obs;
  final imageLoading = false.obs;

  // GetCurrentUserUseCase get _getCurrentUserUseCase =>
  //     Get.find<GetCurrentUserUseCase>();
  // SaveUserUseCase get _saveUserUseCase => Get.find<SaveUserUseCase>();
  // UpdateUserUseCase get _updateUserUseCase => Get.find<UpdateUserUseCase>();
  // UploadImageUseCase get _uploadImageUseCase => Get.find<UploadImageUseCase>();
  // ReAuthenticateUseCase get _reAuthenticateUseCase =>
  //     Get.find<ReAuthenticateUseCase>();
  DeleteAccountUseCase get _deleteAccountUseCase =>
      Get.find<DeleteAccountUseCase>();
  SignInWithGoogleUseCase get _signInWithGoogleUseCase =>
      Get.find<SignInWithGoogleUseCase>();

  Rx<UserModel> user = UserModel.empty().obs;

  final hiddenPassword = false.obs;
  final verifyEmail = TextEditingController();
  final verifyPassword = TextEditingController();
  GlobalKey<FormState> reAuthFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    fetchUser();
  }

  // Load user using Use Case
  Future<void> fetchUser() async {
    try {
      print("lalalalalalala - lalalalalalalala");
      profileLoading.value = true;
      print("lalalalalalala - lalalalalalalala ====== 1");
      // final currentUserEntity = await ();
      final currentUserEntity = await userRepository.getCurrentUser();

      if (currentUserEntity != null) {
        // Convert Entity to Model
        this.user(UserMapper.toModel(currentUserEntity));
      } else {
        this.user(UserModel.empty());
      }

      print("lalalalalalala - lalalalalalalala ====== 3");

      profileLoading.value = false;
    } catch (e) {
      print("===== bị lỗi á =====");

      this.user(UserModel.empty());
    } finally {
      profileLoading.value = false;
    }
  }

  /// Save user Record from any Registration provider
  Future<void> saveUserRecord(UserCredential? userCredential) async {
    try {
      // Refresh user
      await fetchUser();
      if (user.value.id.isEmpty) {
        if (userCredential != null) {
          final nameParts = UserModel.nameParts(
            userCredential.user!.displayName ?? "",
          );
          final userName = UserModel.generateUsername(
            userCredential.user!.displayName ?? "",
          );

          // Create UserEntity from Firebase user
          final userEntity = domain.UserEntity(
            id: userCredential.user!.uid,
            username: userName,
            email: userCredential.user!.email ?? "",
            firstName: nameParts.isNotEmpty ? nameParts[0] : "",
            lastName: nameParts.length > 1
                ? nameParts.sublist(1).join(" ")
                : "",
            phoneNumber: userCredential.user!.phoneNumber ?? "",
            profilePicture: userCredential.user!.photoURL ?? "",
            userType: domain.UserType.victim, // Default
            volunteerStatus: domain.VolunteerStatus.available,
            active: true,
            isVerified: userCredential.user!.emailVerified,
          );

          // Save using Use Case
          // await _saveUserUseCase(userEntity);

          await userRepository.saveUserFireRecord(userEntity);



        }
      }
    } on Failure catch (failure) {
      MinhLoaders.warningSnackBar(
        title: "Data Not Saved",
        message: failure.message,
      );
    } catch (e) {
      MinhLoaders.warningSnackBar(
        title: "Data Not Saved",
        message: e.toString(),
      );
    }
  }

  // Delete
  void deleteAccountWarningPopup() {
    Get.defaultDialog(
      contentPadding: EdgeInsets.all(MinhSizes.md),
      title: "DeleteAccount",
      middleText:
          "Bạn có chắc bạn muốn xóa tài khoản vĩnh viễn, hành động này không thể đảo ngược và tất cả dữ liệu sẽ đợc xóa vĩnh viễn",
      confirm: ElevatedButton(
        onPressed: () async => deleteUserAccount(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: MinhSizes.lg),
          child: Text("Delete"),
        ),
      ),
      cancel: OutlinedButton(
        onPressed: () {
          Navigator.of(Get.overlayContext!).pop();
        },
        child: Text("Cancel"),
      ),
    );
  }

  void deleteUserAccount() async {
    try {
      MinhFullScreenLoader.openLoadingDialog(
        "Processing",
        MinhImages.docerAnimation,
      );

      final authUser = FirebaseAuth.instance.currentUser;
      if (authUser == null) {
        MinhFullScreenLoader.stopLoading();
        return;
      }

      final provider = authUser.providerData.map((e) => e.providerId).first;

      if (provider.isNotEmpty) {
        if (provider == "google.com") {
          // Re-authenticate with Google

          print("Re-authenticate with Google ===============");

          await _signInWithGoogleUseCase();
          // Delete account using Use Case
          await _deleteAccountUseCase();
          MinhFullScreenLoader.stopLoading();
          Get.offAll(() => LoginScreen());
        } else if (provider == "password") {
          MinhFullScreenLoader.stopLoading();
          Get.to(() => ReAuthLoginForm());
        }
      }
    } on Failure catch (failure) {
      MinhFullScreenLoader.stopLoading();
      MinhLoaders.warningSnackBar(title: "Lỗi", message: failure.message);
    } catch (e) {
      MinhFullScreenLoader.stopLoading();
      MinhLoaders.warningSnackBar(title: "Lỗi", message: e.toString());
    }
  }

  Future<void> reAuthenticateEmailAndPasswordUser() async {
    try {
      // Show Loading
      MinhFullScreenLoader.openLoadingDialog(
        "Processing",
        MinhImages.docerAnimation,
      );

      // Check Internet
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        MinhFullScreenLoader.stopLoading();
        return;
      }

      if (!reAuthFormKey.currentState!.validate()) {
        MinhFullScreenLoader.stopLoading();
        return;
      }

      // Re-authenticate using Use Case
      // await _reAuthenticateUseCase(
      //   verifyEmail.text.trim(),
      //   verifyPassword.text.trim(),
      // );



      // Delete account using Use Case
      // await _deleteAccountUseCase();

      await userRepository.deleteAccount(user.value.id);

      // Close loading
      MinhFullScreenLoader.stopLoading();

      // Chuyển trang

      Get.offAll(() => LoginScreen());
    } catch (e) {
      MinhLoaders.warningSnackBar(
        title: "Data Not Saved",
        message: e.toString(),
      );
    }
  }

  // Upload images profile
  void uploadUserProfilePicture() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxHeight: 512,
        maxWidth: 512,
      );

      if (image != null) {
        imageLoading.value = true;

        // Upload via CloudinaryService (uses unsigned preset configured)
        try {
          final uploadedUrl = await CloudinaryService.uploadImage(image);
          if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
            // Update user entity using repository
            final currentUserEntity = await userRepository.getCurrentUser();
            if (currentUserEntity != null) {
              final updatedEntity = currentUserEntity.copyWith(profilePicture: uploadedUrl);
              await userRepository.updateUserDetails(updatedEntity);

              // Update local model
              user.value.profilePicture = uploadedUrl;
              user.refresh();

              MinhLoaders.successSnackBar(
                title: "Thành công",
                message: "Ảnh đại diện đã được cập nhật",
              );
            }
          } else {
            MinhLoaders.errorSnackBar(title: "Lỗi", message: "Không thể tải ảnh lên");
          }
        } catch (e) {
          MinhLoaders.errorSnackBar(title: "Lỗi", message: "Upload thất bại: $e");
        } finally {
          imageLoading.value = false;
        }
      }
    } on Failure catch (failure) {
      print('2. ${failure.message}');
      MinhLoaders.errorSnackBar(title: "Lỗi", message: failure.message);
    } catch (e) {
      print('1. ${e.toString()}');
      MinhLoaders.errorSnackBar(title: "Lỗi", message: e.toString());
    } finally {
      imageLoading.value = false;
    }
  }
}
