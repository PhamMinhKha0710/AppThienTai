import 'package:flutter/foundation.dart';
import 'package:cuutrobaolu/data/services/ai_service_client.dart';
import 'package:cuutrobaolu/domain/entities/alert_entity.dart';
import 'package:cuutrobaolu/core/injection/injection_container.dart';

/// Engagement Tracker
/// 
/// Tracks user interactions with alerts for AI learning.
/// Actions tracked:
/// - view: User viewed alert details
/// - dismiss: User dismissed/closed alert
/// - share: User shared alert
/// - report: User reported alert
/// - click: User clicked on alert for more details
class EngagementTracker {
  static final EngagementTracker _instance = EngagementTracker._internal();
  factory EngagementTracker() => _instance;
  EngagementTracker._internal();
  
  AIServiceClient? _aiService;
  bool _initialized = false;
  
  /// Initialize the tracker
  void initialize() {
    if (_initialized) return;
    
    try {
      _aiService = getIt<AIServiceClient>();
      _initialized = true;
      debugPrint('[EngagementTracker] Initialized');
    } catch (e) {
      debugPrint('[EngagementTracker] Failed to initialize: $e');
    }
  }
  
  /// Track alert view
  Future<void> trackView(AlertEntity alert, String userId) async {
    await _trackEngagement(
      alertId: alert.id,
      userId: userId,
      action: 'view',
    );
  }
  
  /// Track alert dismiss
  Future<void> trackDismiss(AlertEntity alert, String userId) async {
    await _trackEngagement(
      alertId: alert.id,
      userId: userId,
      action: 'dismiss',
    );
  }
  
  /// Track alert share
  Future<void> trackShare(AlertEntity alert, String userId) async {
    await _trackEngagement(
      alertId: alert.id,
      userId: userId,
      action: 'share',
    );
  }
  
  /// Track alert report
  Future<void> trackReport(AlertEntity alert, String userId) async {
    await _trackEngagement(
      alertId: alert.id,
      userId: userId,
      action: 'report',
    );
  }
  
  /// Track alert click
  Future<void> trackClick(AlertEntity alert, String userId) async {
    await _trackEngagement(
      alertId: alert.id,
      userId: userId,
      action: 'click',
    );
  }
  
  /// Internal method to track engagement
  Future<void> _trackEngagement({
    required String alertId,
    required String userId,
    required String action,
  }) async {
    if (!_initialized || _aiService == null) {
      debugPrint('[EngagementTracker] Not initialized, skipping tracking');
      return;
    }
    
    try {
      await _aiService!.logEngagement(
        alertId: alertId,
        userId: userId,
        action: action,
      );
      debugPrint('[EngagementTracker] Tracked: $action for alert $alertId');
    } catch (e) {
      // Non-critical error, just log it
      debugPrint('[EngagementTracker] Failed to track engagement: $e');
    }
  }
}




















