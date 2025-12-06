import '../failures/failures.dart';
import '../repositories/user_repository.dart';

/// Use case để upload ảnh bằng Cloudinary
class UploadImageUseCase {
  final UserRepository repository;

  UploadImageUseCase(this.repository);

  /// Execute upload image to Cloudinary
  /// Trả về URL của ảnh đã upload
  Future<String?> call(String folder, String imagePath) async {
    try {
      // Validation
      if (folder.isEmpty) {
        throw ValidationFailure('Folder cannot be empty');
      }
      if (imagePath.isEmpty) {
        throw ValidationFailure('Image path cannot be empty');
      }

      return await repository.uploadImageCloudinary(folder, imagePath);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to upload image: ${e.toString()}');
    }
  }
}

