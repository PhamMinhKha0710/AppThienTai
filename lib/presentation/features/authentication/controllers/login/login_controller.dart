import 'package:cuutrobaolu/domain/usecases/login_usecase.dart';
import 'package:cuutrobaolu/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:cuutrobaolu/domain/usecases/get_current_user_usecase.dart';
import 'package:cuutrobaolu/domain/usecases/save_user_usecase.dart';
import 'package:cuutrobaolu/domain/entities/user_entity.dart' as domain;
import 'package:cuutrobaolu/presentation/features/personalization/controllers/user/user_controller.dart';
import 'package:cuutrobaolu/presentation/features/personalization/models/user_model.dart';
import 'package:cuutrobaolu/presentation/utils/navigation_helper.dart';
import 'package:cuutrobaolu/core/constants/image_strings.dart';
import 'package:cuutrobaolu/core/utils/exports.dart';
import 'package:cuutrobaolu/core/popups/loaders.dart';
import 'package:cuutrobaolu/core/popups/full_screen_loader.dart';
import 'package:cuutrobaolu/domain/failures/failures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  final hidePassword = true.obs;
  final rememberMe = false.obs;

  final email = TextEditingController();
  final password = TextEditingController();

  final localStorage = GetStorage();

  GlobalKey<FormState> loginFormkey = GlobalKey<FormState>();

  final userController = Get.put(UserController());

  // Use Cases - Clean Architecture (lazy getters để tránh LateInitializationError)
  LoginUseCase get _loginUseCase => Get.find<LoginUseCase>();
  SignInWithGoogleUseCase get _signInWithGoogleUseCase => Get.find<SignInWithGoogleUseCase>();
  GetCurrentUserUseCase get _getCurrentUserUseCase => Get.find<GetCurrentUserUseCase>();
  SaveUserUseCase get _saveUserUseCase => Get.find<SaveUserUseCase>();

  @override
  void onInit() {
    super.onInit();
    email.text = localStorage.read("REMEMBER_ME_EMAIL") ?? "";
    password.text = localStorage.read("REMEMBER_ME_PASSWORD") ?? "";
  }

  Future<void> emailAndPasswordSignIn() async {
    try {
      // Show Loading
      MinhFullScreenLoader.openLoadingDialog(
        "Loading ............",
        MinhImages.docerAnimation,
      );

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (isConnected == false) {
        MinhFullScreenLoader.stopLoading();
        return;
      }

      // Check form Validation
      if (!loginFormkey.currentState!.validate()) {
        MinhFullScreenLoader.stopLoading();
        return;
      }

      // Save Data if Remember Me is select
      if (rememberMe.value) {
        localStorage.write("REMEMBER_ME_EMAIL", email.text.trim());
        localStorage.write("REMEMBER_ME_PASSWORD", password.text.trim());
      }

      // Login using Use Case (Clean Architecture)
      await _loginUseCase(email.text.trim(), password.text.trim());

      // Close Loading
      MinhFullScreenLoader.stopLoading();

      // Redirect using NavigationHelper
      await NavigationHelper.redirectAfterAuth();

    } on Failure catch (failure) {
      MinhFullScreenLoader.stopLoading();
      MinhLoaders.errorSnackBar(title: "Oh Snap!", message: failure.message);
    } catch (e) {
      MinhFullScreenLoader.stopLoading();
      MinhLoaders.errorSnackBar(title: "Oh Snap!", message: e.toString());
    }
  }

  Future<void> googleSignIn() async {
    try {
      // Show Loading
      MinhFullScreenLoader.openLoadingDialog(
        "Loading you in ..............",
        MinhImages.docerAnimation,
      );

      // Check connect Internet
      final isConnected = await NetworkManager.instance.isConnected();
      if (isConnected == false) {
        MinhFullScreenLoader.stopLoading();
        return;
      }

      // Google Authentication using Use Case
      final userId = await _signInWithGoogleUseCase();

      if (userId != null) {
        // Check if user exists, if not create user record
        final currentUser = await _getCurrentUserUseCase();
        
        if (currentUser == null) {
          // User doesn't exist, create from Firebase Auth user
          final firebaseUser = FirebaseAuth.instance.currentUser;
          if (firebaseUser != null) {
            // Create user entity from Firebase user
            final nameParts = UserModel.nameParts(firebaseUser.displayName ?? "");
            final userName = UserModel.generateUsername(firebaseUser.displayName ?? "");

            // Import UserEntity từ domain
            final newUserEntity = domain.UserEntity(
              id: firebaseUser.uid,
              username: userName,
              email: firebaseUser.email ?? "",
              firstName: nameParts.isNotEmpty ? nameParts[0] : "",
              lastName: nameParts.length > 1 ? nameParts.sublist(1).join(" ") : "",
              phoneNumber: firebaseUser.phoneNumber ?? "",
              profilePicture: firebaseUser.photoURL ?? "",
              userType: domain.UserType.victim, // Default
              volunteerStatus: domain.VolunteerStatus.available,
              active: true,
              isVerified: firebaseUser.emailVerified,
            );

            // Save using Use Case
            await _saveUserUseCase(newUserEntity);
          }
        }
      }

      // Close loading
      MinhFullScreenLoader.stopLoading();

      // Redirect using NavigationHelper
      await NavigationHelper.redirectAfterAuth();

    } on Failure catch (failure) {
      MinhFullScreenLoader.stopLoading();
      MinhLoaders.errorSnackBar(
        title: 'Oh Snap!',
        message: failure.message,
      );
    } catch (e) {
      MinhFullScreenLoader.stopLoading();
      MinhLoaders.errorSnackBar(
        title: 'Oh Snap!',
        message: e.toString(),
      );
    }
  }




}

