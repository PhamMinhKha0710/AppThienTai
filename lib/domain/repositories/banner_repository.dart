/// Banner Repository Interface
/// Định nghĩa contract cho banner operations
abstract class BannerRepository {
  /// Lấy tất cả banners đang active
  Future<List<Map<String, dynamic>>> getAllBanners();

  /// Upload banners từ dummy data lên Cloudinary
  Future<void> uploadBannersFromDummyData(List<Map<String, dynamic>> banners);
}







