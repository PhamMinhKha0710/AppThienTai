import '../failures/failures.dart';
import '../repositories/help_request_repository.dart';
import '../entities/help_request_entity.dart';
import 'dart:async';

/// Use case để lấy help requests theo user ID
class GetHelpRequestsByUserUseCase {
  final HelpRequestRepository repository;

  GetHelpRequestsByUserUseCase(this.repository);

  /// Execute get help requests by user ID
  Stream<List<HelpRequestEntity>> call(String userId) {
    try {
      if (userId.isEmpty) {
        throw ValidationFailure('User ID cannot be empty');
      }

      return repository.getRequestsByUserId(userId);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure(
          'Failed to get user help requests: ${e.toString()}');
    }
  }
}

