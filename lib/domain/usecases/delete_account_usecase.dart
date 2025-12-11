import '../failures/failures.dart';
import '../repositories/authentication_repository.dart';

/// Use case để xóa tài khoản
class DeleteAccountUseCase {
  final AuthenticationRepository repository;

  DeleteAccountUseCase(this.repository);

  /// Execute delete account
  Future<void> call() async {
    try {
      if (!repository.isAuthenticated) {
        throw AuthenticationFailure('User is not authenticated');
      }

      await repository.deleteAccount();
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to delete account: ${e.toString()}');
    }
  }
}











