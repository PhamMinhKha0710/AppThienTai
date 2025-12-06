import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/exceptions/exports.dart';
import '../../../domain/failures/failures.dart';

/// Remote Data Source cho Authentication - Tương tác trực tiếp với Firebase Auth
abstract class AuthenticationRemoteDataSource {
  String? get currentUserId;
  bool get isAuthenticated;
  bool get isEmailVerified;
  
  Future<String> loginWithEmailAndPassword(String email, String password);
  Future<String> registerWithEmailAndPassword(String email, String password);
  Future<String?> signInWithGoogle();
  Future<void> logout();
  Future<void> sendEmailVerification();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> reAuthenticateWithEmailAndPassword(String email, String password);
  Future<void> deleteAccount();
}

class AuthenticationRemoteDataSourceImpl implements AuthenticationRemoteDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  bool get isAuthenticated => _auth.currentUser != null;

  @override
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  @override
  Future<String> loginWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user?.uid ?? '';
    } on FirebaseAuthException catch (e) {
      throw AuthenticationFailure(MinhFirebaseAuthException(e.code).message);
    } catch (e) {
      throw UnknownFailure('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<String> registerWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user?.uid ?? '';
    } on FirebaseAuthException catch (e) {
      throw AuthenticationFailure(MinhFirebaseAuthException(e.code).message);
    } catch (e) {
      throw UnknownFailure('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? userAccount = await _googleSignIn.signIn();
      if (userAccount == null) return null;

      final GoogleSignInAuthentication? googleAuth = await userAccount.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user?.uid;
    } on FirebaseAuthException catch (e) {
      throw AuthenticationFailure(MinhFirebaseAuthException(e.code).message);
    } catch (e) {
      throw UnknownFailure('Google sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      throw UnknownFailure('Logout failed: ${e.toString()}');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthenticationFailure(MinhFirebaseAuthException(e.code).message);
    } catch (e) {
      throw UnknownFailure('Failed to send email verification: ${e.toString()}');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthenticationFailure(MinhFirebaseAuthException(e.code).message);
    } catch (e) {
      throw UnknownFailure('Failed to send password reset email: ${e.toString()}');
    }
  }

  @override
  Future<void> reAuthenticateWithEmailAndPassword(String email, String password) async {
    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await _auth.currentUser!.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthenticationFailure(MinhFirebaseAuthException(e.code).message);
    } catch (e) {
      throw UnknownFailure('Re-authentication failed: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthenticationFailure(MinhFirebaseAuthException(e.code).message);
    } catch (e) {
      throw UnknownFailure('Failed to delete account: ${e.toString()}');
    }
  }
}

