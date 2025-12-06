import '../entities/user_entity.dart';

/// User Repository Interface
/// Định nghĩa contract cho việc lấy và lưu user data
/// Implementation sẽ ở data layer
abstract class UserRepository {
  /// Lấy thông tin user hiện tại
  /// Trả về UserEntity hoặc null nếu không tìm thấy
  Future<UserEntity?> getCurrentUser();

  /// Lưu thông tin user
  Future<void> saveUser(UserEntity user);

  /// Cập nhật thông tin user
  Future<void> updateUser(UserEntity user);

  /// Xóa user
  Future<void> deleteUser(String userId);

  /// Upload ảnh profile
  Future<String> uploadProfileImage(String imagePath);

  /// Upload ảnh bằng Cloudinary
  Future<String?> uploadImageCloudinary(String folder, String imagePath);
}

