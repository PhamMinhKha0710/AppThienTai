
/* -- LIST OF Constants used in APIs -- */

// Example
const String tSecretAPIKey = "cwt_live_b2da6ds3df3e785v8ddc59198f7615ba";

// =====================================================
// AI Service Configuration - Firebase Cloud Functions
// =====================================================

/// Firebase Project ID
const String firebaseProjectId = 'cuutrobaolu';

/// Firebase Cloud Functions region
const String firebaseFunctionsRegion = 'us-central1';

/// Base URL for AI Service (Firebase Cloud Functions)
/// Format: https://<region>-<project-id>.cloudfunctions.net
/// 
/// Development: Use localhost:8000 with Python server
/// Production: Use Firebase Cloud Functions URL
const String aiServiceBaseUrl = 
    'https://$firebaseFunctionsRegion-$firebaseProjectId.cloudfunctions.net';

/// Development URL for local Python server
/// Use 10.0.2.2 for Android Emulator, localhost for iOS/Desktop
const String aiServiceDevUrl = 'http://10.0.2.2:8000';

/// Use Firebase Cloud Functions (true) or local Python server (false)
/// Set to false for development/testing with local server
const bool useFirebaseFunctions = false;

/// Get the actual AI service URL based on configuration
String get aiServiceUrl => useFirebaseFunctions ? aiServiceBaseUrl : aiServiceDevUrl;

/// API version for AI service endpoints (only used with local Python server)
const String aiServiceApiVersion = '/api/v1';

/// Connection timeout for AI service requests (milliseconds)
const int aiServiceConnectTimeout = 15000;

/// Receive timeout for AI service requests (milliseconds)
const int aiServiceReceiveTimeout = 15000;

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














