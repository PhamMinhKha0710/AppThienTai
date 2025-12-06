import 'package:cuutrobaolu/features/shop/screens/home/home.dart';
import 'package:cuutrobaolu/features/shop/screens/help/help.dart';
import 'package:cuutrobaolu/features/shop/screens/wishlist/wishlist.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'features/personalization/screens/settings/settings.dart';

class NavigationController extends GetxController {
  static final Rx<int> selectedIndex = 0.obs;

  final screen = <Widget>[
    HomeScreen(),
    HelpScreen(),
    FavoriteScreen(),
    SettingScreen(),
  ];

  // static final screen = <Widget>[
  //   HomeScreen(),
  //   StoreScreen(),
  //   FavoriteScreen(),
  //   Container(color: Colors.greenAccent,),
  // ];
}