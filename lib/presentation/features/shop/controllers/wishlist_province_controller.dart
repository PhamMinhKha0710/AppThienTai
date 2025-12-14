import 'package:cuutrobaolu/core/utils/vietnam_provinces_helper.dart';
import 'package:get/get.dart';
import 'package:vietnam_provinces/vietnam_provinces.dart';

class WishlistProvinceController extends GetxController {
  final selectedProvince = Rxn<Province>();
  final selectedDistrict = Rxn<District>();
  final selectedWard = Rxn<Ward>();

  final filteredProvinces = <Province>[].obs;
  final filteredDistricts = <District>[].obs;
  final filteredWards = <Ward>[].obs;

  final currentVersion = AdministrativeDivisionVersion.v2.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeProvinces();
  }

  Future<void> _initializeProvinces() async {
    try {
      await VietnamProvincesHelper.ensureInitialized(version: currentVersion.value);
      final provinces = await VietnamProvincesHelper.getProvinces(version: currentVersion.value);
      filteredProvinces.value = provinces;
    } catch (e) {
      print('Error initializing provinces: $e');
    }
  }

  Future<void> switchVersion(AdministrativeDivisionVersion newVersion) async {
    if (newVersion == currentVersion.value) return;

    isLoading.value = true;
    selectedProvince.value = null;
    selectedDistrict.value = null;
    selectedWard.value = null;
    filteredDistricts.clear();
    filteredWards.clear();

    try {
      await VietnamProvincesHelper.ensureInitialized(version: newVersion);
      final provinces = await VietnamProvincesHelper.getProvinces(version: newVersion);
      currentVersion.value = newVersion;
      filteredProvinces.value = provinces;
    } catch (e) {
      print('Error switching version: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateFilteredProvinces(String query) async {
    selectedProvince.value = null;
    selectedDistrict.value = null;
    selectedWard.value = null;
    filteredWards.clear();
    filteredDistricts.clear();
    
    try {
      final provinces = await VietnamProvincesHelper.getProvinces(
        query: query.isEmpty ? null : query,
        version: currentVersion.value,
      );
      filteredProvinces.value = provinces;
    } catch (e) {
      print('Error filtering provinces: $e');
    }
  }

  Future<void> updateFilteredDistricts(String query) async {
    selectedDistrict.value = null;
    selectedWard.value = null;
    filteredWards.clear();
    
    if (selectedProvince.value != null) {
      try {
        final districts = await VietnamProvincesHelper.getDistricts(
          provinceCode: selectedProvince.value!.code.toString(),
          query: query.isEmpty ? null : query,
          version: currentVersion.value,
        );
        filteredDistricts.value = districts;
      } catch (e) {
        print('Error filtering districts: $e');
      }
    }
  }

  Future<void> updateFilteredWards(String query) async {
    selectedWard.value = null;
    
    try {
      if (currentVersion.value == AdministrativeDivisionVersion.v2) {
        // For v2, wards are directly under province
        if (selectedProvince.value != null) {
          final wards = await VietnamProvincesHelper.getWards(
            districtCode: '0',
            provinceCode: selectedProvince.value!.code.toString(),
            query: query.isEmpty ? null : query,
            version: currentVersion.value,
          );
          filteredWards.value = wards;
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
          filteredWards.value = wards;
        }
      }
    } catch (e) {
      print('Error filtering wards: $e');
    }
  }

  Future<void> selectProvince(String provinceName) async {
    selectedProvince.value = filteredProvinces.firstWhere((p) => p.name == provinceName);
    selectedDistrict.value = null;
    selectedWard.value = null;
    filteredWards.clear();

    try {
      if (currentVersion.value == AdministrativeDivisionVersion.v1) {
        // For v1, load districts
        final districts = await VietnamProvincesHelper.getDistricts(
          provinceCode: selectedProvince.value!.code.toString(),
          version: currentVersion.value,
        );
        filteredDistricts.value = districts;
      } else {
        // For v2, load wards directly
        final wards = await VietnamProvincesHelper.getWards(
          districtCode: '0',
          provinceCode: selectedProvince.value!.code.toString(),
          version: currentVersion.value,
        );
        filteredWards.value = wards;
      }
    } catch (e) {
      print('Error loading districts/wards: $e');
    }
  }

  Future<void> selectDistrict(String districtName) async {
    selectedDistrict.value = filteredDistricts.firstWhere((d) => d.name == districtName);
    selectedWard.value = null;
    
    try {
      final wards = await VietnamProvincesHelper.getWards(
        districtCode: selectedDistrict.value!.code.toString(),
        provinceCode: selectedProvince.value!.code.toString(),
        version: currentVersion.value,
      );
      filteredWards.value = wards;
    } catch (e) {
      print('Error loading wards: $e');
    }
  }

  void selectWard(String wardName) {
    selectedWard.value = filteredWards.firstWhere((w) => w.name == wardName);
  }
}

