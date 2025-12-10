import '../failures/failures.dart';
import '../repositories/help_request_repository.dart';
import '../entities/help_request_entity.dart';
import 'dart:async';

/// Use case để lấy tất cả help requests
class GetHelpRequestsUseCase {
  final HelpRequestRepository repository;

  GetHelpRequestsUseCase(this.repository);

  /// Execute get all help requests
  Stream<List<HelpRequestEntity>> call() {
    try {
      return repository.getAllRequests();
    } catch (e) {
      throw UnknownFailure('Failed to get help requests: ${e.toString()}');
    }
  }
}







