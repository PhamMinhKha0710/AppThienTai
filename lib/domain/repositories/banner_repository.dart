import '../entities/banner_entity.dart';

/// Banner Repository Interface
/// Định nghĩa contract cho banner operations
abstract class BannerRepository {
  /// Lấy tất cả banners đang active
  Future<List<BannerEntity>> getAllBanners();

  /// Upload banners từ dummy data lên Cloudinary
  Future<void> uploadBannersFromDummyData(List<BannerEntity> banners);
}













