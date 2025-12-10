import 'package:cuutrobaolu/presentation/features/victim/screens/home/victim_home_screen.dart';
import 'package:cuutrobaolu/presentation/features/victim/screens/map/victim_map_screen.dart';
import 'package:cuutrobaolu/presentation/features/victim/screens/alerts/victim_alerts_screen.dart';
import 'package:cuutrobaolu/presentation/features/victim/screens/news/victim_news_screen.dart';
import 'package:cuutrobaolu/presentation/features/personalization/screens/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationVictimController extends GetxController {
  static final Rx<int> selectedIndex = 0.obs;

  List<Widget> get screen => [
    VictimHomeScreen(),
    VictimMapScreen(),
    VictimAlertsScreen(),
    VictimNewsScreen(),
    SettingScreen(),
  ];
}

