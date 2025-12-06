import '../../domain/repositories/authentication_repository.dart';
import '../../domain/failures/failures.dart';
import '../datasources/remote/authentication_remote_data_source.dart';

/// Authentication Repository Implementation
class AuthenticationRepositoryImpl implements AuthenticationRepository {
  final AuthenticationRemoteDataSource remoteDataSource;

  AuthenticationRepositoryImpl(this.remoteDataSource);

  @override
  String? get currentUserId => remoteDataSource.currentUserId;

  @override
  bool get isAuthenticated => remoteDataSource.isAuthenticated;

  @override
  bool get isEmailVerified => remoteDataSource.isEmailVerified;

  @override
  Future<String> loginWithEmailAndPassword(String email, String password) async {
    try {
      return await remoteDataSource.loginWithEmailAndPassword(email, password);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<String> registerWithEmailAndPassword(String email, String password) async {
    try {
      return await remoteDataSource.registerWithEmailAndPassword(email, password);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<String?> signInWithGoogle() async {
    try {
      return await remoteDataSource.signInWithGoogle();
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Google sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Logout failed: ${e.toString()}');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      await remoteDataSource.sendEmailVerification();
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to send email verification: ${e.toString()}');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to send password reset email: ${e.toString()}');
    }
  }

  @override
  Future<void> reAuthenticateWithEmailAndPassword(String email, String password) async {
    try {
      await remoteDataSource.reAuthenticateWithEmailAndPassword(email, password);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Re-authentication failed: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await remoteDataSource.deleteAccount();
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to delete account: ${e.toString()}');
    }
  }
}

