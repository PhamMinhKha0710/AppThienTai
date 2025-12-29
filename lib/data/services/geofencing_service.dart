import 'dart:async';
import 'dart:math' as math;

import 'package:cuutrobaolu/core/injection/injection_container.dart';
import 'package:cuutrobaolu/data/services/notification_service.dart';
import 'package:cuutrobaolu/domain/entities/alert_entity.dart';
import 'package:cuutrobaolu/domain/repositories/alert_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// GeofencingService - Monitors user location and triggers alerts when entering danger zones
class GeofencingService extends GetxService {
  static GeofencingService get instance => Get.find<GeofencingService>();

  final AlertRepository _alertRepo = getIt<AlertRepository>();
  final GetStorage _storage = GetStorage();

  // Stream subscription for location updates
  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<List<AlertEntity>>? _alertsSubscription;

  // Observable state
  final isMonitoring = false.obs;
  final currentPosition = Rxn<Position>();
  final activeAlerts = <AlertEntity>[].obs;
  final triggeredAlertIds = <String>{}.obs;

  // Settings
  final checkRadiusKm = 50.0.obs; // Default check radius in km
  final isEnabled = true.obs;

  // Storage keys
  static const String _triggeredAlertsKey = 'geofence_triggered_alerts';
  static const String _isEnabledKey = 'geofence_enabled';

  /// Initialize the service
  Future<GeofencingService> init() async {
    // Load saved settings
    _loadSettings();

    // Load active alerts
    _loadActiveAlerts();

    debugPrint('[GeofencingService] Initialized');
    return this;
  }

  void _loadSettings() {
    // Load enabled state
    isEnabled.value = _storage.read(_isEnabledKey) ?? true;

    // Load previously triggered alert IDs
    final savedIds = _storage.read<List<dynamic>>(_triggeredAlertsKey);
    if (savedIds != null) {
      triggeredAlertIds.addAll(savedIds.cast<String>());
    }
  }

  void _loadActiveAlerts() {
    _alertsSubscription = _alertRepo.getActiveAlerts().listen((alerts) {
      // Filter location-based alerts
      activeAlerts.value = alerts.where((alert) {
        return (alert.targetAudience == TargetAudience.locationBased ||
                alert.targetAudience == TargetAudience.all ||
                alert.targetAudience == TargetAudience.victims) &&
            alert.lat != null &&
            alert.lng != null;
      }).toList();

      // Check current position against new alerts
      if (currentPosition.value != null && isMonitoring.value) {
        _checkAlertsForPosition(currentPosition.value!);
      }
    });
  }

  /// Start monitoring user location
  Future<void> startMonitoring() async {
    if (!isEnabled.value) {
      debugPrint('[GeofencingService] Service is disabled');
      return;
    }

    if (isMonitoring.value) {
      debugPrint('[GeofencingService] Already monitoring');
      return;
    }

    try {
      // Check permission
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        final requestedPermission = await Geolocator.requestPermission();
        if (requestedPermission == LocationPermission.denied ||
            requestedPermission == LocationPermission.deniedForever) {
          debugPrint('[GeofencingService] Location permission denied');
          return;
        }
      }

      // Check if location service is enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('[GeofencingService] Location service disabled');
        return;
      }

      // Start listening to location updates
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100, // Update every 100 meters
      );

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(_onPositionChanged);

      isMonitoring.value = true;
      debugPrint('[GeofencingService] Started monitoring');
    } catch (e) {
      debugPrint('[GeofencingService] Error starting monitoring: $e');
    }
  }

  /// Stop monitoring user location
  void stopMonitoring() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    isMonitoring.value = false;
    debugPrint('[GeofencingService] Stopped monitoring');
  }

  /// Handle position change
  void _onPositionChanged(Position position) {
    currentPosition.value = position;
    debugPrint(
        '[GeofencingService] Position updated: ${position.latitude}, ${position.longitude}');

    // Check if user is in any danger zone
    _checkAlertsForPosition(position);
  }

  /// Check if position is within any alert zone
  void _checkAlertsForPosition(Position position) {
    for (final alert in activeAlerts) {
      // Skip if already triggered
      if (triggeredAlertIds.contains(alert.id)) {
        continue;
      }

      // Skip if alert has no location
      if (alert.lat == null || alert.lng == null) {
        continue;
      }

      // Calculate distance to alert
      final distance = _calculateDistance(
        position.latitude,
        position.longitude,
        alert.lat!,
        alert.lng!,
      );

      // Check if within alert radius (default 10km if not specified)
      final alertRadius = alert.radiusKm ?? 10.0;

      if (distance <= alertRadius) {
        // User has entered danger zone
        _triggerAlert(alert, distance);
      }
    }
  }

  /// Trigger alert notification
  Future<void> _triggerAlert(AlertEntity alert, double distance) async {
    debugPrint(
        '[GeofencingService] Triggering alert: ${alert.title} (${distance.toStringAsFixed(1)}km away)');

    // Mark as triggered
    triggeredAlertIds.add(alert.id);
    _saveTriggeredAlerts();

    // Send notification
    try {
      final notificationService = Get.find<NotificationService>();

      // Determine notification channel based on severity
      String channelId;
      switch (alert.severity) {
        case AlertSeverity.critical:
          channelId = NotificationChannels.criticalAlert;
          break;
        case AlertSeverity.high:
          channelId = NotificationChannels.highAlert;
          break;
        default:
          channelId = NotificationChannels.normalAlert;
      }

      await notificationService.showNotification(
        id: alert.hashCode,
        title: '⚠️ ${alert.title}',
        body:
            'Bạn đang cách vùng cảnh báo ${distance.toStringAsFixed(1)}km. ${alert.content}',
        channelId: channelId,
        payload: '{"alertId": "${alert.id}", "type": "geofence"}',
      );
    } catch (e) {
      debugPrint('[GeofencingService] Error sending notification: $e');
    }
  }

  /// Save triggered alert IDs to storage
  void _saveTriggeredAlerts() {
    _storage.write(_triggeredAlertsKey, triggeredAlertIds.toList());
  }

  /// Clear triggered alerts (e.g., daily reset)
  void clearTriggeredAlerts() {
    triggeredAlertIds.clear();
    _storage.remove(_triggeredAlertsKey);
    debugPrint('[GeofencingService] Cleared triggered alerts');
  }

  /// Clear specific alert from triggered list
  void clearTriggeredAlert(String alertId) {
    triggeredAlertIds.remove(alertId);
    _saveTriggeredAlerts();
  }

  /// Enable or disable the service
  void setEnabled(bool enabled) {
    isEnabled.value = enabled;
    _storage.write(_isEnabledKey, enabled);

    if (enabled) {
      startMonitoring();
    } else {
      stopMonitoring();
    }
  }

  /// Set check radius
  void setCheckRadius(double radiusKm) {
    checkRadiusKm.value = radiusKm;
  }

  /// Get alerts within a certain radius of current position
  List<AlertEntity> getAlertsWithinRadius(double radiusKm) {
    if (currentPosition.value == null) return [];

    return activeAlerts.where((alert) {
      if (alert.lat == null || alert.lng == null) return false;

      final distance = _calculateDistance(
        currentPosition.value!.latitude,
        currentPosition.value!.longitude,
        alert.lat!,
        alert.lng!,
      );

      return distance <= radiusKm;
    }).toList();
  }

  /// Calculate distance between two coordinates using Haversine formula
  double _calculateDistance(
      double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // km
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * (math.pi / 180);

  @override
  void onClose() {
    stopMonitoring();
    _alertsSubscription?.cancel();
    super.onClose();
  }
}

