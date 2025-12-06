import 'package:cuutrobaolu/app.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vietnam_provinces/vietnam_provinces.dart';

import 'data/repositories/authentication/authentication_repository.dart';
import 'firebase_options.dart';

Future<void> main() async {
  final WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo GetStorage để dùng local storage
  await GetStorage.init();

  await VietnamProvinces.initialize(version: AdministrativeDivisionVersion.v2);

  // Giữ Splash screen (chưa tắt vội) cho đến khi load xong
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Khởi tạo Firebase + đưa AuthenticationRepository vào GetX DI container
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
      .then((FirebaseApp value) => Get.put(AuthenticationRepository()),);

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.deviceCheck,

  );

  runApp(const App());
}
