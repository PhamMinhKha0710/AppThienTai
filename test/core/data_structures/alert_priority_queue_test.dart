import 'package:flutter_test/flutter_test.dart';
import 'package:cuutrobaolu/core/data_structures/alert_priority_queue.dart';
import 'package:cuutrobaolu/domain/entities/scored_alert_entity.dart';
import 'package:cuutrobaolu/domain/entities/alert_entity.dart';

void main() {
  late AlertPriorityQueue queue;

  setUp(() {
    queue = AlertPriorityQueue();
  });

  group('AlertPriorityQueue -', () {
    group('Basic Operations', () {
      test('New queue should be empty', () {
        expect(queue.isEmpty, isTrue);
        expect(queue.isNotEmpty, isFalse);
        expect(queue.length, equals(0));
      });

      test('Insert should add alert to queue', () {
        // Arrange
        final alert = _createScoredAlert(score: 50.0);

        // Act
        queue.insert(alert);

        // Assert
        expect(queue.isEmpty, isFalse);
        expect(queue.length, equals(1));
      });

      test('Peek should return highest priority without removing', () {
        // Arrange
        queue.insert(_createScoredAlert(score: 30.0));
        queue.insert(_createScoredAlert(score: 70.0));
        queue.insert(_createScoredAlert(score: 50.0));

        // Act
        final peeked = queue.peek();
        final lengthAfterPeek = queue.length;

        // Assert
        expect(peeked?.score, equals(70.0));
        expect(lengthAfterPeek, equals(3)); // Should not remove
      });

      test('ExtractMax should return and remove highest priority', () {
        // Arrange
        queue.insert(_createScoredAlert(score: 30.0));
        queue.insert(_createScoredAlert(score: 70.0));
        queue.insert(_createScoredAlert(score: 50.0));

        // Act
        final extracted = queue.extractMax();

        // Assert
        expect(extracted?.score, equals(70.0));
        expect(queue.length, equals(2));
      });
    });

    group('Priority Ordering', () {
      test('Should extract alerts in priority order', () {
        // Arrange
        final scores = [30.0, 70.0, 50.0, 90.0, 10.0];
        for (final score in scores) {
          queue.insert(_createScoredAlert(score: score));
        }

        // Act
        final extracted = <double>[];
        while (queue.isNotEmpty) {
          final alert = queue.extractMax();
          if (alert != null) extracted.add(alert.score);
        }

        // Assert
        expect(extracted, equals([90.0, 70.0, 50.0, 30.0, 10.0]));
      });

      test('Should maintain heap property after multiple inserts', () {
        // Arrange & Act
        for (var i = 0; i < 20; i++) {
          queue.insert(_createScoredAlert(score: i.toDouble()));
        }

        // Assert
        expect(queue.validateHeap(), isTrue);
      });

      test('Should maintain heap property after extract operations', () {
        // Arrange
        for (var i = 0; i < 20; i++) {
          queue.insert(_createScoredAlert(score: i.toDouble()));
        }

        // Act
        for (var i = 0; i < 10; i++) {
          queue.extractMax();
        }

        // Assert
        expect(queue.validateHeap(), isTrue);
      });
    });

    group('Edge Cases', () {
      test('ExtractMax on empty queue should return null', () {
        // Act
        final result = queue.extractMax();

        // Assert
        expect(result, isNull);
      });

      test('Peek on empty queue should return null', () {
        // Act
        final result = queue.peek();

        // Assert
        expect(result, isNull);
      });

      test('Should handle single element', () {
        // Arrange
        final alert = _createScoredAlert(score: 50.0);
        queue.insert(alert);

        // Act
        final extracted = queue.extractMax();

        // Assert
        expect(extracted?.score, equals(50.0));
        expect(queue.isEmpty, isTrue);
      });

      test('Should handle duplicate scores', () {
        // Arrange
        queue.insert(_createScoredAlert(id: 'alert1', score: 50.0));
        queue.insert(_createScoredAlert(id: 'alert2', score: 50.0));
        queue.insert(_createScoredAlert(id: 'alert3', score: 50.0));

        // Act
        final extracted = <String>[];
        while (queue.isNotEmpty) {
          final alert = queue.extractMax();
          if (alert != null) extracted.add(alert.alert.id);
        }

        // Assert
        expect(extracted.length, equals(3));
        expect(queue.isEmpty, isTrue);
      });
    });

    group('Utility Methods', () {
      test('Clear should remove all elements', () {
        // Arrange
        queue.insert(_createScoredAlert(score: 30.0));
        queue.insert(_createScoredAlert(score: 70.0));
        queue.insert(_createScoredAlert(score: 50.0));

        // Act
        queue.clear();

        // Assert
        expect(queue.isEmpty, isTrue);
        expect(queue.length, equals(0));
      });

      test('InsertAll should add multiple alerts', () {
        // Arrange
        final alerts = [
          _createScoredAlert(score: 30.0),
          _createScoredAlert(score: 70.0),
          _createScoredAlert(score: 50.0),
        ];

        // Act
        queue.insertAll(alerts);

        // Assert
        expect(queue.length, equals(3));
      });

      test('PeekN should return top N alerts', () {
        // Arrange
        queue.insert(_createScoredAlert(score: 30.0));
        queue.insert(_createScoredAlert(score: 70.0));
        queue.insert(_createScoredAlert(score: 50.0));
        queue.insert(_createScoredAlert(score: 90.0));

        // Act
        final topTwo = queue.peekN(2);

        // Assert
        expect(topTwo.length, equals(2));
        expect(topTwo[0].score, equals(90.0));
        expect(topTwo[1].score, equals(70.0));
        expect(queue.length, equals(4)); // Should not remove
      });

      test('Contains should find alert in queue', () {
        // Arrange
        final alert = _createScoredAlert(score: 50.0);
        queue.insert(alert);
        queue.insert(_createScoredAlert(score: 30.0));

        // Act
        final contains = queue.contains(alert);

        // Assert
        expect(contains, isTrue);
      });

      test('ContainsAlertId should find alert by ID', () {
        // Arrange
        queue.insert(_createScoredAlert(id: 'test-123', score: 50.0));
        queue.insert(_createScoredAlert(id: 'test-456', score: 30.0));

        // Act
        final contains = queue.containsAlertId('test-123');

        // Assert
        expect(contains, isTrue);
      });

      test('GetByAlertId should return correct alert', () {
        // Arrange
        queue.insert(_createScoredAlert(id: 'test-123', score: 50.0));
        queue.insert(_createScoredAlert(id: 'test-456', score: 30.0));

        // Act
        final found = queue.getByAlertId('test-123');

        // Assert
        expect(found, isNotNull);
        expect(found?.alert.id, equals('test-123'));
        expect(found?.score, equals(50.0));
      });
    });

    group('Statistics', () {
      test('GetStatistics should return correct values', () {
        // Arrange
        queue.insert(_createScoredAlert(score: 30.0));
        queue.insert(_createScoredAlert(score: 70.0));
        queue.insert(_createScoredAlert(score: 50.0));

        // Act
        final stats = queue.getStatistics();

        // Assert
        expect(stats['length'], equals(3));
        expect(stats['isEmpty'], isFalse);
        expect(stats['maxScore'], equals(70.0));
        expect(stats['minScore'], equals(30.0));
        expect(stats['avgScore'], equals(50.0));
      });

      test('GetStatistics on empty queue should handle gracefully', () {
        // Act
        final stats = queue.getStatistics();

        // Assert
        expect(stats['length'], equals(0));
        expect(stats['isEmpty'], isTrue);
        expect(stats['maxScore'], isNull);
      });
    });

    group('Performance', () {
      test('Should handle large number of inserts efficiently', () {
        // Arrange & Act
        final stopwatch = Stopwatch()..start();

        for (var i = 0; i < 1000; i++) {
          queue.insert(_createScoredAlert(score: i.toDouble()));
        }

        stopwatch.stop();

        // Assert
        expect(queue.length, equals(1000));
        expect(stopwatch.elapsedMilliseconds, lessThan(100)); // Should be fast
        expect(queue.validateHeap(), isTrue);
      });

      test('Should handle large number of extracts efficiently', () {
        // Arrange
        for (var i = 0; i < 1000; i++) {
          queue.insert(_createScoredAlert(score: i.toDouble()));
        }

        // Act
        final stopwatch = Stopwatch()..start();

        for (var i = 0; i < 500; i++) {
          queue.extractMax();
        }

        stopwatch.stop();

        // Assert
        expect(queue.length, equals(500));
        expect(stopwatch.elapsedMilliseconds, lessThan(50)); // Should be fast
        expect(queue.validateHeap(), isTrue);
      });
    });
  });
}

// Helper function to create test scored alerts
ScoredAlert _createScoredAlert({
  String id = 'test-alert',
  required double score,
}) {
  final alert = AlertEntity(
    id: id,
    title: 'Test Alert',
    content: 'Test content',
    severity: AlertSeverity.medium,
    alertType: AlertType.general,
    targetAudience: TargetAudience.all,
    lat: null,
    lng: null,
    location: null,
    radiusKm: null,
    province: 'Test Province',
    district: null,
    isActive: true,
    createdAt: DateTime.now(),
  );

  return ScoredAlert(
    alert: alert,
    score: score,
    distanceKm: null,
    calculatedAt: DateTime.now(),
  );
}


