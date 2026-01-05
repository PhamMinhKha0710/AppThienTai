import 'package:cuutrobaolu/presentation/features/home/screens/home/home.dart';
import 'package:cuutrobaolu/presentation/features/home/screens/help/help.dart';
import 'package:cuutrobaolu/presentation/features/home/screens/wishlist/wishlist.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:cuutrobaolu/presentation/features/personalization/screens/settings/settings.dart';
import 'package:cuutrobaolu/data/services/notification_service.dart';
import 'package:cuutrobaolu/presentation/features/chat/screens/realtime_chat_screen.dart';
import 'package:cuutrobaolu/presentation/features/victim/screens/map/victim_map_screen.dart';

class NavigationController extends GetxController {
  static final Rx<int> selectedIndex = 0.obs;

  List<Widget> get screen => [
    HomeScreen(),
    HelpScreen(),
    FavoriteScreen(),
    SettingScreen(),
  ];

  @override
  void onInit() {
    super.onInit();
    _setupNotificationHandling();
  }

  void _setupNotificationHandling() {
    try {
      final notificationService = Get.find<NotificationService>();
      
      notificationService.onNotificationTapped = (data) {
        _handleNotificationData(data);
      };
      
      notificationService.onMessageOpenedApp = (message) {
        _handleNotificationData(message.data);
      };
    } catch (e) {
      print('NavigationController: Could not find NotificationService');
    }
  }

  void _handleNotificationData(Map<String, dynamic> data) {
    if (data.isEmpty) return;
    
    final type = data['type'];
    print('Handling notification type: $type');
    
    switch (type) {
      case 'chat':
        if (data['conversationId'] != null && data['otherUserId'] != null) {
          Get.to(() => RealtimeChatScreen(
            targetUserId: data['otherUserId'],
            targetUserName: data['otherUserName'] ?? 'Chat',
          ));
        }
        break;
      case 'alert':
      case 'sos':
      case 'hazard':
        Get.to(() => VictimMapScreen()); 
        break;
      default:
        print('Unknown notification type: $type');
    }
  }
}