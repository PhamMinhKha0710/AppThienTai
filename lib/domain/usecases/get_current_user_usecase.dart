import '../entities/user_entity.dart';
import '../failures/failures.dart';
import '../repositories/user_repository.dart';

/// Use case để lấy thông tin user hiện tại
class GetCurrentUserUseCase {
  final UserRepository repository;

  GetCurrentUserUseCase(this.repository);

  /// Execute use case
  /// Trả về UserEntity hoặc null nếu không có user đăng nhập
  Future<UserEntity?> call() async {
    try {
      return await repository.getCurrentUser();
    } catch (e) {
      throw UnknownFailure('Failed to get current user: ${e.toString()}');
    }
  }
}










