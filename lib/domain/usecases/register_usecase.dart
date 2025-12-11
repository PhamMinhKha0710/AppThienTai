import '../failures/failures.dart';
import '../repositories/authentication_repository.dart';

/// Use case để đăng ký tài khoản mới
class RegisterUseCase {
  final AuthenticationRepository repository;

  RegisterUseCase(this.repository);

  /// Execute registration
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
      if (password.length < 6) {
        throw ValidationFailure('Password must be at least 6 characters');
      }
      if (!email.contains('@')) {
        throw ValidationFailure('Invalid email format');
      }

      return await repository.registerWithEmailAndPassword(email, password);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Registration failed: ${e.toString()}');
    }
  }
}










