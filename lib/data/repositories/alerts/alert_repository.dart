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
    return _collection
        .where('IsActive', isEqualTo: true)
        .where('ExpiresAt', isGreaterThan: Timestamp.fromDate(now))
        .orderBy('ExpiresAt')
        .orderBy('CreatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AlertDto.fromSnapshot(doc).toEntity())
            .toList());
  }

  @override
  Stream<List<AlertEntity>> getAlertsBySeverity(String severity) {
    return _collection
        .where('Severity', isEqualTo: severity)
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

