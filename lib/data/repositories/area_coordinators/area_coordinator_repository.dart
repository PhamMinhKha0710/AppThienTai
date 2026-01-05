import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/repositories/area_coordinator_repository.dart';
import '../../../domain/entities/area_coordinator_entity.dart';
import '../../models/area_coordinator_dto.dart';

class AreaCoordinatorRepositoryImpl implements AreaCoordinatorRepository {
  final FirebaseFirestore _firestore;

  AreaCoordinatorRepositoryImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('area_coordinators');

  @override
  Future<String> applyAsCoordinator({
    required String userId,
    required String province,
    String? district,
  }) async {
    try {
      // Check if user already applied for this area
      final existing = await getCoordinatorByUser(userId);
      if (existing != null &&
          existing.province == province &&
          existing.district == district) {
        throw Exception('Bạn đã đăng ký làm điều phối cho khu vực này');
      }

      final entity = AreaCoordinatorEntity(
        id: '', // Will be set by Firestore
        userId: userId,
        province: province,
        district: district,
        status: AreaCoordinatorStatus.pending,
        appliedAt: DateTime.now(),
      );

      final dto = AreaCoordinatorDto.fromEntity(entity);
      final docRef = await _collection.add(dto.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to apply as coordinator: $e');
    }
  }

  @override
  Future<void> approveCoordinator(
    String coordinatorId,
    String approvedBy,
  ) async {
    try {
      await _collection.doc(coordinatorId).update({
        'Status': AreaCoordinatorStatus.approved.name,
        'ApprovedAt': FieldValue.serverTimestamp(),
        'ApprovedBy': approvedBy,
      });
    } catch (e) {
      throw Exception('Failed to approve coordinator: $e');
    }
  }

  @override
  Future<void> rejectCoordinator(
    String coordinatorId,
    String approvedBy,
    String? rejectionReason,
  ) async {
    try {
      await _collection.doc(coordinatorId).update({
        'Status': AreaCoordinatorStatus.rejected.name,
        'ApprovedAt': FieldValue.serverTimestamp(),
        'ApprovedBy': approvedBy,
        'RejectionReason': rejectionReason,
      });
    } catch (e) {
      throw Exception('Failed to reject coordinator: $e');
    }
  }

  @override
  Future<AreaCoordinatorEntity?> getCoordinatorByArea(
    String province,
    String? district,
  ) async {
    try {
      Query<Map<String, dynamic>> query = _collection
          .where('Province', isEqualTo: province)
          .where('Status', isEqualTo: AreaCoordinatorStatus.approved.name);

      if (district != null && district.isNotEmpty) {
        query = query.where('District', isEqualTo: district);
      }

      final snapshot = await query.limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        return AreaCoordinatorDto.fromSnapshot(snapshot.docs.first).toEntity();
      }
      return null;
    } catch (e) {
      print('Error getting coordinator by area: $e');
      return null;
    }
  }

  @override
  Future<AreaCoordinatorEntity?> getCoordinatorByUser(String userId) async {
    try {
      final snapshot = await _collection
          .where('UserId', isEqualTo: userId)
          .orderBy('AppliedAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return AreaCoordinatorDto.fromSnapshot(snapshot.docs.first).toEntity();
      }
      return null;
    } catch (e) {
      print('Error getting coordinator by user: $e');
      return null;
    }
  }

  @override
  Future<List<AreaCoordinatorEntity>> getAllCoordinators() async {
    try {
      final snapshot = await _collection
          .where('Status', isEqualTo: AreaCoordinatorStatus.approved.name)
          .orderBy('AppliedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AreaCoordinatorDto.fromSnapshot(doc).toEntity())
          .toList();
    } catch (e) {
      print('Error getting all coordinators: $e');
      return [];
    }
  }

  @override
  Future<bool> isCoordinatorOfArea(
    String userId,
    String province,
    String? district,
  ) async {
    try {
      final coordinator = await getCoordinatorByUser(userId);
      if (coordinator == null || !coordinator.isApproved) {
        return false;
      }

      if (coordinator.province != province) {
        return false;
      }

      if (district != null && coordinator.district != district) {
        return false;
      }

      return true;
    } catch (e) {
      print('Error checking if coordinator: $e');
      return false;
    }
  }
}
















