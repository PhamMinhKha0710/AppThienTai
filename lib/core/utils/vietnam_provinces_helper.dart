import 'package:vietnam_provinces/vietnam_provinces.dart';

/// Helper class để lazy load VietnamProvinces
/// Giúp tránh load dữ liệu lớn khi khởi động app
class VietnamProvincesHelper {
  static bool _isInitialized = false;
  static AdministrativeDivisionVersion _currentVersion = AdministrativeDivisionVersion.v2;

  /// Đảm bảo VietnamProvinces đã được khởi tạo
  /// Nếu chưa khởi tạo, sẽ tự động khởi tạo với version mặc định
  static Future<void> ensureInitialized({
    AdministrativeDivisionVersion? version,
  }) async {
    if (!_isInitialized || 
        (version != null && version != _currentVersion)) {
      await VietnamProvinces.initialize(
        version: version ?? AdministrativeDivisionVersion.v2,
      );
      _isInitialized = true;
      if (version != null) {
        _currentVersion = version;
      }
    }
  }

  /// Lấy danh sách tỉnh thành, tự động khởi tạo nếu cần
  static Future<List<Province>> getProvinces({
    String? query,
    AdministrativeDivisionVersion? version,
  }) async {
    await ensureInitialized(version: version);
    return VietnamProvinces.getProvinces(query: query);
  }

  /// Lấy danh sách quận/huyện, tự động khởi tạo nếu cần
  static Future<List<District>> getDistricts({
    required String provinceCode,
    String? query,
    AdministrativeDivisionVersion? version,
  }) async {
    await ensureInitialized(version: version);
    return VietnamProvinces.getDistricts(
      provinceCode: int.tryParse(provinceCode) ?? 0,
      query: query,
    );
  }

  /// Lấy danh sách phường/xã, tự động khởi tạo nếu cần
  /// Note: provinceCode có thể required tùy version, nên luôn truyền nếu có
  static Future<List<Ward>> getWards({
    required String districtCode,
    String? provinceCode,
    String? query,
    AdministrativeDivisionVersion? version,
  }) async {
    await ensureInitialized(version: version);
    final parsedDistrictCode = int.tryParse(districtCode) ?? 0;
    // Nếu có provinceCode, parse và truyền vào
    if (provinceCode != null) {
      final parsedProvinceCode = int.tryParse(provinceCode) ?? 0;
      return VietnamProvinces.getWards(
        districtCode: parsedDistrictCode,
        provinceCode: parsedProvinceCode,
        query: query,
      );
    } else {
      // Nếu không có provinceCode, chỉ truyền districtCode (có thể không hoạt động với một số version)
      // Tạm thời dùng 0 làm default
      return VietnamProvinces.getWards(
        districtCode: parsedDistrictCode,
        provinceCode: 0, // Default value
        query: query,
      );
    }
  }

  /// Lấy version hiện tại
  static AdministrativeDivisionVersion get currentVersion => _currentVersion;
}

