# API Integration Examples

> **Code examples và hướng dẫn tích hợp Ground Truth System và AI Services vào ứng dụng**

## 📋 Mục Lục

- [Official Data Source Integration](#official-data-source-integration)
- [Source Validator Implementation](#source-validator-implementation)
- [Ground Truth Collector](#ground-truth-collector)
- [Expert Review APIs](#expert-review-apis)
- [Flutter Client Examples](#flutter-client-examples)

---

## Official Data Source Integration

### NCHMF Weather API Integration

```python
# ai_service/services/nchmf_client.py

import requests
from bs4 import BeautifulSoup
from datetime import datetime
from typing import List, Dict

class NCHMFClient:
    """
    Client for Vietnam National Center for Hydro-Meteorological Forecasting
    """
    
    BASE_URL = "http://nchmf.gov.vn"
    TIMEOUT = 30
    
    def __init__(self):
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'DisasterAlertSystem/1.0'
        })
    
    def get_weather_warnings(self) -> List[Dict]:
        """
        Fetch current weather warnings
        
        Returns:
            List of warnings with structure:
            {
                'id': str,
                'title': str,
                'content': str,
                'severity': int (1-5),
                'provinces': List[str],
                'issued_at': datetime,
                'expires_at': datetime,
                'warning_type': str
            }
        """
        try:
            response = self.session.get(
                f"{self.BASE_URL}/KttvsWeb/vi-VN/1/index.html",
                timeout=self.TIMEOUT
            )
            response.raise_for_status()
            
            return self._parse_warnings(response.text)
            
        except requests.RequestException as e:
            print(f"Error fetching NCHMF data: {e}")
            return []
    
    def _parse_warnings(self, html: str) -> List[Dict]:
        """Parse HTML to extract warnings"""
        soup = BeautifulSoup(html, 'html.parser')
        warnings = []
        
        # Find warning elements (adjust selectors based on actual site)
        warning_items = soup.select('.canh-bao-item')
        
        for item in warning_items:
            try:
                warning = {
                    'id': self._generate_warning_id(item),
                    'title': item.select_one('.title').get_text(strip=True),
                    'content': item.select_one('.content').get_text(strip=True),
                    'severity': self._extract_severity(item),
                    'provinces': self._extract_provinces(item),
                    'issued_at': self._extract_date(item),
                    'expires_at': self._extract_expiry(item),
                    'warning_type': self._classify_warning_type(item),
                    'source': 'NCHMF',
                    'source_reliability': 1.0,
                    'official_id': f"NCHMF_{datetime.now().timestamp()}"
                }
                warnings.append(warning)
            except Exception as e:
                print(f"Error parsing warning item: {e}")
                continue
        
        return warnings
    
    def _extract_severity(self, element) -> int:
        """Extract severity level (1-5)"""
        # Look for severity indicators
        text = element.get_text().lower()
        
        if any(word in text for word in ['đặc biệt nguy hiểm', 'rất nguy hiểm']):
            return 5
        elif any(word in text for word in ['nguy hiểm', 'nghiêm trọng']):
            return 4
        elif any(word in text for word in ['cao', 'mạnh']):
            return 3
        elif any(word in text for word in ['trung bình', 'vừa']):
            return 2
        else:
            return 1
    
    def _extract_provinces(self, element) -> List[str]:
        """Extract affected provinces"""
        content = element.get_text()
        
        # List of provinces
        provinces = [
            'Hà Nội', 'Hồ Chí Minh', 'Đà Nẵng', 'Quảng Bình', 'Quảng Trị',
            'Thừa Thiên Huế', 'Quảng Nam', 'Quảng Ngãi', 'Bình Định',
            # Add all 63 provinces...
        ]
        
        found_provinces = []
        for province in provinces:
            if province in content:
                found_provinces.append(province)
        
        return found_provinces
    
    def normalize_to_alert_format(self, warning: Dict) -> Dict:
        """Convert NCHMF warning to standard alert format"""
        return {
            'source': 'NCHMF',
            'source_reliability': 1.0,
            'official_id': warning['id'],
            'title': warning['title'],
            'content': warning['content'],
            'severity': self._map_severity_level(warning['severity']),
            'alert_type': self._map_warning_type(warning['warning_type']),
            'provinces': warning['provinces'],
            'created_at': warning['issued_at'].isoformat(),
            'expires_at': warning['expires_at'].isoformat() if warning['expires_at'] else None,
            'verified': True,
            'requires_validation': False
        }
```

### Usage Example

```python
# Example: Fetch and store NCHMF warnings

from services.nchmf_client import NCHMFClient
from services.ground_truth_collector import GroundTruthCollector

def sync_nchmf_warnings():
    """
    Sync warnings from NCHMF to our database
    """
    client = NCHMFClient()
    collector = GroundTruthCollector()
    
    # Fetch warnings
    warnings = client.get_weather_warnings()
    print(f"Fetched {len(warnings)} warnings from NCHMF")
    
    # Process each warning
    for warning in warnings:
        # Normalize format
        alert = client.normalize_to_alert_format(warning)
        
        # Store as ground truth (high confidence)
        collector.add_ground_truth(
            alert_id=alert['official_id'],
            predicted_score=None,  # No prediction, this is ground truth
            official=True,
            official_source_name='NCHMF'
        )
        
        print(f"✓ Stored warning: {alert['title']}")

# Run daily via cron
if __name__ == "__main__":
    sync_nchmf_warnings()
```

---

## Source Validator Implementation

### Complete Validator with All Checks

```python
# ai_service/services/complete_validator.py

class CompleteSourceValidator:
    """
    Production-ready source validator with all checks
    """
    
    def __init__(self):
        self.source_validator = SourceValidator()
        self.content_validator = ContentValidator()
        self.cross_ref_verifier = CrossReferenceVerifier()
        self.historical_matcher = HistoricalPatternMatcher()
        self.confidence_calc = ConfidenceCalculator()
    
    async def validate_alert_complete(
        self,
        alert: Dict,
        existing_alerts: List[Dict]
    ) -> Dict:
        """
        Complete validation pipeline
        
        Returns:
            {
                'is_valid': bool,
                'confidence': float,
                'validation_results': dict,
                'decision': str ('approve', 'review', 'reject')
            }
        """
        results = {}
        
        # Step 1: Source verification
        results['source'] = self.source_validator.verify_source(alert)
        if not results['source']['is_valid']:
            return self._reject_result("Invalid source", results)
        
        # Step 2: Content validation
        results['content'] = self.content_validator.validate_content(alert)
        if not results['content']['is_valid']:
            return self._reject_result("Invalid content", results)
        
        # Step 3: Cross-reference check (async)
        results['cross_references'] = await self.cross_ref_verifier.find_cross_references_async(
            alert, existing_alerts
        )
        
        # Step 4: Historical pattern matching
        results['historical'] = self.historical_matcher.check_pattern(alert)
        
        # Step 5: Calculate final confidence
        confidence_result = self.confidence_calc.calculate_confidence(
            alert,
            results['source'],
            results['content'],
            results['cross_references'],
            results['historical']
        )
        
        return {
            'is_valid': True,
            'confidence': confidence_result['confidence_score'],
            'validation_results': results,
            'decision': confidence_result['decision'],
            'explanation': confidence_result['explanation']
        }
    
    def _reject_result(self, reason: str, partial_results: Dict) -> Dict:
        """Create rejection result"""
        return {
            'is_valid': False,
            'confidence': 0.0,
            'validation_results': partial_results,
            'decision': 'reject',
            'explanation': reason
        }
```

### FastAPI Endpoint

```python
# ai_service/api/routes/validation.py

from fastapi import APIRouter, HTTPException, BackgroundTasks
from pydantic import BaseModel
from typing import List, Optional

router = APIRouter(prefix="/api/v1/validation", tags=["validation"])

class AlertValidationRequest(BaseModel):
    alert: Dict
    check_cross_references: bool = True
    check_historical: bool = True

class ValidationResponse(BaseModel):
    alert_id: str
    is_valid: bool
    confidence: float
    decision: str
    explanation: str
    validation_details: Dict

@router.post("/validate", response_model=ValidationResponse)
async def validate_alert(
    request: AlertValidationRequest,
    background_tasks: BackgroundTasks
):
    """
    Validate a single alert
    """
    validator = CompleteSourceValidator()
    
    # Get existing alerts for cross-reference
    existing_alerts = []
    if request.check_cross_references:
        existing_alerts = await get_recent_alerts(hours=24)
    
    # Run validation
    result = await validator.validate_alert_complete(
        request.alert,
        existing_alerts
    )
    
    # Store validation result in background
    background_tasks.add_task(
        store_validation_result,
        request.alert.get('id'),
        result
    )
    
    return ValidationResponse(
        alert_id=request.alert.get('id', 'unknown'),
        is_valid=result['is_valid'],
        confidence=result['confidence'],
        decision=result['decision'],
        explanation=result['explanation'],
        validation_details=result['validation_results']
    )

@router.post("/batch-validate")
async def batch_validate_alerts(alerts: List[Dict]):
    """
    Validate multiple alerts in batch
    """
    validator = CompleteSourceValidator()
    existing_alerts = await get_recent_alerts(hours=24)
    
    results = []
    for alert in alerts:
        result = await validator.validate_alert_complete(alert, existing_alerts)
        results.append({
            'alert_id': alert.get('id'),
            'confidence': result['confidence'],
            'decision': result['decision']
        })
    
    return {
        'total': len(alerts),
        'validated': len([r for r in results if r['decision'] == 'approve']),
        'needs_review': len([r for r in results if r['decision'] == 'review']),
        'rejected': len([r for r in results if r['decision'] == 'reject']),
        'results': results
    }
```

---

## Ground Truth Collector

### Production-Ready Collector

```python
# ai_service/services/production_gt_collector.py

import sqlite3
from contextlib import contextmanager
from datetime import datetime
from typing import Optional, Dict

class ProductionGroundTruthCollector:
    """
    Production-grade ground truth collector with error handling
    """
    
    def __init__(self, db_path: str = "data/ground_truth.db"):
        self.db_path = db_path
        self._init_db()
    
    @contextmanager
    def get_db(self):
        """Context manager for database connections"""
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        try:
            yield conn
        finally:
            conn.close()
    
    def add_ground_truth(
        self,
        alert_id: str,
        predicted_score: Optional[float] = None,
        **validations
    ) -> bool:
        """
        Add or update ground truth entry
        
        Args:
            alert_id: Alert identifier
            predicted_score: Model's predicted score (if any)
            **validations: Validation data (official, expert, user_accurate, etc.)
        
        Returns:
            bool: Success status
        """
        try:
            with self.get_db() as conn:
                # Calculate composite ground truth score
                gt_score = self._calculate_ground_truth_score(validations)
                confidence = self._calculate_confidence(validations)
                
                # Upsert ground truth
                conn.execute("""
                    INSERT INTO ground_truth (
                        id, alert_id, predicted_score,
                        official_source_validation,
                        official_source_name,
                        expert_validation,
                        user_feedback_accurate,
                        user_feedback_inaccurate,
                        ground_truth_score,
                        confidence,
                        created_at,
                        updated_at
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    ON CONFLICT(alert_id) DO UPDATE SET
                        official_source_validation = excluded.official_source_validation,
                        expert_validation = excluded.expert_validation,
                        user_feedback_accurate = user_feedback_accurate + excluded.user_feedback_accurate,
                        user_feedback_inaccurate = user_feedback_inaccurate + excluded.user_feedback_inaccurate,
                        ground_truth_score = excluded.ground_truth_score,
                        confidence = excluded.confidence,
                        updated_at = excluded.updated_at
                """, (
                    str(uuid.uuid4()),
                    alert_id,
                    predicted_score,
                    validations.get('official'),
                    validations.get('official_source_name'),
                    validations.get('expert'),
                    validations.get('user_accurate', 0),
                    validations.get('user_inaccurate', 0),
                    gt_score,
                    confidence,
                    datetime.now(),
                    datetime.now()
                ))
                
                conn.commit()
                return True
                
        except Exception as e:
            print(f"Error adding ground truth: {e}")
            return False
    
    def get_training_data(
        self,
        min_confidence: float = 0.8,
        limit: Optional[int] = None
    ) -> List[Dict]:
        """
        Retrieve ground truth data suitable for training
        
        Args:
            min_confidence: Minimum confidence score
            limit: Maximum number of records
        
        Returns:
            List of ground truth records
        """
        query = """
            SELECT *
            FROM ground_truth
            WHERE confidence >= ?
            AND ground_truth_score IS NOT NULL
            ORDER BY confidence DESC, created_at DESC
        """
        
        if limit:
            query += f" LIMIT {limit}"
        
        with self.get_db() as conn:
            cursor = conn.execute(query, (min_confidence,))
            return [dict(row) for row in cursor.fetchall()]
    
    def get_statistics(self) -> Dict:
        """Get ground truth collection statistics"""
        with self.get_db() as conn:
            stats = conn.execute("""
                SELECT 
                    COUNT(*) as total_entries,
                    AVG(confidence) as avg_confidence,
                    SUM(CASE WHEN confidence >= 0.8 THEN 1 ELSE 0 END) as high_quality_count,
                    SUM(CASE WHEN official_source_validation = 1 THEN 1 ELSE 0 END) as official_validated,
                    SUM(CASE WHEN expert_validation = 1 THEN 1 ELSE 0 END) as expert_validated,
                    SUM(user_feedback_accurate + user_feedback_inaccurate) as total_user_feedback
                FROM ground_truth
            """).fetchone()
            
            return dict(stats)
```

---

## Expert Review APIs

### Flutter Integration for Expert Review

```dart
// lib/features/admin/data/datasources/review_remote_datasource.dart

class ReviewRemoteDataSource {
  final Dio _dio;
  
  ReviewRemoteDataSource(this._dio);
  
  /// Get pending reviews
  Future<List<AlertEntity>> getPendingReviews({
    double minConfidence = 0.5,
    double maxConfidence = 0.8,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/expert-review/pending',
        queryParameters: {
          'min_confidence': minConfidence,
          'max_confidence': maxConfidence,
          'limit': limit,
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['alerts'];
        return data.map((json) => AlertEntity.fromJson(json)).toList();
      } else {
        throw ServerException('Failed to fetch pending reviews');
      }
    } on DioError catch (e) {
      throw ServerException(e.message);
    }
  }
  
  /// Submit review decision
  Future<void> submitReview({
    required String alertId,
    required String decision,  // 'approve', 'reject', 'request_info'
    required String reviewerId,
    required String reviewerRole,
    String? notes,
    double? correctedScore,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/expert-review/submit',
        data: {
          'alert_id': alertId,
          'decision': decision,
          'reviewer_id': reviewerId,
          'reviewer_role': reviewerRole,
          'notes': notes,
          'corrected_score': correctedScore,
        },
      );
      
      if (response.statusCode != 200) {
        throw ServerException('Failed to submit review');
      }
    } on DioError catch (e) {
      throw ServerException(e.message);
    }
  }
  
  /// Get expert statistics
  Future<Map<String, dynamic>> getExpertStats(String expertId) async {
    try {
      final response = await _dio.get(
        '/api/v1/expert-review/stats/$expertId',
      );
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw ServerException('Failed to fetch stats');
      }
    } on DioError catch (e) {
      throw ServerException(e.message);
    }
  }
}
```

### Review Controller

```dart
// lib/features/admin/controllers/review_controller.dart

class ReviewController extends GetxController {
  final ReviewRemoteDataSource _dataSource;
  
  final RxList<AlertEntity> pendingReviews = <AlertEntity>[].obs;
  final RxInt pendingCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  ReviewController(this._dataSource);
  
  @override
  void onInit() {
    super.onInit();
    loadPendingReviews();
  }
  
  Future<void> loadPendingReviews() async {
    try {
      isLoading(true);
      errorMessage('');
      
      final reviews = await _dataSource.getPendingReviews();
      pendingReviews.assignAll(reviews);
      pendingCount(reviews.length);
      
    } catch (e) {
      errorMessage('Error loading reviews: $e');
    } finally {
      isLoading(false);
    }
  }
  
  Future<void> approveAlert(String alertId) async {
    try {
      await _dataSource.submitReview(
        alertId: alertId,
        decision: 'approve',
        reviewerId: await _getCurrentUserId(),
        reviewerRole: 'admin',
        notes: 'Approved via mobile app',
      );
      
      // Remove from pending list
      pendingReviews.removeWhere((alert) => alert.id == alertId);
      pendingCount(pendingCount.value - 1);
      
      Get.snackbar(
        'Success',
        'Alert approved successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to approve alert: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  Future<void> rejectAlert(String alertId, String reason) async {
    try {
      await _dataSource.submitReview(
        alertId: alertId,
        decision: 'reject',
        reviewerId: await _getCurrentUserId(),
        reviewerRole: 'admin',
        notes: reason,
      );
      
      pendingReviews.removeWhere((alert) => alert.id == alertId);
      pendingCount(pendingCount.value - 1);
      
      Get.snackbar(
        'Success',
        'Alert rejected',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to reject alert: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  Future<String> _getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid ?? 'unknown';
  }
}
```

---

## Flutter Client Examples

### Complete AI Service Client

```dart
// lib/data/services/complete_ai_service_client.dart

class CompleteAIServiceClient {
  final Dio _dio;
  final String baseUrl;
  
  CompleteAIServiceClient({
    required this.baseUrl,
  }) : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
          },
        ));
  
  /// Get alert score from AI
  Future<AIScoreResult> getAlertScore(AlertEntity alert) async {
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
          'user_lat': null,  // Get from user if available
          'user_lng': null,
          'user_role': 'victim',
        },
      );
      
      return AIScoreResult.fromJson(response.data);
      
    } on DioError catch (e) {
      throw AIServiceException('Failed to get score: ${e.message}');
    }
  }
  
  /// Check for duplicates
  Future<DuplicateCheckResult> checkDuplicate({
    required Map<String, dynamic> newAlert,
    required List<Map<String, dynamic>> existingAlerts,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/duplicate/check',
        data: {
          'new_alert': newAlert,
          'existing_alerts': existingAlerts,
        },
      );
      
      return DuplicateCheckResult.fromJson(response.data);
      
    } on DioError catch (e) {
      throw AIServiceException('Failed to check duplicates: ${e.message}');
    }
  }
  
  /// Submit user feedback
  Future<void> submitFeedback({
    required String alertId,
    required String feedbackType,
    Map<String, dynamic>? userLocation,
  }) async {
    try {
      await _dio.post(
        '/api/v1/feedback/submit',
        data: {
          'alert_id': alertId,
          'user_id': await _getUserId(),
          'feedback_type': feedbackType,
          'user_location': userLocation,
          'response_time_seconds': null,
        },
      );
    } on DioError catch (e) {
      print('Error submitting feedback: ${e.message}');
      // Don't throw - feedback is optional
    }
  }
  
  /// Health check
  Future<bool> healthCheck() async {
    try {
      final response = await _dio.get('/api/v1/health');
      return response.statusCode == 200 && 
             response.data['status'] == 'healthy';
    } catch (e) {
      return false;
    }
  }
  
  Future<String> _getUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid ?? 'anonymous';
  }
}

/// Exception for AI service errors
class AIServiceException implements Exception {
  final String message;
  AIServiceException(this.message);
  
  @override
  String toString() => 'AIServiceException: $message';
}
```

---

## Testing Examples

### Python Unit Tests

```python
# tests/test_ground_truth_collector.py

import pytest
from services.ground_truth_collector import GroundTruthCollector

class TestGroundTruthCollector:
    @pytest.fixture
    def collector(self):
        return GroundTruthCollector(db_path=":memory:")  # In-memory DB for testing
    
    def test_add_official_validation(self, collector):
        """Test adding official source validation"""
        success = collector.add_ground_truth(
            alert_id='test_alert_1',
            official=True,
            official_source_name='NCHMF'
        )
        
        assert success is True
        
        # Verify stored correctly
        data = collector.get_training_data(min_confidence=0.5)
        assert len(data) == 1
        assert data[0]['alert_id'] == 'test_alert_1'
        assert data[0]['confidence'] >= 0.9  # Official source = high confidence
    
    def test_aggregate_user_feedback(self, collector):
        """Test user feedback aggregation"""
        alert_id = 'test_alert_2'
        
        # Add multiple user feedbacks
        for _ in range(10):
            collector.add_ground_truth(
                alert_id=alert_id,
                user_accurate=1
            )
        
        for _ in range(2):
            collector.add_ground_truth(
                alert_id=alert_id,
                user_inaccurate=1
            )
        
        data = collector.get_training_data(min_confidence=0.5)
        entry = [d for d in data if d['alert_id'] == alert_id][0]
        
        # 10 accurate / 12 total = 0.83 accuracy
        assert entry['user_feedback_accurate'] == 10
        assert entry['user_feedback_inaccurate'] == 2
```

### Flutter Integration Tests

```dart
// test/integration/ai_service_integration_test.dart

void main() {
  group('AI Service Integration Tests', () {
    late CompleteAIServiceClient client;
    
    setUp(() {
      client = CompleteAIServiceClient(
        baseUrl: 'http://localhost:8000',
      );
    });
    
    test('should get alert score successfully', () async {
      final alert = AlertEntity(
        id: 'test_1',
        title: 'Test Alert',
        content: 'Test content',
        severity: AlertSeverity.medium,
        alertType: AlertType.weather,
        province: 'Ho Chi Minh',
        createdAt: DateTime.now(),
        targetAudience: AlertAudience.all,
      );
      
      final result = await client.getAlertScore(alert);
      
      expect(result.priorityScore, greaterThan(0));
      expect(result.priorityScore, lessThanOrEqual(100));
      expect(result.confidence, greaterThan(0));
    });
    
    test('should check for duplicates', () async {
      final newAlert = {
        'content': 'Flood warning in District 1',
        'province': 'Ho Chi Minh',
        'alert_type': 'flood',
      };
      
      final existingAlerts = [
        {
          'content': 'Flooding in District 1',
          'province': 'Ho Chi Minh',
          'alert_type': 'flood',
        }
      ];
      
      final result = await client.checkDuplicate(
        newAlert: newAlert,
        existingAlerts: existingAlerts,
      );
      
      expect(result.isDuplicate, isTrue);
      expect(result.duplicates, isNotEmpty);
    });
  });
}
```

---

## Best Practices Summary

### API Integration

1. **Error Handling**: Always wrap API calls in try-catch
2. **Timeouts**: Set appropriate timeouts (10s connect, 30s read)
3. **Retry Logic**: Implement exponential backoff for failures
4. **Caching**: Cache responses when appropriate
5. **Monitoring**: Log all API calls and errors

### Security

1. **API Keys**: Never hardcode, use environment variables
2. **HTTPS**: Always use HTTPS in production
3. **Authentication**: Implement proper auth headers
4. **Rate Limiting**: Respect API rate limits
5. **Input Validation**: Validate all inputs before API calls

### Performance

1. **Batch Requests**: Batch multiple requests when possible
2. **Async/Await**: Use async operations for non-blocking calls
3. **Connection Pooling**: Reuse HTTP connections
4. **Pagination**: Use pagination for large datasets
5. **Compression**: Enable gzip compression

---

**Back to**: [Main Documentation →](./README_GROUND_TRUTH.md)

**Last Updated**: 2025-01-01  
**Version**: 1.0.0




















