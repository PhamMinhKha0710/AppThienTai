import '../../domain/repositories/banner_repository.dart';
import '../../domain/entities/banner_entity.dart';
import '../../domain/failures/failures.dart';
import '../datasources/remote/banner_remote_data_source.dart';
import '../models/banner_dto.dart';
import '../../service/CloudinaryService.dart';

/// Banner Repository Implementation
class BannerRepositoryImpl implements BannerRepository {
  final BannerRemoteDataSource remoteDataSource;

  BannerRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<BannerEntity>> getAllBanners() async {
    try {
      final dtos = await remoteDataSource.getAllBanners();
      return dtos.map((dto) => dto.toEntity()).toList();
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to get banners: ${e.toString()}');
    }
  }

  @override
  Future<void> uploadBannersFromDummyData(List<BannerEntity> banners) async {
    try {
      for (var banner in banners) {
        // Upload image to Cloudinary
        if (banner.imageUrl.isNotEmpty) {
          final url = await CloudinaryService.uploadAssetImage(
            banner.imageUrl,
            preset: "banners",
            folder: "banners/test",
          );

          if (url != null) {
            banner = banner.copyWith(imageUrl: url);
          }
        }

        // Convert to DTO and upload to Firestore
        final dto = BannerDto.fromEntity(banner);
        await remoteDataSource.uploadBannerToFirestore(dto.toJson());
      }
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to upload banners: ${e.toString()}');
    }
  }
}













