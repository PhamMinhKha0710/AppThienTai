import 'package:cuutrobaolu/core/widgets/success_screen/SuccessScreen.dart';
import 'package:cuutrobaolu/presentation/features/authentication/screens/login/login.dart';
import 'package:cuutrobaolu/presentation/features/authentication/screens/password_configuration/forget_password.dart';
import 'package:cuutrobaolu/presentation/features/authentication/screens/password_configuration/reset_password.dart';
import 'package:cuutrobaolu/presentation/features/authentication/screens/singup/singup.dart';
import 'package:cuutrobaolu/presentation/features/authentication/screens/singup/verifi_email.dart';
import 'package:cuutrobaolu/presentation/features/authentication/screens/welcome/welcome_screen.dart';
import 'package:cuutrobaolu/presentation/features/personalization/screens/settings/settings.dart';

import 'package:cuutrobaolu/presentation/features/shop/screens/home/home.dart';

import 'package:cuutrobaolu/presentation/features/shop/screens/help/help.dart';

import 'package:cuutrobaolu/presentation/features/shop/screens/wishlist/wishlist.dart';
import 'package:cuutrobaolu/presentation/routes/routes.dart';
import 'package:cuutrobaolu/core/constants/image_strings.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';

import '../features/authentication/screens/onboarding/onboarding.dart';
import '../features/personalization/screens/profile/profile.dart';

class AppRoutes {
  static final pages = <GetPage>[
    GetPage(name: MinhRoutes.home, page: () => const HomeScreen()),
    GetPage(name: MinhRoutes.store, page: () => const HelpScreen()),
    GetPage(name: MinhRoutes.settings, page: () => const SettingScreen()),
    GetPage(name: MinhRoutes.favourites, page: () => const FavoriteScreen()),




    GetPage(name: MinhRoutes.signUp, page: () => const SignupScreen()),


    GetPage(name: MinhRoutes.logIn, page: () => const LoginScreen()),
    // GetPage(name: MinhRoutes.resetPassword, page: () => const ResetPasswordScreen(email: email)),
    GetPage(name: MinhRoutes.verifyEmail, page: () => const VerifyEmailScreen()),
    GetPage(name: MinhRoutes.forgetPassword, page: () => const ForgetPasswordScreen()),




    GetPage(name: MinhRoutes.welcome, page: () => const WelcomeScreen()),
    GetPage(name: MinhRoutes.onboarding, page: () => const OnboardingScreen()),
    GetPage(name: MinhRoutes.eComDashboard, page: () => const HomeScreen()),


    GetPage(name: MinhRoutes.userProfile, page: () => const ProfileScreen()),


    // GetPage(name: MinhRoutes.notification, page: () => const NotificationScreen(), binding: NotificationBinding(), transition: Transition.fade),
    // GetPage(name: MinhRoutes.notificationDetails, page: () => const NotificationDetailScreen(), binding: NotificationBinding(), transition: Transition.fade),
  ];
}

