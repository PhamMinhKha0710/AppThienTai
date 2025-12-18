import '../entities/shelter_entity.dart';

/// Shelter Repository Interface
/// Định nghĩa contract cho shelter operations
abstract class ShelterRepository {
  /// Lấy tất cả shelters
  Stream<List<ShelterEntity>> getAllShelters();

  /// Lấy shelters gần vị trí
  Future<List<ShelterEntity>> getNearbyShelters(
    double lat,
    double lng,
    double radiusKm,
  );

  /// Tạo shelter mới
  Future<String> createShelter(ShelterEntity shelter);

  /// Cập nhật shelter
  Future<void> updateShelter(ShelterEntity shelter);

  /// Lấy shelter theo ID
  Future<ShelterEntity?> getShelterById(String shelterId);
}


