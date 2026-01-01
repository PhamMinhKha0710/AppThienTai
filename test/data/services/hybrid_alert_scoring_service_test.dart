import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cuutrobaolu/domain/services/alert_scoring_service.dart';
import 'package:cuutrobaolu/domain/services/hybrid_alert_scoring_service.dart';
import 'package:cuutrobaolu/data/services/ai_service_client.dart';
import 'package:cuutrobaolu/domain/entities/alert_entity.dart';

// Generate mocks
@GenerateMocks([AlertScoringService, AIServiceClient])
import 'hybrid_alert_scoring_service_test.mocks.dart';

void main() {
  group('HybridAlertScoringService', () {
    late HybridAlertScoringService hybridService;
    late MockAlertScoringService mockRuleBasedService;
    late MockAIServiceClient mockAIService;
    late AlertEntity testAlert;

    setUp(() {
      mockRuleBasedService = MockAlertScoringService();
      mockAIService = MockAIServiceClient();
      testAlert = AlertEntity(
        id: 'test-alert-1',
        title: 'Test Alert',
        content: 'Test content',
        severity: AlertSeverity.high,
        alertType: AlertType.weather,
        targetAudience: TargetAudience.all,
        province: 'Test Province',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      );
    });

    group('with AI enabled', () {
      setUp(() {
        hybridService = HybridAlertScoringService(
          ruleBasedService: mockRuleBasedService,
          aiService: mockAIService,
          useAI: true,
        );
      });

      test('should use AI service when available', () async {
        // Arrange
        final aiScore = AIScoreResult(
          alertId: testAlert.id,
          priorityScore: 85.5,
          confidence: 0.92,
          explanation: {'reason': 'test'},
        );
        
        when(mockAIService.getAlertScore(
          any,
          userLat: anyNamed('userLat'),
          userLng: anyNamed('userLng'),
          userRole: anyNamed('userRole'),
        )).thenAnswer((_) async => aiScore);

        // Act
        final result = await hybridService.calculateScoredAlert(
          alert: testAlert,
          userLat: 10.762622,
          userLng: 106.660172,
          userRole: 'victim',
        );

        // Assert
        expect(result.score, 85.5);
        expect(result.alert.priorityScore, 85.5);
        verify(mockAIService.getAlertScore(
          any,
          userLat: anyNamed('userLat'),
          userLng: anyNamed('userLng'),
          userRole: anyNamed('userRole'),
        )).called(1);
        verifyNever(mockRuleBasedService.calculatePriorityScore(
          alert: anyNamed('alert'),
          userLat: anyNamed('userLat'),
          userLng: anyNamed('userLng'),
          userRole: anyNamed('userRole'),
        ));
      });

      test('should fallback to rule-based when AI fails', () async {
        // Arrange
        when(mockAIService.getAlertScore(
          any,
          userLat: anyNamed('userLat'),
          userLng: anyNamed('userLng'),
          userRole: anyNamed('userRole'),
        )).thenThrow(Exception('AI service unavailable'));
        
        when(mockRuleBasedService.calculatePriorityScore(
          alert: anyNamed('alert'),
          userLat: anyNamed('userLat'),
          userLng: anyNamed('userLng'),
          userRole: anyNamed('userRole'),
        )).thenReturn(75.0);

        // Act
        final result = await hybridService.calculateScoredAlert(
          alert: testAlert,
          userLat: 10.762622,
          userLng: 106.660172,
          userRole: 'victim',
        );

        // Assert
        expect(result.score, 75.0);
        expect(result.alert.priorityScore, 75.0);
        verify(mockAIService.getAlertScore(
          any,
          userLat: anyNamed('userLat'),
          userLng: anyNamed('userLng'),
          userRole: anyNamed('userRole'),
        )).called(1);
        verify(mockRuleBasedService.calculatePriorityScore(
          alert: anyNamed('alert'),
          userLat: anyNamed('userLat'),
          userLng: anyNamed('userLng'),
          userRole: anyNamed('userRole'),
        )).called(1);
      });
    });

    group('with AI disabled', () {
      setUp(() {
        hybridService = HybridAlertScoringService(
          ruleBasedService: mockRuleBasedService,
          aiService: mockAIService,
          useAI: false,
        );
      });

      test('should use rule-based service only', () async {
        // Arrange
        when(mockRuleBasedService.calculatePriorityScore(
          alert: anyNamed('alert'),
          userLat: anyNamed('userLat'),
          userLng: anyNamed('userLng'),
          userRole: anyNamed('userRole'),
        )).thenReturn(70.0);

        // Act
        final result = await hybridService.calculateScoredAlert(
          alert: testAlert,
          userLat: 10.762622,
          userLng: 106.660172,
          userRole: 'victim',
        );

        // Assert
        expect(result.score, 70.0);
        verifyNever(mockAIService.getAlertScore(
          any,
          userLat: anyNamed('userLat'),
          userLng: anyNamed('userLng'),
          userRole: anyNamed('userRole'),
        ));
        verify(mockRuleBasedService.calculatePriorityScore(
          alert: anyNamed('alert'),
          userLat: anyNamed('userLat'),
          userLng: anyNamed('userLng'),
          userRole: anyNamed('userRole'),
        )).called(1);
      });
    });

    group('health check', () {
      setUp(() {
        hybridService = HybridAlertScoringService(
          ruleBasedService: mockRuleBasedService,
          aiService: mockAIService,
          useAI: true,
        );
      });

      test('should return true when AI service is healthy', () async {
        // Arrange
        when(mockAIService.healthCheck()).thenAnswer((_) async => true);

        // Act
        final isAvailable = await hybridService.isAIServiceAvailable();

        // Assert
        expect(isAvailable, true);
        verify(mockAIService.healthCheck()).called(1);
      });

      test('should return false when AI service is unhealthy', () async {
        // Arrange
        when(mockAIService.healthCheck()).thenAnswer((_) async => false);

        // Act
        final isAvailable = await hybridService.isAIServiceAvailable();

        // Assert
        expect(isAvailable, false);
        verify(mockAIService.healthCheck()).called(1);
      });

      test('should return false when health check throws', () async {
        // Arrange
        when(mockAIService.healthCheck()).thenThrow(Exception('Network error'));

        // Act
        final isAvailable = await hybridService.isAIServiceAvailable();

        // Assert
        expect(isAvailable, false);
      });
    });
  });
}


