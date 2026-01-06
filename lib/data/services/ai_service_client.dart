import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:cuutrobaolu/domain/entities/alert_entity.dart';
import 'package:cuutrobaolu/core/constants/api_constants.dart';

/// Client for connecting to AI Service (Firebase Cloud Functions or Python Server)
///
/// Provides:
/// - AI-powered alert scoring
/// - Semantic duplicate detection
/// - Notification timing optimization
/// - Hazard zone prediction
///
/// Supports two modes:
/// - Firebase Cloud Functions (production)
/// - Local Python server (development)
class AIServiceClient {
  final Dio _dio;
  final String baseUrl;
  final bool useFirebase;

  AIServiceClient({
    required this.baseUrl,
    this.useFirebase = useFirebaseFunctions,
  }) : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: Duration(milliseconds: aiServiceConnectTimeout),
          receiveTimeout: Duration(milliseconds: aiServiceReceiveTimeout),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ));

  /// Get endpoint path based on service type
  String _getEndpoint(String firebaseEndpoint, String pythonEndpoint) {
    return useFirebase ? firebaseEndpoint : pythonEndpoint;
  }

  /// Get AI-powered priority score for an alert
  Future<AIScoreResult> getAlertScore(
    AlertEntity alert, {
    required double? userLat,
    required double? userLng,
    required String userRole,
  }) async {
    try {
      // Firebase: /score_alert, Python: /api/v1/score
      final endpoint = _getEndpoint('/score_alert', '/api/v1/score');
      
      final response = await _dio.post(
        endpoint,
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
      // Firebase: /recommend_timing, Python: /api/v1/timing/recommend
      final endpoint = _getEndpoint('/recommend_timing', '/api/v1/timing/recommend');
      
      final response = await _dio.post(
        endpoint,
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
      // Firebase: /log_engagement, Python: /api/v1/feedback/engagement
      final endpoint = _getEndpoint('/log_engagement', '/api/v1/feedback/engagement');
      
      await _dio.post(
        endpoint,
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
      // Firebase: /health_check, Python: /api/v1/health
      final endpoint = _getEndpoint('/health_check', '/api/v1/health');
      
      final response = await _dio.get(endpoint);
      return response.statusCode == 200 &&
          response.data['status'] == 'healthy';
    } catch (e) {
      debugPrint('[AIService] Health check failed: $e');
      return false;
    }
  }

  /// Get predicted hazard zones for map display
  Future<HazardZonesResult> getHazardZones({
    String? province,
    int? month,
    String? hazardType,
    int minRisk = 2,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/hazard/zones',
        queryParameters: {
          if (province != null) 'province': province,
          if (month != null) 'month': month,
          if (hazardType != null) 'hazard_type': hazardType,
          'min_risk': minRisk,
        },
      );

      return HazardZonesResult.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('[AIService] DioException in getHazardZones: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[AIService] Error getting hazard zones: $e');
      rethrow;
    }
  }

  /// Predict hazard risk for a specific location
  Future<HazardPrediction> predictHazardRisk({
    required double lat,
    required double lng,
    int? month,
    String hazardType = 'flood',
    bool includeWeather = true, // NEW: Include real-time weather
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/hazard/predict',
        data: {
          'lat': lat,
          'lng': lng,
          if (month != null) 'month': month,
          'hazard_type': hazardType,
          'include_weather': includeWeather, // NEW
        },
      );

      return HazardPrediction.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('[AIService] DioException in predictHazardRisk: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[AIService] Error predicting hazard: $e');
      rethrow;
    }
  }

  /// Predict weather for next day using AI model
  Future<WeatherPrediction> predictWeather({
    required String date, // YYYY-MM-DD
    required int provinceId,
    int regionId = 1,
    double currentTemp = 30.0,
    double currentHumid = 75.0,
    double currentRain = 0.0,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/weather/predict',
        data: {
          'date': date,
          'province_id': provinceId,
          'region_id': regionId,
          'current_temp': currentTemp,
          'current_humid': currentHumid,
          'current_rain': currentRain,
        },
      );

      return WeatherPrediction.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('[AIService] DioException in predictWeather: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[AIService] Error predicting weather: $e');
      rethrow;
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

/// Result from hazard zones API
class HazardZonesResult {
  final int total;
  final int? month;
  final List<HazardZone> zones;

  HazardZonesResult({
    required this.total,
    this.month,
    required this.zones,
  });

  factory HazardZonesResult.fromJson(Map<String, dynamic> json) {
    return HazardZonesResult(
      total: json['total'] ?? 0,
      month: json['month'],
      zones: (json['zones'] as List)
          .map((z) => HazardZone.fromJson(z))
          .toList(),
    );
  }
}

/// Hazard zone for map display
class HazardZone {
  final String id;
  final double lat;
  final double lng;
  final double radiusKm;
  final String hazardType;
  final int riskLevel;
  final String description;

  HazardZone({
    required this.id,
    required this.lat,
    required this.lng,
    required this.radiusKm,
    required this.hazardType,
    required this.riskLevel,
    required this.description,
  });

  factory HazardZone.fromJson(Map<String, dynamic> json) {
    return HazardZone(
      id: json['id'] ?? '',
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      radiusKm: (json['radius_km'] as num).toDouble(),
      hazardType: json['hazard_type'] ?? 'unknown',
      riskLevel: json['risk_level'] ?? 1,
      description: json['description'] ?? '',
    );
  }
}

/// Hazard prediction result
class HazardPrediction {
  final double lat;
  final double lng;
  final int riskLevel;
  final String riskLabel;
  final double confidence;
  final String hazardType;
  final int month;
  final String province;
  final String explanation;
  final WeatherData? currentWeather; // NEW
  final ForecastData? forecast; // NEW

  HazardPrediction({
    required this.lat,
    required this.lng,
    required this.riskLevel,
    required this.riskLabel,
    required this.confidence,
    required this.hazardType,
    required this.month,
    required this.province,
    required this.explanation,
    this.currentWeather,
    this.forecast,
  });

  factory HazardPrediction.fromJson(Map<String, dynamic> json) {
    return HazardPrediction(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      riskLevel: json['risk_level'] ?? 1,
      riskLabel: json['risk_label'] ?? 'unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
      hazardType: json['hazard_type'] ?? 'unknown',
      month: json['month'] ?? DateTime.now().month,
      province: json['province'] ?? 'Unknown',
      explanation: json['explanation'] ?? '',
      currentWeather: json['current_weather'] != null
          ? WeatherData.fromJson(json['current_weather'])
          : null,
      forecast: json['forecast'] != null
          ? ForecastData.fromJson(json['forecast'])
          : null,
    );
  }
}

/// Current weather data
class WeatherData {
  final double? temperature;
  final double? precipitation;
  final double? rain;
  final double? windSpeed;
  final double? windGusts;
  final double? humidity;
  final double? cloudCover;
  final double? pressure;

  WeatherData({
    this.temperature,
    this.precipitation,
    this.rain,
    this.windSpeed,
    this.windGusts,
    this.humidity,
    this.cloudCover,
    this.pressure,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: (json['temperature'] as num?)?.toDouble(),
      precipitation: (json['precipitation'] as num?)?.toDouble(),
      rain: (json['rain'] as num?)?.toDouble(),
      windSpeed: (json['wind_speed'] as num?)?.toDouble(),
      windGusts: (json['wind_gusts'] as num?)?.toDouble(),
      humidity: (json['humidity'] as num?)?.toDouble(),
      cloudCover: (json['cloud_cover'] as num?)?.toDouble(),
      pressure: (json['pressure'] as num?)?.toDouble(),
    );
  }
}

/// Weather forecast data
class ForecastData {
  final int days;
  final double totalPrecipitation;
  final double maxTemperature;
  final double minTemperature;
  final double maxWind;

  ForecastData({
    required this.days,
    required this.totalPrecipitation,
    required this.maxTemperature,
    required this.minTemperature,
    required this.maxWind,
  });

  factory ForecastData.fromJson(Map<String, dynamic> json) {
    return ForecastData(
      days: json['days'] ?? 7,
      totalPrecipitation: (json['total_precipitation'] as num?)?.toDouble() ?? 0,
      maxTemperature: (json['max_temperature'] as num?)?.toDouble() ?? 0,
      minTemperature: (json['min_temperature'] as num?)?.toDouble() ?? 0,
      maxWind: (json['max_wind'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// AI weather prediction for next day
class WeatherPrediction {
  final String date;
  final double temperature;
  final double humidity;
  final double rainfall;
  final String? note;

  WeatherPrediction({
    required this.date,
    required this.temperature,
    required this.humidity,
    required this.rainfall,
    this.note,
  });

  factory WeatherPrediction.fromJson(Map<String, dynamic> json) {
    return WeatherPrediction(
      date: json['date'] ?? '',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 30.0,
      humidity: (json['humidity'] as num?)?.toDouble() ?? 75.0,
      rainfall: (json['rainfall'] as num?)?.toDouble() ?? 0.0,
      note: json['note'],
    );
  }

  /// Convert to WeatherData format for display
  WeatherData toWeatherData() {
    return WeatherData(
      temperature: temperature,
      humidity: humidity,
      precipitation: rainfall,
      rain: rainfall,
    );
  }
}
