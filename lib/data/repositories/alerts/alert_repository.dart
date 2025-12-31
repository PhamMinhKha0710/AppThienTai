import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/repositories/alert_repository.dart';
import '../../../domain/entities/alert_entity.dart';
import '../../models/alert_dto.dart';

class AlertRepositoryImpl implements AlertRepository {
  final FirebaseFirestore _firestore;

  AlertRepositoryImpl({
    FirebaseFirestore? firestore,
  })  : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('alerts');

  @override
  Stream<List<AlertEntity>> getAllAlerts() {
    return _collection
        .orderBy('CreatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AlertDto.fromSnapshot(doc).toEntity())
            .toList());
  }

  @override
  Stream<List<AlertEntity>> getActiveAlerts() {
    final now = DateTime.now();
    
    // Fetch all active alerts, then filter in memory to handle null ExpiresAt
    return _collection
        .where('IsActive', isEqualTo: true)
        .orderBy('CreatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          final alerts = snapshot.docs
              .map((doc) => AlertDto.fromSnapshot(doc).toEntity())
              .toList();
          
          // Filter: alert is active if ExpiresAt is null or in the future
          return alerts.where((alert) {
            if (alert.expiresAt == null) {
              return true; // No expiration date means always active
            }
            return alert.expiresAt!.isAfter(now);
          }).toList()
            ..sort((a, b) {
              // Sort by expiration date (nulls last), then by created date
              if (a.expiresAt == null && b.expiresAt == null) {
                return b.createdAt.compareTo(a.createdAt);
              }
              if (a.expiresAt == null) return 1;
              if (b.expiresAt == null) return -1;
              final expiresCompare = a.expiresAt!.compareTo(b.expiresAt!);
              if (expiresCompare != 0) return expiresCompare;
              return b.createdAt.compareTo(a.createdAt);
            });
        });
  }

  @override
  Stream<List<AlertEntity>> getAlertsBySeverity(AlertSeverity severity) {
    return _collection
        .where('Severity', isEqualTo: severity.name)
        .where('IsActive', isEqualTo: true)
        .orderBy('CreatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AlertDto.fromSnapshot(doc).toEntity())
            .toList());
  }

  @override
  Stream<List<AlertEntity>> getAlertsByType(AlertType type) {
    return _collection
        .where('AlertType', isEqualTo: type.name)
        .where('IsActive', isEqualTo: true)
        .orderBy('CreatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AlertDto.fromSnapshot(doc).toEntity())
            .toList());
  }

  @override
  Stream<List<AlertEntity>> getAlertsByTargetAudience(TargetAudience audience) {
    return _collection
        .where('TargetAudience', isEqualTo: audience.name)
        .where('IsActive', isEqualTo: true)
        .orderBy('CreatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AlertDto.fromSnapshot(doc).toEntity())
            .toList());
  }

  @override
  Future<List<AlertEntity>> getNearbyAlerts(
      double lat, double lng, double radiusKm) async {
    // Note: Firestore doesn't support geo queries directly
    // For now, fetch all active alerts and filter in memory
    final snapshot = await _collection
        .where('IsActive', isEqualTo: true)
        .get();

    final alerts = <AlertEntity>[];
    for (var doc in snapshot.docs) {
      final dto = AlertDto.fromSnapshot(doc);
      final alertLat = dto.lat;
      final alertLng = dto.lng;

      if (alertLat != null && alertLng != null) {
        final distance = _calculateDistance(lat, lng, alertLat, alertLng);
        if (distance <= radiusKm) {
          alerts.add(dto.toEntity());
        }
      }
    }

    // Sort by distance (we'd need to add distance to entity or sort separately)
    return alerts;
  }

  @override
  Stream<List<AlertEntity>> getTaskRelatedAlerts(String? volunteerId) {
    if (volunteerId == null) {
      return Stream.value([]);
    }

    return _collection
        .where('IsActive', isEqualTo: true)
        .where('Type', isEqualTo: 'task_related')
        .where('VolunteerId', isEqualTo: volunteerId)
        .orderBy('CreatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AlertDto.fromSnapshot(doc).toEntity())
            .toList());
  }

  @override
  Future<void> createAlert(AlertEntity alert) async {
    try {
      final dto = AlertDto.fromEntity(alert);
      final docRef = _collection.doc();
      await docRef.set(dto.toJson());
      print('[ALERT_REPO] Created alert with ID: ${docRef.id}');
    } catch (e) {
      print('[ALERT_REPO] Error creating alert: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateAlert(AlertEntity alert) async {
    try {
      final dto = AlertDto.fromEntity(alert);
      await _collection.doc(alert.id).update(dto.toJson());
      print('[ALERT_REPO] Updated alert: ${alert.id}');
    } catch (e) {
      print('[ALERT_REPO] Error updating alert: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteAlert(String alertId) async {
    try {
      await _collection.doc(alertId).delete();
      print('[ALERT_REPO] Deleted alert: $alertId');
    } catch (e) {
      print('[ALERT_REPO] Error deleting alert: $e');
      rethrow;
    }
  }

  @override
  Future<void> deactivateAlert(String alertId) async {
    try {
      await _collection.doc(alertId).update({
        'IsActive': false,
        'UpdatedAt': Timestamp.now(),
      });
      print('[ALERT_REPO] Deactivated alert: $alertId');
    } catch (e) {
      print('[ALERT_REPO] Error deactivating alert: $e');
      rethrow;
    }
  }

  @override
  Future<AlertEntity?> getAlertById(String alertId) async {
    try {
      final doc = await _collection.doc(alertId).get();
      if (doc.exists && doc.data() != null) {
        return AlertDto.fromSnapshot(doc).toEntity();
      }
      return null;
    } catch (e) {
      print('[ALERT_REPO] Error getting alert by ID: $e');
      return null;
    }
  }

  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // km
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * (math.pi / 180);
}

