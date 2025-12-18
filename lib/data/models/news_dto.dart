import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/news_entity.dart';

/// News DTO (Data Transfer Object) - Dùng để serialize/deserialize từ Firebase
class NewsDto {
  final String id;
  final String title;
  final String content;
  final String? category;
  final String? imageUrl;
  final String? author;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  NewsDto({
    required this.id,
    required this.title,
    required this.content,
    this.category,
    this.imageUrl,
    this.author,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'Title': title,
      'Content': content,
      'Category': category,
      'ImageUrl': imageUrl,
      'Author': author,
      'IsActive': isActive,
      'CreatedAt': Timestamp.fromDate(createdAt),
      'UpdatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory NewsDto.fromJson(Map<String, dynamic> json, String id) {
    return NewsDto(
      id: id,
      title: json['Title'] ?? "",
      content: json['Content'] ?? "",
      category: json['Category'],
      imageUrl: json['ImageUrl'],
      author: json['Author'],
      isActive: json['IsActive'] ?? true,
      createdAt: (json['CreatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['UpdatedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory NewsDto.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    if (data != null) {
      return NewsDto.fromJson(data, document.id);
    } else {
      throw Exception('News data is null');
    }
  }

  /// Convert DTO to Entity
  NewsEntity toEntity() {
    return NewsEntity(
      id: id,
      title: title,
      content: content,
      category: category,
      imageUrl: imageUrl,
      author: author,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Convert Entity to DTO
  factory NewsDto.fromEntity(NewsEntity entity) {
    return NewsDto(
      id: entity.id,
      title: entity.title,
      content: entity.content,
      category: entity.category,
      imageUrl: entity.imageUrl,
      author: entity.author,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}


