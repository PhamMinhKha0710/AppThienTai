import 'dart:async';
import 'dart:math' as math;
import 'package:cuutrobaolu/data/repositories/help/help_request_repository.dart';
import 'package:cuutrobaolu/presentation/features/shop/models/help_request_modal.dart';
import 'package:cuutrobaolu/core/constants/enums.dart';
import 'package:cuutrobaolu/core/popups/loaders.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AdminSOSController extends GetxController {
  final HelpRequestRepository _helpRequestRepo = HelpRequestRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final allRequests = <HelpRequest>[].obs;
  final filteredRequests = <HelpRequest>[].obs;
  
  // Filter options
  final selectedStatus = 'all'.obs;
  final selectedSeverity = 'all'.obs;
  final selectedType = 'all'.obs;
  final searchQuery = ''.obs;
  final selectedProvince = 'all'.obs;
  
  final isLoading = false.obs;
  
  StreamSubscription? _requestsSub;
  
  @override
  void onInit() {
    super.onInit();
    _setupRealtimeListener();
  }
  
  @override
  void onClose() {
    _requestsSub?.cancel();
    super.onClose();
  }
  
  void _setupRealtimeListener() {
    _requestsSub = _firestore
        .collection('help_requests')
        .snapshots()
        .listen((snapshot) {
      final requests = snapshot.docs
          .map((doc) => HelpRequest.fromSnapshot(doc))
          .toList();
      
      // Sort by createdAt descending
      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      allRequests.value = requests;
      applyFilters();
    });
  }
  
  void applyFilters() {
    var filtered = List<HelpRequest>.from(allRequests);
    
    // Filter by status
    if (selectedStatus.value != 'all') {
      final status = RequestStatus.values.firstWhere(
        (s) => s.name == selectedStatus.value,
        orElse: () => RequestStatus.pending,
      );
      filtered = filtered.where((r) => r.status == status).toList();
    }
    
    // Filter by severity
    if (selectedSeverity.value != 'all') {
      final severity = RequestSeverity.values.firstWhere(
        (s) => s.name == selectedSeverity.value,
        orElse: () => RequestSeverity.medium,
      );
      filtered = filtered.where((r) => r.severity == severity).toList();
    }
    
    // Filter by type
    if (selectedType.value != 'all') {
      final type = RequestType.values.firstWhere(
        (t) => t.name == selectedType.value,
        orElse: () => RequestType.other,
      );
      filtered = filtered.where((r) => r.type == type).toList();
    }
    
    // Filter by province
    if (selectedProvince.value != 'all') {
      filtered = filtered.where((r) {
        return r.province?.toLowerCase() == selectedProvince.value.toLowerCase();
      }).toList();
    }
    
    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((r) {
        return r.title.toLowerCase().contains(query) ||
               r.description.toLowerCase().contains(query) ||
               r.address.toLowerCase().contains(query);
      }).toList();
    }
    
    filteredRequests.value = filtered;
  }
  
  Future<void> assignVolunteer(String requestId, String volunteerId) async {
    try {
      await _helpRequestRepo.updateRequestStatus(
        requestId,
        RequestStatus.inProgress,
        volunteerId: volunteerId,
      );
      
      MinhLoaders.successSnackBar(
        title: 'Thành công',
        message: 'Đã phân công tình nguyện viên',
      );
    } catch (e) {
      print('[ADMIN_SOS] Error assigning volunteer: $e');
      MinhLoaders.errorSnackBar(
        title: 'Lỗi',
        message: 'Không thể phân công: $e',
      );
    }
  }
  
  Future<void> updateStatus(String requestId, RequestStatus status) async {
    try {
      await _helpRequestRepo.updateRequestStatus(requestId, status);
      
      MinhLoaders.successSnackBar(
        title: 'Thành công',
        message: 'Đã cập nhật trạng thái',
      );
    } catch (e) {
      print('[ADMIN_SOS] Error updating status: $e');
      MinhLoaders.errorSnackBar(
        title: 'Lỗi',
        message: 'Không thể cập nhật: $e',
      );
    }
  }
  
  Future<void> deleteRequest(String requestId) async {
    try {
      await _firestore.collection('help_requests').doc(requestId).delete();
      
      MinhLoaders.successSnackBar(
        title: 'Thành công',
        message: 'Đã xóa yêu cầu',
      );
    } catch (e) {
      print('[ADMIN_SOS] Error deleting request: $e');
      MinhLoaders.errorSnackBar(
        title: 'Lỗi',
        message: 'Không thể xóa: $e',
      );
    }
  }
  
  void resetFilters() {
    selectedStatus.value = 'all';
    selectedSeverity.value = 'all';
    selectedType.value = 'all';
    selectedProvince.value = 'all';
    searchQuery.value = '';
    applyFilters();
  }
  
  Future<void> exportToExcel() async {
    // TODO: Implement Excel export
    MinhLoaders.warningSnackBar(
      title: 'Chức năng đang phát triển',
      message: 'Export Excel sẽ có trong phiên bản sau',
    );
  }
  
  /// Get list of available volunteers
  Future<List<Map<String, dynamic>>> getAvailableVolunteers(double? requestLat, double? requestLng) async {
    try {
      final snapshot = await _firestore
          .collection('Users')
          .where('UserType', isEqualTo: 'volunteer')
          .get();
      
      final volunteers = <Map<String, dynamic>>[];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final lat = (data['Lat'] as num?)?.toDouble();
        final lng = (data['Lng'] as num?)?.toDouble();
        final name = data['FullName'] ?? data['Email'] ?? 'Tình nguyện viên';
        final isAvailable = data['IsAvailable'] ?? true;
        
        // Calculate distance if coordinates are available
        double? distance;
        if (requestLat != null && requestLng != null && lat != null && lng != null) {
          distance = _calculateDistance(requestLat, requestLng, lat, lng);
        }
        
        volunteers.add({
          'id': doc.id,
          'name': name,
          'email': data['Email'] ?? '',
          'phone': data['Phone'] ?? '',
          'lat': lat,
          'lng': lng,
          'isAvailable': isAvailable,
          'distance': distance,
        });
      }
      
      // Sort by distance if available, otherwise by name
      volunteers.sort((a, b) {
        if (a['distance'] != null && b['distance'] != null) {
          return (a['distance'] as double).compareTo(b['distance'] as double);
        }
        return (a['name'] as String).compareTo(b['name'] as String);
      });
      
      return volunteers;
    } catch (e) {
      print('[ADMIN_SOS] Error loading volunteers: $e');
      return [];
    }
  }
  
  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // km
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);
    
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) *
        math.sin(dLng / 2) * math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }
  
  double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}



