import 'package:cuutrobaolu/presentation/features/admin/navigation_admin_menu.dart';
import 'package:cuutrobaolu/presentation/features/authentication/screens/login/login.dart';
import 'package:cuutrobaolu/presentation/features/authentication/screens/onboarding/onboarding.dart';
import 'package:cuutrobaolu/presentation/features/authentication/screens/singup/verifi_email.dart';
import 'package:cuutrobaolu/presentation/features/home/navigation_menu.dart';
import 'package:cuutrobaolu/data/services/notification_service.dart';
import 'package:cuutrobaolu/core/exceptions/exports.dart';
import 'package:cuutrobaolu/core/storage/storage_utility.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// DEPRECATED: Không còn dùng UserRepository.instance
// import '../user/user_repository.dart';

/// DEPRECATED: Legacy AuthenticationRepository (GetX Controller)
/// Đã được thay thế bởi AuthenticationRepositoryImpl (Clean Architecture)
/// Class này chỉ tồn tại để tương thích ngược, không nên sử dụng nữa
/// Đổi tên thành AuthenticationRepositoryLegacy để tránh xung đột với domain interface
@Deprecated('Use AuthenticationRepositoryImpl instead')
class AuthenticationRepositoryLegacy extends GetxController {
  // DEPRECATED: Vô hiệu hóa instance getter để tránh lỗi "not found"
  // Không còn code nào nên dùng class này nữa
  // static AuthenticationRepositoryLegacy get instance => Get.find();

  final deviceStorage = GetStorage();
  final _auth = FirebaseAuth.instance;

  User? get authUser => _auth.currentUser;

  // DEPRECATED: onReady() đã được chuyển sang AuthRedirectController
  // Không còn sử dụng để tránh xung đột với Clean Architecture
  // @override
  // void onReady() {
  //   // Tắt splash screen ngay để UI responsive hơn
  //   FlutterNativeSplash.remove();
  //   // Chạy screenRedirect async để không chặn UI
  //   screenRedirect();
  // }

  void screenRedirect() async {
    final user = _auth.currentUser;

    if (user != null) {
      if (user.emailVerified) {
        // DEPRECATED: Logic này đã được chuyển sang AuthRedirectController
        // Khởi tạo storage
        await MinhLocalStorage.init(user.uid);
        
        // Fetch user data trực tiếp từ Firestore (tạm thời)
        // TODO: Nên dùng GetCurrentUserUseCase thay vì truy cập trực tiếp
        final snapshot = await FirebaseFirestore.instance
            .collection("Users")
            .doc(user.uid)
            .get();
        
        // Parse userType từ snapshot data
        final userData = snapshot.exists ? snapshot.data() : null;
        final userTypeMap = userData?['userType'];
        final userTypeName = userTypeMap is Map ? userTypeMap['enName'] : null;

        if (kDebugMode) {
          print('userType: $userTypeName');
        }

        if (userTypeName != null &&
            (userTypeName.toString().toLowerCase() == 'admin' ||
                userTypeMap is Map && userTypeMap['viName']?.toString().toLowerCase() == 'quản trị viên')) {
          
          // Subscribe to notifications
          try {
            final notificationService = Get.find<NotificationService>();
            // Try to get address if available
            String? province;
            if (userData != null && userData['address'] is Map) {
              province = userData['address']['ProvinceName'];
            } else if (userData != null && userData['ProvinceName'] != null) {
              province = userData['ProvinceName'];
            }
            
            await notificationService.subscribeToDefaultTopics(
              userRole: 'admin',
              province: province,
            );
          } catch (e) {
            print('Error subscribing to notifications: $e');
          }

          Get.offAll(() => NavigationAdminMenu());
        } else {
          // Subscribe to notifications
          try {
            final notificationService = Get.find<NotificationService>();
            
            // Determine role string
            String role = 'user'; // Default
            if (userTypeName != null) {
              if (userTypeName.toString().toLowerCase().contains('victim') || 
                  (userTypeMap is Map && userTypeMap['viName'].toString().toLowerCase().contains('nạn nhân'))) {
                role = 'victim';
              } else if (userTypeName.toString().toLowerCase().contains('volunteer') || 
                  (userTypeMap is Map && userTypeMap['viName'].toString().toLowerCase().contains('tình nguyện'))) {
                role = 'volunteer';
              }
            }

            // Try to get address
            String? province;
            if (userData != null && userData['address'] is Map) {
              province = userData['address']['ProvinceName'];
            }
            
            await notificationService.subscribeToDefaultTopics(
              userRole: role,
              province: province,
            );
          } catch (e) {
            print('Error subscribing to notifications: $e');
          }

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
  /// DEPRECATED: Sử dụng DeleteAccountUseCase thay thế
  Future<void> deleteAccount() async {
    try {
      // Không dùng UserRepository.instance nữa, dùng trực tiếp Firestore
      final userId = _auth.currentUser!.uid;
      await FirebaseFirestore.instance.collection("Users").doc(userId).delete();
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
