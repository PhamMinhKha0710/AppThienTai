import 'dart:async';
import 'package:cuutrobaolu/data/services/notification_service.dart';
import 'package:cuutrobaolu/domain/entities/alert_entity.dart';
import 'package:cuutrobaolu/domain/entities/scored_alert_entity.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Smart Notification Service - Batching & Cooldown Management
/// 
/// Quản lý gửi notification thông minh với batching và cooldown để tránh spam.
class SmartNotificationService extends GetxService {
  static SmartNotificationService get instance => Get.find<SmartNotificationService>();

  final NotificationService _notificationService = Get.find<NotificationService>();
  
  // Batching queues by audience
  final Map<String, List<ScoredAlert>> _batches = {};
  
  // Cooldown tracking by audience
  final Map<String, DateTime> _lastNotificationTime = {};
  
  // Timers for batch processing
  final Map<String, Timer> _batchTimers = {};
  
  // Cooldown duration: 2 minutes
  static const Duration _cooldownDuration = Duration(minutes: 2);
  
  // Batch delays
  static const Duration _highSeverityDelay = Duration(minutes: 5);
  static const Duration _mediumLowSeverityDelay = Duration(minutes: 15);
  
  // Max batch sizes
  static const int _maxHighBatch = 3;
  static const int _maxMediumLowBatch = 5;

  /// Schedule a notification with smart batching and cooldown
  Future<void> scheduleNotification(ScoredAlert scoredAlert) async {
    final alert = scoredAlert.alert;
    final audienceKey = _getAudienceKey(alert.targetAudience);
    
    // Critical alerts - send immediately
    if (alert.severity == AlertSeverity.critical) {
      await _sendImmediate(scoredAlert);
      _updateCooldown(audienceKey);
      return;
    }
    
    // Check cooldown
    if (_isInCooldown(audienceKey)) {
      _addToBatch(audienceKey, scoredAlert);
      return;
    }
    
    // High severity - batch with 5 minute delay
    if (alert.severity == AlertSeverity.high) {
      _scheduleWithDelay(audienceKey, scoredAlert, _highSeverityDelay, _maxHighBatch);
      return;
    }
    
    // Medium/Low severity - batch with 15 minute delay
    _scheduleWithDelay(audienceKey, scoredAlert, _mediumLowSeverityDelay, _maxMediumLowBatch);
  }

  /// Send notification immediately
  Future<void> _sendImmediate(ScoredAlert scoredAlert) async {
    final alert = scoredAlert.alert;
    final channelId = _getChannelId(alert.severity);
    
    String title;
    String body;
    
    if (scoredAlert.distanceKm != null) {
      title = '⚠️ ${alert.title}';
      body = 'Bạn đang cách vùng cảnh báo ${scoredAlert.distanceKm!.toStringAsFixed(1)}km. ${alert.content}';
    } else {
      title = '⚠️ ${alert.title}';
      body = alert.content;
    }
    
    await _notificationService.showNotification(
      id: alert.hashCode,
      title: title,
      body: body,
      channelId: channelId,
      payload: '{"alertId": "${alert.id}", "type": "alert", "score": ${scoredAlert.score}}',
    );
    
    debugPrint('[SmartNotification] Sent immediate: ${alert.title} (score: ${scoredAlert.score.toStringAsFixed(1)})');
  }

  /// Schedule notification with delay and batching
  void _scheduleWithDelay(
    String audienceKey,
    ScoredAlert scoredAlert,
    Duration delay,
    int maxBatch,
  ) {
    _addToBatch(audienceKey, scoredAlert);
    
    // Cancel existing timer if any
    _batchTimers[audienceKey]?.cancel();
    
    // Create new timer
    _batchTimers[audienceKey] = Timer(delay, () {
      _processBatch(audienceKey, maxBatch);
    });
    
    debugPrint('[SmartNotification] Scheduled batch for $audienceKey (delay: ${delay.inMinutes}min)');
  }

  /// Add alert to batch queue
  void _addToBatch(String audienceKey, ScoredAlert scoredAlert) {
    _batches.putIfAbsent(audienceKey, () => []).add(scoredAlert);
    debugPrint('[SmartNotification] Added to batch: ${scoredAlert.alert.title}');
  }

  /// Process batch and send notifications
  Future<void> _processBatch(String audienceKey, int maxBatch) async {
    final batch = _batches[audienceKey] ?? [];
    if (batch.isEmpty) return;
    
    // Sort by score (highest first)
    batch.sort((a, b) => b.score.compareTo(a.score));
    
    // Take up to maxBatch
    final toSend = batch.take(maxBatch).toList();
    batch.removeRange(0, toSend.length);
    
    // Send batch notification
    if (toSend.length == 1) {
      // Single alert - send as normal
      await _sendImmediate(toSend.first);
    } else {
      // Multiple alerts - send as batch
      await _sendBatchNotification(audienceKey, toSend);
    }
    
    // Update cooldown
    _updateCooldown(audienceKey);
    
    // If more alerts in batch, schedule next batch
    if (batch.isNotEmpty) {
      final nextAlert = batch.first;
      final delay = nextAlert.alert.severity == AlertSeverity.high
          ? _highSeverityDelay
          : _mediumLowSeverityDelay;
      _scheduleWithDelay(audienceKey, nextAlert, delay, maxBatch);
    }
  }

  /// Send batch notification
  Future<void> _sendBatchNotification(String audienceKey, List<ScoredAlert> batch) async {
    if (batch.isEmpty) return;
    
    // Find highest severity
    final highestSeverity = batch.map((a) => a.alert.severity).reduce((a, b) {
      return _severityToInt(a) > _severityToInt(b) ? a : b;
    });
    
    final channelId = _getChannelId(highestSeverity);
    final title = '⚠️ ${batch.length} Cảnh báo mới';
    
    // Build body with up to 3 alerts
    final bodyLines = <String>[];
    for (var i = 0; i < batch.length && i < 3; i++) {
      final alert = batch[i].alert;
      final icon = _getTypeIcon(alert.alertType);
      bodyLines.add('$icon ${alert.title}');
    }
    
    if (batch.length > 3) {
      bodyLines.add('...và ${batch.length - 3} cảnh báo khác');
    }
    
    final body = bodyLines.join('\n');
    
    await _notificationService.showNotification(
      id: audienceKey.hashCode,
      title: title,
      body: body,
      channelId: channelId,
      payload: '{"type": "batch", "count": ${batch.length}}',
    );
    
    debugPrint('[SmartNotification] Sent batch: ${batch.length} alerts');
  }

  /// Check if audience is in cooldown
  bool _isInCooldown(String audienceKey) {
    final lastTime = _lastNotificationTime[audienceKey];
    if (lastTime == null) return false;
    
    final elapsed = DateTime.now().difference(lastTime);
    return elapsed < _cooldownDuration;
  }

  /// Update cooldown timestamp
  void _updateCooldown(String audienceKey) {
    _lastNotificationTime[audienceKey] = DateTime.now();
  }

  /// Get audience key for cooldown/batching
  String _getAudienceKey(TargetAudience audience) {
    switch (audience) {
      case TargetAudience.victims:
        return 'victims';
      case TargetAudience.volunteers:
        return 'volunteers';
      case TargetAudience.locationBased:
        return 'location';
      case TargetAudience.all:
        return 'all';
    }
  }

  /// Get channel ID based on severity
  String _getChannelId(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return NotificationChannels.criticalAlert;
      case AlertSeverity.high:
        return NotificationChannels.highAlert;
      default:
        return NotificationChannels.normalAlert;
    }
  }

  /// Get severity as int for comparison
  int _severityToInt(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return 4;
      case AlertSeverity.high:
        return 3;
      case AlertSeverity.medium:
        return 2;
      case AlertSeverity.low:
        return 1;
    }
  }

  /// Get icon for alert type
  String _getTypeIcon(AlertType type) {
    switch (type) {
      case AlertType.disaster:
        return '🌊';
      case AlertType.weather:
        return '🌧️';
      case AlertType.evacuation:
        return '🚨';
      case AlertType.resource:
        return '📦';
      case AlertType.general:
        return 'ℹ️';
    }
  }

  @override
  void onClose() {
    // Cancel all timers
    for (final timer in _batchTimers.values) {
      timer.cancel();
    }
    _batchTimers.clear();
    super.onClose();
  }
}
