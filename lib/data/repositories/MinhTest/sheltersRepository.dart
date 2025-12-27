import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cuutrobaolu/data/models/shelter_dto.dart';
import 'package:cuutrobaolu/domain/entities/shelter_entity.dart';
import 'package:get/get.dart';

class SheltersRepository extends GetxService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;


  // Lấy danh sách shelters
  Future<List<ShelterDto>> getNearestShelters() async {
    try {
      final snapshot = await _db.collection("Shelters").get();
      final shelters = snapshot.docs
          .map((doc) => ShelterDto.fromSnapshot(doc))
          .toList();
      return shelters;
    } catch (e) {
      print('Error getting shelters: $e');
      return [];
    }
  }

  Stream<List<ShelterEntity>> getNearestSheltersStream() {
    return _db.collection('Shelters').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          final model = ShelterDto.fromSnapshot(doc);
          return model.toEntity();
        } catch (e) {
          print('Error converting document ${doc.id}: $e');
          // Return a default entity or handle error
          return ShelterEntity(
            id: doc.id,
            name: doc.data()['name'] ?? 'Unknown',
            address: doc.data()['address'] ?? '',
            lat: (doc.data()['lat'] as num?)?.toDouble() ?? 0.0,
            lng: (doc.data()['lng'] as num?)?.toDouble() ?? 0.0,
            capacity: (doc.data()['capacity'] as num?)?.toInt() ?? 0,
            currentOccupancy: (doc.data()['currentOccupancy'] as num?)?.toInt() ?? 0,
            isActive: doc.data()['isActive'] ?? true,
            createdAt: (doc.data()['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            updatedAt: (doc.data()['updatedAt'] as Timestamp?)?.toDate(),
            createdBy: doc.data()['createdBy'],
            contactPhone: doc.data()['contactPhone'],
            contactEmail: doc.data()['contactEmail'],
            amenities: List<String>.from(doc.data()['amenities'] ?? []),
            distributionTime: doc.data()['distributionTime'],
          );
        }
      }).toList();
    });
  }

  Stream<List<ShelterEntity>> getAllSheltersStream() {
    return _db
        .collection('Shelters')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final model = ShelterDto.fromSnapshot(doc);
        return model.toEntity();
      }).toList();
    });
  }

  Future<List<ShelterEntity>> getAllShelters() async {
    try {
      final snapshot = await _db
          .collection('Shelters')
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) {
        final model = ShelterDto.fromSnapshot(doc);
        return model.toEntity();
      }).toList();
    } catch (e) {
      print('Error getting all shelters: $e');
      return [];
    }
  }

  Future<void> createShelter(ShelterEntity shelter) async {
    try {
      final docRef = _db.collection('Shelters').doc();

      // Convert entity to DTO then to JSON
      final dto = ShelterDto.fromEntity(shelter.copyWith(id: docRef.id));
      await docRef.set(dto.toJson());

      print('Shelter created successfully with ID: ${docRef.id}');
    } catch (e) {
      print('Error creating shelter: $e');
      rethrow;
    }
  }
}