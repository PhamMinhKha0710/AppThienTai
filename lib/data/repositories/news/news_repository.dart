import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/repositories/news_repository.dart';
import '../../../domain/entities/news_entity.dart';
import '../../models/news_dto.dart';

class NewsRepositoryImpl implements NewsRepository {
  final FirebaseFirestore _firestore;

  NewsRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('news');

  @override
  Stream<List<NewsEntity>> getAllNews() {
    return _collection
        .where('IsActive', isEqualTo: true)
        .orderBy('CreatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NewsDto.fromSnapshot(doc).toEntity())
            .toList());
  }

  @override
  Stream<List<NewsEntity>> getNewsByCategory(String category) {
    return _collection
        .where('IsActive', isEqualTo: true)
        .where('Category', isEqualTo: category)
        .orderBy('CreatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NewsDto.fromSnapshot(doc).toEntity())
            .toList());
  }

  @override
  Future<List<NewsEntity>> searchNews(String query) async {
    final snapshot = await _collection
        .where('IsActive', isEqualTo: true)
        .get();

    final queryLower = query.toLowerCase();
    final results = <NewsEntity>[];

    for (var doc in snapshot.docs) {
      final dto = NewsDto.fromSnapshot(doc);
      final title = dto.title.toLowerCase();
      final content = dto.content.toLowerCase();

      if (title.contains(queryLower) || content.contains(queryLower)) {
        results.add(dto.toEntity());
      }
    }

    return results;
  }
}






