import '../failures/failures.dart';
import '../repositories/authentication_repository.dart';

/// Use case để đăng nhập
class LoginUseCase {
  final AuthenticationRepository repository;

  LoginUseCase(this.repository);

  /// Execute login
  /// Trả về user ID nếu thành công
  Future<String> call(String email, String password) async {
    try {
      // Validation
      if (email.isEmpty) {
        throw ValidationFailure('Email cannot be empty');
      }
      if (password.isEmpty) {
        throw ValidationFailure('Password cannot be empty');
      }

      return await repository.loginWithEmailAndPassword(email, password);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Login failed: ${e.toString()}');
    }
  }
}














