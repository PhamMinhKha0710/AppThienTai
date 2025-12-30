import 'package:cuutrobaolu/presentation/features/chat/screens/volunteer/volunteer_support_screen.dart';
import 'package:cuutrobaolu/presentation/features/volunteer/screens/home/volunteer_home_screen.dart';
import 'package:cuutrobaolu/presentation/features/volunteer/screens/tasks/volunteer_tasks_screen.dart';
import 'package:cuutrobaolu/presentation/features/volunteer/screens/map/volunteer_map_screen.dart';
import 'package:cuutrobaolu/presentation/features/volunteer/screens/alerts/volunteer_alerts_screen.dart';
import 'package:cuutrobaolu/presentation/features/volunteer/screens/profile/volunteer_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationVolunteerController extends GetxController {
  static final Rx<int> selectedIndex = 0.obs;

  List<Widget> get screen => [
    VolunteerHomeScreen(),
    VolunteerTasksScreen(),
    VolunteerMapScreen(),
    VolunteerAlertsScreen(),
    VolunteerSupportScreen(),
    VolunteerProfileScreen(),
  ];
}

