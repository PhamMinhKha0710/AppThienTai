import 'package:cuutrobaolu/presentation/features/shop/screens/home/home.dart';
import 'package:cuutrobaolu/presentation/features/admin/screens/help/help.dart';
import 'package:cuutrobaolu/presentation/features/shop/screens/wishlist/wishlist.dart';
import 'package:cuutrobaolu/presentation/features/personalization/screens/settings/settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationVolunteerController extends GetxController {
  static final Rx<int> selectedIndex = 0.obs;

  List<Widget> get screen => [
    HomeScreen(), // Sẽ được cập nhật để hiển thị khác cho volunteer
    HelpAdminScreen(), // Màn hình quản lý yêu cầu trợ giúp
    FavoriteScreen(), // Màn hình hỗ trợ
    SettingScreen(),
  ];
}

