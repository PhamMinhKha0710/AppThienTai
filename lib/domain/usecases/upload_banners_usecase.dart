import '../failures/failures.dart';
import '../repositories/banner_repository.dart';

/// Use case để upload banners từ dummy data
class UploadBannersUseCase {
  final BannerRepository repository;

  UploadBannersUseCase(this.repository);

  /// Execute upload banners
  Future<void> call(List<Map<String, dynamic>> banners) async {
    try {
      if (banners.isEmpty) {
        throw ValidationFailure('Banners list cannot be empty');
      }

      await repository.uploadBannersFromDummyData(banners);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to upload banners: ${e.toString()}');
    }
  }
}



