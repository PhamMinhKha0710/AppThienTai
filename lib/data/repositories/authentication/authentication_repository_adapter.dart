import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../domain/repositories/authentication_repository.dart';
import '../../../core/exceptions/exports.dart';
import '../../../core/storage/storage_utility.dart';
import '../../../presentation/features/admin/navigation_admin_menu.dart';
import '../../../presentation/features/authentication/screens/login/login.dart';
import '../../../presentation/features/authentication/screens/onboarding/onboarding.dart';
import '../../../presentation/features/authentication/screens/signup/verifi_email.dart';
import '../../../presentation/features/authentication/screens/welcome/welcome_screen.dart';
import '../../../presentation/features/shop/navigation_menu.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Adapter để tương thích với AuthenticationRepository cũ (GetxController)
/// Wrapper cho AuthenticationRepository mới (Clean Architecture)
class AuthenticationRepositoryAdapter extends GetxController {
  static AuthenticationRepositoryAdapter get instance => Get.find();

  final AuthenticationRepository _repository;
  final deviceStorage = GetStorage();
  final _auth = FirebaseAuth.instance;

  AuthenticationRepositoryAdapter(this._repository);

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
        await MinhLocalStorage.init(user.uid);

        // Get user type from Firestore directly
        final userDoc = await FirebaseFirestore.instance
            .collection("Users")
            .doc(user.uid)
            .get();
        
        String? userTypeStr;
        if (userDoc.exists) {
          final data = userDoc.data();
          userTypeStr = data?['UserType']?.toString().toLowerCase();
        }

        if (kDebugMode) {
          print('userType: $userTypeStr');
        }

        if (userTypeStr != null &&
            (userTypeStr == 'admin' || userTypeStr == 'quản trị viên')) {
          Get.offAll(() => NavigationAdminMenu());
        } else {
          Get.offAll(() => NavigationMenu());
        }
      } else {
        Get.offAll(() => VerifyEmailScreen(email: _auth.currentUser?.email));
      }
    } else {
      deviceStorage.writeIfNull("IsFirstTime", true);
      bool isFirstTime = deviceStorage.read("IsFirstTime");

      if (isFirstTime) {
        Get.offAll(() => WelcomeScreen());
      } else {
        Get.offAll(() => LoginScreen());
      }
    }
  }

  /// Login và trả về UserCredential để tương thích
  Future<UserCredential> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // Gọi trực tiếp Firebase để lấy UserCredential
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw MinhFirebaseAuthException(e.code).message;
    } catch (e) {
      if (e is String) {
        throw e;
      }
      throw "Something went wrong. Please try again";
    }
  }

  /// Register và trả về UserCredential để tương thích
  Future<UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // Gọi trực tiếp Firebase để lấy UserCredential
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw MinhFirebaseAuthException(e.code).message;
    } catch (e) {
      if (e is String) {
        throw e;
      }
      throw "Something went wrong. Please try again";
    }
  }

  /// Sign in with Google và trả về UserCredential để tương thích
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn _googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? userAccount = await _googleSignIn.signIn();
      if (userAccount == null) return null;

      final GoogleSignInAuthentication? googleAuth = await userAccount.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw MinhFirebaseAuthException(e.code).message;
    } catch (e) {
      if (e is String) {
        throw e;
      }
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
      Get.offAll(() => LoginScreen());
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> sendEmailVerification() async {
    await _repository.sendEmailVerification();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _repository.sendPasswordResetEmail(email);
  }

  Future<void> reAuthenticateWithEmailAndPassword(
    String email,
    String password,
  ) async {
    await _repository.reAuthenticateWithEmailAndPassword(email, password);
  }

  Future<void> deleteAccount() async {
    try {

      print("Xoá User");
      // Xóa user record trước
      final userId = _auth.currentUser?.uid;
      print('Xoá User ID $userId');
      if (userId != null) {

        await FirebaseFirestore.instance.collection("Users").doc(userId).delete();
      }
      await _repository.deleteAccount();
      print("tHÀNH CÔNG xoá User");
    } catch (e) {
      throw e.toString();
    }
  }
}

