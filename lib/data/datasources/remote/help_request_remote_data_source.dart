import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cuutrobaolu/domain/failures/failures.dart';
import 'package:cuutrobaolu/domain/entities/help_request_entity.dart' as domain;
import 'package:cuutrobaolu/data/models/help_request_dto.dart';

/// Help Request Remote Data Source
abstract class HelpRequestRemoteDataSource {
  Future<String> createHelpRequest(HelpRequestDto dto);
  Future<void> updateHelpRequest(HelpRequestDto dto);
  Future<HelpRequestDto?> getRequestById(String requestId);
  Stream<List<HelpRequestDto>> getAllRequests();
  Stream<List<HelpRequestDto>> getRequestsByUserId(String userId);
  Future<void> updateRequestStatus(String requestId, domain.RequestStatus status);
  Future<void> deleteRequest(String requestId);
}

class HelpRequestRemoteDataSourceImpl implements HelpRequestRemoteDataSource {
  final FirebaseFirestore _firestore;

  HelpRequestRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('help_requests');

  @override
  Future<String> createHelpRequest(HelpRequestDto dto) async {
    try {
      final docId = dto.id.isNotEmpty
          ? dto.id
          : _firestore.collection('help_requests').doc().id;

      final dtoWithId = dto.copyWith(id: docId);
      await _collection.doc(docId).set(dtoWithId.toJson());

      return docId;
    } catch (e) {
      throw ServerFailure('Failed to create help request: ${e.toString()}');
    }
  }

  @override
  Future<void> updateHelpRequest(HelpRequestDto dto) async {
    try {
      await _collection.doc(dto.id).update(dto.toJson());
    } catch (e) {
      throw ServerFailure('Failed to update help request: ${e.toString()}');
    }
  }

  @override
  Future<HelpRequestDto?> getRequestById(String requestId) async {
    try {
      final doc = await _collection.doc(requestId).get();
      if (!doc.exists) return null;
      return HelpRequestDto.fromJson(doc.data()!, doc.id);
    } catch (e) {
      throw ServerFailure('Failed to get help request: ${e.toString()}');
    }
  }

  @override
  Stream<List<HelpRequestDto>> getAllRequests() {
    try {
      return _collection
          .orderBy('CreatedAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => HelpRequestDto.fromJson(doc.data(), doc.id))
              .toList());
    } catch (e) {
      throw ServerFailure('Failed to stream help requests: ${e.toString()}');
    }
  }

  @override
  Stream<List<HelpRequestDto>> getRequestsByUserId(String userId) {
    try {
      return _collection
          .where('UserId', isEqualTo: userId)
          .orderBy('CreatedAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => HelpRequestDto.fromJson(doc.data(), doc.id))
              .toList());
    } catch (e) {
      throw ServerFailure(
          'Failed to stream user help requests: ${e.toString()}');
    }
  }

  @override
  Future<void> updateRequestStatus(String requestId, domain.RequestStatus status) async {
    try {
      await _collection.doc(requestId).update({
        'Status': status.name, // Domain enum name matches core enum name
        'UpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerFailure('Failed to update status: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteRequest(String requestId) async {
    try {
      await _collection.doc(requestId).delete();
    } catch (e) {
      throw ServerFailure('Failed to delete help request: ${e.toString()}');
    }
  }
}

