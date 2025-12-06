import '../../domain/repositories/help_request_repository.dart';
import '../../domain/entities/help_request_entity.dart' as domain;
import '../../domain/failures/failures.dart';
import '../datasources/remote/help_request_remote_data_source.dart';
import '../models/help_request_dto.dart';

/// Help Request Repository Implementation
class HelpRequestRepositoryImpl implements HelpRequestRepository {
  final HelpRequestRemoteDataSource remoteDataSource;

  HelpRequestRepositoryImpl(this.remoteDataSource);

  @override
  Future<String> createHelpRequest(domain.HelpRequestEntity entity) async {
    try {
      final dto = HelpRequestDto.fromEntity(entity);
      return await remoteDataSource.createHelpRequest(dto);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to create help request: ${e.toString()}');
    }
  }

  @override
  Future<void> updateHelpRequest(domain.HelpRequestEntity entity) async {
    try {
      final dto = HelpRequestDto.fromEntity(entity);
      await remoteDataSource.updateHelpRequest(dto);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to update help request: ${e.toString()}');
    }
  }

  @override
  Future<domain.HelpRequestEntity?> getRequestById(String requestId) async {
    try {
      final dto = await remoteDataSource.getRequestById(requestId);
      return dto?.toEntity();
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to get help request: ${e.toString()}');
    }
  }

  @override
  Stream<List<domain.HelpRequestEntity>> getAllRequests() {
    try {
      return remoteDataSource.getAllRequests().map(
          (dtos) => dtos.map((dto) => dto.toEntity()).toList());
    } catch (e) {
      throw UnknownFailure('Failed to stream help requests: ${e.toString()}');
    }
  }

  @override
  Stream<List<domain.HelpRequestEntity>> getRequestsByUserId(String userId) {
    try {
      return remoteDataSource.getRequestsByUserId(userId).map(
          (dtos) => dtos.map((dto) => dto.toEntity()).toList());
    } catch (e) {
      throw UnknownFailure(
          'Failed to stream user help requests: ${e.toString()}');
    }
  }

  @override
  Future<void> updateRequestStatus(String requestId, domain.RequestStatus status) async {
    try {
      await remoteDataSource.updateRequestStatus(requestId, status);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to update status: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteRequest(String requestId) async {
    try {
      await remoteDataSource.deleteRequest(requestId);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Failed to delete help request: ${e.toString()}');
    }
  }
}

