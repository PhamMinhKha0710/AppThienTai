import '../failures/failures.dart';
import '../repositories/authentication_repository.dart';

/// Use case để gửi email reset password
class SendPasswordResetUseCase {
  final AuthenticationRepository repository;

  SendPasswordResetUseCase(this.repository);

  /// Execute send password reset email
  Future<void> call(String email) async {
    try {
      // Validation
      if (email.isEmpty) {
        throw ValidationFailure('Email cannot be empty');
      }
      if (!email.contains('@')) {
        throw ValidationFailure('Invalid email format');
      }

      await repository.sendPasswordResetEmail(email);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to send password reset email: ${e.toString()}');
    }
  }
}











