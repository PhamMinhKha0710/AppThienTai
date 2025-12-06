import '../failures/failures.dart';
import '../repositories/authentication_repository.dart';

/// Use case để gửi email xác thực
class SendEmailVerificationUseCase {
  final AuthenticationRepository repository;

  SendEmailVerificationUseCase(this.repository);

  /// Execute send email verification
  Future<void> call() async {
    try {
      if (!repository.isAuthenticated) {
        throw AuthenticationFailure('User is not authenticated');
      }

      await repository.sendEmailVerification();
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to send email verification: ${e.toString()}');
    }
  }
}

