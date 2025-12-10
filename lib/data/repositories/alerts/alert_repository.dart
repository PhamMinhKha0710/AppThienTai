import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AlertRepository {
  final FirebaseFirestore _firestore;

  AlertRepository({
    FirebaseFirestore? firestore,
  })  : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('alerts');

  /// Get all alerts
  Stream<List<Map<String, dynamic>>> getAllAlerts() {
    return _collection
        .orderBy('CreatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                ...data,
                'CreatedAt': data['CreatedAt']?.toDate(),
                'UpdatedAt': data['UpdatedAt']?.toDate(),
              };
            }).toList());
  }

  /// Get active alerts (not expired)
  Stream<List<Map<String, dynamic>>> getActiveAlerts() {
    final now = DateTime.now();
    return _collection
        .where('IsActive', isEqualTo: true)
        .where('ExpiresAt', isGreaterThan: Timestamp.fromDate(now))
        .orderBy('ExpiresAt')
        .orderBy('CreatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                ...data,
                'CreatedAt': data['CreatedAt']?.toDate(),
                'UpdatedAt': data['UpdatedAt']?.toDate(),
                'ExpiresAt': data['ExpiresAt']?.toDate(),
              };
            }).toList());
  }

  /// Get alerts by severity
  Stream<List<Map<String, dynamic>>> getAlertsBySeverity(String severity) {
    return _collection
        .where('Severity', isEqualTo: severity)
        .where('IsActive', isEqualTo: true)
        .orderBy('CreatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                ...data,
                'CreatedAt': data['CreatedAt']?.toDate(),
                'UpdatedAt': data['UpdatedAt']?.toDate(),
              };
            }).toList());
  }

  /// Get alerts near location
  Future<List<Map<String, dynamic>>> getNearbyAlerts(
      double lat, double lng, double radiusKm) async {
    // Note: Firestore doesn't support geo queries directly
    // For now, fetch all active alerts and filter in memory
    final snapshot = await _collection
        .where('IsActive', isEqualTo: true)
        .get();

    final alerts = <Map<String, dynamic>>[];
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final alertLat = (data['Lat'] as num?)?.toDouble();
      final alertLng = (data['Lng'] as num?)?.toDouble();

      if (alertLat != null && alertLng != null) {
        final distance = _calculateDistance(lat, lng, alertLat, alertLng);
        if (distance <= radiusKm) {
          alerts.add({
            'id': doc.id,
            ...data,
            'CreatedAt': data['CreatedAt']?.toDate(),
            'distance': distance,
          });
        }
      }
    }

    alerts.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
    return alerts;
  }

  /// Get task-related alerts for volunteer
  Stream<List<Map<String, dynamic>>> getTaskRelatedAlerts(String? volunteerId) {
    if (volunteerId == null) {
      return Stream.value([]);
    }

    return _collection
        .where('IsActive', isEqualTo: true)
        .where('Type', isEqualTo: 'task_related')
        .where('VolunteerId', isEqualTo: volunteerId)
        .orderBy('CreatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                ...data,
                'CreatedAt': data['CreatedAt']?.toDate(),
                'UpdatedAt': data['UpdatedAt']?.toDate(),
              };
            }).toList());
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

