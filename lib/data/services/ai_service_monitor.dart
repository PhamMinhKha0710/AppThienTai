import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cuutrobaolu/data/services/ai_service_client.dart';
import 'package:cuutrobaolu/core/constants/api_constants.dart';

/// AI Service Health Monitor
///
/// Monitors the health and availability of the AI service.
/// Tracks metrics like response time, error rate, and availability.
class AIServiceMonitor {
  final AIServiceClient _aiService;
  Timer? _healthCheckTimer;
  
  // Health status
  bool _isHealthy = false;
  DateTime? _lastHealthCheck;
  DateTime? _lastSuccessfulCheck;
  
  // Metrics
  int _totalRequests = 0;
  int _successfulRequests = 0;
  int _failedRequests = 0;
  final List<Duration> _responseTimes = [];
  
  // Callbacks
  final void Function(bool isHealthy)? onHealthStatusChanged;
  
  AIServiceMonitor({
    required AIServiceClient aiService,
    this.onHealthStatusChanged,
  }) : _aiService = aiService;
  
  /// Current health status
  bool get isHealthy => _isHealthy;
  
  /// Last health check time
  DateTime? get lastHealthCheck => _lastHealthCheck;
  
  /// Last successful check time
  DateTime? get lastSuccessfulCheck => _lastSuccessfulCheck;
  
  /// Total requests made
  int get totalRequests => _totalRequests;
  
  /// Success rate (0.0 to 1.0)
  double get successRate {
    if (_totalRequests == 0) return 0.0;
    return _successfulRequests / _totalRequests;
  }
  
  /// Error rate (0.0 to 1.0)
  double get errorRate {
    if (_totalRequests == 0) return 0.0;
    return _failedRequests / _totalRequests;
  }
  
  /// Average response time
  Duration? get averageResponseTime {
    if (_responseTimes.isEmpty) return null;
    final total = _responseTimes.fold<int>(
      0, 
      (sum, duration) => sum + duration.inMilliseconds,
    );
    return Duration(milliseconds: total ~/ _responseTimes.length);
  }
  
  /// Start periodic health checking
  void startMonitoring() {
    // Perform initial health check
    checkHealth();
    
    // Schedule periodic checks
    _healthCheckTimer = Timer.periodic(
      Duration(seconds: aiHealthCheckIntervalSeconds),
      (_) => checkHealth(),
    );
    
    debugPrint('[AIServiceMonitor] Started monitoring');
  }
  
  /// Stop periodic health checking
  void stopMonitoring() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = null;
    debugPrint('[AIServiceMonitor] Stopped monitoring');
  }
  
  /// Perform a health check
  Future<void> checkHealth() async {
    final startTime = DateTime.now();
    _lastHealthCheck = startTime;
    
    try {
      final isHealthy = await _aiService.healthCheck();
      final responseTime = DateTime.now().difference(startTime);
      
      _recordMetric(
        success: isHealthy,
        responseTime: responseTime,
      );
      
      if (isHealthy) {
        _lastSuccessfulCheck = DateTime.now();
      }
      
      // Update health status
      if (_isHealthy != isHealthy) {
        _isHealthy = isHealthy;
        onHealthStatusChanged?.call(_isHealthy);
        debugPrint('[AIServiceMonitor] Health status changed: ${_isHealthy ? "HEALTHY" : "UNHEALTHY"}');
      }
    } catch (e) {
      final responseTime = DateTime.now().difference(startTime);
      _recordMetric(
        success: false,
        responseTime: responseTime,
      );
      
      if (_isHealthy) {
        _isHealthy = false;
        onHealthStatusChanged?.call(_isHealthy);
        debugPrint('[AIServiceMonitor] Health check failed: $e');
      }
    }
  }
  
  /// Record a metric
  void _recordMetric({
    required bool success,
    required Duration responseTime,
  }) {
    _totalRequests++;
    
    if (success) {
      _successfulRequests++;
    } else {
      _failedRequests++;
    }
    
    _responseTimes.add(responseTime);
    
    // Keep only last 100 response times to prevent memory bloat
    if (_responseTimes.length > 100) {
      _responseTimes.removeAt(0);
    }
  }
  
  /// Record an external request metric (for when AI service is used)
  void recordRequest({required bool success, required Duration responseTime}) {
    _recordMetric(success: success, responseTime: responseTime);
  }
  
  /// Get detailed statistics
  Map<String, dynamic> getStatistics() {
    return {
      'isHealthy': _isHealthy,
      'lastHealthCheck': _lastHealthCheck?.toIso8601String(),
      'lastSuccessfulCheck': _lastSuccessfulCheck?.toIso8601String(),
      'totalRequests': _totalRequests,
      'successfulRequests': _successfulRequests,
      'failedRequests': _failedRequests,
      'successRate': successRate,
      'errorRate': errorRate,
      'averageResponseTime': averageResponseTime?.inMilliseconds,
    };
  }
  
  /// Reset all metrics
  void resetMetrics() {
    _totalRequests = 0;
    _successfulRequests = 0;
    _failedRequests = 0;
    _responseTimes.clear();
    debugPrint('[AIServiceMonitor] Metrics reset');
  }
  
  /// Dispose resources
  void dispose() {
    stopMonitoring();
  }
}




















