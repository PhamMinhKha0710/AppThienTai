/// SupportFaqEntity - Entity for FAQ items
class SupportFaqEntity {
  final String id;
  final String question;
  final String answer;
  final FaqCategory category;
  final int order;
  final bool isActive;

  const SupportFaqEntity({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    this.order = 0,
    this.isActive = true,
  });

  SupportFaqEntity copyWith({
    String? id,
    String? question,
    String? answer,
    FaqCategory? category,
    int? order,
    bool? isActive,
  }) {
    return SupportFaqEntity(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      category: category ?? this.category,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'category': category.name,
      'order': order,
      'isActive': isActive,
    };
  }

  factory SupportFaqEntity.fromJson(Map<String, dynamic> json) {
    return SupportFaqEntity(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      category: FaqCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => FaqCategory.general,
      ),
      order: json['order'] ?? 0,
      isActive: json['isActive'] ?? true,
    );
  }
}

/// Enum for FAQ categories
enum FaqCategory {
  general,    // Câu hỏi chung
  emergency,  // Khẩn cấp / SOS
  features,   // Tính năng ứng dụng
  account,    // Tài khoản
}

/// Extension to get Vietnamese labels
extension FaqCategoryExtension on FaqCategory {
  String get label {
    switch (this) {
      case FaqCategory.general:
        return 'Câu hỏi chung';
      case FaqCategory.emergency:
        return 'Khẩn cấp / SOS';
      case FaqCategory.features:
        return 'Tính năng';
      case FaqCategory.account:
        return 'Tài khoản';
    }
  }

  String get icon {
    switch (this) {
      case FaqCategory.general:
        return 'question';
      case FaqCategory.emergency:
        return 'warning';
      case FaqCategory.features:
        return 'apps';
      case FaqCategory.account:
        return 'person';
    }
  }
}




