import '../failures/failures.dart';
import '../repositories/authentication_repository.dart';

/// Use case để xác thực lại user (re-authenticate)
class ReAuthenticateUseCase {
  final AuthenticationRepository repository;

  ReAuthenticateUseCase(this.repository);

  /// Execute re-authentication
  Future<void> call(String email, String password) async {
    try {
      // Validation
      if (email.isEmpty) {
        throw ValidationFailure('Email cannot be empty');
      }
      if (password.isEmpty) {
        throw ValidationFailure('Password cannot be empty');
      }
      if (!repository.isAuthenticated) {
        throw AuthenticationFailure('User is not authenticated');
      }

      await repository.reAuthenticateWithEmailAndPassword(email, password);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Re-authentication failed: ${e.toString()}');
    }
  }
}










