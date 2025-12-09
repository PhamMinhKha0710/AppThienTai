import '../failures/failures.dart';
import '../repositories/authentication_repository.dart';

/// Use case để đăng nhập bằng Google
class SignInWithGoogleUseCase {
  final AuthenticationRepository repository;

  SignInWithGoogleUseCase(this.repository);

  /// Execute Google sign in
  /// Trả về user ID nếu thành công, null nếu user cancel
  Future<String?> call() async {
    try {
      return await repository.signInWithGoogle();
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Google sign in failed: ${e.toString()}');
    }
  }
}




