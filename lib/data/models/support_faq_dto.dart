import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/support_faq_entity.dart';

/// Support FAQ DTO (Data Transfer Object)
class SupportFaqDto {
  final String id;
  final String question;
  final String answer;
  final String category;
  final int order;
  final bool isActive;

  SupportFaqDto({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    this.order = 0,
    this.isActive = true,
  });

  Map<String, dynamic> toJson({bool includeId = false}) {
    final map = <String, dynamic>{
      'Question': question,
      'Answer': answer,
      'Category': category,
      'Order': order,
      'IsActive': isActive,
    };

    if (includeId) map['Id'] = id;
    return map;
  }

  factory SupportFaqDto.fromJson(Map<String, dynamic> json, [String? id]) {
    return SupportFaqDto(
      id: id ?? json['Id'] ?? '',
      question: json['Question'] ?? '',
      answer: json['Answer'] ?? '',
      category: json['Category'] ?? 'general',
      order: json['Order'] ?? 0,
      isActive: json['IsActive'] ?? true,
    );
  }

  factory SupportFaqDto.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      return SupportFaqDto(
        id: doc.id,
        question: '',
        answer: '',
        category: 'general',
      );
    }

    return SupportFaqDto.fromJson({
      ...data,
      'Id': doc.id,
    });
  }

  /// Convert DTO to Entity
  SupportFaqEntity toEntity() {
    return SupportFaqEntity(
      id: id,
      question: question,
      answer: answer,
      category: _parseCategory(category),
      order: order,
      isActive: isActive,
    );
  }

  /// Convert Entity to DTO
  factory SupportFaqDto.fromEntity(SupportFaqEntity entity) {
    return SupportFaqDto(
      id: entity.id,
      question: entity.question,
      answer: entity.answer,
      category: entity.category.name,
      order: entity.order,
      isActive: entity.isActive,
    );
  }

  FaqCategory _parseCategory(String value) {
    return FaqCategory.values.firstWhere(
      (cat) => cat.name.toLowerCase() == value.toLowerCase(),
      orElse: () => FaqCategory.general,
    );
  }
}


















