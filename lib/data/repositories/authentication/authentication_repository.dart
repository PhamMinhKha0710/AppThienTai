import 'package:cuutrobaolu/features/admin/navigation_admin_menu.dart';
import 'package:cuutrobaolu/features/authentication/screens/login/login.dart';
import 'package:cuutrobaolu/features/authentication/screens/onboarding/onboarding.dart';
import 'package:cuutrobaolu/features/authentication/screens/singup/verifi_email.dart';
import 'package:cuutrobaolu/navigation_menu.dart';
import 'package:cuutrobaolu/util/exceptions/exports.dart';
import 'package:cuutrobaolu/util/local_storage/storage_utility.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../user/user_repository.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final deviceStorage = GetStorage();
  final _auth = FirebaseAuth.instance;

  User? get authUser => _auth.currentUser;

  @override
  void onReady() {
    FlutterNativeSplash.remove();
    screenRedirect();
  }

  void screenRedirect() async {
    final user = _auth.currentUser;

    if (user != null) {
      if (user.emailVerified) {
        MinhLocalStorage.init(user.uid); // khởi tạo

        final userRepository = Get.put(UserRepository());

        final useCurrent = await userRepository.getCurrentUser();




        final userType = useCurrent?.userType;

        print('userType: ${userType}');

        if (userType != null &&
            (userType.enName.toLowerCase() == 'admin' ||
                userType.viName.toLowerCase() == 'quản trị viên')) {
          Get.offAll(() => NavigationAdminMenu());
        } else {
          Get.offAll(() => NavigationMenu()); // Vào trang chính user/supporter
        }


      } else {
        Get.offAll(
          () => VerifyEmailScreen(email: _auth.currentUser?.email),
        ); // Chưa verify email
      }
    } else {
      // Lần đầu mở app?
      deviceStorage.writeIfNull("IsFirstTime", true);
      bool isFirstTime = deviceStorage.read("IsFirstTime");

      if (isFirstTime) {
        Get.offAll(() => OnboardingScreen()); // Lần đầu → Onboarding
      } else {
        Get.offAll(() => LoginScreen()); // Không phải lần đầu → Login
      }
    }
  }

  /* ---------------------------- Email & Password sign-in ---------------------------------*/

  /// [EmailAuthentication] - SignIn - đăng nhập với Email và Mật khẩu

  Future<UserCredential> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw MinhFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw MinhFirebaseException(e.code).message;
    } on FormatException catch (e) {
      throw MinhFormatException();
    } on PlatformException catch (e) {
      throw MinhPlatformException(e.code).message;
    } catch (e) {
      throw "Something went wrong. Please try again";
    }
  }

  /// [EmailAuthentication] - REGISTER - tạo tài khoản

  Future<UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw MinhFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw MinhFirebaseException(e.code).message;
    } on FormatException catch (e) {
      throw MinhFormatException();
    } on PlatformException catch (e) {
      throw MinhPlatformException(e.code).message;
    } catch (e) {
      throw "Something went wrong. Please try again";
    }
  }

  /// [ReAuthenticate] - ReAuthenticate User
  Future<void> reAuthenticateWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // Create a credential
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      // ReAuthenticate
      await _auth.currentUser!.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw MinhFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw MinhFirebaseException(e.code).message;
    } on FormatException catch (e) {
      throw MinhFormatException();
    } on PlatformException catch (e) {
      throw MinhPlatformException(e.code).message;
    } catch (e) {
      throw "Something went wrong. Please try again";
    }
  }

  /// [EmailVerification] - MAIL VERIFICATION - gửi email
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw MinhFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw MinhFirebaseException(e.code).message;
    } on FormatException catch (e) {
      throw MinhFormatException();
    } on PlatformException catch (e) {
      throw MinhPlatformException(e.code).message;
    } catch (e) {
      throw "Something went wrong. Please try again";
    }
  }

  /// [EmailAuthentication] - FORGET PASSWORD
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw MinhFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw MinhFirebaseException(e.code).message;
    } on FormatException catch (e) {
      throw MinhFormatException();
    } on PlatformException catch (e) {
      throw MinhPlatformException(e.code).message;
    } catch (e) {
      throw "Something went wrong. Please try again";
    }
  }

  /* ---------------------------- Federated identity & social sign-in ---------------------------------*/

  /// [GoogleAuthentication] - GOOGLE
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn _googleSignIn = GoogleSignIn();

      // Người dùng chọn tài khoản Google
      final GoogleSignInAccount? userAccount = await _googleSignIn.signIn();

      // Lấy token từ Google
      final GoogleSignInAuthentication? googleAuth =
          await userAccount?.authentication;

      // Tạo credential cho Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Đăng nhập Firebase bằng credential
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw MinhFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw MinhFirebaseException(e.code).message;
    } on FormatException catch (e) {
      throw MinhFormatException();
    } on PlatformException catch (e) {
      throw MinhPlatformException(e.code).message;
    } catch (e) {
      if (kDebugMode) {
        print("Something went wrong: $e");
      }
      return null;
    }
  }

  /* ---------------------------- Phone Number sign-in ---------------------------------*/

  /// [PhoneAuthentication] - LOGIN - Register
  ///
  ///
  /// [PhoneAuthentication] - VERIFY PHONE NO BY OTP
  ///
  ///
  /// [FacebookAuthentication] - FACEBOOK
  ///
  ///

  /* ---------------------------- ./end Federated identity & social sign-in ---------------------------------*/

  /// [LogoutUser] - Valid for any authentication.

  Future<void> logout() async {
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      Get.offAll(() => LoginScreen());
    } on FirebaseAuthException catch (e) {
      throw MinhFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw MinhFirebaseException(e.code).message;
    } on FormatException catch (e) {
      throw MinhFormatException();
    } on PlatformException catch (e) {
      throw MinhPlatformException(e.code).message;
    } catch (e) {
      throw "Something went wrong. Please try again";
    }
  }

  /// DELETE USER - Remove user Auth and Firestore Account.
  Future<void> deleteAccount() async {
    try {
      await UserRepository.instance.removeUserRecord(_auth.currentUser!.uid);
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw MinhFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw MinhFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const MinhFormatException();
    } on PlatformException catch (e) {
      throw MinhPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }
}
