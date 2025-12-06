import 'package:cuutrobaolu/presentation/bindings/app_bindings.dart';
import 'package:cuutrobaolu/presentation/routes/app_routes.dart';
import 'package:cuutrobaolu/presentation/features/authentication/screens/splash/splash_screen.dart';
import 'package:cuutrobaolu/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      themeMode: ThemeMode.system,
      theme: MinhAppTheme.lightTheme, // màu bth light
      darkTheme: MinhAppTheme.darkTheme, // màu dark
      debugShowCheckedModeBanner: false,
      initialBinding: AppBindings(),
      getPages: AppRoutes.pages,
      home: const SplashScreen(), // Sử dụng SplashScreen để khởi tạo AuthRedirectController
    );
  }
}
