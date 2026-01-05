/// SupportContactEntity - Entity for contact/feedback submission
class SupportContactEntity {
  final String? id;
  final String userId;
  final String name;
  final String email;
  final ContactSubject subject;
  final String message;
  final String? attachmentUrl;
  final ContactStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? adminResponse;

  const SupportContactEntity({
    this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.subject,
    required this.message,
    this.attachmentUrl,
    this.status = ContactStatus.pending,
    required this.createdAt,
    this.updatedAt,
    this.adminResponse,
  });

  SupportContactEntity copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    ContactSubject? subject,
    String? message,
    String? attachmentUrl,
    ContactStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? adminResponse,
  }) {
    return SupportContactEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      adminResponse: adminResponse ?? this.adminResponse,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'email': email,
      'subject': subject.name,
      'message': message,
      'attachmentUrl': attachmentUrl,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'adminResponse': adminResponse,
    };
  }

  factory SupportContactEntity.fromJson(Map<String, dynamic> json) {
    return SupportContactEntity(
      id: json['id'],
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      subject: ContactSubject.values.firstWhere(
        (e) => e.name == json['subject'],
        orElse: () => ContactSubject.general,
      ),
      message: json['message'] ?? '',
      attachmentUrl: json['attachmentUrl'],
      status: ContactStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ContactStatus.pending,
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      adminResponse: json['adminResponse'],
    );
  }
}

/// Enum for contact subjects
enum ContactSubject {
  general,      // Câu hỏi chung
  bugReport,    // Báo lỗi
  feedback,     // Góp ý
  account,      // Vấn đề tài khoản
  emergency,    // Hỗ trợ khẩn cấp
  other,        // Khác
}

/// Extension for ContactSubject labels
extension ContactSubjectExtension on ContactSubject {
  String get label {
    switch (this) {
      case ContactSubject.general:
        return 'Câu hỏi chung';
      case ContactSubject.bugReport:
        return 'Báo lỗi';
      case ContactSubject.feedback:
        return 'Góp ý';
      case ContactSubject.account:
        return 'Vấn đề tài khoản';
      case ContactSubject.emergency:
        return 'Hỗ trợ khẩn cấp';
      case ContactSubject.other:
        return 'Khác';
    }
  }
}

/// Enum for contact status
enum ContactStatus {
  pending,    // Đang chờ xử lý
  inProgress, // Đang xử lý
  resolved,   // Đã giải quyết
  closed,     // Đã đóng
}

/// Extension for ContactStatus labels
extension ContactStatusExtension on ContactStatus {
  String get label {
    switch (this) {
      case ContactStatus.pending:
        return 'Đang chờ xử lý';
      case ContactStatus.inProgress:
        return 'Đang xử lý';
      case ContactStatus.resolved:
        return 'Đã giải quyết';
      case ContactStatus.closed:
        return 'Đã đóng';
    }
  }
}





















