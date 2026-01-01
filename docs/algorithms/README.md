# Tài liệu Chi tiết các Thuật toán

Thư mục này chứa tài liệu chi tiết về các thuật toán được sử dụng trong Hệ thống Cảnh báo Thông minh.

## Danh sách Thuật toán

### 1. Multi-factor Severity Scoring Algorithm

**File implementation**: `lib/domain/services/alert_scoring_service.dart`

Thuật toán tính điểm ưu tiên tổng hợp cho mỗi cảnh báo dựa trên 5 yếu tố.

**Độ phức tạp**: O(1) - Constant time

**Use case**: Sắp xếp và ưu tiên hiển thị cảnh báo cho người dùng

**Đặc điểm**:
- Kết hợp weighted scoring từ nhiều yếu tố
- Có thể tùy chỉnh trọng số
- Điểm output từ 0-100 để dễ so sánh

**Công thức**:
```
FinalScore = Σ(Wi × Scorei) 
           = W1×Severity + W2×Type + W3×TimeDecay + W4×Distance + W5×Audience
```

**Bảng điểm chi tiết**:

| Yếu tố | Trọng số | Phạm vi điểm | Công thức/Logic |
|--------|----------|--------------|-----------------|
| Severity | 35% | 25-100 | Critical:100, High:75, Medium:50, Low:25 |
| Type | 20% | 30-100 | Disaster:100, Evacuation:90, Weather:70, Resource:50, General:30 |
| Time Decay | 15% | 0-100 | 100 × e^(-λt) |
| Distance | 20% | 0-100 | 100 × (1 - d/r)² |
| Audience | 10% | 50-100 | Match:100, All:100, LocationBased:80, Other:50 |

**Ví dụ tính toán**:

```
Alert: "Bão cấp 12 đang vào bờ"
- Severity: Critical -> 100 điểm
- Type: Disaster -> 100 điểm
- Time: 2 giờ trước -> 90.5 điểm (decay)
- Distance: 5km -> 98.0 điểm
- Audience: Victims (matching) -> 100 điểm

FinalScore = 0.35×100 + 0.20×100 + 0.15×90.5 + 0.20×98.0 + 0.10×100
           = 35 + 20 + 13.58 + 19.6 + 10
           = 98.18
```

**Trade-offs**:
- ✅ Linh hoạt, dễ điều chỉnh
- ✅ Kết quả trực quan (0-100)
- ❌ Cần fine-tuning trọng số cho từng use case
- ❌ Không xử lý edge cases phức tạp

---

### 2. Time Decay Algorithm

**File implementation**: `lib/domain/services/alert_scoring_service.dart` (method `_calculateTimeDecay`)

Thuật toán suy giảm điểm theo thời gian sử dụng **Exponential Decay**.

**Độ phức tạp**: O(1)

**Use case**: Ưu tiên cảnh báo mới hơn cảnh báo cũ

**Công thức Exponential Decay**:
```
Score(t) = S₀ × e^(-λt)

Trong đó:
- S₀ = 100 (điểm ban đầu)
- λ = 0.05 (hệ số suy giảm, configurable)
- t = thời gian tính bằng giờ
- e = số Euler (~2.71828)
```

**Phân tích suy giảm**:

| Thời gian | Score | % còn lại |
|-----------|-------|-----------|
| 0 giờ | 100.00 | 100% |
| 6 giờ | 74.08 | 74% |
| 12 giờ | 54.88 | 55% |
| 18 giờ | 40.66 | 41% |
| 24 giờ | 30.12 | 30% |
| 36 giờ | 16.53 | 17% |
| 48 giờ | 9.07 | 9% |
| 72 giờ | 2.73 | 3% |

**Đồ thị**:
```
Score
100 |●
    | ●
 80 |  ●
    |   ●
 60 |    ●●
    |      ●
 40 |       ●●
    |         ●●
 20 |           ●●●
    |              ●●●●●●
  0 |____________________●●●●●●●●
    0  12  24  36  48  60  72  84  hours
```

**Half-life calculation**:
```
t_half = ln(2) / λ = 0.693 / 0.05 = 13.86 giờ
```
Sau ~14 giờ, điểm giảm còn một nửa.

**Implementation**:
```dart
double _calculateTimeDecay(DateTime createdAt, DateTime? expiresAt) {
  const double lambda = 0.05;
  final now = DateTime.now();
  
  // Nếu đã hết hạn, trả về 0
  if (expiresAt != null && now.isAfter(expiresAt)) {
    return 0.0;
  }
  
  // Tính giờ đã trôi qua
  final hoursElapsed = now.difference(createdAt).inMinutes / 60.0;
  
  // Exponential decay
  final decayScore = 100 * math.exp(-lambda * hoursElapsed);
  
  return decayScore.clamp(0.0, 100.0);
}
```

**Tại sao chọn Exponential Decay?**:
- ✅ Mô phỏng tự nhiên: Thông tin cũ mất giá trị nhanh ban đầu, chậm dần sau đó
- ✅ Smooth transition: Không có điểm nhảy đột ngột
- ✅ Toán học đơn giản: Dễ tính toán và giải thích
- ✅ Được chứng minh: Sử dụng rộng rãi trong information retrieval

**Alternative algorithms đã xem xét**:
1. **Linear Decay**: `Score = 100 - (t × k)`
   - ❌ Quá đơn giản, không tự nhiên
2. **Step Function**: Giảm theo từng bước thời gian
   - ❌ Có điểm nhảy đột ngột
3. **Logarithmic Decay**: `Score = 100 × log(1 + 1/t)`
   - ❌ Giảm quá chậm

---

### 3. Location-based Priority Boost

**File implementation**: `lib/domain/services/alert_scoring_service.dart` (methods `_calculateDistanceScore`, `_haversineDistance`)

Thuật toán tăng điểm ưu tiên dựa trên khoảng cách địa lý.

**Độ phức tạp**: O(1)

**Gồm 2 components**:

#### 3.1. Haversine Formula (Tính khoảng cách)

Công thức tính khoảng cách chính xác giữa 2 điểm trên mặt cầu.

**Công thức đầy đủ**:
```
a = sin²(Δlat/2) + cos(lat₁) × cos(lat₂) × sin²(Δlng/2)
c = 2 × atan2(√a, √(1-a))
d = R × c

Trong đó:
- lat₁, lng₁: Tọa độ điểm 1
- lat₂, lng₂: Tọa độ điểm 2
- Δlat = lat₂ - lat₁
- Δlng = lng₂ - lng₁
- R = 6371 km (bán kính Trái Đất)
- d = khoảng cách (km)
```

**Độ chính xác**: 
- Sai số < 0.5% cho hầu hết trường hợp
- Phù hợp với khoảng cách < 1000km

**Implementation**:
```dart
double _haversineDistance(
  double lat1, double lng1,
  double lat2, double lng2,
) {
  const double earthRadius = 6371.0; // km
  
  // Chuyển sang radian
  final dLat = _toRadians(lat2 - lat1);
  final dLng = _toRadians(lng2 - lng1);
  
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_toRadians(lat1)) *
          math.cos(_toRadians(lat2)) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  
  return earthRadius * c;
}
```

**Ví dụ tính toán**:
```
Point A: Hồ Chí Minh City (10.762622, 106.660172)
Point B: Biên Hòa (10.951572, 106.843395)

Δlat = 0.188950 rad
Δlng = 0.183223 rad

a = 0.00893
c = 0.18946 rad
d = 6371 × 0.18946 = 23.8 km
```

#### 3.2. Inverse Distance Weighting (Tính điểm)

Công thức điểm dựa trên khoảng cách với quadratic falloff.

**Công thức**:
```
DistanceScore = 100 × (1 - d/r)²

Trong đó:
- d = khoảng cách (km)
- r = bán kính tối đa (mặc định 50km)
```

**Bảng điểm chi tiết**:

| Khoảng cách | Ratio (1-d/r) | Score | Ý nghĩa |
|-------------|---------------|-------|---------|
| 0 km | 1.00 | 100.0 | Ngay tại chỗ |
| 5 km | 0.90 | 81.0 | Rất gần |
| 10 km | 0.80 | 64.0 | Gần |
| 15 km | 0.70 | 49.0 | Khá gần |
| 20 km | 0.60 | 36.0 | Trung bình |
| 25 km | 0.50 | 25.0 | Hơi xa |
| 30 km | 0.40 | 16.0 | Xa |
| 40 km | 0.20 | 4.0 | Rất xa |
| 50+ km | 0.00 | 0.0 | Ngoài phạm vi |

**Đồ thị**:
```
Score
100 |●
    | ●●
 80 |   ●●
    |     ●●
 60 |       ●●
    |         ●●
 40 |           ●●
    |             ●●●
 20 |                ●●●
    |                   ●●●●
  0 |_______________________●●●●●●
    0   10   20   30   40   50  km
```

**Tại sao quadratic (mũ 2)?**:
- ✅ Phạt nặng khoảng cách xa hơn
- ✅ Tạo sự phân biệt rõ ràng
- ✅ Khuyến khích ưu tiên cảnh báo gần

**Alternative weighting functions**:

1. **Linear**: `Score = 100 × (1 - d/r)`
   ```
   - Giảm đều đặn
   - ❌ Không đủ phân biệt
   ```

2. **Exponential**: `Score = 100 × e^(-d/k)`
   ```
   - Giảm rất nhanh
   - ❌ Quá nhạy cảm với khoảng cách nhỏ
   ```

3. **Cubic**: `Score = 100 × (1 - d/r)³`
   ```
   - Giảm cực nhanh
   - ❌ Quá khắt khe
   ```

---

### 4. Priority Queue (Max-Heap)

**File implementation**: `lib/core/data_structures/alert_priority_queue.dart`

Cấu trúc dữ liệu Heap để quản lý hàng đợi theo ưu tiên.

**Độ phức tạp**:
- Insert: O(log n)
- Extract Max: O(log n)
- Peek: O(1)
- Build Heap: O(n)
- Space: O(n)

**Heap Property**: 
- **Max-Heap**: `parent.score >= children.score` cho mọi node

**Cấu trúc trong Array**:
```
Array: [90, 75, 80, 50, 60, 70, 65]
Index:  0   1   2   3   4   5   6

Tree:
            90 [0]
           /  \
        75[1]  80[2]
       /  \    /  \
     50[3] 60[4] 70[5] 65[6]
```

**Quan hệ Parent-Child**:
```
Parent của node i:    (i-1) / 2
Left child của node i:  2*i + 1
Right child của node i: 2*i + 2
```

#### Bubble Up Algorithm

Được gọi sau insert, di chuyển node lên đến vị trí đúng.

**Pseudocode**:
```
function bubbleUp(index):
    while index > 0:
        parentIndex = (index - 1) / 2
        if heap[index] <= heap[parentIndex]:
            break
        swap(heap[index], heap[parentIndex])
        index = parentIndex
```

**Ví dụ**:
```
Insert 95 vào heap [90, 75, 80, 50, 60, 70]

1. Thêm vào cuối:
   [90, 75, 80, 50, 60, 70, 95]
                            ^^

2. Bubble up (95 > 80):
   [90, 75, 95, 50, 60, 70, 80]
            ^^

3. Bubble up (95 > 90):
   [95, 75, 90, 50, 60, 70, 80]
    ^^
```

**Độ phức tạp**: O(log n) - Tối đa log₂(n) swaps

#### Bubble Down Algorithm

Được gọi sau extract max, di chuyển node xuống đến vị trí đúng.

**Pseudocode**:
```
function bubbleDown(index):
    while true:
        largest = index
        leftChild = 2 * index + 1
        rightChild = 2 * index + 2
        
        if leftChild < size && heap[leftChild] > heap[largest]:
            largest = leftChild
        if rightChild < size && heap[rightChild] > heap[largest]:
            largest = rightChild
        
        if largest == index:
            break
        
        swap(heap[index], heap[largest])
        index = largest
```

**Ví dụ**:
```
Extract max từ [95, 75, 90, 50, 60, 70, 80]

1. Lấy root (95), di chuyển cuối (80) lên:
   [80, 75, 90, 50, 60, 70]
    ^^

2. Bubble down (80 < 90):
   [90, 75, 80, 50, 60, 70]
    ^^      ^^

3. Xong! (80 >= con của nó)
```

**Độ phức tạp**: O(log n)

#### Build Heap

Xây dựng heap từ array unsorted.

**Phương pháp 1**: Insert lần lượt
```
Complexity: O(n log n)
```

**Phương pháp 2**: Heapify từ dưới lên (tối ưu hơn)
```
for i from n/2 - 1 down to 0:
    bubbleDown(i)

Complexity: O(n) - Tốt hơn!
```

---

### 5. Jaccard Similarity (Deduplication)

**File implementation**: `lib/domain/services/alert_deduplication_service.dart`

Thuật toán đo độ tương tự giữa 2 tập hợp.

**Độ phức tạp**: O(n + m) với n, m là số từ trong 2 text

**Use case**: Phát hiện cảnh báo trùng lặp

**Công thức**:
```
J(A, B) = |A ∩ B| / |A ∪ B|

Trong đó:
- A, B: Tập hợp các từ
- |A ∩ B|: Số phần tử chung (intersection)
- |A ∪ B|: Tổng phần tử unique (union)
- J: Jaccard coefficient (0-1)
```

**Ví dụ chi tiết**:

```
Text 1: "Bão cấp 12 đang tiến vào bờ biển miền Trung"
Text 2: "Bão cấp 12 sắp vào bờ biển miền Trung"

--- Tokenization ---
Words₁ = {bão, cấp, 12, đang, tiến, vào, bờ, biển, miền, trung}
Words₂ = {bão, cấp, 12, sắp, vào, bờ, biển, miền, trung}

--- Calculate Intersection ---
A ∩ B = {bão, cấp, 12, vào, bờ, biển, miền, trung}
|A ∩ B| = 8

--- Calculate Union ---
A ∪ B = {bão, cấp, 12, đang, tiến, sắp, vào, bờ, biển, miền, trung}
|A ∪ B| = 11

--- Jaccard Similarity ---
J(A,B) = 8 / 11 = 0.727 (72.7%)
```

**Ngưỡng similarity**: 0.80 (80%)

```
> 0.80: Coi là duplicate
≤ 0.80: Coi là khác nhau
```

**Tokenization Process**:

```dart
Set<String> _tokenize(String text) {
  return text
      .toLowerCase()           // "Bão Cấp 12" -> "bão cấp 12"
      .replaceAll(            // Loại bỏ dấu câu
          RegExp(r'[^\w\s]'), 
          ''
      )
      .split(RegExp(r'\s+'))  // Tách từ: ["bão", "cấp", "12"]
      .where((w) =>           // Lọc từ ngắn (stopwords)
          w.length > 2
      )
      .toSet();               // Chuyển thành Set (loại trùng)
}
```

**Ví dụ Tokenization**:
```
Input:  "Mưa lớn, gió mạnh! Cần sơ tán gấp!!!"
Step 1: "mưa lớn, gió mạnh! cần sơ tán gấp!!!"  (lowercase)
Step 2: "mưa lớn gió mạnh cần sơ tán gấp"       (remove punct)
Step 3: ["mưa", "lớn", "gió", "mạnh", "cần", "sơ", "tán", "gấp"]
Step 4: ["mưa", "lớn", "gió", "mạnh", "cần", "tán", "gấp"]  (filter len>2)
Output: {"mưa", "lớn", "gió", "mạnh", "cần", "tán", "gấp"}
```

**Tại sao chọn Jaccard?**:

✅ **Ưu điểm**:
- Đơn giản, dễ hiểu
- Không bị ảnh hưởng bởi độ dài text
- Hiệu quả với short text
- Xử lý tốt từ lặp lại (dùng Set)

❌ **Nhược điểm**:
- Không quan tâm thứ tự từ
- Không xử lý synonym (từ đồng nghĩa)
- Không xử lý typo

**Alternative algorithms**:

1. **Cosine Similarity**:
   ```
   - Dùng vector, xử lý frequency
   - ❌ Phức tạp hơn cho task này
   ```

2. **Levenshtein Distance**:
   ```
   - Edit distance giữa 2 string
   - ❌ O(n×m) complexity, chậm
   ```

3. **TF-IDF + Cosine**:
   ```
   - Tốt cho long documents
   - ❌ Overkill cho short alerts
   ```

---

### 6. Smart Notification Batching

**File implementation**: `lib/data/services/smart_notification_service.dart`

Kỹ thuật gộp nhiều notification thành một để giảm spam.

**Độ phức tạp**: O(1) per notification

**Components**:

#### 6.1. Batching Strategy

**Quy tắc**:

| Severity | Batch Size | Delay | Logic |
|----------|-----------|-------|-------|
| Critical | 1 (không batch) | 0s | Gửi ngay |
| High | Max 3 | 5 phút | Batch nhỏ |
| Medium/Low | Max 5 | 15 phút | Batch lớn |

**State Machine**:

```
┌─────────────────────────────────────┐
│  Notification arrives                │
└───────────────┬─────────────────────┘
                │
                v
        ┌───────────────┐
        │  Is Critical? │
        └───────┬───────┘
                │
        ┌───────┴────────┐
        │ Yes            │ No
        v                v
  ┌──────────┐    ┌─────────────┐
  │ Send Now │    │ Check       │
  │          │    │ Cooldown    │
  └──────────┘    └─────┬───────┘
                        │
                ┌───────┴────────┐
                │ Yes            │ No
                v                v
         ┌──────────┐     ┌─────────────┐
         │ Add to   │     │ Schedule    │
         │ Batch    │     │ with Timer  │
         └──────────┘     └─────────────┘
```

**Implementation**:

```dart
void scheduleNotification(ScoredAlert alert) {
  // Critical - gửi ngay
  if (alert.severity == AlertSeverity.critical) {
    _sendImmediate(alert);
    return;
  }
  
  // Check cooldown
  if (_isInCooldown(audienceKey)) {
    _addToBatch(audienceKey, alert);
    return;
  }
  
  // High - batch với delay 5 phút
  if (alert.severity == AlertSeverity.high) {
    _scheduleWithDelay(alert, Duration(minutes: 5), maxBatch: 3);
    return;
  }
  
  // Medium/Low - batch với delay 15 phút
  _scheduleWithDelay(alert, Duration(minutes: 15), maxBatch: 5);
}
```

#### 6.2. Cooldown Management

**Mục đích**: Tránh gửi notification quá dày

**Thời gian**: 2 phút giữa mỗi lần gửi

**Scope**: Theo audience group (victims, volunteers, all)

**Logic**:
```
lastTime = lastNotificationTime[audienceKey]
elapsed = now - lastTime
isInCooldown = (elapsed < 2 minutes)
```

**Timeline Example**:
```
Time    Event
-----   -----
00:00   Alert 1 (Critical) -> Gửi ngay
00:01   Alert 2 (High) -> In cooldown, add to batch
00:02   Alert 3 (High) -> Still in cooldown, add to batch
00:03   Cooldown expires (2min passed)
00:03   Alert 4 (High) -> Can send now (or batch)
```

#### 6.3. Batch Content Creation

**Title Format**:

```dart
if (batch.length == 1):
    title = alert.title
else:
    icon = getSeverityIcon(highestSeverity)
    title = "$icon ${batch.length} Cảnh báo mới"
```

**Body Format**:

```dart
if (batch.length == 1):
    body = alert.content
else:
    // Liệt kê tối đa 3 cái đầu
    for (i = 0; i < min(3, batch.length); i++):
        icon = getTypeIcon(alert.type)
        lines.add("$icon ${alert.title}")
    
    if (batch.length > 3):
        lines.add("...và ${batch.length - 3} cảnh báo khác")
```

**Ví dụ Batch Notification**:

```
Batch: 4 alerts (2 high, 2 medium)

Title: "⚠️ 4 Cảnh báo mới"

Body:
"🌧️ Mưa lớn khu vực Quận 1
 🌪️ Nguy cơ lũ quét tại Quận 7
 📦 Trung tâm cứu trợ mở cửa
 ...và 1 cảnh báo khác"
```

---

## So sánh Complexity

| Algorithm | Time | Space | Notes |
|-----------|------|-------|-------|
| Scoring | O(1) | O(1) | Mỗi alert |
| Time Decay | O(1) | O(1) | Math formula |
| Haversine | O(1) | O(1) | Trig functions |
| Heap Insert | O(log n) | O(1) | n = queue size |
| Heap Extract | O(log n) | O(1) | |
| Jaccard | O(n+m) | O(n+m) | n,m = word counts |
| Batching | O(1) | O(k) | k = batch size |

---

## Performance Tips

### 1. Tránh tính score nhiều lần

```dart
// ❌ Bad
for (alert in alerts) {
  if (scoringService.calculateScore(alert) > 50) {
    display(alert);
  }
}

// ✅ Good
final scored = scoringService.calculateMultiple(alerts);
final filtered = scored.where((s) => s.score > 50);
```

### 2. Cache distance calculations

```dart
// ✅ Good
final distanceCache = <String, double>{};

double getDistance(String alertId) {
  return distanceCache.putIfAbsent(alertId, () {
    return haversineDistance(...);
  });
}
```

### 3. Batch process alerts

```dart
// ✅ Good
final queue = AlertPriorityQueue();
queue.insertAll(scoredAlerts);  // Batch insert

final top10 = queue.peekN(10);  // Batch peek
```

---

## Testing Guidelines

### Unit Test Coverage

Mỗi algorithm cần test:

1. **Happy path**: Input thông thường
2. **Edge cases**: Empty, null, boundary values
3. **Performance**: Large datasets
4. **Accuracy**: So sánh với expected results

### Example Test Cases

**Alert Scoring**:
```
✓ Critical > High > Medium > Low
✓ Nearby > Far
✓ New > Old
✓ Matching audience > Non-matching
✓ Custom weights work correctly
```

**Priority Queue**:
```
✓ Extract in correct order
✓ Heap property maintained
✓ Handle duplicates
✓ Performance with 1000+ items
```

**Deduplication**:
```
✓ Identical content = 1.0 similarity
✓ Different content = low similarity
✓ Filter removes duplicates
✓ Clustering works correctly
```

---

## References

### Academic Papers
- ["Efficient Priority Queue"](https://en.wikipedia.org/wiki/Heap_(data_structure))
- ["Similarity Measures"](https://en.wikipedia.org/wiki/Jaccard_index)

### Implementation Guides
- Flutter Performance Best Practices
- Dart Math Library Documentation
- Firebase Cloud Messaging Guidelines

---

**Cập nhật**: 2024  
**Version**: 1.0.0



Thư mục này chứa tài liệu chi tiết về các thuật toán được sử dụng trong Hệ thống Cảnh báo Thông minh.

## Danh sách Thuật toán

### 1. Multi-factor Severity Scoring Algorithm

**File implementation**: `lib/domain/services/alert_scoring_service.dart`

Thuật toán tính điểm ưu tiên tổng hợp cho mỗi cảnh báo dựa trên 5 yếu tố.

**Độ phức tạp**: O(1) - Constant time

**Use case**: Sắp xếp và ưu tiên hiển thị cảnh báo cho người dùng

**Đặc điểm**:
- Kết hợp weighted scoring từ nhiều yếu tố
- Có thể tùy chỉnh trọng số
- Điểm output từ 0-100 để dễ so sánh

**Công thức**:
```
FinalScore = Σ(Wi × Scorei) 
           = W1×Severity + W2×Type + W3×TimeDecay + W4×Distance + W5×Audience
```

**Bảng điểm chi tiết**:

| Yếu tố | Trọng số | Phạm vi điểm | Công thức/Logic |
|--------|----------|--------------|-----------------|
| Severity | 35% | 25-100 | Critical:100, High:75, Medium:50, Low:25 |
| Type | 20% | 30-100 | Disaster:100, Evacuation:90, Weather:70, Resource:50, General:30 |
| Time Decay | 15% | 0-100 | 100 × e^(-λt) |
| Distance | 20% | 0-100 | 100 × (1 - d/r)² |
| Audience | 10% | 50-100 | Match:100, All:100, LocationBased:80, Other:50 |

**Ví dụ tính toán**:

```
Alert: "Bão cấp 12 đang vào bờ"
- Severity: Critical -> 100 điểm
- Type: Disaster -> 100 điểm
- Time: 2 giờ trước -> 90.5 điểm (decay)
- Distance: 5km -> 98.0 điểm
- Audience: Victims (matching) -> 100 điểm

FinalScore = 0.35×100 + 0.20×100 + 0.15×90.5 + 0.20×98.0 + 0.10×100
           = 35 + 20 + 13.58 + 19.6 + 10
           = 98.18
```

**Trade-offs**:
- ✅ Linh hoạt, dễ điều chỉnh
- ✅ Kết quả trực quan (0-100)
- ❌ Cần fine-tuning trọng số cho từng use case
- ❌ Không xử lý edge cases phức tạp

---

### 2. Time Decay Algorithm

**File implementation**: `lib/domain/services/alert_scoring_service.dart` (method `_calculateTimeDecay`)

Thuật toán suy giảm điểm theo thời gian sử dụng **Exponential Decay**.

**Độ phức tạp**: O(1)

**Use case**: Ưu tiên cảnh báo mới hơn cảnh báo cũ

**Công thức Exponential Decay**:
```
Score(t) = S₀ × e^(-λt)

Trong đó:
- S₀ = 100 (điểm ban đầu)
- λ = 0.05 (hệ số suy giảm, configurable)
- t = thời gian tính bằng giờ
- e = số Euler (~2.71828)
```

**Phân tích suy giảm**:

| Thời gian | Score | % còn lại |
|-----------|-------|-----------|
| 0 giờ | 100.00 | 100% |
| 6 giờ | 74.08 | 74% |
| 12 giờ | 54.88 | 55% |
| 18 giờ | 40.66 | 41% |
| 24 giờ | 30.12 | 30% |
| 36 giờ | 16.53 | 17% |
| 48 giờ | 9.07 | 9% |
| 72 giờ | 2.73 | 3% |

**Đồ thị**:
```
Score
100 |●
    | ●
 80 |  ●
    |   ●
 60 |    ●●
    |      ●
 40 |       ●●
    |         ●●
 20 |           ●●●
    |              ●●●●●●
  0 |____________________●●●●●●●●
    0  12  24  36  48  60  72  84  hours
```

**Half-life calculation**:
```
t_half = ln(2) / λ = 0.693 / 0.05 = 13.86 giờ
```
Sau ~14 giờ, điểm giảm còn một nửa.

**Implementation**:
```dart
double _calculateTimeDecay(DateTime createdAt, DateTime? expiresAt) {
  const double lambda = 0.05;
  final now = DateTime.now();
  
  // Nếu đã hết hạn, trả về 0
  if (expiresAt != null && now.isAfter(expiresAt)) {
    return 0.0;
  }
  
  // Tính giờ đã trôi qua
  final hoursElapsed = now.difference(createdAt).inMinutes / 60.0;
  
  // Exponential decay
  final decayScore = 100 * math.exp(-lambda * hoursElapsed);
  
  return decayScore.clamp(0.0, 100.0);
}
```

**Tại sao chọn Exponential Decay?**:
- ✅ Mô phỏng tự nhiên: Thông tin cũ mất giá trị nhanh ban đầu, chậm dần sau đó
- ✅ Smooth transition: Không có điểm nhảy đột ngột
- ✅ Toán học đơn giản: Dễ tính toán và giải thích
- ✅ Được chứng minh: Sử dụng rộng rãi trong information retrieval

**Alternative algorithms đã xem xét**:
1. **Linear Decay**: `Score = 100 - (t × k)`
   - ❌ Quá đơn giản, không tự nhiên
2. **Step Function**: Giảm theo từng bước thời gian
   - ❌ Có điểm nhảy đột ngột
3. **Logarithmic Decay**: `Score = 100 × log(1 + 1/t)`
   - ❌ Giảm quá chậm

---

### 3. Location-based Priority Boost

**File implementation**: `lib/domain/services/alert_scoring_service.dart` (methods `_calculateDistanceScore`, `_haversineDistance`)

Thuật toán tăng điểm ưu tiên dựa trên khoảng cách địa lý.

**Độ phức tạp**: O(1)

**Gồm 2 components**:

#### 3.1. Haversine Formula (Tính khoảng cách)

Công thức tính khoảng cách chính xác giữa 2 điểm trên mặt cầu.

**Công thức đầy đủ**:
```
a = sin²(Δlat/2) + cos(lat₁) × cos(lat₂) × sin²(Δlng/2)
c = 2 × atan2(√a, √(1-a))
d = R × c

Trong đó:
- lat₁, lng₁: Tọa độ điểm 1
- lat₂, lng₂: Tọa độ điểm 2
- Δlat = lat₂ - lat₁
- Δlng = lng₂ - lng₁
- R = 6371 km (bán kính Trái Đất)
- d = khoảng cách (km)
```

**Độ chính xác**: 
- Sai số < 0.5% cho hầu hết trường hợp
- Phù hợp với khoảng cách < 1000km

**Implementation**:
```dart
double _haversineDistance(
  double lat1, double lng1,
  double lat2, double lng2,
) {
  const double earthRadius = 6371.0; // km
  
  // Chuyển sang radian
  final dLat = _toRadians(lat2 - lat1);
  final dLng = _toRadians(lng2 - lng1);
  
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_toRadians(lat1)) *
          math.cos(_toRadians(lat2)) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  
  return earthRadius * c;
}
```

**Ví dụ tính toán**:
```
Point A: Hồ Chí Minh City (10.762622, 106.660172)
Point B: Biên Hòa (10.951572, 106.843395)

Δlat = 0.188950 rad
Δlng = 0.183223 rad

a = 0.00893
c = 0.18946 rad
d = 6371 × 0.18946 = 23.8 km
```

#### 3.2. Inverse Distance Weighting (Tính điểm)

Công thức điểm dựa trên khoảng cách với quadratic falloff.

**Công thức**:
```
DistanceScore = 100 × (1 - d/r)²

Trong đó:
- d = khoảng cách (km)
- r = bán kính tối đa (mặc định 50km)
```

**Bảng điểm chi tiết**:

| Khoảng cách | Ratio (1-d/r) | Score | Ý nghĩa |
|-------------|---------------|-------|---------|
| 0 km | 1.00 | 100.0 | Ngay tại chỗ |
| 5 km | 0.90 | 81.0 | Rất gần |
| 10 km | 0.80 | 64.0 | Gần |
| 15 km | 0.70 | 49.0 | Khá gần |
| 20 km | 0.60 | 36.0 | Trung bình |
| 25 km | 0.50 | 25.0 | Hơi xa |
| 30 km | 0.40 | 16.0 | Xa |
| 40 km | 0.20 | 4.0 | Rất xa |
| 50+ km | 0.00 | 0.0 | Ngoài phạm vi |

**Đồ thị**:
```
Score
100 |●
    | ●●
 80 |   ●●
    |     ●●
 60 |       ●●
    |         ●●
 40 |           ●●
    |             ●●●
 20 |                ●●●
    |                   ●●●●
  0 |_______________________●●●●●●
    0   10   20   30   40   50  km
```

**Tại sao quadratic (mũ 2)?**:
- ✅ Phạt nặng khoảng cách xa hơn
- ✅ Tạo sự phân biệt rõ ràng
- ✅ Khuyến khích ưu tiên cảnh báo gần

**Alternative weighting functions**:

1. **Linear**: `Score = 100 × (1 - d/r)`
   ```
   - Giảm đều đặn
   - ❌ Không đủ phân biệt
   ```

2. **Exponential**: `Score = 100 × e^(-d/k)`
   ```
   - Giảm rất nhanh
   - ❌ Quá nhạy cảm với khoảng cách nhỏ
   ```

3. **Cubic**: `Score = 100 × (1 - d/r)³`
   ```
   - Giảm cực nhanh
   - ❌ Quá khắt khe
   ```

---

### 4. Priority Queue (Max-Heap)

**File implementation**: `lib/core/data_structures/alert_priority_queue.dart`

Cấu trúc dữ liệu Heap để quản lý hàng đợi theo ưu tiên.

**Độ phức tạp**:
- Insert: O(log n)
- Extract Max: O(log n)
- Peek: O(1)
- Build Heap: O(n)
- Space: O(n)

**Heap Property**: 
- **Max-Heap**: `parent.score >= children.score` cho mọi node

**Cấu trúc trong Array**:
```
Array: [90, 75, 80, 50, 60, 70, 65]
Index:  0   1   2   3   4   5   6

Tree:
            90 [0]
           /  \
        75[1]  80[2]
       /  \    /  \
     50[3] 60[4] 70[5] 65[6]
```

**Quan hệ Parent-Child**:
```
Parent của node i:    (i-1) / 2
Left child của node i:  2*i + 1
Right child của node i: 2*i + 2
```

#### Bubble Up Algorithm

Được gọi sau insert, di chuyển node lên đến vị trí đúng.

**Pseudocode**:
```
function bubbleUp(index):
    while index > 0:
        parentIndex = (index - 1) / 2
        if heap[index] <= heap[parentIndex]:
            break
        swap(heap[index], heap[parentIndex])
        index = parentIndex
```

**Ví dụ**:
```
Insert 95 vào heap [90, 75, 80, 50, 60, 70]

1. Thêm vào cuối:
   [90, 75, 80, 50, 60, 70, 95]
                            ^^

2. Bubble up (95 > 80):
   [90, 75, 95, 50, 60, 70, 80]
            ^^

3. Bubble up (95 > 90):
   [95, 75, 90, 50, 60, 70, 80]
    ^^
```

**Độ phức tạp**: O(log n) - Tối đa log₂(n) swaps

#### Bubble Down Algorithm

Được gọi sau extract max, di chuyển node xuống đến vị trí đúng.

**Pseudocode**:
```
function bubbleDown(index):
    while true:
        largest = index
        leftChild = 2 * index + 1
        rightChild = 2 * index + 2
        
        if leftChild < size && heap[leftChild] > heap[largest]:
            largest = leftChild
        if rightChild < size && heap[rightChild] > heap[largest]:
            largest = rightChild
        
        if largest == index:
            break
        
        swap(heap[index], heap[largest])
        index = largest
```

**Ví dụ**:
```
Extract max từ [95, 75, 90, 50, 60, 70, 80]

1. Lấy root (95), di chuyển cuối (80) lên:
   [80, 75, 90, 50, 60, 70]
    ^^

2. Bubble down (80 < 90):
   [90, 75, 80, 50, 60, 70]
    ^^      ^^

3. Xong! (80 >= con của nó)
```

**Độ phức tạp**: O(log n)

#### Build Heap

Xây dựng heap từ array unsorted.

**Phương pháp 1**: Insert lần lượt
```
Complexity: O(n log n)
```

**Phương pháp 2**: Heapify từ dưới lên (tối ưu hơn)
```
for i from n/2 - 1 down to 0:
    bubbleDown(i)

Complexity: O(n) - Tốt hơn!
```

---

### 5. Jaccard Similarity (Deduplication)

**File implementation**: `lib/domain/services/alert_deduplication_service.dart`

Thuật toán đo độ tương tự giữa 2 tập hợp.

**Độ phức tạp**: O(n + m) với n, m là số từ trong 2 text

**Use case**: Phát hiện cảnh báo trùng lặp

**Công thức**:
```
J(A, B) = |A ∩ B| / |A ∪ B|

Trong đó:
- A, B: Tập hợp các từ
- |A ∩ B|: Số phần tử chung (intersection)
- |A ∪ B|: Tổng phần tử unique (union)
- J: Jaccard coefficient (0-1)
```

**Ví dụ chi tiết**:

```
Text 1: "Bão cấp 12 đang tiến vào bờ biển miền Trung"
Text 2: "Bão cấp 12 sắp vào bờ biển miền Trung"

--- Tokenization ---
Words₁ = {bão, cấp, 12, đang, tiến, vào, bờ, biển, miền, trung}
Words₂ = {bão, cấp, 12, sắp, vào, bờ, biển, miền, trung}

--- Calculate Intersection ---
A ∩ B = {bão, cấp, 12, vào, bờ, biển, miền, trung}
|A ∩ B| = 8

--- Calculate Union ---
A ∪ B = {bão, cấp, 12, đang, tiến, sắp, vào, bờ, biển, miền, trung}
|A ∪ B| = 11

--- Jaccard Similarity ---
J(A,B) = 8 / 11 = 0.727 (72.7%)
```

**Ngưỡng similarity**: 0.80 (80%)

```
> 0.80: Coi là duplicate
≤ 0.80: Coi là khác nhau
```

**Tokenization Process**:

```dart
Set<String> _tokenize(String text) {
  return text
      .toLowerCase()           // "Bão Cấp 12" -> "bão cấp 12"
      .replaceAll(            // Loại bỏ dấu câu
          RegExp(r'[^\w\s]'), 
          ''
      )
      .split(RegExp(r'\s+'))  // Tách từ: ["bão", "cấp", "12"]
      .where((w) =>           // Lọc từ ngắn (stopwords)
          w.length > 2
      )
      .toSet();               // Chuyển thành Set (loại trùng)
}
```

**Ví dụ Tokenization**:
```
Input:  "Mưa lớn, gió mạnh! Cần sơ tán gấp!!!"
Step 1: "mưa lớn, gió mạnh! cần sơ tán gấp!!!"  (lowercase)
Step 2: "mưa lớn gió mạnh cần sơ tán gấp"       (remove punct)
Step 3: ["mưa", "lớn", "gió", "mạnh", "cần", "sơ", "tán", "gấp"]
Step 4: ["mưa", "lớn", "gió", "mạnh", "cần", "tán", "gấp"]  (filter len>2)
Output: {"mưa", "lớn", "gió", "mạnh", "cần", "tán", "gấp"}
```

**Tại sao chọn Jaccard?**:

✅ **Ưu điểm**:
- Đơn giản, dễ hiểu
- Không bị ảnh hưởng bởi độ dài text
- Hiệu quả với short text
- Xử lý tốt từ lặp lại (dùng Set)

❌ **Nhược điểm**:
- Không quan tâm thứ tự từ
- Không xử lý synonym (từ đồng nghĩa)
- Không xử lý typo

**Alternative algorithms**:

1. **Cosine Similarity**:
   ```
   - Dùng vector, xử lý frequency
   - ❌ Phức tạp hơn cho task này
   ```

2. **Levenshtein Distance**:
   ```
   - Edit distance giữa 2 string
   - ❌ O(n×m) complexity, chậm
   ```

3. **TF-IDF + Cosine**:
   ```
   - Tốt cho long documents
   - ❌ Overkill cho short alerts
   ```

---

### 6. Smart Notification Batching

**File implementation**: `lib/data/services/smart_notification_service.dart`

Kỹ thuật gộp nhiều notification thành một để giảm spam.

**Độ phức tạp**: O(1) per notification

**Components**:

#### 6.1. Batching Strategy

**Quy tắc**:

| Severity | Batch Size | Delay | Logic |
|----------|-----------|-------|-------|
| Critical | 1 (không batch) | 0s | Gửi ngay |
| High | Max 3 | 5 phút | Batch nhỏ |
| Medium/Low | Max 5 | 15 phút | Batch lớn |

**State Machine**:

```
┌─────────────────────────────────────┐
│  Notification arrives                │
└───────────────┬─────────────────────┘
                │
                v
        ┌───────────────┐
        │  Is Critical? │
        └───────┬───────┘
                │
        ┌───────┴────────┐
        │ Yes            │ No
        v                v
  ┌──────────┐    ┌─────────────┐
  │ Send Now │    │ Check       │
  │          │    │ Cooldown    │
  └──────────┘    └─────┬───────┘
                        │
                ┌───────┴────────┐
                │ Yes            │ No
                v                v
         ┌──────────┐     ┌─────────────┐
         │ Add to   │     │ Schedule    │
         │ Batch    │     │ with Timer  │
         └──────────┘     └─────────────┘
```

**Implementation**:

```dart
void scheduleNotification(ScoredAlert alert) {
  // Critical - gửi ngay
  if (alert.severity == AlertSeverity.critical) {
    _sendImmediate(alert);
    return;
  }
  
  // Check cooldown
  if (_isInCooldown(audienceKey)) {
    _addToBatch(audienceKey, alert);
    return;
  }
  
  // High - batch với delay 5 phút
  if (alert.severity == AlertSeverity.high) {
    _scheduleWithDelay(alert, Duration(minutes: 5), maxBatch: 3);
    return;
  }
  
  // Medium/Low - batch với delay 15 phút
  _scheduleWithDelay(alert, Duration(minutes: 15), maxBatch: 5);
}
```

#### 6.2. Cooldown Management

**Mục đích**: Tránh gửi notification quá dày

**Thời gian**: 2 phút giữa mỗi lần gửi

**Scope**: Theo audience group (victims, volunteers, all)

**Logic**:
```
lastTime = lastNotificationTime[audienceKey]
elapsed = now - lastTime
isInCooldown = (elapsed < 2 minutes)
```

**Timeline Example**:
```
Time    Event
-----   -----
00:00   Alert 1 (Critical) -> Gửi ngay
00:01   Alert 2 (High) -> In cooldown, add to batch
00:02   Alert 3 (High) -> Still in cooldown, add to batch
00:03   Cooldown expires (2min passed)
00:03   Alert 4 (High) -> Can send now (or batch)
```

#### 6.3. Batch Content Creation

**Title Format**:

```dart
if (batch.length == 1):
    title = alert.title
else:
    icon = getSeverityIcon(highestSeverity)
    title = "$icon ${batch.length} Cảnh báo mới"
```

**Body Format**:

```dart
if (batch.length == 1):
    body = alert.content
else:
    // Liệt kê tối đa 3 cái đầu
    for (i = 0; i < min(3, batch.length); i++):
        icon = getTypeIcon(alert.type)
        lines.add("$icon ${alert.title}")
    
    if (batch.length > 3):
        lines.add("...và ${batch.length - 3} cảnh báo khác")
```

**Ví dụ Batch Notification**:

```
Batch: 4 alerts (2 high, 2 medium)

Title: "⚠️ 4 Cảnh báo mới"

Body:
"🌧️ Mưa lớn khu vực Quận 1
 🌪️ Nguy cơ lũ quét tại Quận 7
 📦 Trung tâm cứu trợ mở cửa
 ...và 1 cảnh báo khác"
```

---

## So sánh Complexity

| Algorithm | Time | Space | Notes |
|-----------|------|-------|-------|
| Scoring | O(1) | O(1) | Mỗi alert |
| Time Decay | O(1) | O(1) | Math formula |
| Haversine | O(1) | O(1) | Trig functions |
| Heap Insert | O(log n) | O(1) | n = queue size |
| Heap Extract | O(log n) | O(1) | |
| Jaccard | O(n+m) | O(n+m) | n,m = word counts |
| Batching | O(1) | O(k) | k = batch size |

---

## Performance Tips

### 1. Tránh tính score nhiều lần

```dart
// ❌ Bad
for (alert in alerts) {
  if (scoringService.calculateScore(alert) > 50) {
    display(alert);
  }
}

// ✅ Good
final scored = scoringService.calculateMultiple(alerts);
final filtered = scored.where((s) => s.score > 50);
```

### 2. Cache distance calculations

```dart
// ✅ Good
final distanceCache = <String, double>{};

double getDistance(String alertId) {
  return distanceCache.putIfAbsent(alertId, () {
    return haversineDistance(...);
  });
}
```

### 3. Batch process alerts

```dart
// ✅ Good
final queue = AlertPriorityQueue();
queue.insertAll(scoredAlerts);  // Batch insert

final top10 = queue.peekN(10);  // Batch peek
```

---

## Testing Guidelines

### Unit Test Coverage

Mỗi algorithm cần test:

1. **Happy path**: Input thông thường
2. **Edge cases**: Empty, null, boundary values
3. **Performance**: Large datasets
4. **Accuracy**: So sánh với expected results

### Example Test Cases

**Alert Scoring**:
```
✓ Critical > High > Medium > Low
✓ Nearby > Far
✓ New > Old
✓ Matching audience > Non-matching
✓ Custom weights work correctly
```

**Priority Queue**:
```
✓ Extract in correct order
✓ Heap property maintained
✓ Handle duplicates
✓ Performance with 1000+ items
```

**Deduplication**:
```
✓ Identical content = 1.0 similarity
✓ Different content = low similarity
✓ Filter removes duplicates
✓ Clustering works correctly
```

---

## References

### Academic Papers
- ["Efficient Priority Queue"](https://en.wikipedia.org/wiki/Heap_(data_structure))
- ["Similarity Measures"](https://en.wikipedia.org/wiki/Jaccard_index)

### Implementation Guides
- Flutter Performance Best Practices
- Dart Math Library Documentation
- Firebase Cloud Messaging Guidelines

---

**Cập nhật**: 2024  
**Version**: 1.0.0



