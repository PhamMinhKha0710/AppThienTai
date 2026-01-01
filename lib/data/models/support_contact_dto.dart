import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/support_contact_entity.dart';

/// Support Contact DTO (Data Transfer Object)
class SupportContactDto {
  final String? id;
  final String userId;
  final String name;
  final String email;
  final String subject;
  final String message;
  final String? attachmentUrl;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? adminResponse;

  SupportContactDto({
    this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.subject,
    required this.message,
    this.attachmentUrl,
    this.status = 'pending',
    required this.createdAt,
    this.updatedAt,
    this.adminResponse,
  });

  Map<String, dynamic> toJson({bool includeId = false}) {
    final map = <String, dynamic>{
      'UserId': userId,
      'Name': name,
      'Email': email,
      'Subject': subject,
      'Message': message,
      'AttachmentUrl': attachmentUrl,
      'Status': status,
      'CreatedAt': Timestamp.fromDate(createdAt),
      'UpdatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'AdminResponse': adminResponse,
    };

    if (includeId && id != null) map['Id'] = id;
    map.removeWhere((key, value) => value == null);
    return map;
  }

  factory SupportContactDto.fromJson(Map<String, dynamic> json, [String? docId]) {
    DateTime parseDT(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      return DateTime.now();
    }

    return SupportContactDto(
      id: docId ?? json['Id'],
      userId: json['UserId'] ?? '',
      name: json['Name'] ?? '',
      email: json['Email'] ?? '',
      subject: json['Subject'] ?? 'general',
      message: json['Message'] ?? '',
      attachmentUrl: json['AttachmentUrl'],
      status: json['Status'] ?? 'pending',
      createdAt: parseDT(json['CreatedAt']),
      updatedAt: json['UpdatedAt'] != null ? parseDT(json['UpdatedAt']) : null,
      adminResponse: json['AdminResponse'],
    );
  }

  factory SupportContactDto.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      return SupportContactDto(
        id: doc.id,
        userId: '',
        name: '',
        email: '',
        subject: 'general',
        message: '',
        createdAt: DateTime.now(),
      );
    }

    return SupportContactDto.fromJson({
      ...data,
      'Id': doc.id,
    });
  }

  /// Convert DTO to Entity
  SupportContactEntity toEntity() {
    return SupportContactEntity(
      id: id,
      userId: userId,
      name: name,
      email: email,
      subject: _parseSubject(subject),
      message: message,
      attachmentUrl: attachmentUrl,
      status: _parseStatus(status),
      createdAt: createdAt,
      updatedAt: updatedAt,
      adminResponse: adminResponse,
    );
  }

  /// Convert Entity to DTO
  factory SupportContactDto.fromEntity(SupportContactEntity entity) {
    return SupportContactDto(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      email: entity.email,
      subject: entity.subject.name,
      message: entity.message,
      attachmentUrl: entity.attachmentUrl,
      status: entity.status.name,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      adminResponse: entity.adminResponse,
    );
  }

  ContactSubject _parseSubject(String value) {
    return ContactSubject.values.firstWhere(
      (sub) => sub.name.toLowerCase() == value.toLowerCase(),
      orElse: () => ContactSubject.general,
    );
  }

  ContactStatus _parseStatus(String value) {
    return ContactStatus.values.firstWhere(
      (st) => st.name.toLowerCase() == value.toLowerCase(),
      orElse: () => ContactStatus.pending,
    );
  }
}




