# AI Service Integration Guide

## Overview

This document describes the integration between the Flutter app and the Python AI Service for intelligent alert scoring, duplicate detection, and notification timing optimization.

## Architecture

```
┌─────────────────────────────────────┐
│       Flutter App (Dart)            │
│                                     │
│  ┌─────────────────────────────┐   │
│  │  Controllers/UI             │   │
│  └──────────┬──────────────────┘   │
│             │                       │
│  ┌──────────▼──────────────────┐   │
│  │  HybridAlertScoringService  │   │
│  │  (AI + Rule-based Fallback) │   │
│  └──┬──────────────────────┬───┘   │
│     │                      │        │
│  ┌──▼───────────┐   ┌─────▼──────┐│
│  │AIServiceClient│   │RuleService ││
│  └──┬────────────┘   └────────────┘│
│     │ HTTP/REST                     │
└─────┼───────────────────────────────┘
      │
┌─────▼───────────────────────────────┐
│  Python AI Service (FastAPI)        │
│                                     │
│  - Alert Scorer (ML)                │
│  - Duplicate Detector (Semantic)    │
│  - Notification Timing (Bandit)     │
└─────────────────────────────────────┘
```

## Components

### 1. Flutter App Components

#### AIServiceClient
**Location:** `lib/data/services/ai_service_client.dart`

HTTP client for communicating with the Python AI service.

**Key Methods:**
- `getAlertScore()` - Get AI-powered priority score for an alert
- `checkDuplicate()` - Check if alert is duplicate using semantic similarity
- `getNotificationTiming()` - Get recommended notification time
- `logEngagement()` - Log user engagement for AI learning
- `healthCheck()` - Check if AI service is available

#### HybridAlertScoringService
**Location:** `lib/domain/services/hybrid_alert_scoring_service.dart`

Combines AI-powered scoring (primary) with rule-based scoring (fallback).

**Strategy:**
1. Try AI service first for ML-based scoring
2. If AI fails (network, timeout, error), fallback to rule-based
3. Log AI predictions for continuous improvement

**Key Methods:**
- `calculateScoredAlert()` - Calculate scored alert using hybrid approach
- `scoreMultipleAlerts()` - Batch score multiple alerts
- `isAIServiceAvailable()` - Check AI service health
- `logAlertEngagement()` - Log user engagement with alert
- `isDuplicate()` - Check if alert is duplicate using AI

#### AIServiceMonitor
**Location:** `lib/data/services/ai_service_monitor.dart`

Monitors AI service health and tracks metrics.

**Features:**
- Periodic health checking (configurable interval)
- Tracks success/error rates
- Measures average response time
- Callback for health status changes

#### EngagementTracker
**Location:** `lib/data/services/engagement_tracker.dart`

Tracks user interactions with alerts for AI learning.

**Actions Tracked:**
- `view` - User viewed alert details
- `dismiss` - User dismissed/closed alert
- `share` - User shared alert
- `report` - User reported alert
- `click` - User clicked on alert for more details

### 2. Python AI Service Components

#### Alert Scorer
**Location:** `ai_service/models/alert_scorer.py`

Random Forest classifier for alert priority scoring.

**Features:**
- 15 engineered features from alert data
- Cold start with synthetic data
- Online learning from user feedback
- Confidence estimation

#### Duplicate Detector
**Location:** `ai_service/models/duplicate_detector.py`

Semantic similarity using Sentence Transformers.

**Features:**
- Multilingual model (paraphrase-multilingual-MiniLM-L12-v2)
- Cosine similarity threshold (default: 0.85)
- Caching for performance

#### Notification Timing
**Location:** `ai_service/models/notification_timing.py`

Contextual Bandit for optimal notification timing.

**Features:**
- Thompson Sampling algorithm
- 24 time slots (hourly)
- Learns from user engagement patterns
- Epsilon-greedy exploration

## Configuration

### Flutter App Configuration

**File:** `lib/core/constants/api_constants.dart`

```dart
/// Base URL for AI Service
const String aiServiceBaseUrl = 'http://localhost:8000'; // Dev
// const String aiServiceBaseUrl = 'https://your-ai-service.com'; // Prod

/// Feature flag to enable/disable AI-powered scoring
const bool enableAiScoring = true;

/// Whether to fallback to rule-based scoring when AI service fails
const bool aiFallbackToRules = true;

/// Duplicate detection similarity threshold (0.0 to 1.0)
const double duplicateSimilarityThreshold = 0.85;

/// Health check interval for AI service (seconds)
const int aiHealthCheckIntervalSeconds = 60;
```

### Python Service Configuration

**File:** `ai_service/config.py`

```python
# API configurations
API_HOST = os.getenv("API_HOST", "0.0.0.0")
API_PORT = int(os.getenv("API_PORT", "8000"))

# Model configurations
SENTENCE_TRANSFORMER_MODEL = "paraphrase-multilingual-MiniLM-L12-v2"
DUPLICATE_SIMILARITY_THRESHOLD = 0.85

# Random Forest configurations
RF_N_ESTIMATORS = 100
RF_MAX_DEPTH = 10

# Notification timing configurations
N_TIME_SLOTS = 24
EPSILON_EXPLORATION = 0.1
```

## Setup Instructions

### 1. Start AI Service (Development)

```bash
cd ai_service

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Start service
python main.py
```

The service will be available at `http://localhost:8000`

### 2. Start AI Service (Production - Docker)

```bash
cd ai_service

# Build and run with Docker Compose
docker-compose up -d

# View logs
docker-compose logs -f

# Stop service
docker-compose down
```

### 3. Configure Flutter App

1. Update `lib/core/constants/api_constants.dart` with your AI service URL
2. Set `enableAiScoring = true` to enable AI features
3. Run the app:
   ```bash
   flutter run
   ```

## API Endpoints

### Alert Scoring
```
POST /api/v1/score
```
**Request:**
```json
{
  "alert_id": "alert-123",
  "severity": "high",
  "alert_type": "weather",
  "content": "Heavy rain expected",
  "province": "TP.HCM",
  "district": "Quận 1",
  "lat": 10.762622,
  "lng": 106.660172,
  "created_at": "2024-01-15T10:00:00Z",
  "user_lat": 10.762622,
  "user_lng": 106.660172,
  "user_role": "victim"
}
```
**Response:**
```json
{
  "alert_id": "alert-123",
  "priority_score": 85.5,
  "confidence": 0.92,
  "explanation": {
    "severity_weight": 35,
    "distance_weight": 20,
    "recency_weight": 15
  }
}
```

### Duplicate Detection
```
POST /api/v1/duplicate/check
```
**Request:**
```json
{
  "new_alert": {
    "id": "alert-new",
    "content": "Flooding in district 1",
    "alert_type": "weather",
    "severity": "high"
  },
  "existing_alerts": [
    {
      "id": "alert-old",
      "content": "Heavy flooding in D1",
      "alert_type": "weather",
      "severity": "high"
    }
  ],
  "threshold": 0.85
}
```
**Response:**
```json
{
  "is_duplicate": true,
  "duplicates": [
    {
      "alert": {
        "id": "alert-old"
      },
      "similarity": 0.92
    }
  ],
  "best_match": {
    "alert": {
      "id": "alert-old"
    },
    "similarity": 0.92
  }
}
```

### Health Check
```
GET /api/v1/health
```
**Response:**
```json
{
  "status": "healthy",
  "version": "1.0.0",
  "models": {
    "alert_scorer": "loaded",
    "duplicate_detector": "loaded",
    "notification_timing": "loaded"
  }
}
```

## Testing

### Run Flutter Tests

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/data/services/hybrid_alert_scoring_service_test.dart

# Run with coverage
flutter test --coverage
```

### Run Python Tests

```bash
cd ai_service

# Run all tests
pytest

# Run with coverage
pytest --cov=. --cov-report=html

# Run specific test
pytest tests/test_api.py -k test_score_endpoint
```

## Monitoring

### Check AI Service Status

The `AIServiceMonitor` runs periodic health checks and tracks metrics:

```dart
final monitor = getIt<AIServiceMonitor>();

print('AI Service Status:');
print('Healthy: ${monitor.isHealthy}');
print('Success Rate: ${(monitor.successRate * 100).toStringAsFixed(1)}%');
print('Avg Response Time: ${monitor.averageResponseTime?.inMilliseconds}ms');
```

### View Metrics

AI service metrics are available at:
```
GET /api/v1/stats/engagement
GET /api/v1/stats/duplicate
GET /api/v1/stats/timing
```

## Troubleshooting

### AI Service Not Available

**Symptom:** Alerts show rule-based scores only

**Solutions:**
1. Check if AI service is running: `curl http://localhost:8000/api/v1/health`
2. Check `aiServiceBaseUrl` in `api_constants.dart`
3. Check firewall/network settings
4. Review `AIServiceMonitor` logs in Flutter app

### Slow Response Times

**Symptom:** App feels laggy when scoring alerts

**Solutions:**
1. AI service automatically falls back to rule-based after 10s timeout
2. Consider deploying AI service closer to users
3. Enable caching in AI service for frequently scored alerts
4. Use batch scoring: `scoreMultipleAlerts()` instead of individual calls

### High Error Rates

**Symptom:** `AIServiceMonitor` shows high error rate

**Solutions:**
1. Check AI service logs: `docker-compose logs -f`
2. Verify model files are loaded correctly
3. Check system resources (CPU, memory)
4. Consider scaling AI service horizontally

## Best Practices

1. **Always Enable Fallback:** Keep `aiFallbackToRules = true` to ensure service continuity
2. **Monitor Health:** Regularly check `AIServiceMonitor` metrics
3. **Log Engagement:** Use `EngagementTracker` to improve AI model accuracy over time
4. **Batch Operations:** Use `scoreMultipleAlerts()` for better performance
5. **Test Fallback:** Regularly test that rule-based fallback works correctly
6. **Update Models:** Retrain AI models periodically with new feedback data

## Performance Considerations

### Flutter App
- Rule-based scoring is synchronous and instant
- AI scoring is async with 10s timeout
- Hybrid service uses caching for recently scored alerts

### Python Service
- First request may be slow (model loading)
- Subsequent requests benefit from caching
- Semantic similarity calculation is GPU-accelerated if available

## Security

1. **Production Deployment:**
   - Use HTTPS for AI service
   - Implement API key authentication
   - Rate limiting on endpoints
   - Input validation and sanitization

2. **Data Privacy:**
   - Alert content is sent to AI service for scoring
   - User IDs are anonymized for engagement tracking
   - No personal information is stored in AI service

## Future Enhancements

- [ ] Background scoring with result caching
- [ ] Multi-language support for duplicate detection
- [ ] Advanced features: image analysis, source credibility scoring
- [ ] Federated learning for privacy-preserving model updates
- [ ] Real-time model updates without app restart

## Support

For issues or questions:
- Check logs: Flutter (debugPrint) and Python (uvicorn logs)
- Review test files for usage examples
- Consult API documentation: `http://localhost:8000/docs`




















