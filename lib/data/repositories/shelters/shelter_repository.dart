import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShelterRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ShelterRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('shelters');

  /// Get all shelters
  Stream<List<Map<String, dynamic>>> getAllShelters() {
    return _collection
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

  /// Get shelters near location
  Future<List<Map<String, dynamic>>> getNearbyShelters(
      double lat, double lng, double radiusKm) async {
    final snapshot = await _collection
        .where('IsActive', isEqualTo: true)
        .get();

    final shelters = <Map<String, dynamic>>[];
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final shelterLat = (data['Lat'] as num?)?.toDouble();
      final shelterLng = (data['Lng'] as num?)?.toDouble();

      if (shelterLat != null && shelterLng != null) {
        final distance = _calculateDistance(lat, lng, shelterLat, shelterLng);
        if (distance <= radiusKm) {
          shelters.add({
            'id': doc.id,
            ...data,
            'CreatedAt': data['CreatedAt']?.toDate(),
            'distance': distance,
          });
        }
      }
    }

    shelters.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
    return shelters;
  }

  /// Create shelter
  Future<String> createShelter(Map<String, dynamic> shelterData) async {
    try {
      final docRef = await _collection.add({
        ...shelterData,
        'IsActive': true,
        'CreatedAt': FieldValue.serverTimestamp(),
        'UpdatedAt': FieldValue.serverTimestamp(),
        'CreatedBy': _auth.currentUser?.uid,
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create shelter: $e');
    }
  }

  /// Update shelter
  Future<void> updateShelter(String shelterId, Map<String, dynamic> updates) async {
    try {
      await _collection.doc(shelterId).update({
        ...updates,
        'UpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update shelter: $e');
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

