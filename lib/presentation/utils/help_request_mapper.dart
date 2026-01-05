import '../../domain/entities/help_request_entity.dart' as domain;
import '../features/home/models/help_request_modal.dart';
import '../../core/constants/enums.dart' as core;

/// Mapper để convert giữa HelpRequestEntity (domain) và HelpRequest (presentation)
class HelpRequestMapper {
  /// Convert HelpRequestEntity to HelpRequest (presentation model)
  static HelpRequest toModel(domain.HelpRequestEntity entity) {
    return HelpRequest(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      lat: entity.lat,
      lng: entity.lng,
      contact: entity.contact,
      severity: _convertSeverity(entity.severity),
      status: _convertStatus(entity.status),
      type: _convertType(entity.type),
      address: entity.address,
      imageUrl: entity.imageUrl,
      userId: entity.userId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      province: entity.province,
      district: entity.district,
      ward: entity.ward,
      detailedAddress: entity.detailedAddress,
    );
  }

  /// Convert HelpRequest (presentation model) to HelpRequestEntity
  static domain.HelpRequestEntity toEntity(HelpRequest model) {
    return domain.HelpRequestEntity(
      id: model.id,
      title: model.title,
      description: model.description,
      lat: model.lat,
      lng: model.lng,
      contact: model.contact,
      severity: _convertSeverityToDomain(model.severity),
      status: _convertStatusToDomain(model.status),
      type: _convertTypeToDomain(model.type),
      address: model.address,
      imageUrl: model.imageUrl,
      userId: model.userId,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      province: model.province,
      district: model.district,
      ward: model.ward,
      detailedAddress: model.detailedAddress,
    );
  }

  static core.RequestSeverity _convertSeverity(
      domain.RequestSeverity severity) {
    return core.RequestSeverity.values.firstWhere(
      (s) => s.name == severity.name,
      orElse: () => core.RequestSeverity.medium,
    );
  }

  static domain.RequestSeverity _convertSeverityToDomain(
      core.RequestSeverity severity) {
    return domain.RequestSeverity.values.firstWhere(
      (s) => s.name == severity.name,
      orElse: () => domain.RequestSeverity.medium,
    );
  }

  static core.RequestStatus _convertStatus(domain.RequestStatus status) {
    return core.RequestStatus.values.firstWhere(
      (s) => s.name == status.name,
      orElse: () => core.RequestStatus.pending,
    );
  }

  static domain.RequestStatus _convertStatusToDomain(
      core.RequestStatus status) {
    return domain.RequestStatus.values.firstWhere(
      (s) => s.name == status.name,
      orElse: () => domain.RequestStatus.pending,
    );
  }

  static core.RequestType _convertType(domain.RequestType type) {
    return core.RequestType.values.firstWhere(
      (t) => t.name == type.name,
      orElse: () => core.RequestType.other,
    );
  }

  static domain.RequestType _convertTypeToDomain(core.RequestType type) {
    return domain.RequestType.values.firstWhere(
      (t) => t.name == type.name,
      orElse: () => domain.RequestType.other,
    );
  }
}
