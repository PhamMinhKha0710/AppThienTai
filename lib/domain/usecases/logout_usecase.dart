import '../failures/failures.dart';
import '../repositories/authentication_repository.dart';

/// Use case để đăng xuất
class LogoutUseCase {
  final AuthenticationRepository repository;

  LogoutUseCase(this.repository);

  /// Execute logout
  Future<void> call() async {
    try {
      if (!repository.isAuthenticated) {
        throw AuthenticationFailure('User is not authenticated');
      }

      await repository.logout();
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Logout failed: ${e.toString()}');
    }
  }
}

