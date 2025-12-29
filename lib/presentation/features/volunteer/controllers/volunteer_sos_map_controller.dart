import 'dart:async';
import 'dart:math' as math;

import 'package:cuutrobaolu/core/injection/injection_container.dart';
import 'package:cuutrobaolu/core/popups/loaders.dart';
import 'package:cuutrobaolu/data/services/location_service.dart';
import 'package:cuutrobaolu/domain/entities/help_request_entity.dart';
import 'package:cuutrobaolu/domain/repositories/help_request_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class VolunteerSOSMapController extends GetxController {
  final HelpRequestRepository _helpRequestRepo = getIt<HelpRequestRepository>();
  LocationService? _locationService;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final MapController mapController = MapController();

  // Stream subscription - must be cancelled on dispose
  StreamSubscription<List<HelpRequestEntity>>? _requestsSubscription;

  // Observable state
  final isLoading = false.obs;
  final currentPosition = Rxn<Position>();
  final requests = <HelpRequestEntity>[].obs;
  final selectedRequest = Rxn<HelpRequestEntity>();
  final selectedFilter = 'all'.obs;
  final sortType = 'time'.obs;

  // Cached computed values - avoid recomputing on every getter call
  final _cachedFilteredRequests = <HelpRequestEntity>[].obs;
  final _cachedSosMarkers = <Marker>[].obs;

  // Distance cache - memoize expensive calculations
  final Map<String, double> _distanceCache = {};

  @override
  void onInit() {
    super.onInit();
    _initLocationService();
    _loadData();

    // Setup reactive listeners to update cache when dependencies change
    ever(requests, (_) => _updateCachedValues());
    ever(selectedFilter, (_) => _updateCachedValues());
    ever(sortType, (_) => _updateCachedValues());
    ever(currentPosition, (_) {
      _distanceCache.clear(); // Clear distance cache when position changes
      _updateCachedValues();
    });
  }

  @override
  void onClose() {
    // CRITICAL: Cancel stream subscription to prevent memory leak
    _requestsSubscription?.cancel();
    _distanceCache.clear();
    super.onClose();
  }

  void _initLocationService() {
    try {
      _locationService = Get.find<LocationService>();
    } catch (e) {
      _locationService = Get.put(LocationService(), permanent: true);
    }
  }

  Future<void> _loadData() async {
    isLoading.value = true;

    try {
      // Load current location
      final position = await _locationService?.getCurrentLocation();
      currentPosition.value = position;

      // Cancel existing subscription before creating new one
      _requestsSubscription?.cancel();

      // Load help requests with proper subscription management
      _requestsSubscription = _helpRequestRepo.getAllRequests().listen(
        (requestList) {
          // Filter to show only pending or in-progress requests
          final activeRequests = requestList.where((request) {
            return request.status == RequestStatus.pending ||
                request.status == RequestStatus.inProgress;
          }).toList();

          requests.value = activeRequests;
        },
        onError: (e) {
          debugPrint('Error in requests stream: $e');
        },
      );
    } catch (e) {
      debugPrint('Error loading SOS map data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Update cached computed values - called reactively when dependencies change
  void _updateCachedValues() {
    _cachedFilteredRequests.value = _computeFilteredRequests();
    _cachedSosMarkers.value = _buildSosMarkers(_cachedFilteredRequests);
  }

  /// Compute filtered requests - internal method
  List<HelpRequestEntity> _computeFilteredRequests() {
    var result = requests.toList();

    // Apply filter
    switch (selectedFilter.value) {
      case 'pending':
        result = result
            .where((r) => r.status == RequestStatus.pending)
            .toList();
        break;
      case 'urgent':
        result = result
            .where((r) => r.severity == RequestSeverity.urgent)
            .toList();
        break;
      case 'nearby':
        if (currentPosition.value != null) {
          result = result.where((r) {
            final distance = _getCachedDistance(r);
            return distance != null && distance <= 10; // Within 10km
          }).toList();
        }
        break;
    }

    // Apply sort
    switch (sortType.value) {
      case 'distance':
        if (currentPosition.value != null) {
          result.sort((a, b) {
            final distA = _getCachedDistance(a) ?? double.infinity;
            final distB = _getCachedDistance(b) ?? double.infinity;
            return distA.compareTo(distB);
          });
        }
        break;
      case 'severity':
        result.sort((a, b) {
          const severityOrder = {
            RequestSeverity.urgent: 0,
            RequestSeverity.high: 1,
            RequestSeverity.medium: 2,
            RequestSeverity.low: 3,
          };
          return (severityOrder[a.severity] ?? 4)
              .compareTo(severityOrder[b.severity] ?? 4);
        });
        break;
      case 'time':
      default:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return result;
  }

  /// Build SOS markers from filtered requests
  List<Marker> _buildSosMarkers(List<HelpRequestEntity> filteredList) {
    return filteredList.map((request) {
      final isPending = request.status == RequestStatus.pending;
      final color = isPending ? Colors.red.shade700 : Colors.orange.shade700;

      return Marker(
        key: ValueKey(request.id),
        point: LatLng(request.lat, request.lng),
        width: 44,
        height: 44,
        child: GestureDetector(
          onTap: () {
            selectedRequest.value = request;
          },
          child: SOSMarkerWidget(color: color, isPending: isPending),
        ),
      );
    }).toList();
  }

  Future<void> refreshData() async {
    _distanceCache.clear();
    await _loadData();
  }

  void goToCurrentLocation() {
    if (currentPosition.value != null) {
      mapController.move(
        LatLng(
          currentPosition.value!.latitude,
          currentPosition.value!.longitude,
        ),
        14.0,
      );
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  void sortBy(String type) {
    sortType.value = type;
  }

  /// Get filtered and sorted requests - uses cached value
  List<HelpRequestEntity> get filteredRequests => _cachedFilteredRequests;

  /// Get counts
  int get pendingCount =>
      requests.where((r) => r.status == RequestStatus.pending).length;

  int get inProgressCount =>
      requests.where((r) => r.status == RequestStatus.inProgress).length;

  /// Get SOS markers for the map - uses cached value
  List<Marker> get sosMarkers => _cachedSosMarkers;

  /// Get cached distance to request - memoized
  double? _getCachedDistance(HelpRequestEntity request) {
    if (currentPosition.value == null) return null;

    final cacheKey = request.id;
    return _distanceCache[cacheKey] ??= _calculateDistance(
      currentPosition.value!.latitude,
      currentPosition.value!.longitude,
      request.lat,
      request.lng,
    );
  }

  /// Calculate distance to request - public API uses cache
  double? getDistanceToRequest(HelpRequestEntity request) {
    return _getCachedDistance(request);
  }

  /// Navigate to request location
  Future<void> navigateToRequest(HelpRequestEntity request) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${request.lat},${request.lng}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  /// Accept a help request
  Future<void> acceptRequest(HelpRequestEntity request) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        MinhLoaders.errorSnackBar(
          title: 'Lỗi',
          message: 'Bạn cần đăng nhập để nhận yêu cầu',
        );
        return;
      }

      isLoading.value = true;

      // Update request status
      final updatedRequest = request.copyWith(
        status: RequestStatus.inProgress,
      );

      await _helpRequestRepo.updateHelpRequest(updatedRequest);

      selectedRequest.value = null;

      MinhLoaders.successSnackBar(
        title: 'Thành công',
        message: 'Bạn đã nhận yêu cầu hỗ trợ này',
      );

      // Refresh data
      await refreshData();
    } catch (e) {
      MinhLoaders.errorSnackBar(
        title: 'Lỗi',
        message: 'Không thể nhận yêu cầu: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  double _calculateDistance(
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
}

/// Animated SOS marker widget - fixed AnimationController bug
class SOSMarkerWidget extends StatefulWidget {
  final Color color;
  final bool isPending;

  const SOSMarkerWidget({
    super.key,
    required this.color,
    required this.isPending,
  });

  @override
  State<SOSMarkerWidget> createState() => _SOSMarkerWidgetState();
}

class _SOSMarkerWidgetState extends State<SOSMarkerWidget>
    with SingleTickerProviderStateMixin {
  // Use nullable instead of late to prevent crash when isPending is false
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    if (widget.isPending) {
      _controller = AnimationController(
        duration: const Duration(milliseconds: 1000),
        vsync: this,
      )..repeat(reverse: true);

      _animation = Tween<double>(begin: 1.0, end: 1.3).animate(
        CurvedAnimation(parent: _controller!, curve: Curves.easeInOut),
      );
    }
  }

  @override
  void dispose() {
    // Safe disposal with null check
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final markerWidget = Container(
      decoration: BoxDecoration(
        color: widget.color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: widget.color.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.sos,
          color: Colors.white,
          size: 24,
        ),
      ),
    );

    if (widget.isPending && _animation != null) {
      return AnimatedBuilder(
        animation: _animation!,
        builder: (context, child) {
          return Transform.scale(
            scale: _animation!.value,
            child: markerWidget,
          );
        },
      );
    }

    return markerWidget;
  }
}
