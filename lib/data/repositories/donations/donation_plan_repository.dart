import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/repositories/donation_plan_repository.dart';
import '../../../domain/entities/donation_plan_entity.dart';
import '../../models/donation_plan_dto.dart';

class DonationPlanRepositoryImpl implements DonationPlanRepository {
  final FirebaseFirestore _firestore;

  DonationPlanRepositoryImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('donation_plans');

  @override
  Future<String> createPlan(DonationPlanEntity plan) async {
    try {
      final dto = DonationPlanDto.fromEntity(plan);
      final docRef = await _collection.add(dto.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create donation plan: $e');
    }
  }

  @override
  Future<void> updatePlan(DonationPlanEntity plan) async {
    try {
      final dto = DonationPlanDto.fromEntity(plan);
      await _collection.doc(plan.id).update(dto.toJson());
    } catch (e) {
      throw Exception('Failed to update donation plan: $e');
    }
  }

  @override
  Future<DonationPlanEntity?> getPlanById(String planId) async {
    try {
      final doc = await _collection.doc(planId).get();
      if (doc.exists && doc.data() != null) {
        return DonationPlanDto.fromSnapshot(doc).toEntity();
      }
      return null;
    } catch (e) {
      print('Error getting donation plan by id: $e');
      return null;
    }
  }

  @override
  Future<List<DonationPlanEntity>> getPlansByArea(
    String province,
    String? district,
  ) async {
    try {
      Query<Map<String, dynamic>> query = _collection
          .where('Province', isEqualTo: province)
          .where('Status', isEqualTo: 'active');

      if (district != null && district.isNotEmpty) {
        query = query.where('District', isEqualTo: district);
      }

      final snapshot = await query
          .orderBy('CreatedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => DonationPlanDto.fromSnapshot(doc).toEntity())
          .toList();
    } catch (e) {
      print('Error getting plans by area: $e');
      return [];
    }
  }

  @override
  Future<List<DonationPlanEntity>> getPlansByAlert(String alertId) async {
    try {
      final snapshot = await _collection
          .where('AlertId', isEqualTo: alertId)
          .where('Status', isEqualTo: 'active')
          .orderBy('CreatedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => DonationPlanDto.fromSnapshot(doc).toEntity())
          .toList();
    } catch (e) {
      print('Error getting plans by alert: $e');
      return [];
    }
  }

  @override
  Future<List<DonationPlanEntity>> getPlansByCoordinator(
      String coordinatorId) async {
    try {
      final snapshot = await _collection
          .where('CoordinatorId', isEqualTo: coordinatorId)
          .orderBy('CreatedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => DonationPlanDto.fromSnapshot(doc).toEntity())
          .toList();
    } catch (e) {
      print('Error getting plans by coordinator: $e');
      return [];
    }
  }

  @override
  Future<void> deletePlan(String planId) async {
    try {
      await _collection.doc(planId).delete();
    } catch (e) {
      throw Exception('Failed to delete donation plan: $e');
    }
  }

  @override
  Stream<List<DonationPlanEntity>> streamPlansByArea(
    String province,
    String? district,
  ) {
    try {
      Query<Map<String, dynamic>> query = _collection
          .where('Province', isEqualTo: province)
          .where('Status', isEqualTo: 'active');

      if (district != null && district.isNotEmpty) {
        query = query.where('District', isEqualTo: district);
      }

      return query
          .orderBy('CreatedAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => DonationPlanDto.fromSnapshot(doc).toEntity())
              .toList());
    } catch (e) {
      print('Error streaming plans by area: $e');
      return Stream.value([]);
    }
  }
}



















