import '../entities/news_entity.dart';

/// News Repository Interface
/// Định nghĩa contract cho news operations
abstract class NewsRepository {
  /// Lấy tất cả news
  Stream<List<NewsEntity>> getAllNews();

  /// Lấy news theo category
  Stream<List<NewsEntity>> getNewsByCategory(String category);

  /// Tìm kiếm news
  Future<List<NewsEntity>> searchNews(String query);
}


