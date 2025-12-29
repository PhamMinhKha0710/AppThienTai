import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

/// Notification channels for different alert types
class NotificationChannels {
  static const String criticalAlert = 'critical_alert_channel';
  static const String highAlert = 'high_alert_channel';
  static const String normalAlert = 'normal_alert_channel';
  static const String sosAlert = 'sos_alert_channel';
}

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM] Background message received: ${message.messageId}');
  // Handle background message
  await NotificationService.instance.handleBackgroundMessage(message);
}

/// NotificationService - Handles FCM and local notifications
class NotificationService extends GetxService {
  static NotificationService get instance => Get.find<NotificationService>();
  
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  // Observable state
  final fcmToken = Rxn<String>();
  final isInitialized = false.obs;
  final subscribedTopics = <String>[].obs;
  
  // Callbacks
  Function(RemoteMessage)? onMessageReceived;
  Function(RemoteMessage)? onMessageOpenedApp;
  Function(Map<String, dynamic>)? onNotificationTapped;
  
  /// Initialize the notification service
  Future<NotificationService> init() async {
    if (isInitialized.value) return this;
    
    try {
      // Request permission
      await _requestPermission();
      
      // Initialize local notifications
      await _initLocalNotifications();
      
      // Setup FCM handlers
      await _setupFCMHandlers();
      
      // Get FCM token
      await _getFCMToken();
      
      isInitialized.value = true;
      debugPrint('[NotificationService] Initialized successfully');
    } catch (e) {
      debugPrint('[NotificationService] Error initializing: $e');
    }
    
    return this;
  }
  
  /// Request notification permission
  Future<void> _requestPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true, // For emergency alerts
      provisional: false,
      sound: true,
    );
    
    debugPrint('[FCM] Permission status: ${settings.authorizationStatus}');
  }
  
  /// Initialize local notifications with channels
  Future<void> _initLocalNotifications() async {
    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestCriticalPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTapped,
    );
    
    // Create notification channels for Android
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }
  }
  
  /// Create Android notification channels
  Future<void> _createNotificationChannels() async {
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin == null) return;
    
    // Critical Alert Channel - Bypass DND
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        NotificationChannels.criticalAlert,
        'Cảnh báo khẩn cấp',
        description: 'Thông báo cảnh báo cực kỳ nghiêm trọng',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        ledColor: Color.fromARGB(255, 255, 0, 0),
      ),
    );
    
    // High Alert Channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        NotificationChannels.highAlert,
        'Cảnh báo quan trọng',
        description: 'Thông báo cảnh báo mức độ cao',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );
    
    // Normal Alert Channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        NotificationChannels.normalAlert,
        'Thông báo',
        description: 'Thông báo thông thường',
        importance: Importance.defaultImportance,
        playSound: true,
      ),
    );
    
    // SOS Alert Channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        NotificationChannels.sosAlert,
        'Yêu cầu SOS',
        description: 'Thông báo khi có yêu cầu SOS mới',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        ledColor: Color.fromARGB(255, 255, 0, 0),
      ),
    );
    
    debugPrint('[NotificationService] Notification channels created');
  }
  
  /// Setup FCM message handlers
  Future<void> _setupFCMHandlers() async {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle message when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    
    // Check for initial message (app opened from terminated state)
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }
  
  /// Get and store FCM token
  Future<void> _getFCMToken() async {
    try {
      final token = await _fcm.getToken();
      fcmToken.value = token;
      debugPrint('[FCM] Token: $token');
      
      // Listen for token refresh
      _fcm.onTokenRefresh.listen((newToken) {
        fcmToken.value = newToken;
        debugPrint('[FCM] Token refreshed: $newToken');
        // TODO: Update token in backend
      });
    } catch (e) {
      debugPrint('[FCM] Error getting token: $e');
    }
  }
  
  /// Handle foreground message
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('[FCM] Foreground message: ${message.messageId}');
    debugPrint('[FCM] Data: ${message.data}');
    
    // Show local notification
    showNotificationFromMessage(message);
    
    // Trigger callback
    onMessageReceived?.call(message);
  }
  
  /// Handle message when app opened from notification
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('[FCM] Message opened app: ${message.messageId}');
    
    // Trigger callback
    onMessageOpenedApp?.call(message);
  }
  
  /// Handle background message
  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('[FCM] Background message: ${message.messageId}');
    // Background processing if needed
  }
  
  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('[Notification] Tapped: ${response.payload}');
    
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        onNotificationTapped?.call(data);
      } catch (e) {
        debugPrint('[Notification] Error parsing payload: $e');
      }
    }
  }
  
  /// Handle background notification tap
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTapped(NotificationResponse response) {
    debugPrint('[Notification] Background tapped: ${response.payload}');
  }
  
  /// Show local notification from FCM message
  Future<void> showNotificationFromMessage(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;
    
    if (notification == null) return;
    
    // Determine channel based on severity
    final severity = data['severity'] ?? 'medium';
    final channelId = _getChannelForSeverity(severity);
    
    await showNotification(
      id: notification.hashCode,
      title: notification.title ?? 'Thông báo',
      body: notification.body ?? '',
      channelId: channelId,
      payload: jsonEncode(data),
    );
  }
  
  /// Get notification channel based on severity
  String _getChannelForSeverity(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return NotificationChannels.criticalAlert;
      case 'high':
        return NotificationChannels.highAlert;
      case 'sos':
        return NotificationChannels.sosAlert;
      default:
        return NotificationChannels.normalAlert;
    }
  }
  
  /// Show a local notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String channelId = NotificationChannels.normalAlert,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      importance: _getImportanceForChannel(channelId),
      priority: _getPriorityForChannel(channelId),
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(body),
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.show(id, title, body, details, payload: payload);
  }
  
  /// Get channel name for display
  String _getChannelName(String channelId) {
    switch (channelId) {
      case NotificationChannels.criticalAlert:
        return 'Cảnh báo khẩn cấp';
      case NotificationChannels.highAlert:
        return 'Cảnh báo quan trọng';
      case NotificationChannels.sosAlert:
        return 'Yêu cầu SOS';
      default:
        return 'Thông báo';
    }
  }
  
  /// Get importance for channel
  Importance _getImportanceForChannel(String channelId) {
    switch (channelId) {
      case NotificationChannels.criticalAlert:
      case NotificationChannels.sosAlert:
        return Importance.max;
      case NotificationChannels.highAlert:
        return Importance.high;
      default:
        return Importance.defaultImportance;
    }
  }
  
  /// Get priority for channel
  Priority _getPriorityForChannel(String channelId) {
    switch (channelId) {
      case NotificationChannels.criticalAlert:
      case NotificationChannels.sosAlert:
        return Priority.max;
      case NotificationChannels.highAlert:
        return Priority.high;
      default:
        return Priority.defaultPriority;
    }
  }
  
  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _fcm.subscribeToTopic(topic);
      if (!subscribedTopics.contains(topic)) {
        subscribedTopics.add(topic);
      }
      debugPrint('[FCM] Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('[FCM] Error subscribing to topic: $e');
    }
  }
  
  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _fcm.unsubscribeFromTopic(topic);
      subscribedTopics.remove(topic);
      debugPrint('[FCM] Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('[FCM] Error unsubscribing from topic: $e');
    }
  }
  
  /// Subscribe to default topics based on user role
  Future<void> subscribeToDefaultTopics({
    required String userRole,
    String? province,
    String? district,
  }) async {
    // Subscribe to all alerts
    await subscribeToTopic('all_alerts');
    
    // Subscribe based on role
    switch (userRole.toLowerCase()) {
      case 'victim':
        await subscribeToTopic('victims');
        break;
      case 'volunteer':
        await subscribeToTopic('volunteers');
        break;
      case 'admin':
        await subscribeToTopic('admins');
        break;
    }
    
    // Subscribe to location-based topics
    if (province != null && province.isNotEmpty) {
      final provinceTopic = 'province_${province.toLowerCase().replaceAll(' ', '_')}';
      await subscribeToTopic(provinceTopic);
    }
    
    if (district != null && district.isNotEmpty) {
      final districtTopic = 'district_${district.toLowerCase().replaceAll(' ', '_')}';
      await subscribeToTopic(districtTopic);
    }
  }
  
  /// Unsubscribe from all topics
  Future<void> unsubscribeFromAllTopics() async {
    for (final topic in List.from(subscribedTopics)) {
      await unsubscribeFromTopic(topic);
    }
  }
  
  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }
  
  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }
}

