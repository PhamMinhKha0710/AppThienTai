import '../../domain/entities/scored_alert_entity.dart';

/// Priority Queue implementation sử dụng Max-Heap cho alerts
/// 
/// Cấu trúc dữ liệu này duy trì danh sách các ScoredAlert theo thứ tự ưu tiên,
/// với alert có điểm cao nhất luôn ở đầu hàng đợi.
/// 
/// ## Đặc điểm:
/// - Dựa trên Max-Heap (parent >= children)
/// - Insert: O(log n)
/// - Extract Max: O(log n)  
/// - Peek: O(1)
/// - Build Heap: O(n)
/// 
/// ## Ví dụ sử dụng:
/// ```dart
/// final queue = AlertPriorityQueue();
/// queue.insert(scoredAlert1);
/// queue.insert(scoredAlert2);
/// 
/// final highest = queue.extractMax(); // Lấy alert ưu tiên cao nhất
/// final next = queue.peek(); // Xem alert tiếp theo mà không lấy ra
/// ```
/// 
/// ## Cấu trúc Heap:
/// ```
///       90
///      /  \
///    75    80
///   /  \   /
///  50  60 70
/// ```
/// 
/// Mảng tương ứng: [90, 75, 80, 50, 60, 70]
/// 
/// ## Quan hệ parent-child:
/// - Parent của node i: (i-1) / 2
/// - Left child của node i: 2*i + 1
/// - Right child của node i: 2*i + 2
class AlertPriorityQueue {
  /// Heap array lưu trữ các scored alerts
  final List<ScoredAlert> _heap = [];

  /// Số lượng phần tử trong queue
  int get length => _heap.length;

  /// Kiểm tra queue có rỗng không
  bool get isEmpty => _heap.isEmpty;

  /// Kiểm tra queue có phần tử không
  bool get isNotEmpty => _heap.isNotEmpty;

  /// Lấy danh sách tất cả alerts (không sắp xếp)
  /// 
  /// **Lưu ý**: Không nên dùng để lấy theo thứ tự ưu tiên,
  /// dùng [extractMax] hoặc [toSortedList] thay thế
  List<ScoredAlert> get all => List.unmodifiable(_heap);

  // ========== Core Operations ==========

  /// Insert alert vào queue với O(log n) complexity
  /// 
  /// Alert được thêm vào cuối heap và "nổi lên" (bubble up) 
  /// đến vị trí đúng để duy trì tính chất max-heap.
  /// 
  /// ## Bubble Up Process:
  /// 1. Thêm phần tử vào cuối mảng
  /// 2. So sánh với parent
  /// 3. Nếu lớn hơn parent, swap và lặp lại
  /// 4. Dừng khi nhỏ hơn hoặc bằng parent hoặc đã đến root
  void insert(ScoredAlert alert) {
    _heap.add(alert);
    _bubbleUp(_heap.length - 1);
  }

  /// Insert nhiều alerts cùng lúc
  /// 
  /// Hiệu quả hơn việc gọi [insert] nhiều lần.
  void insertAll(List<ScoredAlert> alerts) {
    for (final alert in alerts) {
      insert(alert);
    }
  }

  /// Extract alert có điểm cao nhất với O(log n) complexity
  /// 
  /// Lấy ra và xóa alert ở root (điểm cao nhất), sau đó
  /// di chuyển phần tử cuối lên root và "chìm xuống" (bubble down).
  /// 
  /// ## Bubble Down Process:
  /// 1. Lấy phần tử ở root (max)
  /// 2. Di chuyển phần tử cuối lên root
  /// 3. So sánh với 2 children
  /// 4. Swap với child lớn hơn nếu cần
  /// 5. Lặp lại cho đến khi đúng vị trí
  /// 
  /// ## Returns
  /// Alert có điểm cao nhất, hoặc null nếu queue rỗng
  ScoredAlert? extractMax() {
    if (_heap.isEmpty) return null;

    final max = _heap[0];
    final last = _heap.removeLast();

    if (_heap.isNotEmpty) {
      _heap[0] = last;
      _bubbleDown(0);
    }

    return max;
  }

  /// Peek alert có điểm cao nhất mà không xóa - O(1)
  /// 
  /// ## Returns
  /// Alert có điểm cao nhất, hoặc null nếu queue rỗng
  ScoredAlert? peek() => _heap.isEmpty ? null : _heap[0];

  /// Peek N alerts có điểm cao nhất
  /// 
  /// ## Returns
  /// Danh sách tối đa [n] alerts theo thứ tự ưu tiên
  List<ScoredAlert> peekN(int n) {
    if (n <= 0) return [];
    if (n >= _heap.length) return List.from(_heap);

    // Tạo copy để không ảnh hưởng queue gốc
    final tempQueue = AlertPriorityQueue();
    tempQueue._heap.addAll(_heap);

    final result = <ScoredAlert>[];
    for (var i = 0; i < n && tempQueue.isNotEmpty; i++) {
      final alert = tempQueue.extractMax();
      if (alert != null) result.add(alert);
    }

    return result;
  }

  /// Xóa tất cả phần tử trong queue
  void clear() {
    _heap.clear();
  }

  /// Xóa alerts cụ thể khỏi queue
  /// 
  /// **Cảnh báo**: O(n) complexity, sử dụng cẩn thận
  bool remove(ScoredAlert alert) {
    final index = _heap.indexOf(alert);
    if (index == -1) return false;

    // Nếu là phần tử cuối, xóa trực tiếp
    if (index == _heap.length - 1) {
      _heap.removeLast();
      return true;
    }

    // Swap với phần tử cuối và xóa
    final last = _heap.removeLast();
    _heap[index] = last;

    // Restore heap property
    _bubbleDown(index);
    _bubbleUp(index);

    return true;
  }

  // ========== Heap Operations ==========

  /// Bubble up: Di chuyển phần tử lên đến vị trí đúng
  /// 
  /// Được gọi sau khi insert phần tử mới.
  void _bubbleUp(int index) {
    while (index > 0) {
      final parentIndex = (index - 1) ~/ 2;

      // Nếu điểm <= parent, đã đúng vị trí
      if (_heap[index].score <= _heap[parentIndex].score) break;

      // Swap với parent
      _swap(index, parentIndex);
      index = parentIndex;
    }
  }

  /// Bubble down: Di chuyển phần tử xuống đến vị trí đúng
  /// 
  /// Được gọi sau khi extract max.
  void _bubbleDown(int index) {
    while (true) {
      final leftChild = 2 * index + 1;
      final rightChild = 2 * index + 2;
      var largest = index;

      // So sánh với left child
      if (leftChild < _heap.length &&
          _heap[leftChild].score > _heap[largest].score) {
        largest = leftChild;
      }

      // So sánh với right child
      if (rightChild < _heap.length &&
          _heap[rightChild].score > _heap[largest].score) {
        largest = rightChild;
      }

      // Nếu đã là largest, dừng
      if (largest == index) break;

      // Swap và tiếp tục
      _swap(index, largest);
      index = largest;
    }
  }

  /// Swap 2 phần tử trong heap
  void _swap(int i, int j) {
    final temp = _heap[i];
    _heap[i] = _heap[j];
    _heap[j] = temp;
  }

  // ========== Utility Methods ==========

  /// Chuyển queue thành danh sách đã sắp xếp theo điểm giảm dần
  /// 
  /// **Cảnh báo**: Thao tác này sẽ làm rỗng queue!
  /// Nếu cần giữ nguyên queue, dùng [peekN] hoặc copy trước.
  List<ScoredAlert> toSortedList() {
    final sorted = <ScoredAlert>[];
    while (isNotEmpty) {
      final alert = extractMax();
      if (alert != null) sorted.add(alert);
    }
    return sorted;
  }

  /// Chuyển thành danh sách sắp xếp mà không làm rỗng queue
  /// 
  /// Tạo copy của queue và extract từ copy.
  List<ScoredAlert> toSortedListCopy() {
    final copy = AlertPriorityQueue();
    copy._heap.addAll(_heap);
    return copy.toSortedList();
  }

  /// Kiểm tra xem queue có chứa alert này không
  bool contains(ScoredAlert alert) {
    return _heap.contains(alert);
  }

  /// Kiểm tra xem queue có chứa alert với ID cụ thể không
  bool containsAlertId(String alertId) {
    return _heap.any((scored) => scored.alert.id == alertId);
  }

  /// Lấy alert theo ID
  ScoredAlert? getByAlertId(String alertId) {
    try {
      return _heap.firstWhere((scored) => scored.alert.id == alertId);
    } catch (_) {
      return null;
    }
  }

  /// Lọc alerts theo điều kiện
  /// 
  /// **Lưu ý**: Trả về danh sách mới, không ảnh hưởng queue gốc
  List<ScoredAlert> where(bool Function(ScoredAlert) test) {
    return _heap.where(test).toList();
  }

  /// Kiểm tra tính đúng đắn của heap (for debugging)
  /// 
  /// Trả về true nếu heap property được duy trì đúng:
  /// Mọi parent phải >= children
  bool validateHeap() {
    for (var i = 0; i < _heap.length; i++) {
      final leftChild = 2 * i + 1;
      final rightChild = 2 * i + 2;

      if (leftChild < _heap.length &&
          _heap[i].score < _heap[leftChild].score) {
        return false;
      }

      if (rightChild < _heap.length &&
          _heap[i].score < _heap[rightChild].score) {
        return false;
      }
    }
    return true;
  }

  /// Thống kê queue
  Map<String, dynamic> getStatistics() {
    if (isEmpty) {
      return {
        'length': 0,
        'isEmpty': true,
        'maxScore': null,
        'minScore': null,
        'avgScore': null,
      };
    }

    final scores = _heap.map((s) => s.score).toList();
    final maxScore = scores.reduce((a, b) => a > b ? a : b);
    final minScore = scores.reduce((a, b) => a < b ? a : b);
    final avgScore = scores.reduce((a, b) => a + b) / scores.length;

    return {
      'length': length,
      'isEmpty': false,
      'maxScore': maxScore,
      'minScore': minScore,
      'avgScore': avgScore,
    };
  }

  @override
  String toString() {
    if (isEmpty) return 'AlertPriorityQueue(empty)';

    final stats = getStatistics();
    return 'AlertPriorityQueue('
        'length: ${stats['length']}, '
        'max: ${stats['maxScore']?.toStringAsFixed(1)}, '
        'min: ${stats['minScore']?.toStringAsFixed(1)}, '
        'avg: ${stats['avgScore']?.toStringAsFixed(1)}'
        ')';
  }
}


