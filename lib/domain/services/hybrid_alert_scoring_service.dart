import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:cuutrobaolu/domain/entities/alert_entity.dart';
import 'package:cuutrobaolu/domain/entities/scored_alert_entity.dart';
import 'package:cuutrobaolu/domain/services/alert_scoring_service.dart';
import 'package:cuutrobaolu/data/services/ai_service_client.dart';

/// Hybrid Alert Scoring Service
///
/// Combines rule-based scoring (fallback) with AI-powered scoring (primary).
/// 
/// Strategy:
/// 1. Try AI service first for ML-based scoring
/// 2. If AI fails (network, timeout, error), fallback to rule-based
/// 3. Log AI predictions for continuous improvement
class HybridAlertScoringService {
  final AlertScoringService _ruleBasedService;
  final AIServiceClient _aiService;
  final bool _useAI;

  HybridAlertScoringService({
    required AlertScoringService ruleBasedService,
    required AIServiceClient aiService,
    bool useAI = true,
  })  : _ruleBasedService = ruleBasedService,
        _aiService = aiService,
        _useAI = useAI;

  /// Calculate scored alert using hybrid approach
  Future<ScoredAlert> calculateScoredAlert({
    required AlertEntity alert,
    required double? userLat,
    required double? userLng,
    required String userRole,
  }) async {
    // Try AI first if enabled
    if (_useAI) {
      try {
        final aiResult = await _aiService.getAlertScore(
          alert,
          userLat: userLat,
          userLng: userLng,
          userRole: userRole,
        );

        debugPrint(
          '[HybridScoring] AI score: ${aiResult.priorityScore} (confidence: ${aiResult.confidence})',
        );

        // Calculate distance if coordinates available
        double? distanceKm;
        if (alert.lat != null &&
            alert.lng != null &&
            userLat != null &&
            userLng != null) {
          distanceKm = _haversineDistance(
            userLat,
            userLng,
            alert.lat!,
            alert.lng!,
          );
        }

        return ScoredAlert.now(
          alert: alert.copyWith(
            priorityScore: aiResult.priorityScore,
            distanceKm: distanceKm,
          ),
          score: aiResult.priorityScore,
          distanceKm: distanceKm,
        );
      } catch (e) {
        debugPrint('[HybridScoring] AI failed, falling back to rule-based: $e');
      }
    }

    // Fallback to rule-based scoring
    debugPrint('[HybridScoring] Using rule-based scoring');
    final score = _ruleBasedService.calculatePriorityScore(
      alert: alert,
      userLat: userLat,
      userLng: userLng,
      userRole: userRole,
    );

    // Calculate distance if coordinates available
    double? distanceKm;
    if (alert.lat != null &&
        alert.lng != null &&
        userLat != null &&
        userLng != null) {
      distanceKm = _haversineDistance(
        userLat,
        userLng,
        alert.lat!,
        alert.lng!,
      );
    }

    return ScoredAlert.now(
      alert: alert.copyWith(
        priorityScore: score,
        distanceKm: distanceKm,
      ),
      score: score,
      distanceKm: distanceKm,
    );
  }

  /// Batch score multiple alerts
  Future<List<ScoredAlert>> scoreMultipleAlerts({
    required List<AlertEntity> alerts,
    required double? userLat,
    required double? userLng,
    required String userRole,
  }) async {
    final scoredAlerts = <ScoredAlert>[];

    for (final alert in alerts) {
      try {
        final scored = await calculateScoredAlert(
          alert: alert,
          userLat: userLat,
          userLng: userLng,
          userRole: userRole,
        );
        scoredAlerts.add(scored);
      } catch (e) {
        debugPrint('[HybridScoring] Error scoring alert ${alert.id}: $e');
        // Skip this alert if scoring fails
      }
    }

    // Sort by score descending
    scoredAlerts.sort((a, b) => b.score.compareTo(a.score));

    return scoredAlerts;
  }

  /// Check AI service health
  Future<bool> isAIServiceAvailable() async {
    if (!_useAI) return false;

    try {
      return await _aiService.healthCheck();
    } catch (e) {
      debugPrint('[HybridScoring] AI health check failed: $e');
      return false;
    }
  }

  /// Log user engagement with alert (for AI learning)
  Future<void> logAlertEngagement({
    required String alertId,
    required String userId,
    required String action,
  }) async {
    if (!_useAI) return;

    try {
      final now = DateTime.now();
      await _aiService.logEngagement(
        alertId: alertId,
        userId: userId,
        action: action,
        timeSlot: now.hour,
      );
    } catch (e) {
      debugPrint('[HybridScoring] Error logging engagement: $e');
      // Non-critical, don't rethrow
    }
  }

  /// Check if alert is duplicate using AI semantic similarity
  Future<bool> isDuplicate(
    AlertEntity newAlert,
    List<AlertEntity> existingAlerts,
  ) async {
    if (!_useAI || existingAlerts.isEmpty) {
      return false;
    }

    try {
      final result = await _aiService.checkDuplicate(
        newAlert,
        existingAlerts,
      );
      return result.isDuplicate;
    } catch (e) {
      debugPrint('[HybridScoring] Error checking duplicate: $e');
      return false; // Assume not duplicate if check fails
    }
  }

  /// Haversine Formula để tính khoảng cách giữa 2 tọa độ
  double _haversineDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const double earthRadius = 6371.0; // km

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

  /// Chuyển đổi độ sang radian
  double _toRadians(double degrees) => degrees * (math.pi / 180);
}


