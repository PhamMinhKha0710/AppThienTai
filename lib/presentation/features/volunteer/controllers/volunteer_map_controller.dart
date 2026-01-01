import 'dart:async';
import 'dart:math' as math;
import 'package:cuutrobaolu/data/services/location_service.dart';
import 'package:cuutrobaolu/data/services/routing_service.dart';
import 'package:cuutrobaolu/domain/repositories/help_request_repository.dart';
import 'package:cuutrobaolu/domain/repositories/shelter_repository.dart';
import 'package:cuutrobaolu/domain/repositories/alert_repository.dart';
import 'package:cuutrobaolu/domain/entities/shelter_entity.dart';
import 'package:cuutrobaolu/domain/entities/help_request_entity.dart' as domain;
import 'package:cuutrobaolu/domain/entities/alert_entity.dart';
import 'package:cuutrobaolu/core/injection/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';

class VolunteerMapController extends GetxController {
  LocationService? _locationService;
  final RoutingService _routingService = getIt<RoutingService>();
  final HelpRequestRepository _helpRequestRepo = getIt<HelpRequestRepository>();
  final ShelterRepository _shelterRepo = getIt<ShelterRepository>();
  final AlertRepository _alertRepo = getIt<AlertRepository>();

  final currentPosition = Rxn<LatLng>();
  final disasterMarkers = <Marker>[].obs;
  final shelterMarkers = <Marker>[].obs;
  final taskMarkers = <Marker>[].obs;
  final isLoading = false.obs;
  
  // Alert-related observables
  final alerts = <AlertEntity>[].obs;
  final selectedAlertMarker = Rxn<AlertEntity>();

  // Map controller for programmatic control
  final mapController = Rxn<MapController>();

  // Focus location (for navigating to specific task)
  final focusLocation = Rxn<LatLng>();

  // Route polylines for navigation
  final routePolylines = <Polyline>[].obs;

  // Filter state
  final activeFilter = 'all'.obs;

  // Store help requests for later access - cached from single fetch
  final helpRequests = <domain.HelpRequestEntity>[].obs;

  // Stream subscriptions
  StreamSubscription<List<AlertEntity>>? _alertsSubscription;

  @override
  void onInit() {
    super.onInit();
    mapController.value = MapController();
    _initLocationService();
    _loadLocation();
    loadMarkers();
    loadAlertMarkers();
  }

  @override
  void onClose() {
    _alertsSubscription?.cancel();
    super.onClose();
  }

  /// Focus map on a specific location
  void focusOnLocation(LatLng location, {double zoom = 15.0}) {
    focusLocation.value = location;
    mapController.value?.move(location, zoom);
  }

  /// Find and display route from current position to target
  Future<void> findRouteTo(LatLng target) async {
    try {
      final current = currentPosition.value;
      if (current == null) {
        debugPrint('Current position not available for routing');
        return;
      }

      final routePoints = await _routingService.getRoutePoints(current, target);
      if (routePoints != null && routePoints.isNotEmpty) {
        routePolylines.value = [
          Polyline(
            points: routePoints,
            color: Colors.blue,
            strokeWidth: 4.0,
          ),
        ];
      } else {
        debugPrint('No route found');
        routePolylines.clear();
      }
    } catch (e) {
      debugPrint('Error finding route: $e');
      routePolylines.clear();
    }
  }

  void _initLocationService() {
    try {
      _locationService = Get.find<LocationService>();
    } catch (_) {
      _locationService = Get.put(LocationService(), permanent: true);
    }
  }

  Future<void> _loadLocation() async {
    try {
      final pos = await _locationService?.getCurrentLocation();
      if (pos != null) {
        currentPosition.value = LatLng(pos.latitude, pos.longitude);
      }
    } catch (e) {
      debugPrint('Error loading location: $e');
    }
  }

  /// Optimized loadMarkers - fetches pending requests only ONCE
  Future<void> loadMarkers() async {
    isLoading.value = true;
    try {
      // Fetch pending requests ONCE and reuse for both disaster and task markers
      final pendingRequests = await _helpRequestRepo
          .getRequestsByStatus(domain.RequestStatus.pending)
          .first;

      debugPrint('[VOLUNTEER_MAP] Found ${pendingRequests.length} pending requests (single fetch)');

      // Store for later access
      helpRequests.value = pendingRequests;

      // Build markers from the single fetch
      _buildDisasterMarkers(pendingRequests);
      _buildTaskMarkers(pendingRequests);

      // Load shelter markers separately (different collection)
      await loadShelterMarkers();
    } catch (e) {
      debugPrint('Error loading markers: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void filterMarkers(String filter) {
    activeFilter.value = filter;
    // Clear markers based on filter
    if (filter == 'tasks') {
      disasterMarkers.clear();
      shelterMarkers.clear();
    } else if (filter == 'disasters') {
      taskMarkers.clear();
      shelterMarkers.clear();
    } else if (filter == 'shelters') {
      disasterMarkers.clear();
      taskMarkers.clear();
    } else {
      // Reload all
      loadMarkers();
      loadAlertMarkers();
    }
  }

  /// Load alert markers from Firebase
  Future<void> loadAlertMarkers() async {
    try {
      // Cancel existing subscription if any
      _alertsSubscription?.cancel();
      
      _alertsSubscription = _alertRepo.getActiveAlerts().listen((alertList) {
        // Filter alerts relevant to volunteers
        final relevantAlerts = alertList.where((alert) {
          return alert.targetAudience == TargetAudience.all ||
              alert.targetAudience == TargetAudience.volunteers;
        }).toList();

        // Sort by severity (critical first)
        relevantAlerts.sort(_compareAlerts);
        alerts.value = relevantAlerts;
      }, onError: (error) {
        debugPrint('[VOLUNTEER_MAP] Error listening to alerts: $error');
      });
    } catch (e) {
      debugPrint('[VOLUNTEER_MAP] Error loading alerts: $e');
    }
  }

  int _compareAlerts(AlertEntity a, AlertEntity b) {
    // Sort by severity (critical first)
    final severityCompare = _severityToInt(b.severity)
        .compareTo(_severityToInt(a.severity));
    if (severityCompare != 0) return severityCompare;

    // Then by created date (newest first)
    return b.createdAt.compareTo(a.createdAt);
  }

  int _severityToInt(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return 4;
      case AlertSeverity.high:
        return 3;
      case AlertSeverity.medium:
        return 2;
      case AlertSeverity.low:
        return 1;
    }
  }

  /// Get alert markers for the map
  List<Marker> get alertMarkers {
    return alerts
        .where((alert) => alert.lat != null && alert.lng != null)
        .map((alert) {
      return Marker(
        key: Key('alert_${alert.id}'),
        point: LatLng(alert.lat!, alert.lng!),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () {
            selectedAlertMarker.value = alert;
          },
          child: _AlertMarkerWidget(alert: alert),
        ),
      );
    }).toList();
  }

  /// Get alert circles (radius of effect) for the map
  List<CircleMarker> get alertCircles {
    return alerts
        .where((alert) =>
            alert.lat != null && alert.lng != null && alert.radiusKm != null)
        .map((alert) {
      final color = _getAlertSeverityColor(alert.severity);
      return CircleMarker(
        point: LatLng(alert.lat!, alert.lng!),
        radius: alert.radiusKm! * 1000, // Convert km to meters
        useRadiusInMeter: true,
        color: color.withOpacity(0.15),
        borderColor: color.withOpacity(0.5),
        borderStrokeWidth: 2,
      );
    }).toList();
  }

  /// Calculate distance to alert
  double? getDistanceToAlert(AlertEntity alert) {
    if (currentPosition.value == null ||
        alert.lat == null ||
        alert.lng == null) {
      return null;
    }

    return _calculateDistanceToPoint(
      currentPosition.value!.latitude,
      currentPosition.value!.longitude,
      alert.lat!,
      alert.lng!,
    );
  }

  double _calculateDistanceToPoint(
      double lat1, double lng1, double lat2, double lng2) {
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

  Color _getAlertSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return Colors.red.shade700;
      case AlertSeverity.high:
        return Colors.orange.shade700;
      case AlertSeverity.medium:
        return Colors.amber.shade700;
      case AlertSeverity.low:
        return Colors.blue.shade700;
    }
  }

  /// Build disaster markers from cached requests
  void _buildDisasterMarkers(List<domain.HelpRequestEntity> pendingRequests) {
    disasterMarkers.value = pendingRequests.map((req) {
      // Màu sắc theo mức độ nghiêm trọng
      Color markerColor = Colors.orange;
      IconData markerIcon = Icons.warning;

      switch (req.severity) {
        case domain.RequestSeverity.urgent:
        case domain.RequestSeverity.high:
          markerColor = Colors.red;
          markerIcon = Icons.warning;
          break;
        case domain.RequestSeverity.medium:
          markerColor = Colors.orange;
          markerIcon = Icons.info_outline;
          break;
        case domain.RequestSeverity.low:
          markerColor = Colors.yellow;
          markerIcon = Icons.circle_notifications;
          break;
      }

      return Marker(
        key: Key(req.id),
        point: LatLng(req.lat, req.lng),
        width: 50,
        height: 50,
        child: InkWell(
          onTap: () {
            debugPrint('[VOLUNTEER_MAP] Marker tapped for request: ${req.id}');
            _showRequestDetail(req);
          },
          child: Container(
            decoration: BoxDecoration(
              color: markerColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: markerColor.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(markerIcon, color: Colors.white, size: 28),
          ),
        ),
      );
    }).toList();

    debugPrint('[VOLUNTEER_MAP] Created ${disasterMarkers.length} disaster markers');
  }

  /// Build task markers from cached requests (reuses same data)
  void _buildTaskMarkers(List<domain.HelpRequestEntity> pendingRequests) {
    taskMarkers.value = pendingRequests.map((req) {
      return Marker(
        key: Key('task_${req.id}'),
        point: LatLng(req.lat, req.lng),
        width: 36,
        height: 36,
        child: const Icon(Icons.location_on, color: Colors.orange, size: 32),
      );
    }).toList();

    debugPrint('[VOLUNTEER_MAP] Created ${taskMarkers.length} task markers');
  }

  /// Hiển thị chi tiết yêu cầu và cho phép tìm đường
  void _showRequestDetail(domain.HelpRequestEntity request) {
    debugPrint('[VOLUNTEER_MAP] Showing detail for request: ${request.id}');

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getSeverityColor(request.severity).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: _getSeverityColor(request.severity),
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getSeverityColor(request.severity),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getSeverityText(request.severity),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(request.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getStatusColor(request.status),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(request.status),
                      size: 16,
                      color: _getStatusColor(request.status),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getStatusText(request.status),
                      style: TextStyle(
                        color: _getStatusColor(request.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Details
              _buildDetailRow('Mô tả', request.description),
              const Divider(height: 24),

              _buildDetailRow('Địa chỉ', request.address),
              const Divider(height: 24),

              _buildDetailRow('Liên hệ', request.contact),
              const Divider(height: 24),

              _buildDetailRow(
                'Tọa độ',
                '${request.lat.toStringAsFixed(6)}, ${request.lng.toStringAsFixed(6)}',
              ),
              const Divider(height: 24),

              _buildDetailRow(
                'Thời gian',
                _formatDateTime(request.createdAt),
              ),
              const Divider(height: 24),

              _buildDetailRow(
                'Loại yêu cầu',
                request.type.viName,
              ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close),
                      label: const Text('Đóng'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        focusOnLocation(
                          LatLng(request.lat, request.lng),
                          zoom: 16.0,
                        );
                        findRouteTo(LatLng(request.lat, request.lng));
                      },
                      icon: const Icon(Icons.directions),
                      label: const Text('Tìm đường đi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }

  Color _getSeverityColor(domain.RequestSeverity severity) {
    switch (severity) {
      case domain.RequestSeverity.urgent:
      case domain.RequestSeverity.high:
        return Colors.red;
      case domain.RequestSeverity.medium:
        return Colors.orange;
      case domain.RequestSeverity.low:
        return Colors.yellow.shade700;
    }
  }

  String _getSeverityText(domain.RequestSeverity severity) {
    switch (severity) {
      case domain.RequestSeverity.urgent:
        return 'Khẩn cấp cực cao';
      case domain.RequestSeverity.high:
        return 'Khẩn cấp cao';
      case domain.RequestSeverity.medium:
        return 'Khẩn cấp trung bình';
      case domain.RequestSeverity.low:
        return 'Khẩn cấp thấp';
    }
  }

  Color _getStatusColor(domain.RequestStatus status) {
    switch (status) {
      case domain.RequestStatus.pending:
        return Colors.orange;
      case domain.RequestStatus.inProgress:
        return Colors.blue;
      case domain.RequestStatus.completed:
        return Colors.green;
      case domain.RequestStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(domain.RequestStatus status) {
    switch (status) {
      case domain.RequestStatus.pending:
        return 'Chờ xử lý';
      case domain.RequestStatus.inProgress:
        return 'Đang xử lý';
      case domain.RequestStatus.completed:
        return 'Hoàn thành';
      case domain.RequestStatus.cancelled:
        return 'Đã hủy';
    }
  }

  IconData _getStatusIcon(domain.RequestStatus status) {
    switch (status) {
      case domain.RequestStatus.pending:
        return Icons.pending;
      case domain.RequestStatus.inProgress:
        return Icons.refresh;
      case domain.RequestStatus.completed:
        return Icons.check_circle;
      case domain.RequestStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  Future<void> loadShelterMarkers() async {
    try {
      final shelters = await _shelterRepo.getAllShelters().first;

      shelterMarkers.value = shelters.map((shelter) {
        return Marker(
          key: Key('shelter_${shelter.id}'),
          point: LatLng(shelter.lat, shelter.lng),
          width: 36,
          height: 36,
          child: const Icon(Icons.home, color: Colors.green, size: 32),
        );
      }).toList();
    } catch (e) {
      debugPrint('Error loading shelter markers: $e');
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
        debugPrint('Error loading address: $e');
      } finally {
        isLoadingAddress.value = false;
      }
    }

    // Load address immediately
    loadAddress();

    Get.dialog(
      Dialog(
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thêm điểm trú ẩn',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  'Vị trí: ${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên điểm trú ẩn *',
                    border: OutlineInputBorder(),
                    hintText: 'Ví dụ: Trường học ABC',
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() => TextField(
                      controller: addressController,
                      decoration: InputDecoration(
                        labelText: 'Địa chỉ *',
                        border: const OutlineInputBorder(),
                        hintText: 'Ví dụ: 123 Đường ABC, Phường XYZ',
                        suffixIcon: isLoadingAddress.value
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.my_location),
                                tooltip: 'Lấy địa chỉ từ vị trí',
                                onPressed: () => loadAddress(),
                              ),
                      ),
                      maxLines: 2,
                    )),
                const SizedBox(height: 12),
                TextField(
                  controller: capacityController,
                  decoration: const InputDecoration(
                    labelText: 'Sức chứa (người) *',
                    border: OutlineInputBorder(),
                    hintText: '50',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả',
                    border: OutlineInputBorder(),
                    hintText: 'Thông tin thêm về điểm trú ẩn',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: isLoading.value ? null : () => Get.back(),
                          child: const Text('Hủy'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: isLoading.value
                              ? null
                              : () async {
                                  if (nameController.text.trim().isEmpty ||
                                      addressController.text.trim().isEmpty ||
                                      capacityController.text.trim().isEmpty) {
                                    Get.snackbar(
                                      'Lỗi',
                                      'Vui lòng điền đầy đủ thông tin bắt buộc',
                                    );
                                    return;
                                  }

                                  final capacity =
                                      int.tryParse(capacityController.text);
                                  if (capacity == null || capacity <= 0) {
                                    Get.snackbar(
                                      'Lỗi',
                                      'Sức chứa phải là số dương',
                                    );
                                    return;
                                  }

                                  isLoading.value = true;
                                  try {
                                    // Import ShelterEntity
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
                                      description:
                                          descriptionController.text.trim().isEmpty
                                              ? null
                                              : descriptionController.text.trim(),
                                    );
                                    await _shelterRepo.createShelter(shelter);
                                    Get.back();
                                    Get.snackbar(
                                      'Thành công',
                                      'Đã thêm điểm trú ẩn thành công!',
                                    );
                                    await loadShelterMarkers();
                                  } catch (e) {
                                    Get.snackbar(
                                      'Lỗi',
                                      'Không thể thêm điểm trú ẩn: $e',
                                    );
                                  } finally {
                                    isLoading.value = false;
                                  }
                                },
                          child: isLoading.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Thêm'),
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
}

/// Alert marker widget for the map
class _AlertMarkerWidget extends StatelessWidget {
  final AlertEntity alert;

  const _AlertMarkerWidget({required this.alert});

  @override
  Widget build(BuildContext context) {
    final color = _getSeverityColor(alert.severity);
    final icon = _getAlertIcon(alert.alertType);

    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Color _getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return Colors.red.shade700;
      case AlertSeverity.high:
        return Colors.orange.shade700;
      case AlertSeverity.medium:
        return Colors.amber.shade700;
      case AlertSeverity.low:
        return Colors.blue.shade700;
    }
  }

  IconData _getAlertIcon(AlertType type) {
    switch (type) {
      case AlertType.disaster:
        return Iconsax.danger;
      case AlertType.weather:
        return Iconsax.cloud_lightning;
      case AlertType.evacuation:
        return Iconsax.routing;
      case AlertType.resource:
        return Iconsax.box;
      case AlertType.general:
        return Iconsax.warning_2;
    }
  }
}
