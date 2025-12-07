import 'package:cuutrobaolu/domain/usecases/create_help_request_usecase.dart';
import 'package:cuutrobaolu/presentation/utils/help_request_mapper.dart';
import 'package:cuutrobaolu/data/services/location_service.dart';
import 'package:cuutrobaolu/presentation/features/shop/models/help_request_modal.dart';
import 'package:cuutrobaolu/core/constants/enums.dart';
import 'package:cuutrobaolu/core/utils/vietnam_provinces_helper.dart';
import 'package:cuutrobaolu/domain/failures/failures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:vietnam_provinces/vietnam_provinces.dart';
import 'package:uuid/uuid.dart';

class CreateRequestController extends GetxController {
  // Services
  final locationService = Get.put(LocationService());
  final uuid = Uuid();

  // Use Case - Clean Architecture (lazy getter để tránh LateInitializationError)
  CreateHelpRequestUseCase get _createHelpRequestUseCase => Get.find<CreateHelpRequestUseCase>();

  // Text controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final contactController = TextEditingController();
  final detailedAddressController = TextEditingController();

  // Observables
  final isSubmitting = false.obs;
  final selectedSeverity = 'medium'.obs;
  final selectedType = 'other'.obs;

  // Address selection
  final selectedProvince = Rx<Province?>(null);
  final selectedDistrict = Rx<District?>(null);
  final selectedWard = Rx<Ward?>(null);
  final currentVersion = Rx<AdministrativeDivisionVersion>(
    AdministrativeDivisionVersion.v1,
  );

  // Filtered lists - Sử dụng Rx cho lists
  final filteredProvinces = <Province>[].obs;
  final filteredDistricts = <District>[].obs;
  final filteredWards = <Ward>[].obs;

  // Form key
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    // Initialize provinces list async
    _initializeAddressData();
    // Get location khi controller khởi tạo
    _getLocationIfNeeded();
  }

  Future<void> _initializeAddressData() async {
    try {
      currentVersion.value = AdministrativeDivisionVersion.v1; // Dùng v1 mặc định
      // Sử dụng helper để đảm bảo VietnamProvinces đã được khởi tạo
      final provinces = await VietnamProvincesHelper.getProvinces(
        version: AdministrativeDivisionVersion.v1,
      );
      filteredProvinces.assignAll(provinces);
      print('Initialized with ${filteredProvinces.length} provinces');
    } catch (e) {
      print('Error initializing address data: $e');
      // Fallback: thử khởi tạo trực tiếp
      try {
        await VietnamProvinces.initialize(version: AdministrativeDivisionVersion.v1);
        filteredProvinces.assignAll(VietnamProvinces.getProvinces());
      } catch (e2) {
        print('Error in fallback initialization: $e2');
      }
    }
  }

  /// ============================
  /// ADDRESS SELECTION METHODS
  /// ============================

  Future<void> filterProvinces(String query) async {
    try {
      final provinces = await VietnamProvincesHelper.getProvinces(
        query: query.isEmpty ? null : query,
        version: currentVersion.value,
      );
      filteredProvinces.assignAll(provinces);
    } catch (e) {
      print('Error filtering provinces: $e');
    }
  }

  Future<void> filterDistricts(String query) async {
    if (selectedProvince.value != null) {
      try {
        final districts = await VietnamProvincesHelper.getDistricts(
          provinceCode: selectedProvince.value!.code.toString(),
          query: query.isEmpty ? null : query,
          version: currentVersion.value,
        );
        filteredDistricts.assignAll(districts);
      } catch (e) {
        print('Error filtering districts: $e');
      }
    }
  }

  Future<void> filterWards(String query) async {
    try {
      if (currentVersion.value == AdministrativeDivisionVersion.v2) {
        // For v2, wards are directly under province
        if (selectedProvince.value != null) {
          final wards = await VietnamProvincesHelper.getWards(
            districtCode: '0', // v2 không cần districtCode
            provinceCode: selectedProvince.value!.code.toString(),
            query: query.isEmpty ? null : query,
            version: currentVersion.value,
          );
          filteredWards.assignAll(wards);
        }
      } else {
        // For v1, wards are under district
        if (selectedDistrict.value != null && selectedProvince.value != null) {
          final wards = await VietnamProvincesHelper.getWards(
            districtCode: selectedDistrict.value!.code.toString(),
            provinceCode: selectedProvince.value!.code.toString(),
            query: query.isEmpty ? null : query,
            version: currentVersion.value,
          );
          filteredWards.assignAll(wards);
        }
      }
    } catch (e) {
      print('Error filtering wards: $e');
    }
  }

  Future<void> selectProvince(String? provinceName) async {
    if (provinceName == null || provinceName.isEmpty) {
      selectedProvince.value = null;
      selectedDistrict.value = null;
      selectedWard.value = null;
      filteredDistricts.clear();
      filteredWards.clear();
      return;
    }

    try {
      final province = filteredProvinces.firstWhere(
        (p) => p.name == provinceName,
      );

      print('Selected province: ${province.name} (${province.code})');

      selectedProvince.value = province;
      selectedDistrict.value = null;
      selectedWard.value = null;

      // Load districts
      if (currentVersion.value == AdministrativeDivisionVersion.v1) {
        final districts = await VietnamProvincesHelper.getDistricts(
          provinceCode: province.code.toString(),
          version: currentVersion.value,
        );
        print('Loaded ${districts.length} districts for ${province.name}');
        filteredDistricts.assignAll(districts);
        filteredWards.clear();
      } else {
        // For v2, load wards directly
        final wards = await VietnamProvincesHelper.getWards(
          districtCode: '0',
          provinceCode: province.code.toString(),
          version: currentVersion.value,
        );
        print('Loaded ${wards.length} wards for ${province.name}');
        filteredDistricts.clear();
        filteredWards.assignAll(wards);
      }
    } catch (e) {
      print('Error selecting province: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể chọn tỉnh/thành phố này',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> selectDistrict(String? districtName) async {
    if (districtName == null ||
        districtName.isEmpty ||
        selectedProvince.value == null) {
      selectedDistrict.value = null;
      selectedWard.value = null;
      filteredWards.clear();
      return;
    }

    try {
      final district = filteredDistricts.firstWhere(
        (d) => d.name == districtName,
      );

      print('Selected district: ${district.name} (${district.code})');

      selectedDistrict.value = district;
      selectedWard.value = null;

      // Load wards for this district
      final wards = await VietnamProvincesHelper.getWards(
        districtCode: district.code.toString(),
        provinceCode: selectedProvince.value!.code.toString(),
        version: currentVersion.value,
      );
      print('Loaded ${wards.length} wards for ${district.name}');
      filteredWards.assignAll(wards);
    } catch (e) {
      print('Error selecting district: $e');
    }
  }

  void selectWard(String? wardName) {
    if (wardName == null || wardName.isEmpty) {
      selectedWard.value = null;
      return;
    }

    try {
      final ward = filteredWards.firstWhere((w) => w.name == wardName);

      print('Selected ward: ${ward.name} (${ward.code})');
      selectedWard.value = ward;
    } catch (e) {
      print('Error selecting ward: $e');
    }
  }

  Future<void> switchVersion(AdministrativeDivisionVersion newVersion) async {
    if (newVersion == currentVersion.value) return;

    print('Switching version from ${currentVersion.value} to $newVersion');

    try {
      await VietnamProvincesHelper.ensureInitialized(version: newVersion);

      currentVersion.value = newVersion;
      selectedProvince.value = null;
      selectedDistrict.value = null;
      selectedWard.value = null;
      filteredDistricts.clear();
      filteredWards.clear();

      final provinces = await VietnamProvincesHelper.getProvinces(version: newVersion);
      filteredProvinces.assignAll(provinces);

      print(
        'Version switched successfully. Loaded ${provinces.length} provinces',
      );
    } catch (e) {
      print('Error switching version: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể chuyển đổi phiên bản địa chỉ',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// ============================
  /// GET CURRENT LOCATION DATA FROM SERVICE
  /// ============================
  Position? get currentPosition => locationService.currentPosition.value;
  String? get currentAddress => locationService.currentAddress.value;
  bool get isLocationLoading => locationService.isLoadingLocation.value;
  String? get locationError => locationService.locationError.value;

  Future<void> _getLocationIfNeeded() async {
    // Chỉ lấy location nếu chưa có
    if (locationService.currentPosition.value == null) {
      await locationService.getCurrentLocation();
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    contactController.dispose();
    detailedAddressController.dispose();
    super.onClose();
  }

  /// ============================
  /// GET CURRENT LOCATION
  /// ============================
  Future<void> getCurrentLocation() async {
    try {
      final position = await locationService.getCurrentLocation();
      if (position != null) {
        // Hiển thị thông báo thành công
        Get.snackbar(
          'Thành công',
          'Đã lấy được vị trí hiện tại',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        
        // Nếu có địa chỉ, có thể tự động điền vào detailedAddressController
        if (locationService.currentAddress.value != null) {
          detailedAddressController.text = locationService.currentAddress.value!;
        }
      } else {
        // Hiển thị lỗi nếu có
        if (locationService.locationError.value != null) {
          Get.snackbar(
            'Lỗi',
            locationService.locationError.value!,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }
      }
    } catch (e) {
      print('Error getting current location: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể lấy vị trí: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// ============================
  /// CREATE HELP REQUEST
  /// ============================
  Future<void> createHelpRequest() async {
    try {
      // Validate form
      if (!formKey.currentState!.validate()) {
        return;
      }

      // Check address selection
      if (selectedProvince.value == null) {
        Get.snackbar(
          'Lỗi',
          'Vui lòng chọn tỉnh/thành phố',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (currentVersion.value == AdministrativeDivisionVersion.v1 &&
          selectedDistrict.value == null) {
        Get.snackbar(
          'Lỗi',
          'Vui lòng chọn quận/huyện',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (selectedWard.value == null) {
        Get.snackbar(
          'Lỗi',
          'Vui lòng chọn phường/xã',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Check detailed address
      if (detailedAddressController.text.isEmpty) {
        Get.snackbar(
          'Lỗi',
          'Vui lòng nhập địa chỉ chi tiết',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      isSubmitting.value = true;

      // TODO: Get current user ID từ AuthService (nếu có)
      // Tạm thời dùng ID tạm

      final _auth = FirebaseAuth.instance;

      final user = _auth.currentUser;
      final userId = user?.uid;

      print('userId:  ${userId}');

      final requestId = uuid.v4();

      // Build full address
      String fullAddress = detailedAddressController.text.trim();
      if (currentVersion.value == AdministrativeDivisionVersion.v1) {
        fullAddress +=
            ', ${selectedWard.value?.name}, '
            '${selectedDistrict.value?.name}, '
            '${selectedProvince.value?.name}';
      } else {
        fullAddress +=
            ', ${selectedWard.value?.name}, '
            '${selectedProvince.value?.name}';
      }

      // Use GPS coordinates if available, otherwise use approximate coordinates
      // double lat = 0.0 ;
      // double lng = 0.0 ;
      //
      // 1. Ưu tiên dùng GPS
      // if (locationService.currentPosition.value != null) {
      //   lat = locationService.currentPosition.value!.latitude;
      //   lng = locationService.currentPosition.value!.longitude;
      //
      // } else {
      //   // 2. Không có GPS → dùng geocoding từ fullAddress
      //   try {
      //     final locations = await locationFromAddress(fullAddress);
      //
      //     if (locations.isNotEmpty) {
      //       lat = locations.first.latitude;
      //       lng = locations.first.longitude;
      //     }
      //   } catch (e) {
      //     print('Geocoding error: $e');
      //   }
      // }

      List<Location> locations = await locationFromAddress(fullAddress);
      double lat = locations.first.latitude;
      double lng = locations.first.longitude;

      print('lat: ${lat} - lng: ${lng}');

      // Kiểm tra thời tieets
      final check = await locationService.isExtremeWeather(lat, lng);
      if (check != true) {
        print("Không thể gửi yêu cầu: do không có thời tiết phù hợp");
        Get.snackbar(
          'Lỗi',
          'Không thể gửi yêu cầu: do không có thời tiết phù hợp',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return ;
      }

      // Convert string severity to enum
      RequestSeverity severityEnum;
      switch (selectedSeverity.value) {
        case 'low':
          severityEnum = RequestSeverity.low;
          break;
        case 'medium':
          severityEnum = RequestSeverity.medium;
          break;
        case 'high':
          severityEnum = RequestSeverity.high;
          break;
        default:
          severityEnum = RequestSeverity.medium;
      }

      // Convert string type to enum
      RequestType typeEnum;
      switch (selectedType.value) {
        case 'food':
          typeEnum = RequestType.food;
          break;
        case 'water':
          typeEnum = RequestType.water;
          break;
        case 'medicine':
          typeEnum = RequestType.medicine;
          break;
        case 'clothes':
          typeEnum = RequestType.clothes;
          break;
        case 'shelter':
          typeEnum = RequestType.shelter;
          break;
        case 'other':
        default:
          typeEnum = RequestType.other;
      }

      // Create HelpRequest object (presentation model)
      final helpRequest = HelpRequest(
        id: requestId,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        lat: lat,
        lng: lng,
        contact: contactController.text.trim(),
        severity: severityEnum,
        type: typeEnum,
        status: RequestStatus.pending,
        address: fullAddress,
        province: selectedProvince.value?.name,
        district: currentVersion.value == AdministrativeDivisionVersion.v1
            ? selectedDistrict.value?.name
            : null,
        ward: selectedWard.value?.name,
        detailedAddress: detailedAddressController.text.trim(),
        userId: userId,
        createdAt: DateTime.now(),
      );

      // Convert to Entity and use Use Case
      final helpRequestEntity = HelpRequestMapper.toEntity(helpRequest);
      final createdId = await _createHelpRequestUseCase(helpRequestEntity);

      Get.snackbar(
        'Thành công!',
        'Yêu cầu trợ giúp đã được gửi với ID: $createdId',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Clear form
      _clearForm();

      // Navigate back after delay
      await Future.delayed(const Duration(milliseconds: 1500));
      Get.back();
    } on Failure catch (failure) {
      print('Error creating help request: ${failure.message}');
      Get.snackbar(
        'Lỗi',
        failure.message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error creating help request: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể gửi yêu cầu: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void _clearForm() {
    titleController.clear();
    descriptionController.clear();
    contactController.clear();
    detailedAddressController.clear();
    selectedSeverity.value = 'medium';
    selectedType.value = 'other';
    selectedProvince.value = null;
    selectedDistrict.value = null;
    selectedWard.value = null;
    filteredDistricts.clear();
    filteredWards.clear();
  }

  /// ============================
  /// UPDATE SEVERITY
  /// ============================
  void updateSeverity(String severity) {
    selectedSeverity.value = severity;
  }

  /// ============================
  /// UPDATE TYPE
  /// ============================
  void updateType(String type) {
    selectedType.value = type;
  }

  /// ============================
  /// GET SEVERITY COLOR
  /// ============================
  Color getSeverityColor(String severity) {
    switch (severity) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// ============================
  /// VALIDATION METHODS
  /// ============================
  String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập tiêu đề';
    }
    if (value.length < 5) {
      return 'Tiêu đề phải có ít nhất 5 ký tự';
    }
    return null;
  }

  String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mô tả';
    }
    if (value.length < 10) {
      return 'Mô tả phải có ít nhất 10 ký tự';
    }
    return null;
  }

  String? validateContact(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập thông tin liên hệ';
    }
    return null;
  }

  String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập địa chỉ chi tiết';
    }
    if (value.length < 5) {
      return 'Địa chỉ phải có ít nhất 5 ký tự';
    }
    return null;
  }
}

