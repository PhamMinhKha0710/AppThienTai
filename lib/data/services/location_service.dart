// lib/services/location_service.dart
import 'dart:async';
import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class LocationService extends GetxService {
  static LocationService get instance => Get.find();

  // Observables
  final currentPosition = Rxn<Position>();
  final currentAddress = Rxn<String>();
  final isLoadingLocation = false.obs;
  final locationError = Rxn<String>();
  final locationPermissionGranted = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Get last known location on init
    getLastKnownLocation();
  }

  /// ============================
  /// CHECK LOCATION PERMISSIONS (OLD) kiểm tra quyền truy cập vị trí
  /// ============================

  bool isProbablyMocked(Position pos) {
    try {
      return pos.isMocked;
    } catch (_) {
      return false;
    }
  }

  /// ============================
  /// CHECK LOCATION PERMISSIONS (IMPROVED)
  /// ============================
  Future<bool> checkLocationPermission() async {
    try {
      print('[LOC] start checkLocationPermission');

      // 1) isLocationServiceEnabled with timeout
      print('[LOC] calling isLocationServiceEnabled...');
      bool serviceEnabled = false;
      try {
        serviceEnabled = await Geolocator.isLocationServiceEnabled().timeout(
          const Duration(seconds: 5),
        );
      } on TimeoutException {
        print('[LOC] isLocationServiceEnabled TIMEOUT');
        locationError.value =
            'Không xác định trạng thái dịch vụ vị trí (timeout).';
        locationPermissionGranted.value = false;
        return false;
      }

      print('[LOC] serviceEnabled=$serviceEnabled');
      if (!serviceEnabled) {
        locationError.value = 'Dịch vụ vị trí chưa được bật. Vui lòng bật GPS.';
        locationPermissionGranted.value = false;
        return false;
      }

      // 2) checkPermission with timeout
      print('[LOC] calling checkPermission...');
      LocationPermission permission;
      try {
        permission = await Geolocator.checkPermission().timeout(
          const Duration(seconds: 5),
        );
      } on TimeoutException {
        print('[LOC] checkPermission TIMEOUT');
        locationError.value = 'Không thể kiểm tra quyền (timeout).';
        locationPermissionGranted.value = false;
        return false;
      }

      print('[LOC] current permission = $permission');

      // 3) requestPermission only if denied
      if (permission == LocationPermission.denied) {
        print('[LOC] permission is denied -> requestPermission...');
        try {
          permission = await Geolocator.requestPermission().timeout(
            const Duration(seconds: 10),
          );
        } on TimeoutException {
          print('[LOC] requestPermission TIMEOUT');
          locationError.value = 'Yêu cầu quyền bị timeout. Vui lòng thử lại.';
          locationPermissionGranted.value = false;
          return false;
        }
        print('[LOC] permission after request = $permission');
      }

      final isGranted =
          permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;

      locationPermissionGranted.value = isGranted;

      if (!isGranted) {
        if (permission == LocationPermission.deniedForever) {
          locationError.value =
              'Quyền truy cập vị trí bị từ chối vĩnh viễn. Vui lòng cấp quyền trong cài đặt.';
          print('[LOC] deniedForever -> opening app settings hint');
          // Bạn có thể mở setting trực tiếp để user sửa:
          // await Geolocator.openAppSettings();
        } else {
          locationError.value = 'Quyền truy cập vị trí bị từ chối.';
        }
      }

      print('[LOC] checkLocationPermission result = $isGranted');
      return isGranted;
    } catch (e, st) {
      print('[LOC] checkLocationPermission EXCEPTION: $e\n$st');
      locationError.value = 'Lỗi kiểm tra quyền vị trí: $e';
      return false;
    }
  }

  /// ============================
  /// GET CURRENT LOCATION WITH ADDRESS // lấy vị trí hiện tại
  /// ============================
  Future<Position?> getCurrentLocation({
    int maxRetries = 3,
    Duration totalTimeout = const Duration(seconds: 20),
    double desiredAccuracyMeters = 30.0, // chấp nhận nếu độ chính xác <= 30m
    bool forceAndroidLocationManager = false, // useful for some emulators
  }) async {
    final sw = Stopwatch()..start();
    isLoadingLocation.value = true;
    locationError.value = null;

    try {
      print(
        '[LOC] getCurrentLocation START (desiredAcc=${desiredAccuracyMeters}m)',
      );
      final hasPermission = await checkLocationPermission();
      if (!hasPermission) {
        print('[LOC] permission not granted');
        return null;
      }

      if (!await Geolocator.isLocationServiceEnabled()) {
        locationError.value = 'Dịch vụ vị trí chưa bật.';
        print('[LOC] location service disabled');
        return null;
      }

      Position? bestPosition;
      int attempt = 0;
      final perAttemptTimeout = Duration(
        milliseconds: (totalTimeout.inMilliseconds / maxRetries).ceil(),
      );

      while (sw.elapsed < totalTimeout && attempt < maxRetries) {
        attempt++;
        try {
          print(
            '[LOC] Attempt #$attempt, perAttemptTimeout=$perAttemptTimeout',
          );
          final pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: perAttemptTimeout,
            forceAndroidLocationManager: forceAndroidLocationManager,
          );

          print(
            '[LOC] got pos: lat=${pos.latitude}, lng=${pos.longitude}, acc=${pos.accuracy}m, time=${pos.timestamp}',
          );
          // Keep the best (lowest accuracy) position
          if (bestPosition == null ||
              (pos.accuracy != null && pos.accuracy < bestPosition.accuracy!)) {
            bestPosition = pos;
          }

          // If this position meets desired accuracy, break early
          if (pos.accuracy != null && pos.accuracy <= desiredAccuracyMeters) {
            print(
              '[LOC] desired accuracy achieved (${pos.accuracy}m). Breaking.',
            );
            break;
          }

          // Otherwise wait briefly and retry to get better satellite lock
          await Future.delayed(const Duration(milliseconds: 400));
        } on TimeoutException {
          print('[LOC] Attempt #$attempt timed out');
        } catch (e) {
          print('[LOC] Attempt #$attempt error: $e');
        }
      }

      // If we didn't get current, fallback to last known
      if (bestPosition == null) {
        try {
          final last = await Geolocator.getLastKnownPosition();
          print('[LOC] fallback lastKnownPosition = $last');
          bestPosition = last;
        } catch (e) {
          print('[LOC] getLastKnownPosition error: $e');
        }
      }

      if (bestPosition == null) {
        locationError.value = 'Không lấy được vị trí hiện tại.';
        return null;
      }

      // Log final chosen position
      print(
        '[LOC] FINAL pos: lat=${bestPosition.latitude}, lng=${bestPosition.longitude}, acc=${bestPosition.accuracy}m, time=${bestPosition.timestamp}',
      );

      currentPosition.value = bestPosition;
      await _getAddressFromPosition(bestPosition);

      return bestPosition;
    } catch (e, st) {
      locationError.value = 'Không thể lấy vị trí: $e';
      print('[LOC] getCurrentLocation EXCEPTION: $e\n$st');
      return null;
    } finally {
      isLoadingLocation.value = false;
      print('[LOC] getCurrentLocation END');
    }
  }

  /// ============================
  /// GET ADDRESS FROM POSITION (PRIVATE): lấy địa chỉ theo toạ độ
  /// ============================
  Future<void> _getAddressFromPosition(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;

        // Xây dựng địa chỉ tiếng Việt
        final addressParts = <String>[];

        if (placemark.street != null && placemark.street!.isNotEmpty) {
          addressParts.add(placemark.street!);
        }

        if (placemark.subLocality != null &&
            placemark.subLocality!.isNotEmpty) {
          addressParts.add(placemark.subLocality!);
        }

        if (placemark.locality != null && placemark.locality!.isNotEmpty) {
          addressParts.add(placemark.locality!);
        }

        if (placemark.administrativeArea != null &&
            placemark.administrativeArea!.isNotEmpty) {
          addressParts.add(placemark.administrativeArea!);
        }

        if (addressParts.isNotEmpty) {
          currentAddress.value = addressParts.join(', ');
        }
      }
    } catch (e) {
      print("Geocoding error: $e");
      // Không xử lý lỗi ở đây vì không ảnh hưởng đến chức năng chính
    }
  }

  /// ============================
  /// GET LAST KNOWN LOCATION
  /// ============================
  Future<Position?> getLastKnownLocation() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        currentPosition.value = position;
        await _getAddressFromPosition(position);
      }
      return position;
    } catch (e) {
      return null;
    }
  }

  /// ============================
  /// GET ADDRESS FROM COORDINATES (PUBLIC)
  /// ============================
  Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return '${placemark.street ?? ''}, '
            '${placemark.subLocality ?? ''}, '
            '${placemark.locality ?? ''}';
      }
      return null;
    } catch (e) {
      print("Geocoding error: $e");
      return null;
    }
  }

  /// ============================
  /// REFRESH LOCATION
  /// ============================
  Future<void> refreshLocation() async {
    await getCurrentLocation();
  }

  /// ============================
  /// GET DISTANCE BETWEEN TWO POINTS (KM)
  /// ============================
  double getDistanceInKm(double lat1, double lng1, double lat2, double lng2) {
    try {
      final distanceInMeters = Geolocator.distanceBetween(
        lat1,
        lng1,
        lat2,
        lng2,
      );
      return distanceInMeters / 1000; // Convert to kilometers
    } catch (e) {
      return 0.0;
    }
  }

  /// ============================
  /// GET DISTANCE WITH FORMAT
  /// ============================
  String getFormattedDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    final distanceKm = getDistanceInKm(lat1, lng1, lat2, lng2);

    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m';
    } else if (distanceKm < 10) {
      return '${distanceKm.toStringAsFixed(1)} km';
    } else {
      return '${distanceKm.round()} km';
    }
  }

  /// ============================
  /// CHECK IF LOCATION IS AVAILABLE
  /// ============================
  bool get isLocationAvailable {
    return currentPosition.value != null &&
        locationPermissionGranted.value == true &&
        locationError.value == null;
  }

  /// ============================
  /// GET CURRENT COORDINATES
  /// ============================
  ({double lat, double lng})? get currentCoordinates {
    final position = currentPosition.value;
    if (position != null) {
      return (lat: position.latitude, lng: position.longitude);
    }
    return null;
  }

  /// ============================
  /// CLEAR ALL LOCATION DATA
  /// ============================
  void clearLocationData() {
    currentPosition.value = null;
    currentAddress.value = null;
    locationError.value = null;
  }

  /// ============================
  /// START LOCATION UPDATES (FOR REAL-TIME TRACKING)
  /// ============================
  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // meters
      ),
    );
  }

  /// ============================
  /// OPEN LOCATION SETTINGS
  /// ============================
  Future<void> openLocationSettings() async {
    try {
      await Geolocator.openLocationSettings();
    } catch (e) {
      print("Cannot open location settings: $e");
    }
  }

  /// ============================
  /// OPEN APP SETTINGS FOR PERMISSION
  /// ============================
  Future<void> openAppSettings() async {
    try {
      await Geolocator.openAppSettings();
    } catch (e) {
      print("Cannot open app settings: $e");
    }
  }

  /// ============================
  /// kiểm tra thời tiết coi có bị lạm dụng không
  /// ============================

  Future<bool>  isExtremeWeather(double lat, double lng) async {
    try {
      print('isExtremeWeather');
      print('lat: ${lat} - lng: ${lng}');

      final apiKey = "96c479b875506871d9e6e0c1721de21a";

      final url =
          "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lng&appid=$apiKey&units=metric";

      final response = await http.get(Uri.parse(url));
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode != 200) {
        print("❌ API Error: ${response.body}");
        return false;
      }

      final data = jsonDecode(response.body);

      print("➡️ Dữ liệu thời tiết: $data");

      // 1: Kiểu thời tiết chính
      final weather = data["weather"][0]["main"];
      print("Weather: $weather");

      // 2: Lượng mưa (mm)
      final rain = data["rain"]?["1h"] ?? data["rain"]?["3h"] ?? 0.0;
      final rainAmount = (rain as num).toDouble();

      print("Rain (mm): $rainAmount");

      // 3: Điều kiện nguy hiểm
      if (weather == "Thunderstorm") return true;

      // mưa lớn > 10mm/h
      // if (weather == "Rain" && rainAmount > 10) return true;
      if (weather == "Rain" ) return true;

      if (weather == "Drizzle") return false;
      if (weather == "Clear") return false;
      if (weather == "Clouds") return false;

      return false;
    } catch (e) {
      print("❌ Lỗi kiểm tra thời tiết: $e");
      return false;
    }
  }
}
