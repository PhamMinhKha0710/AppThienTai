import 'dart:async';
import 'package:cuutrobaolu/data/services/location_service.dart';
import 'package:cuutrobaolu/domain/repositories/shelter_repository.dart';
import 'package:cuutrobaolu/core/injection/injection_container.dart';
import 'package:cuutrobaolu/core/popups/loaders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class VictimReceiveController extends GetxController {
  LocationService? _locationService;
  final ShelterRepository _shelterRepo = getIt<ShelterRepository>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final currentPosition = Rxn<Position>(); // vị trí hiện tại
  final nearbyDistributionPoints = <Map<String, dynamic>>[].obs; // điểm phân phối gần nhất
  final myRegistrations = <Map<String, dynamic>>[].obs; // đăng ký của tôi
  final isLoading = false.obs;
  final searchQuery = ''.obs;
  
  StreamSubscription? _registrationsSub;

  @override
  void onInit() {
    super.onInit();
    _initLocationService();
    loadData();
    _setupRegistrationsListener();
  }

  @override
  void onClose() {
    _registrationsSub?.cancel();
    super.onClose();
  }

  void _initLocationService() {
    try {
      _locationService = Get.find<LocationService>();
    } catch (e) {
      _locationService = Get.put(LocationService(), permanent: true);
    }
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      await getCurrentLocation();
      await loadNearbyDistributionPoints();
    } catch (e) {
      print('[VICTIM_RECEIVE] Error loading data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getCurrentLocation() async {
    if (_locationService == null) {
      _initLocationService();
    }
    try {
      final position = await _locationService?.getCurrentLocation();
      currentPosition.value = position;
    } catch (e) {
      print('[VICTIM_RECEIVE] Error getting location: $e');
    }
  }

  Future<void> loadNearbyDistributionPoints() async {
    try {
      if (currentPosition.value == null) {
        await getCurrentLocation();
      }

      final position = currentPosition.value;
      if (position != null) {
        // Load shelters within 20km as distribution points
        final nearby = await _shelterRepo.getNearbyShelters(
          position.latitude,
          position.longitude,
          20.0,
        );

        nearbyDistributionPoints.value = nearby.map((shelter) {
          final available = shelter.availableSlots;
          final percent = shelter.capacity > 0 ? (shelter.currentOccupancy / shelter.capacity * 100).toInt() : 0;

          return {
            'id': shelter.id,
            'name': shelter.name,
            'address': shelter.address,
            'lat': shelter.lat,
            'lng': shelter.lng,
            'distance': 0.0, // TODO: Calculate distance if needed
            'capacity': shelter.capacity,
            'occupancy': shelter.currentOccupancy,
            'available': available,
            'percent': percent,
            'distributionTime': shelter.distributionTime ?? '08:00 - 17:00',
            'items': shelter.amenities ?? <String>[],
          };
        }).toList();
      } else {
        // Fallback: load all active shelters
        final allShelters = await _shelterRepo.getAllShelters().first;
        nearbyDistributionPoints.value = allShelters.take(10).map((shelter) {
          final available = shelter.availableSlots;
          final percent = shelter.capacity > 0 ? (shelter.currentOccupancy / shelter.capacity * 100).toInt() : 0;

          return {
            'id': shelter.id,
            'name': shelter.name,
            'address': shelter.address,
            'lat': shelter.lat,
            'lng': shelter.lng,
            'distance': 0.0,
            'capacity': shelter.capacity,
            'occupancy': shelter.currentOccupancy,
            'available': available,
            'percent': percent,
            'distributionTime': shelter.distributionTime ?? '08:00 - 17:00',
            'items': shelter.amenities ?? <String>[],
          };
        }).toList();
      }
    } catch (e) {
      print('[VICTIM_RECEIVE] Error loading distribution points: $e');
    }
  }

  void _setupRegistrationsListener() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _registrationsSub = _firestore
        .collection('distribution_registrations')
        .where('UserId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
      myRegistrations.value = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
          'CreatedAt': data['CreatedAt']?.toDate(),
          'DistributionTime': data['DistributionTime']?.toDate(),
        };
      }).toList();
    });
  }

  Future<void> registerForDistribution(String pointId, Map<String, dynamic> pointData) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        MinhLoaders.errorSnackBar(
          title: 'Lỗi',
          message: 'Bạn cần đăng nhập để đăng ký',
        );
        return;
      }

      // Check if already registered
      final existing = myRegistrations.firstWhereOrNull(
        (reg) => reg['PointId'] == pointId && reg['Status'] != 'cancelled',
      );

      if (existing != null) {
        MinhLoaders.warningSnackBar(
          title: 'Thông báo',
          message: 'Bạn đã đăng ký tại điểm này rồi',
        );
        return;
      }

      // Check availability
      final available = pointData['available'] as int? ?? 0;
      if (available <= 0) {
        MinhLoaders.errorSnackBar(
          title: 'Hết chỗ',
          message: 'Điểm phân phối này đã hết chỗ',
        );
        return;
      }

      // Create registration
      await _firestore.collection('distribution_registrations').add({
        'UserId': user.uid,
        'PointId': pointId,
        'PointName': pointData['name'],
        'PointAddress': pointData['address'],
        'Status': 'registered',
        'NumberOfPeople': 1, // Default, can be updated
        'CreatedAt': FieldValue.serverTimestamp(),
        'DistributionTime': pointData['distributionTime'],
      });

      // Update shelter occupancy
      final shelter = await _shelterRepo.getShelterById(pointId);
      if (shelter != null) {
        final updatedShelter = shelter.copyWith(
          currentOccupancy: shelter.currentOccupancy + 1,
        );
        await _shelterRepo.updateShelter(updatedShelter);
      }

      MinhLoaders.successSnackBar(
        title: 'Thành công',
        message: 'Đã đăng ký nhận hỗ trợ tại ${pointData['name']}',
      );
    } catch (e) {
      print('[VICTIM_RECEIVE] Error registering: $e');
      MinhLoaders.errorSnackBar(
        title: 'Lỗi',
        message: 'Không thể đăng ký: $e',
      );
    }
  }

  Future<void> cancelRegistration(String registrationId, String pointId) async {
    try {
      await _firestore.collection('distribution_registrations').doc(registrationId).update({
        'Status': 'cancelled',
        'CancelledAt': FieldValue.serverTimestamp(),
      });

      // Decrease shelter occupancy
      final shelter = await _shelterRepo.getShelterById(pointId);
      if (shelter != null) {
        final updatedShelter = shelter.copyWith(
          currentOccupancy: shelter.currentOccupancy - 1,
        );
        await _shelterRepo.updateShelter(updatedShelter);
      }

      MinhLoaders.successSnackBar(
        title: 'Thành công',
        message: 'Đã hủy đăng ký',
      );
    } catch (e) {
      print('[VICTIM_RECEIVE] Error cancelling: $e');
      MinhLoaders.errorSnackBar(
        title: 'Lỗi',
        message: 'Không thể hủy đăng ký: $e',
      );
    }
  }

  List<Map<String, dynamic>> get filteredPoints {
    var filtered = List<Map<String, dynamic>>.from(nearbyDistributionPoints);
    
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((point) {
        final name = (point['name'] ?? '').toString().toLowerCase();
        final address = (point['address'] ?? '').toString().toLowerCase();
        return name.contains(query) || address.contains(query);
      }).toList();
    }
    
    return filtered;
  }

  Future<void> refreshData() async {
    await loadData();
  }
}





