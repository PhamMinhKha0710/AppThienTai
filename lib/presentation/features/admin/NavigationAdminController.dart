import 'package:cuutrobaolu/presentation/features/admin/screens/dashboard/admin_dashboard_screen.dart';
import 'package:cuutrobaolu/presentation/features/admin/screens/sos/admin_sos_screen.dart';
import 'package:cuutrobaolu/presentation/features/admin/screens/setting/setting.dart';
import 'package:cuutrobaolu/presentation/features/admin/screens/profile/admin_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationAdminController extends GetxController {
  static final Rx<int> selectedIndex = 0.obs;

  List<Widget> get screen => [
    const AdminDashboardScreen(), // Dashboard with realtime stats
    const AdminSOSScreen(), // SOS Management with advanced filtering
    const SettingAdminScreen(), // System settings
    const AdminProfileScreen(), // Profile
  ];
}
