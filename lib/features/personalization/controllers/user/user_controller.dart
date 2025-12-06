import 'package:cuutrobaolu/data/repositories/authentication/authentication_repository.dart';
import 'package:cuutrobaolu/data/repositories/user/user_repository.dart';
import 'package:cuutrobaolu/features/authentication/screens/login/login.dart';
import 'package:cuutrobaolu/features/personalization/models/user_model.dart';
import 'package:cuutrobaolu/features/personalization/screens/profile/widgets/ReAuthLoginForm.dart';
import 'package:cuutrobaolu/util/constants/image_strings.dart';
import 'package:cuutrobaolu/util/constants/sizes.dart';
import 'package:cuutrobaolu/util/helpers/exports.dart';
import 'package:cuutrobaolu/util/popups/exports.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class  UserController extends GetxController
{

  static UserController get instance => Get.find();

  final profileLoading = false.obs;
  final imageLoading = false.obs;

  final userRepository = Get.put(UserRepository());

  Rx<UserModel> user = UserModel.empty().obs ;

  final hiddenPassword = false.obs;
  final verifyEmail = TextEditingController();
  final verifyPassword = TextEditingController();
  GlobalKey<FormState> reAuthFormKey = GlobalKey<FormState>();


  @override
  void onInit() {
    super.onInit();
    fetchUser();
  }

  // Load user
  Future<void> fetchUser() async {
    try{
      profileLoading.value = true;

      final currentUser = await userRepository.getCurrentUser();
      this.user(currentUser);

      profileLoading.value = false;
    }
    catch (e)
    {
      this.user(UserModel.empty());
    }
    finally
    {
      profileLoading.value = false;
    }

  }

  /// Save user Record from any Registration provider
  Future<void> saveUserRecord(UserCredential? userCredential) async
  {
    try {

      // Refresh user
      await fetchUser();
      if(user.value.id.isEmpty)
      {
        if(userCredential != null)
        {
          final nameParts = UserModel.nameParts(userCredential.user!.displayName ?? "");
          final userName = UserModel.generateUsername(userCredential.user!.displayName ?? "");

          final userNew = UserModel(
              id: userCredential.user!.uid,
              username: userName,
              email: userCredential.user!.email ?? "",
              firstName: nameParts[0],
              lastName: nameParts.length > 1 ? nameParts.sublist(1).join(" ") : "" ,
              phoneNumber: userCredential.user!.phoneNumber ?? "",
              profilePicture: userCredential.user!.photoURL ?? ""
          );

          // save user data
          await userRepository.saveUserFireRecord(userNew);
        }
      }



    }
    catch (e){
      MinhLoaders.warningSnackBar(
        title: "Data Not Saved",
        message: e.toString(),
      );
    }
  }


  // Delete
  void deleteAccountWarningPopup()
  {
    Get.defaultDialog(
      contentPadding: EdgeInsets.all(MinhSizes.md),
      title: "DeleteAccount",
      middleText: "Bạn có chắc bạn muốn xóa tài khoản vĩnh viễn, hành động này không thể đảo ngược và tất cả dữ liệu sẽ đợc xóa vĩnh viễn",
      confirm: ElevatedButton(
          onPressed: () async => deleteUserAccount(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MinhSizes.lg,
            ),
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

  void deleteUserAccount() async
  {
    try
    {
      MinhFullScreenLoader.openLoadingDialog(
          "Processing",
          MinhImages.docerAnimation,
      );

      //
      final auth = AuthenticationRepository.instance;
      final provider = auth.authUser!.providerData.map((e) => e.providerId).first;

      if(provider.isNotEmpty)
      {
        if(provider == "google.com")
        {
          await auth.signInWithGoogle();
          await auth.deleteAccount();
          MinhFullScreenLoader.stopLoading();
          Get.offAll(() => LoginScreen());
        }
        else if(provider == "password")
        {
          MinhFullScreenLoader.stopLoading();
          Get.to(() => ReAuthLoginForm());
        }
      }

    }
    catch(e)
    {
      MinhFullScreenLoader.stopLoading();
      MinhLoaders.warningSnackBar(
          title: "Oh Snap!",
          message: e.toString(),
      );
    }
  }

  Future<void> reAuthenticateEmailAndPasswordUser() async
  {
    try {
      // Show Loading
      MinhFullScreenLoader.openLoadingDialog(
        "Processing",
        MinhImages.docerAnimation,
      );

      // Check Internet
      final isConnected = await NetworkManager.instance.isConnected();
      if(!isConnected)
      {
        MinhFullScreenLoader.stopLoading();
        return;
      }

      if(!reAuthFormKey.currentState!.validate())
      {
        MinhFullScreenLoader.stopLoading();
        return;
      }

      await AuthenticationRepository.instance.reAuthenticateWithEmailAndPassword(verifyEmail.text.trim(), verifyPassword.text.trim());

      await AuthenticationRepository.instance.deleteAccount();

      // Close loading
      MinhFullScreenLoader.stopLoading();

      // Chuyển trang

      Get.offAll(() => LoginScreen());


    }
    catch (e){
      MinhLoaders.warningSnackBar(
        title: "Data Not Saved",
        message: e.toString(),
      );
    }
  }

  // Upload images profile
  void uploadUserProfilePicture() async {
    try{
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxHeight: 512,
        maxWidth: 512,
      );

      if(image != null)
      {
        imageLoading.value = true;

        // upload images
        // C1: Firebase storage
        // final imageUrl = await userRepository.upLoadImage("Users/images/Profile/", images);

        // C2 Cloudinary
        final imageUrl = await userRepository.upLoadImageCloudinary("/profileUsers", image);


        // update user record
        Map<String, dynamic> json = {
          "ProfilePicture" : imageUrl,
        };

        await userRepository.updateSingField(json);

        user.value.profilePicture = imageUrl!;

        user.refresh();

        MinhLoaders.successSnackBar(
            title: "Congratulations",
            message: "Your Profile Image has been updated!"
        );
      }
    }
    catch (e){
      MinhLoaders.errorSnackBar(
          title: "Oh Snap !!!!!",
          message: e.toString(),
      );
    }
    finally{
      imageLoading.value = false;
    }

  }








}