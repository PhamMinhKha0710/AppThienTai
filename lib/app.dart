import 'package:cuutrobaolu/bindings/general_bindings.dart';
import 'package:cuutrobaolu/routes/app_routes.dart';
import 'package:cuutrobaolu/util/constants/colors.dart';
import 'package:cuutrobaolu/util/theme/theme.dart';
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
      initialBinding: GeneralBindings(),
      getPages: AppRoutes.pages,
      // home: OnboardingScreen(),
      home: Scaffold(
        backgroundColor: MinhColors.primary,
        body: Center(
          child: CircularProgressIndicator(color: MinhColors.white,),
        ),
      ),
    );
  }
}
