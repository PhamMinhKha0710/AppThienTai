
/* -- LIST OF Constants used in APIs -- */

// Example
const String tSecretAPIKey = "cwt_live_b2da6ds3df3e785v8ddc59198f7615ba";

// =====================================================
// AI Service Configuration
// =====================================================

/// Base URL for AI Service
/// Development: http://localhost:8000
/// Production: Update with deployed AI service URL
const String aiServiceBaseUrl = 'http://localhost:8000';

/// API version for AI service endpoints
const String aiServiceApiVersion = '/api/v1';

/// Connection timeout for AI service requests (milliseconds)
const int aiServiceConnectTimeout = 10000;

/// Receive timeout for AI service requests (milliseconds)
const int aiServiceReceiveTimeout = 10000;

/// Feature flag to enable/disable AI-powered scoring
/// Set to false to use only rule-based scoring
const bool enableAiScoring = true;

/// Whether to fallback to rule-based scoring when AI service fails
/// Recommended: true for production to ensure service continuity
const bool aiFallbackToRules = true;

/// Duplicate detection similarity threshold (0.0 to 1.0)
/// Higher = stricter matching, Lower = more duplicates detected
const double duplicateSimilarityThreshold = 0.85;

/// Health check interval for AI service (seconds)
/// Service will periodically check if AI is available
const int aiHealthCheckIntervalSeconds = 60;














