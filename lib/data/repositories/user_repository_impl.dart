import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/failures/failures.dart';
import '../datasources/remote/user_remote_data_source.dart';
import '../models/user_dto.dart';

/// User Repository Implementation - Implement interface từ domain layer
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final dto = await remoteDataSource.getCurrentUser();
      return dto?.toEntity();
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to get current user: ${e.toString()}');
    }
  }

  @override
  Future<void> saveUser(UserEntity user) async {
    try {
      final dto = UserDto.fromEntity(user);
      await remoteDataSource.saveUser(dto);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to save user: ${e.toString()}');
    }
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    try {
      final dto = UserDto.fromEntity(user);
      await remoteDataSource.updateUser(dto);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to update user: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      await remoteDataSource.deleteUser(userId);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to delete user: ${e.toString()}');
    }
  }

  @override
  Future<String> uploadProfileImage(String imagePath) async {
    try {
      // Note: Cần XFile từ image_picker, có thể cần refactor
      // Tạm thời giữ nguyên implementation cũ
      throw UnimplementedError('Use uploadImageCloudinary instead');
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to upload image: ${e.toString()}');
    }
  }

  @override
  Future<String?> uploadImageCloudinary(String folder, String imagePath) async {
    try {
      // Note: Cần refactor CloudinaryService để nhận String path thay vì XFile
      // Tạm thời giữ nguyên
      return null;
    } catch (e) {
      throw UnknownFailure('Failed to upload image to Cloudinary: ${e.toString()}');
    }
  }
}

