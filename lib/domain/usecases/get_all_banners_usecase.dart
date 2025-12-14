import '../failures/failures.dart';
import '../repositories/banner_repository.dart';
import '../entities/banner_entity.dart';

/// Use case để lấy tất cả banners
class GetAllBannersUseCase {
  final BannerRepository repository;

  GetAllBannersUseCase(this.repository);

  /// Execute get all banners
  Future<List<BannerEntity>> call() async {
    try {
      return await repository.getAllBanners();
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to get banners: ${e.toString()}');
    }
  }
}













