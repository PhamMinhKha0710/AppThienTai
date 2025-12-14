/// Base class cho tất cả domain failures
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

/// Server failure - Lỗi từ server/API
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Cache failure - Lỗi khi đọc/ghi cache
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Network failure - Lỗi kết nối mạng
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Authentication failure - Lỗi xác thực
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message);
}

/// Validation failure - Lỗi validation
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Unknown failure - Lỗi không xác định
class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}














