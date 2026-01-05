import 'package:cuutrobaolu/presentation/features/victim/screens/home/victim_home_screen.dart';
import 'package:cuutrobaolu/presentation/features/victim/screens/map/victim_map_screen.dart';
import 'package:cuutrobaolu/presentation/features/victim/screens/alerts/victim_alerts_screen.dart';
import 'package:cuutrobaolu/presentation/features/chat/screens/conversation_list_screen.dart';
import 'package:cuutrobaolu/presentation/features/victim/screens/profile/victim_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationVictimController extends GetxController {
  static final Rx<int> selectedIndex = 0.obs;

  List<Widget> get screen => [
    const VictimHomeScreen(),
    const VictimMapScreen(),
    const VictimAlertsScreen(),
    const ConversationListScreen(),
    const VictimProfileScreen(),
  ];
}






