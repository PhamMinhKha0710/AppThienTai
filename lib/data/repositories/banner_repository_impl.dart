import '../../domain/repositories/banner_repository.dart';
import '../../domain/failures/failures.dart';
import '../datasources/remote/banner_remote_data_source.dart';
import '../../service/CloudinaryService.dart';

/// Banner Repository Implementation
class BannerRepositoryImpl implements BannerRepository {
  final BannerRemoteDataSource remoteDataSource;

  BannerRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Map<String, dynamic>>> getAllBanners() async {
    try {
      return await remoteDataSource.getAllBanners();
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to get banners: ${e.toString()}');
    }
  }

  @override
  Future<void> uploadBannersFromDummyData(
      List<Map<String, dynamic>> banners) async {
    try {
      for (var bannerData in banners) {
        // Upload image to Cloudinary
        final imageUrl = bannerData['ImageUrl'] as String? ?? '';
        if (imageUrl.isNotEmpty) {
          final url = await CloudinaryService.uploadAssetImage(
            imageUrl,
            preset: "banners",
            folder: "banners/test",
          );

          if (url != null) {
            bannerData['ImageUrl'] = url;
          }
        }

        // Upload to Firestore
        await remoteDataSource.uploadBannerToFirestore(bannerData);
      }
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to upload banners: ${e.toString()}');
    }
  }
}

