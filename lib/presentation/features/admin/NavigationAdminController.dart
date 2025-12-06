
import 'package:cuutrobaolu/presentation/features/admin/screens/help/help.dart';
import 'package:cuutrobaolu/presentation/features/admin/screens/home/home.dart';
import 'package:cuutrobaolu/presentation/features/admin/screens/setting/setting.dart';
import 'package:cuutrobaolu/presentation/features/personalization/screens/settings/settings.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';



class NavigationAdminController extends GetxController {
  static final Rx<int> selectedIndex = 0.obs;

  final screen = <Widget>[
    HomeAdminScreen(),
    HelpAdminScreen(),
    SettingAdminScreen(),
    SettingScreen(),
  ];

  // static final screen = <Widget>[
  //   HomeScreen(),
  //   StoreScreen(),
  //   FavoriteScreen(),
  //   Container(color: Colors.greenAccent,),
  // ];
}
