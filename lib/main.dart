import 'package:cuutrobaolu/app.dart';
import 'package:cuutrobaolu/core/injection/injection_container.dart' as di;
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_storage/get_storage.dart';

import 'firebase_options.dart';

Future<void> main() async {
  final WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Giữ Splash screen (chưa tắt vội) cho đến khi load xong
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Khởi tạo GetStorage và Firebase song song để tăng tốc
  await Future.wait([
    GetStorage.init(),
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
  ]);

  // Khởi tạo dependency injection (get_it)
  await di.init();

  // Firebase App Check chạy async, không chặn main thread
  // Chỉ kích hoạt trong production mode để tránh chậm khi debug
  if (!kDebugMode) {
    FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.deviceCheck,
    ).catchError((error) {
      // Bỏ qua lỗi App Check để không chặn app khởi động
      debugPrint('Firebase App Check error: $error');
    });
  }

  // VietnamProvinces sẽ được lazy load khi cần (không load ở đây)
  // Điều này giúp giảm thời gian khởi động đáng kể

  runApp(const App());
}
