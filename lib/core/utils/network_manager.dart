import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../popups/loaders.dart';

class NetworkManager extends GetxController {
  static NetworkManager get instance => Get.find();

  final Connectivity _connectivity = Connectivity();
  // late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription; // 🔥 sửa ở đây
  final Rx<ConnectivityResult> _connectionStatus = ConnectivityResult.none.obs;


  @override
  void onInit() {
    super.onInit();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }


  Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    _connectionStatus.value = result;

    if (result == ConnectivityResult.none) {
      MinhLoaders.customToast(message: 'No Internet Connection');
    }
  }

  Future<bool> isConnected() async {
    try {
      final result = await _connectivity.checkConnectivity();
      if (result.any((element) => element == ConnectivityResult.none)) {
        return false;
      } else {
        return true;
      }
    } on PlatformException catch (_) {
      return false;
    }
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }
}











