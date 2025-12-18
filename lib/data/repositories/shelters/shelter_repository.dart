import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/repositories/shelter_repository.dart';
import '../../../domain/entities/shelter_entity.dart';
import '../../models/shelter_dto.dart';

class ShelterRepositoryImpl implements ShelterRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ShelterRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('shelters');

  @override
  Stream<List<ShelterEntity>> getAllShelters() {
    return _collection
        .where('IsActive', isEqualTo: true)
        .orderBy('CreatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ShelterDto.fromSnapshot(doc).toEntity())
            .toList());
  }

  @override
  Future<List<ShelterEntity>> getNearbyShelters(
      double lat, double lng, double radiusKm) async {
    final snapshot = await _collection
        .where('IsActive', isEqualTo: true)
        .get();

    final shelters = <ShelterEntity>[];
    for (var doc in snapshot.docs) {
      final dto = ShelterDto.fromSnapshot(doc);
      final distance = _calculateDistance(lat, lng, dto.lat, dto.lng);
      if (distance <= radiusKm) {
        shelters.add(dto.toEntity());
      }
    }

    // Sort by distance (we'd need to add distance to entity or sort separately)
    return shelters;
  }

  @override
  Future<String> createShelter(ShelterEntity shelter) async {
    try {
      final dto = ShelterDto.fromEntity(shelter);
      final docRef = await _collection.add({
        ...dto.toJson(),
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

  @override
  Future<void> updateShelter(ShelterEntity shelter) async {
    try {
      final dto = ShelterDto.fromEntity(shelter);
      await _collection.doc(shelter.id).update({
        ...dto.toJson(),
        'UpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update shelter: $e');
    }
  }

  @override
  Future<ShelterEntity?> getShelterById(String shelterId) async {
    try {
      final doc = await _collection.doc(shelterId).get();
      if (doc.exists && doc.data() != null) {
        return ShelterDto.fromSnapshot(doc).toEntity();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get shelter: $e');
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






