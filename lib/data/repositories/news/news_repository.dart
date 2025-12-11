import 'package:cloud_firestore/cloud_firestore.dart';

class NewsRepository {
  final FirebaseFirestore _firestore;

  NewsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('news');

  /// Get all news
  Stream<List<Map<String, dynamic>>> getAllNews() {
    return _collection
        .where('IsActive', isEqualTo: true)
        .orderBy('CreatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                ...data,
                'CreatedAt': data['CreatedAt']?.toDate(),
                'UpdatedAt': data['UpdatedAt']?.toDate(),
              };
            }).toList());
  }

  /// Get news by category
  Stream<List<Map<String, dynamic>>> getNewsByCategory(String category) {
    return _collection
        .where('IsActive', isEqualTo: true)
        .where('Category', isEqualTo: category)
        .orderBy('CreatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                ...data,
                'CreatedAt': data['CreatedAt']?.toDate(),
                'UpdatedAt': data['UpdatedAt']?.toDate(),
              };
            }).toList());
  }

  /// Get news by search query
  Future<List<Map<String, dynamic>>> searchNews(String query) async {
    final snapshot = await _collection
        .where('IsActive', isEqualTo: true)
        .get();

    final queryLower = query.toLowerCase();
    final results = <Map<String, dynamic>>[];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final title = (data['Title'] ?? '').toString().toLowerCase();
      final content = (data['Content'] ?? '').toString().toLowerCase();

      if (title.contains(queryLower) || content.contains(queryLower)) {
        results.add({
          'id': doc.id,
          ...data,
          'CreatedAt': data['CreatedAt']?.toDate(),
        });
      }
    }

    return results;
  }
}




