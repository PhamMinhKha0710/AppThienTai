import 'dart:async';
import 'dart:math' as math;
import 'package:cuutrobaolu/data/services/location_service.dart';
import 'package:cuutrobaolu/data/services/routing_service.dart';
import 'package:cuutrobaolu/data/services/ai_service_client.dart';
import 'package:cuutrobaolu/domain/repositories/help_request_repository.dart';
import 'package:cuutrobaolu/domain/repositories/shelter_repository.dart';
import 'package:cuutrobaolu/domain/repositories/alert_repository.dart';
import 'package:cuutrobaolu/domain/entities/help_request_entity.dart' as domain;
import 'package:cuutrobaolu/domain/entities/alert_entity.dart';
import 'package:cuutrobaolu/core/injection/injection_container.dart';
import 'package:cuutrobaolu/core/constants/api_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:cuutrobaolu/core/widgets/storms/storm_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class VictimMapController extends GetxController {
  LocationService? _locationService;
  RoutingService? _routingService;
  final HelpRequestRepository _helpRequestRepo = getIt<HelpRequestRepository>();
  final ShelterRepository _shelterRepo = getIt<ShelterRepository>();
  final AlertRepository _alertRepo = getIt<AlertRepository>();
  
  final currentPosition = Rxn<Position>();
  final disasterMarkers = <Marker>[].obs;
  final shelterMarkers = <Marker>[].obs;
  final myRequestMarkers = <Marker>[].obs;
  final myRequests = <domain.HelpRequestEntity>[].obs;
  final selectedShelter = Rxn<Map<String, dynamic>>();
  final selectedRequest = Rxn<domain.HelpRequestEntity>();
  final isLoading = false.obs;
  final routePolylines = <Polyline>[].obs;
  
  // Alert-related observables
  final alerts = <AlertEntity>[].obs;
  final selectedAlertMarker = Rxn<AlertEntity>();
  // Hazard polygons (e.g., flood, storm, landslide areas)
  final hazardPolygons = <Polygon>[].obs;
  final showHazards = true.obs;
  // AI-predicted hazard zones
  final showPredictedHazards = true.obs;
  final predictedHazardZones = <HazardZone>[].obs;
  final hazardMarkers = <Marker>[].obs; // NEW: Markers for hazard zones
  final isLoadingHazards = false.obs;
  late final AIServiceClient _aiService;
  // Radar overlay support
  final radarImageUrl = Rxn<String>();
  final radarBounds = Rxn<LatLngBounds>();
  // OpenWeatherMap tiles integration
  final owmApiKey = Rxn<String>();
  final availableOwmLayers = <String>[
    'precipitation_new',
    'clouds_new',
    'pressure_new',
    'wind_new',
    'temp_new'
  ];
  final selectedOwmLayer = 'precipitation_new'.obs;
  final showOwmTiles = false.obs;
  final owmTileOpacity = 0.6.obs;
  // secure storage
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _owmStorageKey = 'owm_api_key';
  // UI: show distribution list panel
  final showDistributionPanel = false.obs;

  void toggleDistributionPanel() {
    showDistributionPanel.value = !showDistributionPanel.value;
  }
  // Hazard alert infor
  final showHazardBanner = false.obs;
  final hazardSummary = Rxn<String>();
  
  // Filter state - NEW
  final hazardTypeFilter = RxnString(); // null = all, 'flood', 'landslide', 'storm'
  final searchQuery = ''.obs;
  final showSheltersOnly = false.obs;
  final hazardDistanceKm = Rxn<double>();
  
  // Current location hazard prediction with weather - NEW
  final currentHazardPrediction = Rxn<HazardPrediction>();
  final isLoadingPrediction = false.obs;
  final selectedHazardTypeForWeather = 'flood'.obs;
  final showWeatherCard = true.obs;

  /// Evaluate nearby hazards based on disasterMarkers and current position
  void evaluateNearbyHazards() {
    try {
      final pos = currentPosition.value;
      if (pos == null || disasterMarkers.isEmpty) {
        showHazardBanner.value = false;
        hazardSummary.value = null;
        hazardDistanceKm.value = null;
        return;
      }

      double closestKm = double.infinity;
      for (final m in disasterMarkers) {
        final dkm = _distanceKm(pos.latitude, pos.longitude, m.point.latitude, m.point.longitude);
        if (dkm < closestKm) closestKm = dkm;
      }

      // Show banner if within 20 km, severity message varies by distance
      if (closestKm <= 20.0) {
        showHazardBanner.value = true;
        hazardDistanceKm.value = double.parse(closestKm.toStringAsFixed(2));
        if (closestKm <= 2.0) {
          hazardSummary.value = 'Nguy hiểm cao: Vùng ảnh hưởng rất gần (${hazardDistanceKm.value} km)';
        } else if (closestKm <= 8.0) {
          hazardSummary.value = 'Nguy hiểm: Vùng ảnh hưởng gần (${hazardDistanceKm.value} km)';
        } else {
          hazardSummary.value = 'Cảnh báo: Vùng nguy hiểm trong bán kính ${hazardDistanceKm.value} km';
        }
      } else {
        showHazardBanner.value = false;
        hazardSummary.value = null;
        hazardDistanceKm.value = null;
      }
    } catch (e) {
      print('[VICTIM_MAP] evaluateNearbyHazards error: $e');
    }
  }

  double _distanceKm(double lat1, double lng1, double lat2, double lng2) {
    try {
      return _locationService?.getDistanceInKm(lat1, lng1, lat2, lng2) ?? 0.0;
    } catch (_) {
      return 0.0;
    }
  }
  
  StreamSubscription? _myRequestsSub;
  StreamSubscription<List<AlertEntity>>? _alertsSubscription;
  // Map controller
  final mapController = Rxn<MapController>();

  @override
  void onInit() {
    super.onInit();
    _initLocationService();
    _initAIService();
    getCurrentLocation();
    loadDisasterMarkers();
    // Load AI-predicted hazard zones (replaces old loadDisasterPolygons)
    loadPredictedHazardZones();
    loadShelterMarkers();
    loadAlertMarkers();
    _setupMyRequestsListener();
    mapController.value = MapController();
    // Load current location prediction with weather
    loadCurrentLocationPrediction();
  }

  void _initAIService() {
    _aiService = AIServiceClient(baseUrl: aiServiceUrl);
  }
  
  @override
  void onClose() {
    _myRequestsSub?.cancel();
    _alertsSubscription?.cancel();
    super.onClose();
  }
  
  void _setupMyRequestsListener() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    _myRequestsSub = _helpRequestRepo
        .getRequestsByUserId(user.uid)
        .listen((requests) {
      myRequests.value = requests;
      _updateMyRequestMarkers(requests);
    });
  }

  @override
  void onReady() {
    super.onReady();
    // Load stored OWM key (if any)
    _loadOwmKeyFromStorage();
  }
  
  void _updateMyRequestMarkers(List<domain.HelpRequestEntity> requests) {
    myRequestMarkers.value = requests.map((req) {
      // Color based on status
      Color markerColor = Colors.orange; // pending
      IconData markerIcon = Iconsax.warning_2;
      
      switch (req.status) {
        case domain.RequestStatus.pending:
          markerColor = Colors.orange;
          markerIcon = Iconsax.clock;
          break;
        case domain.RequestStatus.inProgress:
          markerColor = Colors.blue;
          markerIcon = Iconsax.refresh;
          break;
        case domain.RequestStatus.completed:
          markerColor = Colors.green;
          markerIcon = Iconsax.tick_circle;
          break;
        case domain.RequestStatus.cancelled:
          markerColor = Colors.grey;
          markerIcon = Iconsax.close_circle;
          break;
      }
      
      return Marker(
        point: LatLng(req.lat, req.lng),
        width: 50,
        height: 50,
        child: GestureDetector(
          onTap: () => _showRequestDetail(req),
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
            child: Icon(
              markerIcon,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      );
    }).toList();
  }
  
  void _showRequestDetail(domain.HelpRequestEntity request) {
    selectedRequest.value = request;
    
    // Status colors
    Color statusColor = Colors.orange;
    String statusText = 'Chờ xử lý';
    IconData statusIcon = Iconsax.clock;
    
    switch (request.status) {
      case domain.RequestStatus.pending:
        statusColor = Colors.orange;
        statusText = 'Chờ xử lý';
        statusIcon = Iconsax.clock;
        break;
      case domain.RequestStatus.inProgress:
        statusColor = Colors.blue;
        statusText = 'Đang xử lý';
        statusIcon = Iconsax.refresh;
        break;
      case domain.RequestStatus.completed:
        statusColor = Colors.green;
        statusText = 'Đã hỗ trợ';
        statusIcon = Iconsax.tick_circle;
        break;
      case domain.RequestStatus.cancelled:
        statusColor = Colors.grey;
        statusText = 'Đã hủy';
        statusIcon = Iconsax.close_circle;
        break;
    }
    
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _DetailRow(
              icon: Iconsax.document_text,
              label: 'Mô tả',
              value: request.description,
            ),
            const SizedBox(height: 12),
            _DetailRow(
              icon: Iconsax.location,
              label: 'Địa chỉ',
              value: request.address,
            ),
            const SizedBox(height: 12),
            _DetailRow(
              icon: Iconsax.call,
              label: 'Liên hệ',
              value: request.contact,
            ),
            const SizedBox(height: 12),
            _DetailRow(
              icon: Iconsax.tag,
              label: 'Loại',
              value: _getRequestTypeName(request.type),
            ),
            const SizedBox(height: 12),
            _DetailRow(
              icon: Iconsax.danger,
              label: 'Mức độ',
              value: _getRequestSeverityName(request.severity),
            ),
            const SizedBox(height: 16),
            if (request.status == domain.RequestStatus.pending)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Get.back();
                    // TODO: Navigate to edit request
                    Get.snackbar(
                      'Thông báo',
                      'Tính năng cập nhật yêu cầu đang phát triển',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  icon: const Icon(Iconsax.edit),
                  label:  Text('Cập nhật thông tin'),
                ),
              ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _initLocationService() {
    try {
      _locationService = Get.find<LocationService>();
    } catch (e) {
      _locationService = Get.put(LocationService(), permanent: true);
    }
    
    try {
      _routingService = getIt<RoutingService>();
    } catch (e) {
      _routingService = Get.put(RoutingService(), permanent: true);
    }
  }
  
  String _getRequestTypeName(domain.RequestType type) {
    return type.viName;
  }
  
  String _getRequestSeverityName(domain.RequestSeverity severity) {
    return severity.viName;
  }

  Future<void> getCurrentLocation() async {
    if (_locationService == null) {
      _initLocationService();
    }
    try {
      final position = await _locationService?.getCurrentLocation();
      currentPosition.value = position;
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> loadDisasterMarkers() async {
    isLoading.value = true;
    try {
      // Load high severity requests as disaster markers
      final highSeverityRequests = await _helpRequestRepo
          .getRequestsBySeverity(domain.RequestSeverity.high)
          .first;

      disasterMarkers.value = highSeverityRequests.map((req) {
        return Marker(
          point: LatLng(req.lat, req.lng),
          width: 40,
          height: 40,
          child: Icon(Icons.warning, color: Colors.red, size: 40),
        );
      }).toList();
    } catch (e) {
      print('Error loading disaster markers: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load hazard polygons from AI service (primary) or fallback to rule-based
  Future<void> loadPredictedHazardZones() async {
    if (!showPredictedHazards.value) {
      hazardPolygons.clear();
      hazardMarkers.clear();
      return;
    }

    isLoadingHazards.value = true;
    debugPrint('[MAP] Loading hazard zones from: $aiServiceUrl');
    try {
      // DEMO: Use October (month 10 - high risk info) instead of current month
      // to demonstrate hazard zones when testing in dry season.
      final demoMonth = 10; 
      debugPrint('[MAP] DEMO MODE: Showing hazard zones for Month $demoMonth');
      
      final result = await _aiService.getHazardZones(
        month: demoMonth,
        minRisk: 3, // Chỉ lấy rủi ro Trung bình trở lên (3,4,5)
      );

      debugPrint('[MAP] ✓ Got ${result.zones.length} zones from AI');
      
      // Filter top 30 highest risk zones to avoid clutter
      final sortedZones = List.of(result.zones)
        ..sort((a, b) => b.riskLevel.compareTo(a.riskLevel));
      
      final displayZones = sortedZones.take(30).toList();
      
      predictedHazardZones.value = displayZones;
      
      final polygons = <Polygon>[];
      final markers = <Marker>[];
      
      for (final zone in displayZones) {
        final center = LatLng(zone.lat, zone.lng);
        
        // Color and icon based on hazard type
        Color fillColor;
        Color borderColor;
        IconData icon;
        String typeLabel;
        
        switch (zone.hazardType) {
          case 'flood':
            fillColor = _getHazardFillColor(zone.riskLevel, Colors.blue);
            borderColor = Colors.blue.shade700;
            icon = Icons.water_drop;
            typeLabel = 'Lũ lụt';
            break;
          case 'landslide':
            fillColor = _getHazardFillColor(zone.riskLevel, Colors.brown);
            borderColor = Colors.brown.shade700;
            icon = Icons.landscape;
            typeLabel = 'Sạt lở';
            break;
          case 'storm':
            fillColor = _getHazardFillColor(zone.riskLevel, Colors.purple);
            borderColor = Colors.purple.shade700;
            icon = Icons.storm;
            typeLabel = 'Bão';
            break;
          default:
            fillColor = _getHazardFillColor(zone.riskLevel, Colors.red);
            borderColor = Colors.red.shade700;
            icon = Icons.warning_amber;
            typeLabel = 'Nguy hiểm';
        }
        
        // Create polygon for zone area
        final points = circlePolygon(center, zone.radiusKm, points: 48);
        polygons.add(Polygon(
          points: points,
          color: fillColor,
          borderColor: borderColor,
          borderStrokeWidth: 2.5,
          label: _getRiskLabel(zone.riskLevel),
          labelStyle: TextStyle(
            color: borderColor,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ));
        
        // Create marker at center for tap interaction - Enhanced Design
        markers.add(Marker(
          key: Key('hazard_${zone.id}'),
          point: center,
          width: 60,
          height: 70,
          child: GestureDetector(
            onTap: () => showHazardZoneDetail(zone),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Main icon container with gradient
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        borderColor,
                        borderColor.withOpacity(0.7),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: borderColor.withOpacity(0.5),
                        blurRadius: 12,
                        spreadRadius: 3,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _getHazardEmoji(zone.hazardType),
                  ),
                ),
                // Risk level badge
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getRiskBadgeColor(zone.riskLevel),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    'Cấp ${zone.riskLevel}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
      }
      
      hazardPolygons.value = polygons;
      hazardMarkers.value = markers;
      debugPrint('[MAP] ✓ Displayed ${polygons.length} hazard polygons and ${markers.length} markers');
      
    } catch (e) {
      debugPrint('[MAP] ✗ AI failed: $e');
      debugPrint('[MAP] → Falling back to rule-based');
      // Fallback to rule-based method
      await loadDisasterPolygons();
    } finally {
      isLoadingHazards.value = false;
    }
  }
  
  /// Get risk label from level
  String _getRiskLabel(int riskLevel) {
    switch (riskLevel) {
      case 1: return 'Rất thấp';
      case 2: return 'Thấp';
      case 3: return 'Trung bình';
      case 4: return 'Cao';
      case 5: return 'Rất cao';
      default: return 'Không rõ';
    }
  }
  
  /// Get fill color with enhanced opacity based on risk level
  Color _getHazardFillColor(int riskLevel, Color baseColor) {
    // More prominent opacity for higher risk
    final opacity = 0.10 + (riskLevel * 0.05); // 0.15 to 0.35
    return baseColor.withOpacity(opacity.clamp(0.10, 0.40));
  }
  
  /// Get hazard emoji widget based on type
  Widget _getHazardEmoji(String hazardType) {
    String emoji;
    switch (hazardType) {
      case 'flood':
        emoji = '🌊';
        break;
      case 'landslide':
        emoji = '⛰️';
        break;
      case 'storm':
        emoji = '🌀';
        break;
      default:
        emoji = '⚠️';
    }
    return Text(
      emoji,
      style: const TextStyle(fontSize: 24),
    );
  }
  
  /// Get risk badge color based on level
  Color _getRiskBadgeColor(int riskLevel) {
    switch (riskLevel) {
      case 1: return Colors.green.shade600;
      case 2: return Colors.lime.shade700;
      case 3: return Colors.orange.shade700;
      case 4: return Colors.deepOrange.shade600;
      case 5: return Colors.red.shade700;
      default: return Colors.grey.shade600;
    }
  }

  /// Get color based on risk level (1-5)
  Color _getRiskColor(int riskLevel, Color baseColor) {
    // Reduced opacity for better visibility of underlying map features
    final opacity = 0.05 + (riskLevel * 0.03); // 0.08 to 0.20
    return baseColor.withOpacity(opacity.clamp(0.05, 0.25));
  }

  /// Toggle predicted hazards visibility
  void togglePredictedHazards() {
    showPredictedHazards.value = !showPredictedHazards.value;
    loadPredictedHazardZones();
  }

  /// Show hazard zone details
  void showHazardZoneDetail(HazardZone zone) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getHazardIcon(zone.hazardType),
                  color: _getHazardColor(zone.hazardType),
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vùng cảnh báo ${_getHazardTypeName(zone.hazardType)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildRiskBadge(zone.riskLevel),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              zone.description,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Iconsax.location, size: 16),
                const SizedBox(width: 8),
                Text('Bán kính: ${zone.radiusKm.toStringAsFixed(1)} km'),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildRiskBadge(int riskLevel) {
    final colors = {
      1: Colors.green,
      2: Colors.lime,
      3: Colors.orange,
      4: Colors.deepOrange,
      5: Colors.red,
    };
    final labels = {
      1: 'Rất thấp',
      2: 'Thấp',
      3: 'Trung bình',
      4: 'Cao',
      5: 'Rất cao',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors[riskLevel]?.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Nguy cơ: ${labels[riskLevel]}',
        style: TextStyle(
          color: colors[riskLevel],
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  IconData _getHazardIcon(String hazardType) {
    switch (hazardType) {
      case 'flood':
        return Iconsax.cloud_drizzle;
      case 'landslide':
        return Iconsax.warning_2;
      case 'storm':
        return Iconsax.wind;
      default:
        return Iconsax.danger;
    }
  }

  Color _getHazardColor(String hazardType) {
    switch (hazardType) {
      case 'flood':
        return Colors.blue;
      case 'landslide':
        return Colors.brown;
      case 'storm':
        return Colors.purple;
      default:
        return Colors.red;
    }
  }

  String _getHazardTypeName(String hazardType) {
    switch (hazardType) {
      case 'flood':
        return 'Ngập lụt';
      case 'landslide':
        return 'Sạt lở';
      case 'storm':
        return 'Bão';
      default:
        return 'Thiên tai';
    }
  }

  /// Load hazard prediction for current location with real-time weather
  Future<void> loadCurrentLocationPrediction() async {
    final pos = currentPosition.value;
    if (pos == null) {
      debugPrint('[MAP] No current position for prediction');
      return;
    }

    isLoadingPrediction.value = true;
    try {
      final prediction = await _aiService.predictHazardRisk(
        lat: pos.latitude,
        lng: pos.longitude,
        hazardType: selectedHazardTypeForWeather.value,
        includeWeather: true,
      );

      currentHazardPrediction.value = prediction;
      debugPrint('[MAP] ✓ Loaded prediction with weather for current location');
    } catch (e) {
      debugPrint('[MAP] ✗ Error loading prediction: $e');
    } finally {
      isLoadingPrediction.value = false;
    }
  }

  /// Change hazard type and reload prediction
  Future<void> changeHazardTypeForWeather(String hazardType) async {
    selectedHazardTypeForWeather.value = hazardType;
    await loadCurrentLocationPrediction();
  }

  /// Refresh weather prediction
  Future<void> refreshWeatherPrediction() async {
    await loadCurrentLocationPrediction();
  }

  /// Dismiss weather card
  void dismissWeatherCard() {
    showWeatherCard.value = false;
  }

  /// Show weather card again
  void showWeatherCardAgain() {
    showWeatherCard.value = true;
    loadCurrentLocationPrediction();
  }

  // ===================== FILTER METHODS =====================
  
  /// Set hazard type filter and apply
  void setHazardTypeFilter(String? type) {
    hazardTypeFilter.value = type;
    applyFilters();
  }
  
  /// Search and filter by query
  void searchAndFilter(String query) {
    searchQuery.value = query.toLowerCase();
    applyFilters();
  }
  
  /// Toggle show shelters only
  void toggleSheltersOnly() {
    showSheltersOnly.value = !showSheltersOnly.value;
    applyFilters();
  }
  
  /// Clear all filters
  void clearFilters() {
    hazardTypeFilter.value = null;
    searchQuery.value = '';
    showSheltersOnly.value = false;
    applyFilters();
  }
  
  /// Check if any filter is active
  bool get hasActiveFilters => 
      hazardTypeFilter.value != null || 
      searchQuery.value.isNotEmpty ||
      showSheltersOnly.value;
  
  /// Apply filters to hazard zones and rebuild markers/polygons
  void applyFilters() {
    // If showing shelters only, clear hazard zones
    if (showSheltersOnly.value) {
      hazardPolygons.clear();
      hazardMarkers.clear();
      debugPrint('[FILTER] Showing shelters only - hazards hidden');
      return;
    }
    
    if (predictedHazardZones.isEmpty) {
      loadPredictedHazardZones();
      return;
    }
    
    var filtered = predictedHazardZones.toList();
    
    // Filter by hazard type
    if (hazardTypeFilter.value != null) {
      filtered = filtered.where((z) => z.hazardType == hazardTypeFilter.value).toList();
    }
    
    // Filter by search query (match type name or description)
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((z) {
        final typeName = _getHazardTypeName(z.hazardType).toLowerCase();
        final desc = z.description.toLowerCase();
        return typeName.contains(searchQuery.value) || desc.contains(searchQuery.value);
      }).toList();
    }
    
    _buildFilteredHazardMarkers(filtered);
    
    debugPrint('[FILTER] Applied filters: ${filtered.length} zones shown');
  }
  
  void _updateShelterVisibility() {
    // Shelters are always visible, but we can highlight if showSheltersOnly is true
    // This doesn't hide markers but can be used for UI feedback
  }
  
  void _buildFilteredHazardMarkers(List<HazardZone> zones) {
    final polygons = <Polygon>[];
    final markers = <Marker>[];
    
    for (final zone in zones) {
      final center = LatLng(zone.lat, zone.lng);
      
      Color fillColor;
      Color borderColor;
      
      switch (zone.hazardType) {
        case 'flood':
          fillColor = _getHazardFillColor(zone.riskLevel, Colors.blue);
          borderColor = Colors.blue.shade700;
          break;
        case 'landslide':
          fillColor = _getHazardFillColor(zone.riskLevel, Colors.brown);
          borderColor = Colors.brown.shade700;
          break;
        case 'storm':
          fillColor = _getHazardFillColor(zone.riskLevel, Colors.purple);
          borderColor = Colors.purple.shade700;
          break;
        default:
          fillColor = _getHazardFillColor(zone.riskLevel, Colors.red);
          borderColor = Colors.red.shade700;
      }
      
      final points = circlePolygon(center, zone.radiusKm, points: 48);
      polygons.add(Polygon(
        points: points,
        color: fillColor,
        borderColor: borderColor,
        borderStrokeWidth: 2.5,
        label: '${_getRiskLabel(zone.riskLevel)}',
        labelStyle: TextStyle(color: borderColor, fontSize: 10, fontWeight: FontWeight.bold),
      ));
      
      markers.add(Marker(
        key: Key('hazard_${zone.id}'),
        point: center,
        width: 60,
        height: 70,
        child: GestureDetector(
          onTap: () => showHazardZoneDetail(zone),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [borderColor, borderColor.withOpacity(0.7)],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(color: borderColor.withOpacity(0.5), blurRadius: 12, spreadRadius: 3),
                  ],
                ),
                child: Center(child: _getHazardEmoji(zone.hazardType)),
              ),
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getRiskBadgeColor(zone.riskLevel),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text(
                  'Cấp ${zone.riskLevel}',
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ));
    }
    
    hazardPolygons.value = polygons;
    hazardMarkers.value = markers;
  }

  /// Load hazard polygons based on high severity requests (fallback method).
  /// For now we create circular polygons around each high-severity point.
  Future<void> loadDisasterPolygons() async {
    try {
      final highSeverityRequests = await _helpRequestRepo
          .getRequestsBySeverity(domain.RequestSeverity.high)
          .first;

      final polygons = <Polygon>[];

      for (final req in highSeverityRequests) {
        final center = LatLng(req.lat, req.lng);

        // Decide radius and color by request type
        double radiusKm = 3.0;
        Color fillColor = Colors.red.withOpacity(0.12);
        Color borderColor = Colors.red.withOpacity(0.7);

        // Determine radius and colors by request type or text hints.
        // Explicit defaults (can be tuned):
        // flood -> 8 km, storm -> 150 km, landslide -> 2 km, others -> 3 km
        try {
          final type = req.type;
          switch (type) {
            case domain.RequestType.water:
            case domain.RequestType.food:
            case domain.RequestType.medicine:
            case domain.RequestType.clothes:
              radiusKm = 3.0;
              fillColor = Colors.orange.withOpacity(0.10);
              borderColor = Colors.orange.withOpacity(0.6);
              break;
            case domain.RequestType.shelter:
            case domain.RequestType.rescue:
              radiusKm = 3.0;
              fillColor = Colors.orange.withOpacity(0.10);
              borderColor = Colors.orange.withOpacity(0.6);
              break;
            default:
              // Infer from title/description for hazard-like types
              final text = '${req.title} ${req.description}'.toLowerCase();
              if (text.contains('flood') || text.contains('lũ') || text.contains('ngập')) {
                radiusKm = 8.0;
                fillColor = Colors.blue.withOpacity(0.12);
                borderColor = Colors.blue.withOpacity(0.6);
              } else if (text.contains('storm') || text.contains('bão') || text.contains('gió')) {
                radiusKm = 150.0;
                fillColor = Colors.purple.withOpacity(0.08);
                borderColor = Colors.purple.withOpacity(0.5);
              } else if (text.contains('landslide') || text.contains('sạt lở') || text.contains('sạt')) {
                radiusKm = 2.0;
                fillColor = Colors.brown.withOpacity(0.12);
                borderColor = Colors.brown.withOpacity(0.6);
              } else {
                radiusKm = 3.0;
                fillColor = Colors.orange.withOpacity(0.10);
                borderColor = Colors.orange.withOpacity(0.6);
              }
          }
        } catch (_) {
          // fallback defaults already set
        }

        final points = circlePolygon(center, radiusKm, points: 80);
        polygons.add(Polygon(
          points: points,
          color: fillColor,
          borderColor: borderColor,
          borderStrokeWidth: 2,
        ));
      }

      hazardPolygons.value = polygons;
    } catch (e) {
      print('Error loading disaster polygons: $e');
    }
  }

  Future<void> loadShelterMarkers() async {
    try {
      final shelters = await _shelterRepo.getAllShelters().first;

      shelterMarkers.value = shelters.map((shelter) {
        final available = shelter.availableSlots;

        return Marker(
          point: LatLng(shelter.lat, shelter.lng),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () {
              final shelterData = {
                'id': shelter.id,
                'name': shelter.name,
                'address': shelter.address,
                'available': available,
                'capacity': shelter.capacity,
                'occupancy': shelter.currentOccupancy,
                'lat': shelter.lat,
                'lng': shelter.lng,
              };
              selectedShelter.value = shelterData;
              _showShelterInfo(shelterData);
            },
            child: Icon(Icons.home, color: Colors.green, size: 40),
          ),
        );
      }).toList();
    } catch (e) {
      print('Error loading shelter markers: $e');
    }
  }

  /// Focus map on a specific location
  void focusOnLocation(LatLng location, {double zoom = 15.0}) {
    try {
      mapController.value?.move(location, zoom);
    } catch (e) {
      print('[VICTIM_MAP] Error focusing map: $e');
    }
  }

  /// Find route from current position to arbitrary destination and draw polyline
  Future<void> findRouteTo(LatLng destination) async {
    try {
      if (currentPosition.value == null) {
        await getCurrentLocation();
      }
      final pos = currentPosition.value;
      if (pos == null) {
        Get.snackbar('Lỗi', 'Không thể lấy vị trí hiện tại để chỉ đường');
        return;
      }
      final start = LatLng(pos.latitude, pos.longitude);
      isLoading.value = true;
      final routePoints = await _getRoutePoints(start, destination);
      if (routePoints != null && routePoints.isNotEmpty) {
        routePolylines.value = [
          Polyline(points: routePoints, strokeWidth: 4, color: Colors.blue),
        ];
        final distance = await _routingService?.getFormattedRouteDistance(
          start.latitude,
          start.longitude,
          destination.latitude,
          destination.longitude,
        );
        if (distance != null) {
          Get.snackbar('Chỉ đường', 'Khoảng cách: $distance', duration: const Duration(seconds: 3));
        }
      } else {
        // fallback straight line
        routePolylines.value = [
          Polyline(points: [start, destination], strokeWidth: 3, color: Colors.blue.withOpacity(0.6)),
        ];
        Get.snackbar('Thông báo', 'Không tìm thấy đường, hiển thị đường thẳng');
      }
    } catch (e) {
      print('[VICTIM_MAP] Error findRouteTo: $e');
      Get.snackbar('Lỗi', 'Không thể chỉ đường: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchShelter(String query) async {
    try {
      final allShelters = await _shelterRepo.getAllShelters().first;
      final queryLower = query.toLowerCase();

      final filtered = allShelters.where((shelter) {
        final name = shelter.name.toLowerCase();
        final address = shelter.address.toLowerCase();
        return name.contains(queryLower) || address.contains(queryLower);
      }).toList();

      // Update markers with filtered results
      shelterMarkers.value = filtered.map((shelter) {
        return Marker(
          point: LatLng(shelter.lat, shelter.lng),
          width: 40,
          height: 40,
          child: Icon(Icons.home, color: Colors.green, size: 40),
        );
      }).toList();
    } catch (e) {
      print('Error searching shelters: $e');
    }
  }

  void filterDisasterType(String type) {
    // Reload markers with filter
    loadDisasterMarkers();
  }

  Future<void> findRoute() async {
    if (currentPosition.value == null || selectedShelter.value == null) {
      Get.snackbar('Lỗi', 'Không thể tìm đường: Thiếu thông tin vị trí');
      return;
    }
    
    try {
      isLoading.value = true;
      
      final start = LatLng(
        currentPosition.value!.latitude,
        currentPosition.value!.longitude,
      );
      final end = LatLng(
        selectedShelter.value!['lat'],
        selectedShelter.value!['lng'],
      );
      
      print('[VICTIM_MAP] Finding route from $start to $end');
      
      // Get route using OSRM
      if (_routingService != null) {
        final routePoints = await _getRoutePoints(start, end);
        
        if (routePoints != null && routePoints.isNotEmpty) {
          routePolylines.value = [
            Polyline(
              points: routePoints,
              strokeWidth: 4,
              color: Colors.blue,
            ),
          ];
          
          final distance = await _routingService!.getFormattedRouteDistance(
            start.latitude,
            start.longitude,
            end.latitude,
            end.longitude,
          );
          
          Get.snackbar(
            'Đã tìm thấy đường đi',
            'Khoảng cách: $distance',
            duration: const Duration(seconds: 3),
          );
        } else {
          // Fallback: straight line
          routePolylines.value = [
            Polyline(
              points: [start, end],
              strokeWidth: 3,
              color: Colors.blue.withOpacity(0.5),
            ),
          ];
          Get.snackbar('Thông báo', 'Không tìm thấy đường đi, hiển thị đường thẳng');
        }
      } else {
        // No routing service, show straight line
        routePolylines.value = [
          Polyline(
            points: [start, end],
            strokeWidth: 3,
            color: Colors.blue.withOpacity(0.5),
          ),
        ];
      }
    } catch (e) {
      print('[VICTIM_MAP] Error finding route: $e');
      Get.snackbar('Lỗi', 'Không thể tìm đường: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<List<LatLng>?> _getRoutePoints(LatLng start, LatLng end) async {
    try {
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson',
      );
      
      print('[VICTIM_MAP] Fetching route geometry from OSRM...');
      
      final geoResponse = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Route request timeout'),
      );
      
      if (geoResponse.statusCode == 200) {
        final data = json.decode(geoResponse.body);
        if (data['code'] == 'Ok' && data['routes'] != null && data['routes'].isNotEmpty) {
          final geometry = data['routes'][0]['geometry'];
          if (geometry != null && geometry['coordinates'] != null) {
            final coordinates = geometry['coordinates'] as List;
            final points = coordinates.map((coord) {
              return LatLng(coord[1] as double, coord[0] as double);
            }).toList();
            print('[VICTIM_MAP] Got ${points.length} route points');
            return points;
          }
        }
      }
      print('[VICTIM_MAP] Failed to get route geometry');
    } catch (e) {
      print('[VICTIM_MAP] Error getting route points: $e');
    }
    return null;
  }

  void showReportDialog(LatLng point) {
    Get.dialog(
      AlertDialog(
        title: const Text('Báo cáo thiên tai'),
        content: Text(
          'Bạn muốn gửi yêu cầu SOS tại vị trí:\n'
          'Vĩ độ: ${point.latitude.toStringAsFixed(6)}\n'
          'Kinh độ: ${point.longitude.toStringAsFixed(6)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child:  Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Navigate to SOS screen
              Get.toNamed('/sos', arguments: {
                'lat': point.latitude,
                'lng': point.longitude,
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Gửi SOS'),
          ),
        ],
      ),
    );
  }
  
  void _showShelterInfo(Map<String, dynamic> shelter) {
    final available = shelter['available'] as int;
    final capacity = shelter['capacity'] as int;
    final occupancy = shelter['occupancy'] as int;
    final availabilityPercent = capacity > 0 ? (available / capacity * 100).toInt() : 0;
    
    Color statusColor = Colors.green;
    String statusText = 'Còn chỗ';
    if (availabilityPercent < 20) {
      statusColor = Colors.red;
      statusText = 'Gần đầy';
    } else if (availabilityPercent < 50) {
      statusColor = Colors.orange;
      statusText = 'Còn ít chỗ';
    }
    
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.home, color: statusColor, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shelter['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (shelter['address'] != null && shelter['address'].toString().isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.location_on, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      shelter['address'],
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _InfoChip(
                  icon: Icons.people,
                  label: 'Sức chứa',
                  value: '$capacity',
                ),
                _InfoChip(
                  icon: Icons.person,
                  label: 'Đang ở',
                  value: '$occupancy',
                ),
                _InfoChip(
                  icon: Icons.check_circle,
                  label: 'Còn trống',
                  value: '$available',
                  color: statusColor,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: findRoute,
                icon: const Icon(Icons.directions),
                label: const Text('Chỉ đường đến đây'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
  
  void refreshMarkers() {
    loadDisasterMarkers();
    loadShelterMarkers();
    loadAlertMarkers();
    // Refresh hazard polygons as well
    loadDisasterPolygons();
    // My requests will auto-update via stream
  }

  /// Load alert markers from Firebase
  Future<void> loadAlertMarkers() async {
    try {
      // Cancel existing subscription if any
      _alertsSubscription?.cancel();
      
      _alertsSubscription = _alertRepo.getActiveAlerts().listen((alertList) {
        // Filter alerts relevant to victims
        final relevantAlerts = alertList.where((alert) {
          return alert.targetAudience == TargetAudience.all ||
              alert.targetAudience == TargetAudience.victims ||
              alert.targetAudience == TargetAudience.locationBased;
        }).toList();

        // Sort by severity (critical first)
        relevantAlerts.sort(_compareAlerts);
        alerts.value = relevantAlerts;
      }, onError: (error) {
        debugPrint('[VICTIM_MAP] Error listening to alerts: $error');
      });
    } catch (e) {
      debugPrint('[VICTIM_MAP] Error loading alerts: $e');
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

  /// Set OpenWeatherMap API key (keep it runtime only)
  void setOwmApiKey(String? key) {
    if (key == null || key.trim().isEmpty) {
      owmApiKey.value = null;
      _secureStorage.delete(key: _owmStorageKey);
    } else {
      final val = key.trim();
      owmApiKey.value = val;
      // persist securely
      _secureStorage.write(key: _owmStorageKey, value: val);
    }
  }

  void setSelectedOwmLayer(String layer) {
    if (availableOwmLayers.contains(layer)) {
      selectedOwmLayer.value = layer;
    }
  }

  void setOwmOpacity(double opacity) {
    owmTileOpacity.value = opacity.clamp(0.0, 1.0);
  }

  void toggleShowOwmTiles(bool show) {
    showOwmTiles.value = show;
  }

  /// Return the tile URL template for the selected OWM layer (includes API key)
  String? getOwmTileUrlTemplate() {
    final key = owmApiKey.value;
    if (key == null || key.isEmpty) return null;
    final layer = selectedOwmLayer.value;
    // Example: https://tile.openweathermap.org/map/precipitation_new/{z}/{x}/{y}.png?appid=APIKEY
    return 'https://tile.openweathermap.org/map/$layer/{z}/{x}/{y}.png?appid=$key';
  }

  /// Load stored OWM key from secure storage (if exists)
  Future<void> _loadOwmKeyFromStorage() async {
    try {
      final stored = await _secureStorage.read(key: _owmStorageKey);
      if (stored != null && stored.isNotEmpty) {
        owmApiKey.value = stored;
      }
    } catch (e) {
      print('Error loading OWM key from storage: $e');
    }
  }

  /// Set radar overlay image (network URL) and its bounds on the map.
  void setRadarOverlay(String imageUrl, LatLngBounds bounds) {
    radarImageUrl.value = imageUrl;
    radarBounds.value = bounds;
  }

  /// Clear any radar overlay
  void clearRadarOverlay() {
    radarImageUrl.value = null;
    radarBounds.value = null;
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
               SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color ?? Colors.blue),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
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
