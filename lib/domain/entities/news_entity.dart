/// News Entity - Pure business object
class NewsEntity {
  final String id;
  final String title;
  final String content;
  final String? category;
  final String? imageUrl;
  final String? author;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const NewsEntity({
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

  NewsEntity copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    String? imageUrl,
    String? author,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NewsEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      author: author ?? this.author,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}


