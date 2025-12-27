import 'dart:async';
import 'package:cuutrobaolu/data/repositories/MinhTest/sheltersRepository.dart';
import 'package:cuutrobaolu/data/services/location_service.dart';
import 'package:cuutrobaolu/domain/entities/shelter_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class ShelterMapController extends GetxController {
  LocationService? _locationService;
  final SheltersRepository _sheltersRepo = SheltersRepository();

  // Current user position
  final currentPosition = Rxn<LatLng>();

  // Map markers
  final shelterMarkers = <Marker>[].obs;
  final filteredShelterMarkers = <Marker>[].obs;

  // Shelter data
  final shelters = <ShelterEntity>[].obs;
  final selectedShelter = Rxn<ShelterEntity>();

  // UI states
  final isLoading = false.obs;
  final isAddingShelter = false.obs;
  final filterType = 'all'.obs; // 'all', 'available', 'full', 'nearby'
  final searchQuery = ''.obs;

  // Map controller
  final mapController = Rxn<MapController>();

  // Focus location
  final focusLocation = Rxn<LatLng>();

  // Stats
  final stats = {'total': 0, 'available': 0, 'full': 0}.obs;

  // Stream subscriptions
  StreamSubscription<List<ShelterEntity>>? _shelterSub;

  @override
  void onInit() {
    super.onInit();
    mapController.value = MapController();
    _initLocationService();
    _loadCurrentLocation();
    _startSheltersStream();
  }

  @override
  void onClose() {
    _shelterSub?.cancel();
    super.onClose();
  }

  void _initLocationService() {
    try {
      _locationService = Get.find<LocationService>();
    } catch (_) {
      _locationService = Get.put(LocationService(), permanent: true);
    }
  }

  Future<void> _loadCurrentLocation() async {
    try {
      final pos = await _locationService?.getCurrentLocation();
      if (pos != null) {
        currentPosition.value = LatLng(pos.latitude, pos.longitude);
        // Move map to current location
        mapController.value?.move(currentPosition.value!, 13);
      }
    } catch (e) {
      print('Error loading location: $e');
    }
  }

  void _startSheltersStream() {
    isLoading.value = true;

    _shelterSub?.cancel();
    _shelterSub = _sheltersRepo.getAllSheltersStream().listen(
          (shelterList) {
        shelters.value = shelterList;
        _updateStats(shelterList);
        _createMarkers(shelterList);
        isLoading.value = false;
      },
      onError: (e) {
        print('Error in shelters stream: $e');
        isLoading.value = false;
      },
    );
  }

  void _updateStats(List<ShelterEntity> shelterList) {
    final total = shelterList.length;
    final available = shelterList.where((s) => !s.isFull).length;
    final full = shelterList.where((s) => s.isFull).length;

    stats.value = {
      'total': total,
      'available': available,
      'full': full,
    };
  }

  void _createMarkers(List<ShelterEntity> shelterList) {
    shelterMarkers.clear();

    for (final shelter in shelterList) {
      final marker = Marker(
        point: LatLng(shelter.lat, shelter.lng),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => _onMarkerTap(shelter),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: shelter.isFull ? Colors.red : Colors.green,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              shelter.isFull ? Icons.home_work : Icons.home,
              color: shelter.isFull ? Colors.red : Colors.green,
              size: 24,
            ),
          ),
        ),
      );

      shelterMarkers.add(marker);
    }

    _applyFilters();
  }

  void _onMarkerTap(ShelterEntity shelter) {
    selectedShelter.value = shelter;

    // Show shelter info dialog
    _showShelterInfoDialog(shelter);

    // Move map to shelter location
    focusOnLocation(LatLng(shelter.lat, shelter.lng), zoom: 15);
  }

  void _showShelterInfoDialog(ShelterEntity shelter) {
    final availableSlots = shelter.availableSlots;
    final occupancyPercent = shelter.capacity > 0
        ? (shelter.currentOccupancy / shelter.capacity * 100).round()
        : 0;

    Get.dialog(
      Dialog(
        child: Container(
          padding: EdgeInsets.all(16),
          width: Get.width * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      shelter.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: shelter.isFull
                          ? Colors.red.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      shelter.isFull ? 'Đã đầy' : 'Còn $availableSlots chỗ',
                      style: TextStyle(
                        color: shelter.isFull ? Colors.red : Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),

              // Address
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      shelter.address,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),

              // Capacity
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(
                    'Sức chứa: ${shelter.currentOccupancy}/${shelter.capacity} người',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
              SizedBox(height: 8),

              // Occupancy progress
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Độ chiếm dụng: $occupancyPercent%',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: shelter.capacity > 0
                        ? shelter.currentOccupancy / shelter.capacity
                        : 0,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      occupancyPercent > 80 ? Colors.red :
                      occupancyPercent > 50 ? Colors.orange : Colors.green,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),

              // Amenities
              if (shelter.amenities != null && shelter.amenities!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tiện ích:',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: shelter.amenities!.map((amenity) {
                        return Chip(
                          label: Text(
                            _getAmenityText(amenity),
                            style: TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          visualDensity: VisualDensity.compact,
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 12),
                  ],
                ),

              // Contact info
              if (shelter.contactPhone != null)
                Row(
                  children: [
                    Icon(Icons.phone, size: 16, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      'Điện thoại: ${shelter.contactPhone!}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),

              if (shelter.contactEmail != null)
                Row(
                  children: [
                    Icon(Icons.email, size: 16, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      'Email: ${shelter.contactEmail!}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              SizedBox(height: 16),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Đóng'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: Icon(Icons.directions, size: 16),
                    label: Text('Chỉ đường'),
                    onPressed: () {
                      Get.back();
                      _navigateToShelter(shelter);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getAmenityText(String amenity) {
    switch (amenity) {
      case 'water': return 'Nước uống';
      case 'food': return 'Thực phẩm';
      case 'medical': return 'Y tế';
      case 'electricity': return 'Điện';
      case 'wifi': return 'WiFi';
      case 'bathroom': return 'Nhà vệ sinh';
      case 'bedding': return 'Giường nằm';
      default: return amenity;
    }
  }

  void _navigateToShelter(ShelterEntity shelter) {
    // Open Google Maps with directions
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${shelter.lat},${shelter.lng}';
    // Use url_launcher package to open URL
    // launchUrl(Uri.parse(url));

    Get.snackbar(
      'Mở Google Maps',
      'Đang mở chỉ đường đến ${shelter.name}',
      duration: Duration(seconds: 2),
    );
  }

  void focusOnLocation(LatLng location, {double zoom = 15.0}) {
    focusLocation.value = location;
    mapController.value?.move(location, zoom);
  }

  void filterMarkers(String filter) {
    filterType.value = filter;
    _applyFilters();
  }

  void _applyFilters() {
    filteredShelterMarkers.clear();

    if (shelters.isEmpty) return;

    List<ShelterEntity> filteredShelters = shelters.where((shelter) {
      // Filter by type
      switch (filterType.value) {
        case 'available':
          return !shelter.isFull;
        case 'full':
          return shelter.isFull;
        case 'nearby':
          if (currentPosition.value == null) return true;
          // This would require distance calculation
          // For now, just return all
          return true;
        default: // 'all'
          return true;
      }
    }).toList();

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filteredShelters = filteredShelters.where((shelter) {
        final name = shelter.name.toLowerCase();
        final address = shelter.address.toLowerCase();
        final description = shelter.description?.toLowerCase() ?? '';
        return name.contains(query) ||
            address.contains(query) ||
            description.contains(query);
      }).toList();
    }

    // Create markers for filtered shelters
    for (final shelter in filteredShelters) {
      try {
        final marker = shelterMarkers.firstWhere(
              (m) => m.point.latitude == shelter.lat && m.point.longitude == shelter.lng,
        );
        filteredShelterMarkers.add(marker);
      } catch (e) {
        // Create new marker if not found
        final marker = Marker(
          point: LatLng(shelter.lat, shelter.lng),
          width: 40,
          height: 40,
          child: Icon(
            shelter.isFull ? Icons.home_work : Icons.home,
            color: shelter.isFull ? Colors.red : Colors.green,
            size: 24,
          ),
        );
        filteredShelterMarkers.add(marker);
      }
    }
  }

  Future<void> refreshShelters() async {
    isLoading.value = true;
    try {
      // Force refresh from repository
      final shelterList = await _sheltersRepo.getAllShelters();
      shelters.value = shelterList;
      _updateStats(shelterList);
      _createMarkers(shelterList);
    } catch (e) {
      print('Error refreshing shelters: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addShelterAt(LatLng point) async {
    _showAddShelterDialog(point);
  }

  Future<void> showAddShelterForm() async {
    final pos = currentPosition.value;
    if (pos != null) {
      _showAddShelterDialog(pos);
    } else {
      Get.snackbar('Lỗi', 'Không thể lấy vị trí hiện tại');
    }
  }

  void _showAddShelterDialog(LatLng point) {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final capacityController = TextEditingController(text: '50');
    final descriptionController = TextEditingController();
    final contactPhoneController = TextEditingController();
    final contactEmailController = TextEditingController();

    final isLoading = false.obs;
    final isLoadingAddress = false.obs;

    // Auto-fill address from coordinates
    Future<void> loadAddress() async {
      isLoadingAddress.value = true;
      try {
        final address = await _locationService?.getAddressFromCoordinates(
          point.latitude,
          point.longitude,
        );
        if (address != null && address.isNotEmpty) {
          addressController.text = address;
        }
      } catch (e) {
        print('Error loading address: $e');
      } finally {
        isLoadingAddress.value = false;
      }
    }

    // Load address immediately
    loadAddress();

    // Amenities selection
    final selectedAmenities = <String>[].obs;
    final amenitiesList = [
      {'id': 'water', 'name': 'Nước uống'},
      {'id': 'food', 'name': 'Thực phẩm'},
      {'id': 'medical', 'name': 'Y tế'},
      {'id': 'electricity', 'name': 'Điện'},
      {'id': 'wifi', 'name': 'WiFi'},
      {'id': 'bathroom', 'name': 'Nhà vệ sinh'},
      {'id': 'bedding', 'name': 'Giường nằm'},
    ];

    Get.dialog(
      Dialog(
        child: Container(
          padding: EdgeInsets.all(20),
          constraints: BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thêm điểm trú ẩn',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text(
                  'Vị trí: ${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SizedBox(height: 16),

                // Name
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Tên điểm trú ẩn *',
                    border: OutlineInputBorder(),
                    hintText: 'Ví dụ: Trường học ABC',
                  ),
                ),
                SizedBox(height: 12),

                // Address
                Obx(() => TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: 'Địa chỉ *',
                    border: OutlineInputBorder(),
                    hintText: 'Ví dụ: 123 Đường ABC, Phường XYZ',
                    suffixIcon: isLoadingAddress.value
                        ? Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                        : IconButton(
                      icon: Icon(Icons.my_location),
                      tooltip: 'Lấy địa chỉ từ vị trí',
                      onPressed: () => loadAddress(),
                    ),
                  ),
                  maxLines: 2,
                )),
                SizedBox(height: 12),

                // Capacity
                TextField(
                  controller: capacityController,
                  decoration: InputDecoration(
                    labelText: 'Sức chứa (người) *',
                    border: OutlineInputBorder(),
                    hintText: '50',
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 12),

                // Contact info
                TextField(
                  controller: contactPhoneController,
                  decoration: InputDecoration(
                    labelText: 'Số điện thoại liên hệ',
                    border: OutlineInputBorder(),
                    hintText: '0987 654 321',
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 12),

                TextField(
                  controller: contactEmailController,
                  decoration: InputDecoration(
                    labelText: 'Email liên hệ',
                    border: OutlineInputBorder(),
                    hintText: 'example@email.com',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 12),

                // Amenities
                Text('Tiện ích có sẵn:', style: TextStyle(fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                Obx(() => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: amenitiesList.map((amenity) {
                    final isSelected = selectedAmenities.contains(amenity['id']);
                    return FilterChip(
                      label: Text(amenity['name']!),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          selectedAmenities.add(amenity['id']!);
                        } else {
                          selectedAmenities.remove(amenity['id']!);
                        }
                      },
                    );
                  }).toList(),
                )),
                SizedBox(height: 12),

                // Description
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Mô tả thêm',
                    border: OutlineInputBorder(),
                    hintText: 'Thông tin thêm về điểm trú ẩn',
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 20),

                // Buttons
                Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: isLoading.value ? null : () => Get.back(),
                      child: Text('Hủy'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: isLoading.value ? null : () async {
                        if (nameController.text.trim().isEmpty ||
                            addressController.text.trim().isEmpty ||
                            capacityController.text.trim().isEmpty) {
                          Get.snackbar('Lỗi', 'Vui lòng điền đầy đủ thông tin bắt buộc');
                          return;
                        }

                        final capacity = int.tryParse(capacityController.text);
                        if (capacity == null || capacity <= 0) {
                          Get.snackbar('Lỗi', 'Sức chứa phải là số dương');
                          return;
                        }

                        isLoading.value = true;
                        try {
                          final shelter = ShelterEntity(
                            id: '', // Will be set by Firestore
                            name: nameController.text.trim(),
                            address: addressController.text.trim(),
                            lat: point.latitude,
                            lng: point.longitude,
                            capacity: capacity,
                            currentOccupancy: 0,
                            isActive: true,
                            createdAt: DateTime.now(),
                            description: descriptionController.text.trim().isEmpty
                                ? null
                                : descriptionController.text.trim(),
                            contactPhone: contactPhoneController.text.trim().isEmpty
                                ? null
                                : contactPhoneController.text.trim(),
                            contactEmail: contactEmailController.text.trim().isEmpty
                                ? null
                                : contactEmailController.text.trim(),
                            amenities: selectedAmenities.isNotEmpty
                                ? selectedAmenities.toList()
                                : null,
                          );

                          await _sheltersRepo.createShelter(shelter);
                          Get.back();
                          Get.snackbar('Thành công', 'Đã thêm điểm trú ẩn thành công!');
                          await refreshShelters();
                        } catch (e) {
                          Get.snackbar('Lỗi', 'Không thể thêm điểm trú ẩn: $e');
                        } finally {
                          isLoading.value = false;
                        }
                      },
                      child: isLoading.value
                          ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : Text('Thêm'),
                    ),
                  ],
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Add this public method for the screen to call
  void loadCurrentLocation() {
    _loadCurrentLocation();
  }
}