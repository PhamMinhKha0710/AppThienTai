import 'package:flutter_test/flutter_test.dart';
import 'package:cuutrobaolu/domain/services/alert_scoring_service.dart';
import 'package:cuutrobaolu/domain/entities/alert_entity.dart';

void main() {
  late AlertScoringService service;

  setUp(() {
    service = const AlertScoringService();
  });

  group('AlertScoringService -', () {
    group('Severity Scoring', () {
      test('Critical severity should have highest score', () {
        // Arrange
        final criticalAlert = _createTestAlert(severity: AlertSeverity.critical);
        final lowAlert = _createTestAlert(severity: AlertSeverity.low);

        // Act
        final criticalScore = service.calculatePriorityScore(
          alert: criticalAlert,
          userLat: null,
          userLng: null,
          userRole: 'victim',
        );
        final lowScore = service.calculatePriorityScore(
          alert: lowAlert,
          userLat: null,
          userLng: null,
          userRole: 'victim',
        );

        // Assert
        expect(criticalScore, greaterThan(lowScore));
      });

      test('Severity scores should be in correct order', () {
        // Arrange
        final alerts = [
          _createTestAlert(severity: AlertSeverity.critical),
          _createTestAlert(severity: AlertSeverity.high),
          _createTestAlert(severity: AlertSeverity.medium),
          _createTestAlert(severity: AlertSeverity.low),
        ];

        // Act
        final scores = alerts.map((alert) {
          return service.calculatePriorityScore(
            alert: alert,
            userLat: null,
            userLng: null,
            userRole: 'victim',
          );
        }).toList();

        // Assert
        expect(scores[0], greaterThan(scores[1])); // critical > high
        expect(scores[1], greaterThan(scores[2])); // high > medium
        expect(scores[2], greaterThan(scores[3])); // medium > low
      });
    });

    group('Type Scoring', () {
      test('Disaster type should have higher score than general', () {
        // Arrange
        final disasterAlert = _createTestAlert(
          alertType: AlertType.disaster,
          severity: AlertSeverity.medium, // Same severity for fair comparison
        );
        final generalAlert = _createTestAlert(
          alertType: AlertType.general,
          severity: AlertSeverity.medium,
        );

        // Act
        final disasterScore = service.calculatePriorityScore(
          alert: disasterAlert,
          userLat: null,
          userLng: null,
          userRole: 'victim',
        );
        final generalScore = service.calculatePriorityScore(
          alert: generalAlert,
          userLat: null,
          userLng: null,
          userRole: 'victim',
        );

        // Assert
        expect(disasterScore, greaterThan(generalScore));
      });
    });

    group('Time Decay Algorithm', () {
      test('Newer alerts should have higher score than older alerts', () {
        // Arrange
        final newAlert = _createTestAlert(
          createdAt: DateTime.now(),
        );
        final oldAlert = _createTestAlert(
          createdAt: DateTime.now().subtract(const Duration(hours: 24)),
        );

        // Act
        final newScore = service.calculatePriorityScore(
          alert: newAlert,
          userLat: null,
          userLng: null,
          userRole: 'victim',
        );
        final oldScore = service.calculatePriorityScore(
          alert: oldAlert,
          userLat: null,
          userLng: null,
          userRole: 'victim',
        );

        // Assert
        expect(newScore, greaterThan(oldScore));
      });

      test('Expired alerts should have very low score', () {
        // Arrange
        final expiredAlert = _createTestAlert(
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        // Act
        final score = service.calculatePriorityScore(
          alert: expiredAlert,
          userLat: null,
          userLng: null,
          userRole: 'victim',
        );

        // Assert
        expect(score, lessThan(50.0));
      });
    });

    group('Location-based Priority Boost', () {
      test('Nearby alerts should have higher distance score', () {
        // Arrange - Hồ Chí Minh City coordinates
        final userLat = 10.762622;
        final userLng = 106.660172;

        // Alert 5km away
        final nearbyAlert = _createTestAlert(
          lat: 10.807854,
          lng: 106.676711,
        );

        // Alert 30km away
        final farAlert = _createTestAlert(
          lat: 10.975346,
          lng: 106.837234,
        );

        // Act
        final nearbyScore = service.calculatePriorityScore(
          alert: nearbyAlert,
          userLat: userLat,
          userLng: userLng,
          userRole: 'victim',
        );
        final farScore = service.calculatePriorityScore(
          alert: farAlert,
          userLat: userLat,
          userLng: userLng,
          userRole: 'victim',
        );

        // Assert
        expect(nearbyScore, greaterThan(farScore));
      });

      test('Alerts without location should get default score', () {
        // Arrange
        final alertWithoutLocation = _createTestAlert(
          lat: null,
          lng: null,
        );

        // Act
        final score = service.calculatePriorityScore(
          alert: alertWithoutLocation,
          userLat: 10.762622,
          userLng: 106.660172,
          userRole: 'victim',
        );

        // Assert
        expect(score, greaterThan(0.0));
      });
    });

    group('Audience Scoring', () {
      test('Matching audience should have higher score', () {
        // Arrange
        final victimAlert = _createTestAlert(
          targetAudience: TargetAudience.victims,
        );
        final volunteerAlert = _createTestAlert(
          targetAudience: TargetAudience.volunteers,
        );

        // Act
        final victimScore = service.calculatePriorityScore(
          alert: victimAlert,
          userLat: null,
          userLng: null,
          userRole: 'victim',
        );
        final volunteerScore = service.calculatePriorityScore(
          alert: volunteerAlert,
          userLat: null,
          userLng: null,
          userRole: 'victim',
        );

        // Assert
        expect(victimScore, greaterThan(volunteerScore));
      });

      test('All audience alerts should have high score for any role', () {
        // Arrange
        final allAlert = _createTestAlert(
          targetAudience: TargetAudience.all,
        );

        // Act
        final victimScore = service.calculatePriorityScore(
          alert: allAlert,
          userLat: null,
          userLng: null,
          userRole: 'victim',
        );
        final volunteerScore = service.calculatePriorityScore(
          alert: allAlert,
          userLat: null,
          userLng: null,
          userRole: 'volunteer',
        );

        // Assert
        expect(victimScore, greaterThan(50.0));
        expect(volunteerScore, greaterThan(50.0));
      });
    });

    group('Multi-factor Scoring Integration', () {
      test('Combined factors should produce expected score range', () {
        // Arrange
        final perfectAlert = _createTestAlert(
          severity: AlertSeverity.critical,
          alertType: AlertType.disaster,
          targetAudience: TargetAudience.victims,
          createdAt: DateTime.now(),
          lat: 10.807854, // 5km from user
          lng: 106.676711,
        );

        // Act
        final score = service.calculatePriorityScore(
          alert: perfectAlert,
          userLat: 10.762622,
          userLng: 106.660172,
          userRole: 'victim',
        );

        // Assert
        expect(score, greaterThan(70.0)); // Should be very high
        expect(score, lessThanOrEqualTo(100.0)); // But not exceed 100
      });

      test('calculateScoredAlert should include distance', () {
        // Arrange
        final alert = _createTestAlert(
          lat: 10.807854,
          lng: 106.676711,
        );

        // Act
        final scoredAlert = service.calculateScoredAlert(
          alert: alert,
          userLat: 10.762622,
          userLng: 106.660172,
          userRole: 'victim',
        );

        // Assert
        expect(scoredAlert.score, greaterThan(0.0));
        expect(scoredAlert.distanceKm, isNotNull);
        expect(scoredAlert.distanceKm, greaterThan(0.0));
      });
    });

    group('Weight Configuration', () {
      test('Custom weights should affect scoring', () {
        // Arrange
        final customService = const AlertScoringService(
          weightSeverity: 0.8, // Much higher weight on severity
          weightType: 0.05,
          weightTimeDecay: 0.05,
          weightDistance: 0.05,
          weightAudience: 0.05,
        );

        final highSeverityAlert = _createTestAlert(
          severity: AlertSeverity.critical,
          alertType: AlertType.general,
        );
        final lowSeverityAlert = _createTestAlert(
          severity: AlertSeverity.low,
          alertType: AlertType.disaster,
        );

        // Act
        final highScore = customService.calculatePriorityScore(
          alert: highSeverityAlert,
          userLat: null,
          userLng: null,
          userRole: 'victim',
        );
        final lowScore = customService.calculatePriorityScore(
          alert: lowSeverityAlert,
          userLat: null,
          userLng: null,
          userRole: 'victim',
        );

        // Assert
        // With high severity weight, severity should dominate
        expect(highScore, greaterThan(lowScore));
      });

      test('Default weights should sum to 1.0', () {
        // Act
        final isValid = service.isWeightValid();

        // Assert
        expect(isValid, isTrue);
      });
    });
  });
}

// Helper function to create test alerts
AlertEntity _createTestAlert({
  String id = 'test-alert',
  String title = 'Test Alert',
  String content = 'Test content',
  AlertSeverity severity = AlertSeverity.medium,
  AlertType alertType = AlertType.general,
  TargetAudience targetAudience = TargetAudience.all,
  DateTime? createdAt,
  DateTime? expiresAt,
  double? lat,
  double? lng,
}) {
  return AlertEntity(
    id: id,
    title: title,
    content: content,
    severity: severity,
    alertType: alertType,
    targetAudience: targetAudience,
    lat: lat,
    lng: lng,
    location: lat != null ? 'Test Location' : null,
    radiusKm: lat != null ? 10.0 : null,
    province: 'Test Province',
    district: 'Test District',
    isActive: true,
    createdAt: createdAt ?? DateTime.now(),
    updatedAt: null,
    expiresAt: expiresAt,
    volunteerId: null,
    safetyGuide: 'Test safety guide',
    imageUrls: null,
  );
}


