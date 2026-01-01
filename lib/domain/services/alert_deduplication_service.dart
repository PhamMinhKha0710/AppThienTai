import 'package:flutter/foundation.dart';
import '../entities/alert_entity.dart';

/// Alert Deduplication Service sử dụng Jaccard Similarity
/// 
/// Service này giúp phát hiện và loại bỏ các cảnh báo trùng lặp hoặc tương tự
/// để tránh spam người dùng với nhiều cảnh báo giống nhau.
/// 
/// ## Tiêu chí xác định trùng lặp:
/// 1. Cùng [AlertType] + [AlertSeverity] + province/district
/// 2. Nội dung tương tự > 80% (Jaccard Similarity)
/// 3. Được tạo trong vòng 1 giờ
/// 
/// ## Jaccard Similarity:
/// ```
/// J(A,B) = |A ∩ B| / |A ∪ B|
/// ```
/// 
/// Trong đó:
/// - A, B: Tập hợp các từ trong 2 cảnh báo
/// - |A ∩ B|: Số từ chung
/// - |A ∪ B|: Tổng số từ unique
/// 
/// ## Ví dụ:
/// ```
/// Text 1: "Bão cấp 12 đang tiến vào bờ"
/// Text 2: "Bão cấp 12 sắp vào bờ"
/// 
/// Words 1: {bão, cấp, 12, đang, tiến, vào, bờ}
/// Words 2: {bão, cấp, 12, sắp, vào, bờ}
/// 
/// Intersection: {bão, cấp, 12, vào, bờ} = 5 words
/// Union: {bão, cấp, 12, đang, tiến, sắp, vào, bờ} = 8 words
/// 
/// Jaccard = 5/8 = 0.625 (62.5% tương tự)
/// ```
/// 
/// ## Ví dụ sử dụng:
/// ```dart
/// final service = AlertDeduplicationService();
/// 
/// if (service.isDuplicate(newAlert, existingAlerts)) {
///   print('Cảnh báo trùng lặp, bỏ qua');
/// } else {
///   // Thêm cảnh báo mới
/// }
/// ```
class AlertDeduplicationService {
  /// Ngưỡng tương tự tối thiểu để coi là trùng lặp (0.0 - 1.0)
  /// 
  /// Mặc định 0.80 (80% tương tự)
  final double similarityThreshold;

  /// Cửa sổ thời gian để xét trùng lặp
  /// 
  /// Chỉ xét các cảnh báo được tạo trong khoảng thời gian này
  /// Mặc định 1 giờ
  final Duration timeWindow;

  /// Constructor với cấu hình mặc định
  const AlertDeduplicationService({
    this.similarityThreshold = 0.80,
    this.timeWindow = const Duration(hours: 1),
  });

  // ========== Public Methods ==========

  /// Kiểm tra xem alert mới có trùng với các alert hiện có không
  /// 
  /// ## Parameters:
  /// - [newAlert]: Cảnh báo mới cần kiểm tra
  /// - [existingAlerts]: Danh sách các cảnh báo hiện có
  /// 
  /// ## Returns:
  /// - `true`: Là trùng lặp, nên bỏ qua
  /// - `false`: Không trùng, có thể thêm
  bool isDuplicate(AlertEntity newAlert, List<AlertEntity> existingAlerts) {
    for (final existing in existingAlerts) {
      if (_isSimilar(newAlert, existing)) {
        debugPrint('[Deduplication] Found duplicate: '
            '${newAlert.title} ≈ ${existing.title}');
        return true;
      }
    }
    return false;
  }

  /// Tìm alert trùng lặp
  /// 
  /// ## Returns:
  /// Alert trùng lặp đầu tiên tìm thấy, hoặc null nếu không trùng
  AlertEntity? findDuplicate(
    AlertEntity newAlert,
    List<AlertEntity> existingAlerts,
  ) {
    for (final existing in existingAlerts) {
      if (_isSimilar(newAlert, existing)) {
        return existing;
      }
    }
    return null;
  }

  /// Lọc danh sách alerts, loại bỏ trùng lặp
  /// 
  /// Giữ lại alert mới nhất khi có trùng lặp.
  /// 
  /// ## Parameters:
  /// - [alerts]: Danh sách cảnh báo cần lọc
  /// - [keepFirst]: Nếu true, giữ alert đầu tiên; nếu false, giữ alert mới nhất
  /// 
  /// ## Returns:
  /// Danh sách alerts đã loại bỏ trùng lặp
  List<AlertEntity> filterDuplicates(
    List<AlertEntity> alerts, {
    bool keepFirst = false,
  }) {
    if (alerts.isEmpty) return [];

    final unique = <AlertEntity>[];

    for (final alert in alerts) {
      if (!isDuplicate(alert, unique)) {
        unique.add(alert);
      } else if (!keepFirst) {
        // Nếu giữ mới nhất, thay thế alert cũ
        final duplicateIndex = unique.indexWhere(
          (existing) => _isSimilar(alert, existing),
        );
        if (duplicateIndex != -1 &&
            alert.createdAt.isAfter(unique[duplicateIndex].createdAt)) {
          unique[duplicateIndex] = alert;
        }
      }
    }

    debugPrint('[Deduplication] Filtered ${alerts.length} -> ${unique.length} alerts');
    return unique;
  }

  /// Tính độ tương tự giữa 2 cảnh báo
  /// 
  /// ## Returns:
  /// Điểm từ 0.0 (hoàn toàn khác) đến 1.0 (giống hệt)
  double calculateSimilarity(AlertEntity a, AlertEntity b) {
    // Không cùng type hoặc severity -> không giống
    if (a.alertType != b.alertType) return 0.0;
    if (a.severity != b.severity) return 0.0;

    // Không cùng vùng -> không giống
    if (a.province != b.province) return 0.0;

    // Tính Jaccard similarity cho nội dung
    return _jaccardSimilarity(a.content, b.content);
  }

  // ========== Private Methods ==========

  /// Kiểm tra 2 cảnh báo có tương tự không
  bool _isSimilar(AlertEntity a, AlertEntity b) {
    // 1. Kiểm tra time window
    final timeDiff = a.createdAt.difference(b.createdAt).abs();
    if (timeDiff > timeWindow) return false;

    // 2. Kiểm tra cùng type và severity
    if (a.alertType != b.alertType) return false;
    if (a.severity != b.severity) return false;

    // 3. Kiểm tra cùng vị trí (province/district)
    if (a.province != b.province) return false;
    if (a.district != null &&
        b.district != null &&
        a.district != b.district) {
      return false;
    }

    // 4. Tính độ tương tự nội dung
    final similarity = _jaccardSimilarity(a.content, b.content);

    return similarity >= similarityThreshold;
  }

  /// Jaccard Similarity cho text comparison
  /// 
  /// ## Công thức:
  /// ```
  /// J(A,B) = |A ∩ B| / |A ∪ B|
  /// ```
  /// 
  /// ## Process:
  /// 1. Tokenize cả 2 text thành tập hợp từ
  /// 2. Tính intersection (từ chung)
  /// 3. Tính union (tổng từ unique)
  /// 4. Chia intersection / union
  /// 
  /// ## Returns:
  /// Điểm từ 0.0 đến 1.0
  double _jaccardSimilarity(String text1, String text2) {
    final words1 = _tokenize(text1);
    final words2 = _tokenize(text2);

    // Nếu một trong 2 rỗng, trả về 0
    if (words1.isEmpty || words2.isEmpty) return 0.0;

    // Tính intersection và union
    final intersection = words1.intersection(words2).length;
    final union = words1.union(words2).length;

    // Tránh chia cho 0
    if (union == 0) return 0.0;

    return intersection / union;
  }

  /// Tokenize text thành tập hợp các từ
  /// 
  /// ## Process:
  /// 1. Chuyển về lowercase
  /// 2. Loại bỏ dấu câu
  /// 3. Tách thành từ
  /// 4. Loại bỏ từ ngắn (< 3 ký tự) - thường là stopwords
  /// 5. Trả về Set để tự động loại trùng
  /// 
  /// ## Example:
  /// ```
  /// "Bão cấp 12 đang tiến vào bờ!"
  /// -> {"bão", "cấp", "đang", "tiến", "vào", "bờ"}
  /// ```
  Set<String> _tokenize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '') // Loại bỏ dấu câu
        .split(RegExp(r'\s+')) // Tách từ
        .where((word) => word.length > 2) // Lọc từ ngắn
        .toSet(); // Chuyển thành Set
  }

  // ========== Advanced Methods ==========

  /// Phân nhóm các alerts tương tự thành clusters
  /// 
  /// Sử dụng thuật toán Greedy Clustering:
  /// - Duyệt qua từng alert
  /// - Nếu tương tự với bất kỳ alert nào trong cluster hiện tại, thêm vào
  /// - Nếu không, tạo cluster mới
  /// 
  /// ## Returns:
  /// List các clusters, mỗi cluster là list các alerts tương tự
  List<List<AlertEntity>> clusterSimilarAlerts(List<AlertEntity> alerts) {
    if (alerts.isEmpty) return [];

    final clusters = <List<AlertEntity>>[];

    for (final alert in alerts) {
      var added = false;

      // Thử thêm vào cluster hiện có
      for (final cluster in clusters) {
        // Kiểm tra với alert đầu tiên của cluster (representative)
        if (_isSimilar(alert, cluster.first)) {
          cluster.add(alert);
          added = true;
          break;
        }
      }

      // Nếu không khớp cluster nào, tạo cluster mới
      if (!added) {
        clusters.add([alert]);
      }
    }

    debugPrint('[Deduplication] Clustered ${alerts.length} alerts into ${clusters.length} groups');
    return clusters;
  }

  /// Lấy alert đại diện cho mỗi cluster
  /// 
  /// Chọn alert mới nhất hoặc có severity cao nhất từ mỗi cluster.
  /// 
  /// ## Parameters:
  /// - [clusters]: Danh sách clusters từ [clusterSimilarAlerts]
  /// - [preferLatest]: Nếu true, chọn alert mới nhất; nếu false, chọn severity cao nhất
  List<AlertEntity> getRepresentatives(
    List<List<AlertEntity>> clusters, {
    bool preferLatest = true,
  }) {
    return clusters.map((cluster) {
      if (cluster.isEmpty) return null;
      if (cluster.length == 1) return cluster.first;

      if (preferLatest) {
        // Chọn alert mới nhất
        return cluster.reduce((a, b) =>
            a.createdAt.isAfter(b.createdAt) ? a : b);
      } else {
        // Chọn severity cao nhất
        return cluster.reduce((a, b) {
          final aSeverity = _severityToInt(a.severity);
          final bSeverity = _severityToInt(b.severity);
          return aSeverity > bSeverity ? a : b;
        });
      }
    }).whereType<AlertEntity>().toList();
  }

  int _severityToInt(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return 4;
      case AlertSeverity.high:
        return 3;
      case AlertSeverity.medium:
        return 2;
      case AlertSeverity.low:
        return 1;
    }
  }

  // ========== Statistics ==========

  /// Thống kê về deduplication
  Map<String, dynamic> getDeduplicationStats(
    List<AlertEntity> original,
    List<AlertEntity> filtered,
  ) {
    final duplicates = original.length - filtered.length;
    final rate = original.isEmpty ? 0.0 : duplicates / original.length;

    return {
      'originalCount': original.length,
      'filteredCount': filtered.length,
      'duplicatesRemoved': duplicates,
      'deduplicationRate': rate,
      'deduplicationPercent': '${(rate * 100).toStringAsFixed(1)}%',
    };
  }

  // ========== Utility Methods ==========

  /// Tạo config tùy chỉnh
  AlertDeduplicationService copyWith({
    double? similarityThreshold,
    Duration? timeWindow,
  }) {
    return AlertDeduplicationService(
      similarityThreshold: similarityThreshold ?? this.similarityThreshold,
      timeWindow: timeWindow ?? this.timeWindow,
    );
  }

  @override
  String toString() {
    return 'AlertDeduplicationService('
        'threshold: $similarityThreshold, '
        'window: ${timeWindow.inHours}h'
        ')';
  }
}

