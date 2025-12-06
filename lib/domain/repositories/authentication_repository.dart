/// Authentication Repository Interface
/// Định nghĩa contract cho authentication operations
abstract class AuthenticationRepository {
  /// Lấy user hiện tại đã đăng nhập
  String? get currentUserId;

  /// Kiểm tra user đã đăng nhập chưa
  bool get isAuthenticated;

  /// Đăng nhập bằng email và password
  Future<String> loginWithEmailAndPassword(String email, String password);

  /// Đăng ký tài khoản mới
  Future<String> registerWithEmailAndPassword(String email, String password);

  /// Đăng nhập bằng Google
  Future<String?> signInWithGoogle();

  /// Đăng xuất
  Future<void> logout();

  /// Gửi email xác thực
  Future<void> sendEmailVerification();

  /// Gửi email reset password
  Future<void> sendPasswordResetEmail(String email);

  /// Xác thực lại user (re-authenticate)
  Future<void> reAuthenticateWithEmailAndPassword(
    String email,
    String password,
  );

  /// Xóa tài khoản
  Future<void> deleteAccount();

  /// Kiểm tra email đã được verify chưa
  bool get isEmailVerified;
}

