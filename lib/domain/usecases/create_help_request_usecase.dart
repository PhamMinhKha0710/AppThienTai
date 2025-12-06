import '../failures/failures.dart';
import '../repositories/help_request_repository.dart';
import '../entities/help_request_entity.dart';

/// Use case để tạo help request mới
class CreateHelpRequestUseCase {
  final HelpRequestRepository repository;

  CreateHelpRequestUseCase(this.repository);

  /// Execute create help request
  Future<String> call(HelpRequestEntity request) async {
    try {
      // Validation
      if (request.title.isEmpty) {
        throw ValidationFailure('Title cannot be empty');
      }
      if (request.description.isEmpty) {
        throw ValidationFailure('Description cannot be empty');
      }
      if (request.contact.isEmpty) {
        throw ValidationFailure('Contact cannot be empty');
      }
      if (request.address.isEmpty) {
        throw ValidationFailure('Address cannot be empty');
      }

      return await repository.createHelpRequest(request);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to create help request: ${e.toString()}');
    }
  }
}

