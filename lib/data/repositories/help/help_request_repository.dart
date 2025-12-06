// lib/repositories/help_request_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cuutrobaolu/presentation/features/shop/models/help_request_modal.dart';
import 'package:cuutrobaolu/core/constants/enums.dart';

class HelpRequestRepository {
  final FirebaseFirestore _firestore;

  HelpRequestRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// ============================
  /// COLLECTION REFERENCE
  /// ============================
  CollectionReference<HelpRequest> get requestsCollection =>
      _firestore.collection('help_requests').withConverter<HelpRequest>(
        fromFirestore: (snapshot, _) => HelpRequest.fromSnapshot(snapshot),
        toFirestore: (request, _) => request.toJson(),
      );

  /// ============================
  /// CREATE HELP REQUEST
  /// ============================
  Future<String> createHelpRequest(HelpRequest request) async {
    try {
      // Generate document ID if not provided
      final docId = request.id.isNotEmpty ? request.id : _firestore.collection('help_requests').doc().id;

      // Create request with proper ID
      final requestWithId = request.copyWith(id: docId);

      await requestsCollection.doc(docId).set(requestWithId);

      print('Successfully created help request with ID: $docId');
      return docId;
    } catch (e) {
      print('Error creating help request: $e');
      throw Exception('Failed to create help request: $e');
    }
  }

  /// ============================
  /// UPDATE HELP REQUEST
  /// ============================
  Future<void> updateHelpRequest(HelpRequest request) async {
    try {
      final updatedRequest = request.copyWith(
        updatedAt: DateTime.now(),
      );
      await requestsCollection.doc(request.id).update(updatedRequest.toJson());
    } catch (e) {
      throw Exception('Failed to update help request: $e');
    }
  }

  /// ============================
  /// GET REQUEST BY ID
  /// ============================
  Future<HelpRequest?> getRequestById(String requestId) async {
    try {
      final doc = await requestsCollection.doc(requestId).get();
      return doc.data();
    } catch (e) {
      throw Exception('Failed to get help request: $e');
    }
  }

  /// ============================
  /// GET ALL REQUESTS
  /// ============================
  Stream<List<HelpRequest>> getAllRequests() {
    return requestsCollection
        .orderBy('CreatedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// ============================
  /// GET REQUESTS BY STATUS
  /// ============================
  Stream<List<HelpRequest>> getRequestsByStatus(String status) {
    return requestsCollection
        .where('Status', isEqualTo: status)
        .orderBy('CreatedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// ============================
  /// GET REQUESTS BY USER ID
  /// ============================
  Stream<List<HelpRequest>> getRequestsByUserId(String userId) {
    return requestsCollection
        .where('UserId', isEqualTo: userId)
        .orderBy('CreatedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// ============================
  /// GET REQUESTS BY PROVINCE
  /// ============================
  Stream<List<HelpRequest>> getRequestsByProvince(String province) {
    return requestsCollection
        .where('Province', isEqualTo: province)
        .orderBy('CreatedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// ============================
  /// GET REQUESTS BY SEVERITY
  /// ============================
  Stream<List<HelpRequest>> getRequestsBySeverity(String severity) {
    return requestsCollection
        .where('Severity', isEqualTo: severity)
        .orderBy('CreatedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// ============================
  /// GET NEARBY REQUESTS
  /// ============================
  Stream<List<HelpRequest>> getNearbyRequests(double lat, double lng, double radiusKm) {
    // Lưu ý: Firestore không hỗ trợ truy vấn theo khoảng cách trực tiếp
    // Cần sử dụng Geohash hoặc giải pháp khác cho tính năng này
    return getAllRequests(); // Tạm thời trả về tất cả
  }

  /// ============================
  /// DELETE REQUEST
  /// ============================
  Future<void> deleteRequest(String requestId) async {
    try {
      await requestsCollection.doc(requestId).delete();
    } catch (e) {
      throw Exception('Failed to delete help request: $e');
    }
  }

  /// ============================
  /// UPDATE REQUEST STATUS
  /// ============================
  Future<void> updateRequestStatus(String requestId, RequestStatus status) async {
    try {
      await requestsCollection.doc(requestId).update({
        'Status': status.toJson(),
        'UpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update request status: $e');
    }
  }

  /// ============================
  /// SEARCH REQUESTS
  /// ============================
  Stream<List<HelpRequest>> searchRequests({
    String? keyword,
    String? province,
    String? severity,
    RequestType? type,
  }) {
    Query<HelpRequest> query = requestsCollection;

    // Apply filters
    if (province != null && province.isNotEmpty) {
      query = query.where('Province', isEqualTo: province);
    }

    if (severity != null && severity.isNotEmpty) {
      query = query.where('Severity', isEqualTo: severity);
    }

    if (type != null) {
      query = query.where('Type', isEqualTo: type.toJson());
    }

    // Note: Full-text search requires different approach (Algolia, ElasticSearch, etc.)
    // For now, we'll just filter by the above criteria

    return query
        .orderBy('CreatedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => doc.data()).toList());
  }
}