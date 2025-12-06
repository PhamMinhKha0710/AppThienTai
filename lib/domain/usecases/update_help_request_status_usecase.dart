import '../failures/failures.dart';
import '../repositories/help_request_repository.dart';
import '../entities/help_request_entity.dart' as domain;

/// Use case để cập nhật status của help request
class UpdateHelpRequestStatusUseCase {
  final HelpRequestRepository repository;

  UpdateHelpRequestStatusUseCase(this.repository);

  /// Execute update status
  Future<void> call(String requestId, domain.RequestStatus status) async {
    try {
      if (requestId.isEmpty) {
        throw ValidationFailure('Request ID cannot be empty');
      }

      await repository.updateRequestStatus(requestId, status);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to update status: ${e.toString()}');
    }
  }
}

