import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:cuutrobaolu/domain/entities/alert_entity.dart';

/// Client for connecting to Python AI Service
///
/// Provides:
/// - AI-powered alert scoring
/// - Semantic duplicate detection
/// - Notification timing optimization
class AIServiceClient {
  final Dio _dio;
  final String baseUrl;

  AIServiceClient({
    required this.baseUrl, // e.g., "http://localhost:8000" or your server
  }) : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ));

  /// Get AI-powered priority score for an alert
  Future<AIScoreResult> getAlertScore(
    AlertEntity alert, {
    required double? userLat,
    required double? userLng,
    required String userRole,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/score',
        data: {
          'alert_id': alert.id,
          'severity': alert.severity.name,
          'alert_type': alert.alertType.name,
          'content': alert.content,
          'province': alert.province,
          'district': alert.district,
          'lat': alert.lat,
          'lng': alert.lng,
          'created_at': alert.createdAt.toIso8601String(),
          'user_lat': userLat,
          'user_lng': userLng,
          'user_role': userRole,
        },
      );

      return AIScoreResult.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('[AIService] DioException in getAlertScore: ${e.message}');
      if (e.response != null) {
        debugPrint('[AIService] Response: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      debugPrint('[AIService] Error scoring alert: $e');
      rethrow;
    }
  }

  /// Check if alert is duplicate using semantic similarity
  Future<DuplicateCheckResult> checkDuplicate(
    AlertEntity newAlert,
    List<AlertEntity> existingAlerts,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v1/duplicate/check',
        data: {
          'new_alert': _alertToDict(newAlert),
          'existing_alerts':
              existingAlerts.map(_alertToDict).toList(),
          'threshold': 0.85,
        },
      );

      return DuplicateCheckResult.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('[AIService] DioException in checkDuplicate: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[AIService] Error checking duplicate: $e');
      rethrow;
    }
  }

  /// Get recommended notification timing
  Future<NotificationTimingResult> getNotificationTiming({
    required String alertSeverity,
    required String userId,
    Map<String, dynamic>? userContext,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/timing/recommend',
        data: {
          'alert_severity': alertSeverity,
          'user_id': userId,
          'user_context': userContext ?? {},
        },
      );

      return NotificationTimingResult.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('[AIService] DioException in getNotificationTiming: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[AIService] Error getting timing: $e');
      rethrow;
    }
  }

  /// Log user engagement for online learning
  Future<void> logEngagement({
    required String alertId,
    required String userId,
    required String action,
    int? timeSlot,
    double? actualScore,
  }) async {
    try {
      await _dio.post(
        '/api/v1/feedback/engagement',
        data: {
          'alert_id': alertId,
          'user_id': userId,
          'action': action,
          'time_slot': timeSlot,
          'actual_score': actualScore,
        },
      );
      debugPrint('[AIService] Engagement logged: $alertId - $action');
    } on DioException catch (e) {
      debugPrint('[AIService] Error logging engagement: ${e.message}');
      // Don't throw - logging is non-critical
    } catch (e) {
      debugPrint('[AIService] Error logging engagement: $e');
    }
  }

  /// Get engagement statistics
  Future<Map<String, dynamic>> getEngagementStats({int days = 7}) async {
    try {
      final response = await _dio.get(
        '/api/v1/stats/engagement',
        queryParameters: {'days': days},
      );
      return response.data;
    } catch (e) {
      debugPrint('[AIService] Error getting engagement stats: $e');
      rethrow;
    }
  }

  /// Get duplicate detection statistics
  Future<Map<String, dynamic>> getDuplicateStats({int days = 7}) async {
    try {
      final response = await _dio.get(
        '/api/v1/stats/duplicate',
        queryParameters: {'days': days},
      );
      return response.data;
    } catch (e) {
      debugPrint('[AIService] Error getting duplicate stats: $e');
      rethrow;
    }
  }

  /// Get notification timing statistics
  Future<Map<String, dynamic>> getTimingStats() async {
    try {
      final response = await _dio.get('/api/v1/stats/timing');
      return response.data;
    } catch (e) {
      debugPrint('[AIService] Error getting timing stats: $e');
      rethrow;
    }
  }

  /// Health check
  Future<bool> healthCheck() async {
    try {
      final response = await _dio.get('/api/v1/health');
      return response.statusCode == 200 &&
          response.data['status'] == 'healthy';
    } catch (e) {
      debugPrint('[AIService] Health check failed: $e');
      return false;
    }
  }

  /// Convert AlertEntity to dictionary for API
  Map<String, dynamic> _alertToDict(AlertEntity alert) {
    return {
      'id': alert.id,
      'content': alert.content,
      'alert_type': alert.alertType.name,
      'severity': alert.severity.name,
      'province': alert.province,
      'district': alert.district,
      'lat': alert.lat,
      'lng': alert.lng,
      'created_at': alert.createdAt.toIso8601String(),
    };
  }
}

/// Result from AI scoring
class AIScoreResult {
  final String alertId;
  final double priorityScore;
  final double confidence;
  final Map<String, dynamic> explanation;

  AIScoreResult({
    required this.alertId,
    required this.priorityScore,
    required this.confidence,
    required this.explanation,
  });

  factory AIScoreResult.fromJson(Map<String, dynamic> json) {
    return AIScoreResult(
      alertId: json['alert_id'],
      priorityScore: (json['priority_score'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      explanation: json['explanation'] as Map<String, dynamic>,
    );
  }
}

/// Result from duplicate check
class DuplicateCheckResult {
  final bool isDuplicate;
  final List<DuplicateMatch> duplicates;
  final DuplicateMatch? bestMatch;

  DuplicateCheckResult({
    required this.isDuplicate,
    required this.duplicates,
    this.bestMatch,
  });

  factory DuplicateCheckResult.fromJson(Map<String, dynamic> json) {
    final duplicatesList = (json['duplicates'] as List)
        .map((d) => DuplicateMatch.fromJson(d))
        .toList();

    return DuplicateCheckResult(
      isDuplicate: json['is_duplicate'],
      duplicates: duplicatesList,
      bestMatch: json['best_match'] != null
          ? DuplicateMatch.fromJson(json['best_match'])
          : null,
    );
  }
}

/// Duplicate match information
class DuplicateMatch {
  final Map<String, dynamic> alert;
  final double similarity;

  DuplicateMatch({
    required this.alert,
    required this.similarity,
  });

  factory DuplicateMatch.fromJson(Map<String, dynamic> json) {
    return DuplicateMatch(
      alert: json['alert'] as Map<String, dynamic>,
      similarity: (json['similarity'] as num).toDouble(),
    );
  }
}

/// Result from notification timing
class NotificationTimingResult {
  final int recommendedHour;
  final List<TimeSlotInfo> topTimes;
  final String strategy;

  NotificationTimingResult({
    required this.recommendedHour,
    required this.topTimes,
    required this.strategy,
  });

  factory NotificationTimingResult.fromJson(Map<String, dynamic> json) {
    return NotificationTimingResult(
      recommendedHour: json['recommended_hour'],
      topTimes: (json['top_times'] as List)
          .map((t) => TimeSlotInfo.fromJson(t))
          .toList(),
      strategy: json['strategy'],
    );
  }
}

/// Time slot information
class TimeSlotInfo {
  final int hour;
  final double successRate;
  final double confidence;
  final int sampleSize;

  TimeSlotInfo({
    required this.hour,
    required this.successRate,
    required this.confidence,
    required this.sampleSize,
  });

  factory TimeSlotInfo.fromJson(Map<String, dynamic> json) {
    return TimeSlotInfo(
      hour: json['hour'],
      successRate: (json['success_rate'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      sampleSize: json['sample_size'] ?? 0,
    );
  }
}

