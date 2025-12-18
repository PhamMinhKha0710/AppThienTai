/// Alert Entity - Pure business object
class AlertEntity {
  final String id;
  final String title;
  final String content;
  final String severity; // low, medium, high, critical
  final double? lat;
  final double? lng;
  final String? location;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? expiresAt;
  final String? type; // general, task_related, etc.
  final String? volunteerId; // For task-related alerts

  const AlertEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.severity,
    this.lat,
    this.lng,
    this.location,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
    this.expiresAt,
    this.type,
    this.volunteerId,
  });

  AlertEntity copyWith({
    String? id,
    String? title,
    String? content,
    String? severity,
    double? lat,
    double? lng,
    String? location,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expiresAt,
    String? type,
    String? volunteerId,
  }) {
    return AlertEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      severity: severity ?? this.severity,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      location: location ?? this.location,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      type: type ?? this.type,
      volunteerId: volunteerId ?? this.volunteerId,
    );
  }
}


