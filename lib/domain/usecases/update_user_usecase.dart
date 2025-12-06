import '../entities/user_entity.dart';
import '../failures/failures.dart';
import '../repositories/user_repository.dart';

/// Use case để cập nhật thông tin user
class UpdateUserUseCase {
  final UserRepository repository;

  UpdateUserUseCase(this.repository);

  /// Execute update user
  Future<void> call(UserEntity user) async {
    try {
      // Validation
      if (user.id.isEmpty) {
        throw ValidationFailure('User ID cannot be empty');
      }

      await repository.updateUser(user);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to update user: ${e.toString()}');
    }
  }
}

