import '../entities/user_entity.dart';
import '../failures/failures.dart';
import '../repositories/user_repository.dart';

/// Use case để lưu thông tin user
class SaveUserUseCase {
  final UserRepository repository;

  SaveUserUseCase(this.repository);

  /// Execute save user
  Future<void> call(UserEntity user) async {
    try {
      // Validation
      if (user.id.isEmpty) {
        throw ValidationFailure('User ID cannot be empty');
      }
      if (user.email.isEmpty) {
        throw ValidationFailure('Email cannot be empty');
      }

      await repository.saveUser(user);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to save user: ${e.toString()}');
    }
  }
}










