# 📚 Tài liệu Chi tiết các Thuật toán
# AppThienTai - Hệ thống Cứu trợ Thiên tai

**Phiên bản**: 2.0.0  
**Cập nhật**: Tháng 01/2026

---

## 📑 Mục lục

1. [Tổng quan Thuật toán](#1-tổng-quan-thuật-toán)
2. [Mobile App (Flutter/Dart)](#2-mobile-app-flutterdart)
   - [Multi-factor Severity Scoring](#21-multi-factor-severity-scoring)
   - [Time Decay (Exponential)](#22-time-decay-exponential)
   - [Haversine Distance](#23-haversine-distance)
   - [Inverse Distance Weighting](#24-inverse-distance-weighting)
   - [Priority Queue (Max-Heap)](#25-priority-queue-max-heap)
   - [Jaccard Similarity](#26-jaccard-similarity)
   - [Smart Notification Batching](#27-smart-notification-batching)
   - [Geofencing with Deduplication](#28-geofencing-with-deduplication)
3. [Routing Service](#3-routing-service)
   - [OSRM Routing (Dijkstra/CH)](#31-osrm-routing-dijkstrach)
4. [AI Service (Python/FastAPI)](#4-ai-service-pythonfastapi)
   - [XGBoost Hazard Prediction](#41-xgboost-hazard-prediction)
   - [Random Forest Alert Scoring](#42-random-forest-alert-scoring)
   - [Sentence Transformers Duplicate Detection](#43-sentence-transformers-duplicate-detection)
   - [Thompson Sampling (Contextual Bandit)](#44-thompson-sampling-contextual-bandit)
5. [Bảng So sánh Complexity](#5-bảng-so-sánh-complexity)
6. [References](#6-references)

---

## 1. Tổng quan Thuật toán

### Phân loại theo Layer

| Layer | Thuật toán | Ngôn ngữ | Use case |
|-------|-----------|----------|----------|
| **Mobile** | Multi-factor Scoring | Dart | Sắp xếp ưu tiên cảnh báo |
| **Mobile** | Exponential Decay | Dart | Ưu tiên tin mới |
| **Mobile** | Haversine Distance | Dart | Tính khoảng cách GPS |
| **Mobile** | Max-Heap | Dart | Priority Queue |
| **Mobile** | Jaccard Similarity | Dart | Phát hiện trùng lặp |
| **Mobile** | Smart Batching | Dart | Gộp notification |
| **Routing** | OSRM (Dijkstra/CH) | API | Tìm đường đi ngắn nhất |
| **AI** | XGBoost | Python | Dự báo thiên tai |
| **AI** | Random Forest | Python | Scoring cảnh báo ML |
| **AI** | Sentence BERT | Python | Semantic duplicate |
| **AI** | Thompson Sampling | Python | Tối ưu thời điểm gửi |

---

## 2. Mobile App (Flutter/Dart)

### 2.1. Multi-factor Severity Scoring

**File**: `lib/domain/services/alert_scoring_service.dart`

Thuật toán tính điểm ưu tiên tổng hợp cho cảnh báo dựa trên **5 yếu tố**.

**Độ phức tạp**: O(1) - Constant time

**Công thức**:
```
FinalScore = Σ(Wi × Scorei) 
           = W₁×Severity + W₂×Type + W₃×TimeDecay + W₄×Distance + W₅×Audience
```

**Bảng trọng số và điểm**:

| Yếu tố | Trọng số | Phạm vi điểm | Logic |
|--------|----------|--------------|-------|
| **Severity** | 35% | 25-100 | Critical:100, High:75, Medium:50, Low:25 |
| **Type** | 20% | 30-100 | Disaster:100, Evacuation:90, Weather:70, Resource:50, General:30 |
| **Time Decay** | 15% | 0-100 | 100 × e^(-λt) với λ=0.05 |
| **Distance** | 20% | 0-100 | 100 × (1 - d/r)² với r=50km |
| **Audience** | 10% | 50-100 | Match:100, All:100, LocationBased:80, Other:50 |

**Ví dụ tính toán**:
```
Alert: "Bão cấp 12 đang vào bờ"
├── Severity: Critical → 100 điểm
├── Type: Disaster → 100 điểm
├── Time: 2 giờ trước → 90.5 điểm (decay)
├── Distance: 5km → 98.0 điểm
└── Audience: Victims (matching) → 100 điểm

FinalScore = 0.35×100 + 0.20×100 + 0.15×90.5 + 0.20×98.0 + 0.10×100
           = 35 + 20 + 13.58 + 19.6 + 10
           = 98.18
```

---

### 2.2. Time Decay (Exponential)

**File**: `lib/domain/services/alert_scoring_service.dart` → `_calculateTimeDecay()`

Thuật toán suy giảm điểm theo thời gian sử dụng **Exponential Decay**.

**Độ phức tạp**: O(1)

**Công thức**:
```
Score(t) = S₀ × e^(-λt)

Trong đó:
- S₀ = 100 (điểm ban đầu)
- λ = 0.05 (hệ số suy giảm)
- t = thời gian (giờ)
- e = số Euler (~2.71828)
```

**Half-life**: `t_half = ln(2) / λ = 13.86 giờ`

**Bảng suy giảm**:

| Thời gian | Score | % còn lại |
|-----------|-------|-----------|
| 0 giờ | 100.00 | 100% |
| 6 giờ | 74.08 | 74% |
| 12 giờ | 54.88 | 55% |
| 24 giờ | 30.12 | 30% |
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

**Implementation**:
```dart
double _calculateTimeDecay(DateTime createdAt, DateTime? expiresAt) {
  const double lambda = 0.05;
  final now = DateTime.now();
  
  if (expiresAt != null && now.isAfter(expiresAt)) return 0.0;
  
  final hoursElapsed = now.difference(createdAt).inMinutes / 60.0;
  final decayScore = 100 * math.exp(-lambda * hoursElapsed);
  
  return decayScore.clamp(0.0, 100.0);
}
```

---

### 2.3. Haversine Distance

**File**: `lib/domain/services/alert_scoring_service.dart` → `_haversineDistance()`  
**File**: `lib/data/services/geofencing_service.dart` → `_calculateDistance()`

Công thức tính khoảng cách chính xác giữa 2 điểm trên **mặt cầu Trái Đất**.

**Độ phức tạp**: O(1)

**Công thức**:
```
a = sin²(Δlat/2) + cos(lat₁) × cos(lat₂) × sin²(Δlng/2)
c = 2 × atan2(√a, √(1-a))
d = R × c

Trong đó:
- lat₁, lng₁: Tọa độ điểm 1 (radian)
- lat₂, lng₂: Tọa độ điểm 2 (radian)
- R = 6371 km (bán kính Trái Đất)
- d = khoảng cách (km)
```

**Độ chính xác**: Sai số < 0.5% cho khoảng cách < 1000km

**Implementation**:
```dart
double _haversineDistance(double lat1, double lng1, double lat2, double lng2) {
  const double earthRadius = 6371.0; // km
  
  final dLat = _toRadians(lat2 - lat1);
  final dLng = _toRadians(lng2 - lng1);
  
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_toRadians(lat1)) *
      math.cos(_toRadians(lat2)) *
      math.sin(dLng / 2) * math.sin(dLng / 2);
  
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  
  return earthRadius * c;
}
```

**Ví dụ**:
```
HCM City: (10.762622, 106.660172)
Biên Hòa: (10.951572, 106.843395)
→ Khoảng cách: 23.8 km
```

---

### 2.4. Inverse Distance Weighting

**File**: `lib/domain/services/alert_scoring_service.dart` → `_calculateDistanceScore()`

Công thức điểm dựa trên khoảng cách với **quadratic falloff**.

**Độ phức tạp**: O(1)

**Công thức**:
```
DistanceScore = 100 × (1 - d/r)²

Trong đó:
- d = khoảng cách từ user đến alert (km)
- r = bán kính tối đa (mặc định 50km)
```

**Bảng điểm**:

| Khoảng cách | Ratio | Score | Ý nghĩa |
|-------------|-------|-------|---------|
| 0 km | 1.00 | 100.0 | Ngay tại chỗ |
| 5 km | 0.90 | 81.0 | Rất gần |
| 10 km | 0.80 | 64.0 | Gần |
| 20 km | 0.60 | 36.0 | Trung bình |
| 30 km | 0.40 | 16.0 | Xa |
| 50+ km | 0.00 | 0.0 | Ngoài phạm vi |

**Tại sao chọn Quadratic?**
- ✅ Phạt nặng khoảng cách xa
- ✅ Tạo phân biệt rõ ràng
- ✅ Ưu tiên cảnh báo gần người dùng

---

### 2.5. Priority Queue (Max-Heap)

**File**: `lib/core/data_structures/alert_priority_queue.dart`

Cấu trúc dữ liệu **Heap** để quản lý cảnh báo theo ưu tiên.

**Độ phức tạp**:
| Operation | Time | Space |
|-----------|------|-------|
| Insert | O(log n) | O(1) |
| Extract Max | O(log n) | O(1) |
| Peek | O(1) | O(1) |
| Build Heap | O(n) | O(n) |

**Heap Property**: `parent.score >= children.score` (Max-Heap)

**Quan hệ index trong Array**:
```
Parent của node i:     (i-1) / 2
Left child của node i:  2*i + 1
Right child của node i: 2*i + 2
```

**Bubble Up** (sau Insert):
```
function bubbleUp(index):
    while index > 0:
        parentIndex = (index - 1) / 2
        if heap[index] <= heap[parentIndex]:
            break
        swap(heap[index], heap[parentIndex])
        index = parentIndex
```

**Bubble Down** (sau Extract):
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

---

### 2.6. Jaccard Similarity

**File**: `lib/domain/services/alert_deduplication_service.dart`

Thuật toán đo **độ tương tự** giữa 2 tập hợp từ.

**Độ phức tạp**: O(n + m) với n, m là số từ

**Công thức**:
```
J(A, B) = |A ∩ B| / |A ∪ B|

Trong đó:
- A, B: Tập hợp các từ đã tokenize
- |A ∩ B|: Số phần tử chung (intersection)
- |A ∪ B|: Tổng phần tử unique (union)
```

**Ngưỡng**: ≥ 0.80 (80%) → Coi là duplicate

**Ví dụ**:
```
Text 1: "Bão cấp 12 đang tiến vào bờ biển miền Trung"
Text 2: "Bão cấp 12 sắp vào bờ biển miền Trung"

Words₁ = {bão, cấp, 12, đang, tiến, vào, bờ, biển, miền, trung}
Words₂ = {bão, cấp, 12, sắp, vào, bờ, biển, miền, trung}

A ∩ B = 8 từ chung
A ∪ B = 11 từ unique

J(A,B) = 8/11 = 0.727 (72.7%) → Không phải duplicate
```

**Tokenization Process**:
```dart
Set<String> _tokenize(String text) {
  return text
      .toLowerCase()
      .replaceAll(RegExp(r'[^\w\s]'), '')
      .split(RegExp(r'\s+'))
      .where((w) => w.length > 2)
      .toSet();
}
```

---

### 2.7. Smart Notification Batching

**File**: `lib/data/services/smart_notification_service.dart`

Kỹ thuật **gộp notification** thông minh với batching và cooldown.

**Độ phức tạp**: O(1) per notification

**Quy tắc Batching**:

| Severity | Batch Size | Delay | Action |
|----------|-----------|-------|--------|
| Critical | 1 | 0s | Gửi ngay lập tức |
| High | Max 3 | 5 phút | Batch nhỏ |
| Medium/Low | Max 5 | 15 phút | Batch lớn |

**Cooldown**: 2 phút giữa mỗi lần gửi (theo audience group)

**State Machine**:
```
Notification arrives
        │
        v
  Is Critical? ──Yes──> Send Immediately
        │
       No
        v
  In Cooldown? ──Yes──> Add to Batch
        │
       No
        v
  Schedule with Timer (5/15 min)
        │
        v
  Timer expires → Process Batch → Send
```

**Batch Notification Format**:
```
Title: "⚠️ 4 Cảnh báo mới"
Body:
  🌧️ Mưa lớn khu vực Quận 1
  🌪️ Nguy cơ lũ quét tại Quận 7
  📦 Trung tâm cứu trợ mở cửa
  ...và 1 cảnh báo khác
```

---

### 2.8. Geofencing with Deduplication

**File**: `lib/data/services/geofencing_service.dart`

Hệ thống cảnh báo tự động khi user vào **vùng nguy hiểm**.

**Components**:
1. **Location Tracking**: GPS update mỗi 100m
2. **Zone Checking**: Haversine distance calculation
3. **Deduplication**: Tránh gửi trùng cùng một cảnh báo
4. **Priority Scoring**: AI tính điểm ưu tiên

**Flow**:
```
User moves (100m)
      │
      v
Check all active alerts
      │
      v
For each alert:
  ├── Calculate distance (Haversine)
  ├── If distance <= alert.radius:
  │     ├── Check deduplication
  │     ├── Calculate priority score
  │     └── Send via SmartNotificationService
  └── Skip if already triggered
```

---

## 3. Routing Service

### 3.1. OSRM Routing (Dijkstra/Contraction Hierarchies)

**File**: `lib/data/services/routing_service.dart`

Dịch vụ tìm đường đi ngắn nhất sử dụng **OSRM** (Open Source Routing Machine).

**API Endpoint**: `https://router.project-osrm.org`

**Thuật toán bên trong OSRM**:

| Thuật toán | Mục đích |
|------------|----------|
| **Contraction Hierarchies (CH)** | Tiền xử lý graph, tăng tốc query |
| **Multi-Level Dijkstra (MLD)** | Tìm đường phân cấp |
| **Dijkstra's Algorithm** | Thuật toán nền tảng |

**Độ phức tạp (OSRM)**:
- Preprocessing: O(n log n)
- Query: O(log n) - Rất nhanh!

**API Request**:
```
GET /route/v1/driving/{lng1},{lat1};{lng2},{lat2}
    ?overview=full
    &geometries=geojson
```

**Fallback Strategy**:
```dart
try {
  // Gọi OSRM API
  final distance = await osrmGetRouteDistance(...);
  return distance;
} catch (e) {
  // Fallback: Haversine (đường thẳng)
  return Geolocator.distanceBetween(lat1, lng1, lat2, lng2) / 1000;
}
```

**Các method chính**:

| Method | Chức năng |
|--------|-----------|
| `getRouteDistance()` | Khoảng cách routing (km) |
| `getFormattedRouteDistance()` | Khoảng cách format đẹp |
| `getBatchRouteDistances()` | Batch nhiều điểm |
| `getRoutePoints()` | Lấy tọa độ vẽ polyline |

---

## 4. AI Service (Python/FastAPI)

### 4.1. XGBoost Hazard Prediction

**File**: `ai_service/models/hazard_predictor.py`

Mô hình **Gradient Boosting** dự báo mức độ rủi ro thiên tai (1-5 sao).

**Algorithm**: XGBoost (Scikit-learn GradientBoostingClassifier)

**Độ phức tạp**:
- Training: O(n × m × d × k) với n samples, m features, d depth, k trees
- Prediction: O(k × d)

**Features Input** (11 features):
```python
[
    lat,                    # Vĩ độ
    lng,                    # Kinh độ
    province_id,            # ID tỉnh (0-63)
    region_id,              # Vùng (0-3)
    month,                  # Tháng (1-12)
    season,                 # Mùa (0-2)
    hazard_type_id,         # Loại thiên tai (0-2)
    base_flood_risk,        # Rủi ro ngập cơ bản
    base_landslide_risk,    # Rủi ro sạt lở cơ bản
    base_storm_risk,        # Rủi ro bão cơ bản
    seasonal_multiplier     # Hệ số mùa
]
```

**Output**: Risk Level (1-5)

| Level | Label | Ý nghĩa |
|-------|-------|---------|
| 1 | very_low | Rất thấp |
| 2 | low | Thấp |
| 3 | medium | Trung bình |
| 4 | high | Cao |
| 5 | very_high | Rất cao |

**Seasonal Multiplier**:
```python
# Tháng 9-10: Mùa mưa bão → multiplier = 1.0
# Tháng 1-4: Mùa khô → multiplier = 0.2-0.3
```

**Training Data**: 50,000+ samples từ 25 tỉnh thành Việt Nam

**API Endpoint**:
```http
POST /api/v1/hazard/predict
{
    "lat": 16.0544,
    "lng": 108.2022,
    "month": 10,
    "hazard_type": "flood"
}
→ Response: {"risk_level": 4, "confidence": 0.85, ...}
```

---

### 4.2. Random Forest Alert Scoring

**File**: `ai_service/models/alert_scorer.py`

Mô hình **Random Forest** dự đoán điểm ưu tiên cảnh báo (0-100).

**Algorithm**: Scikit-learn RandomForestRegressor

**Hyperparameters**:
```python
n_estimators = 100      # Số cây
max_depth = 10          # Độ sâu tối đa
random_state = 42       # Seed
n_jobs = -1             # Song song tất cả CPU
```

**Features Input** (15 features):
```python
[
    severity_score,           # 1-4
    alert_type_score,         # 1-4
    hours_since_created,      # Giờ từ khi tạo
    distance_km,              # Khoảng cách từ user
    target_audience_match,    # 0/1
    user_previous_interactions,  # Số lần tương tác trước
    time_of_day,              # 0-23
    day_of_week,              # 0-6
    weather_severity,         # 0-4
    content_length,           # Độ dài nội dung
    has_images,               # 0/1
    has_safety_guide,         # 0/1
    similar_alerts_count,     # Số cảnh báo tương tự
    alert_engagement_rate,    # Tỷ lệ engage
    source_reliability        # Độ tin cậy nguồn
]
```

**Output**: Priority Score (0-100) + Confidence (0-1)

**Cold Start Strategy**:
```python
# Nếu chưa có model, bootstrap từ rule-based scoring
X_synthetic = generate_synthetic_features(n_samples=5000)
y_synthetic = apply_rule_based_scoring(X_synthetic)
model.fit(X_synthetic, y_synthetic)
```

**Predict with Confidence**:
```python
def predict_with_confidence(features):
    # Lấy predictions từ tất cả cây
    tree_predictions = [tree.predict(X) for tree in model.estimators_]
    
    score = np.mean(tree_predictions)
    confidence = 1.0 - (np.std(tree_predictions) / 100.0)
    
    return score, confidence
```

---

### 4.3. Sentence Transformers Duplicate Detection

**File**: `ai_service/models/duplicate_detector.py`

Phát hiện tin trùng lặp sử dụng **Semantic Similarity** với Sentence BERT.

**Model**: `paraphrase-multilingual-MiniLM-L12-v2`
- **Multilingual**: Hỗ trợ tiếng Việt và English
- **Output**: 384-dimensional embedding vector

**Algorithm**: Cosine Similarity giữa embeddings

**Độ phức tạp**:
- Embedding: O(n) với n = token count
- Similarity: O(d) với d = embedding dimension (384)

**Công thức Cosine Similarity**:
```
similarity = (A · B) / (||A|| × ||B||)

Trong đó:
- A, B: Embedding vectors
- · : Dot product
- ||x||: Euclidean norm
```

**Ngưỡng**: ≥ 0.85 → Duplicate

**Flow**:
```python
def is_duplicate(alert1, alert2):
    # 1. Pre-filter (rule-based)
    if not basic_match(alert1, alert2):  # type, severity, province
        return False
    
    # 2. Semantic similarity
    emb1 = model.encode(alert1['content'])
    emb2 = model.encode(alert2['content'])
    
    similarity = cosine_similarity(emb1, emb2)
    
    return similarity >= 0.85
```

**Caching**: LRU cache 1000 embeddings để tăng tốc

**Fallback**: Jaccard Similarity nếu Sentence Transformers không available

---

### 4.4. Thompson Sampling (Contextual Bandit)

**File**: `ai_service/models/notification_timing.py`

Thuật toán **Multi-Armed Bandit** để tối ưu thời điểm gửi notification.

**Algorithm**: Thompson Sampling với Beta Distribution

**Độ phức tạp**: O(k) với k = số time slots (24)

**Beta Distribution**:
```
Beta(α, β)

Trong đó:
- α = số lần engaged (click, view)
- β = số lần dismissed
- Prior: α = β = 1 (uniform)
```

**Thompson Sampling Flow**:
```python
def select_time_slot():
    # 1. Epsilon-greedy exploration
    if random() < epsilon:
        return random_slot()
    
    # 2. Sample from Beta distributions
    samples = [np.random.beta(alpha[i], beta[i]) for i in range(24)]
    
    # 3. Choose slot with highest sample
    return argmax(samples)
```

**Online Learning Update**:
```python
def update_feedback(time_slot, engaged):
    if engaged:
        alpha[time_slot] += 1  # Success
    else:
        beta[time_slot] += 1   # Failure
```

**Exploration vs Exploitation**:
- **Exploration (epsilon=0.1)**: Thử ngẫu nhiên 10% để học
- **Exploitation (90%)**: Chọn thời điểm tốt nhất đã biết

**Typical Day Pattern** (sau học):
```
Morning (6-9):   60% engagement
Work (9-17):     30% engagement
Evening (17-22): 80% engagement  ← Best!
Night (22-6):    10% engagement
```

---

## 5. Bảng So sánh Complexity

| Algorithm | Time | Space | Layer |
|-----------|------|-------|-------|
| Multi-factor Scoring | O(1) | O(1) | Mobile |
| Time Decay | O(1) | O(1) | Mobile |
| Haversine | O(1) | O(1) | Mobile |
| Inverse Distance | O(1) | O(1) | Mobile |
| Heap Insert | O(log n) | O(1) | Mobile |
| Heap Extract | O(log n) | O(1) | Mobile |
| Jaccard Similarity | O(n+m) | O(n+m) | Mobile |
| Smart Batching | O(1) | O(k) | Mobile |
| OSRM Query | O(log n) | O(1) | Routing |
| XGBoost Predict | O(k×d) | O(1) | AI |
| Random Forest Predict | O(k×d) | O(1) | AI |
| Sentence Embedding | O(n) | O(d) | AI |
| Cosine Similarity | O(d) | O(1) | AI |
| Thompson Sampling | O(k) | O(k) | AI |

**Legend**:
- n, m: Số phần tử input
- k: Số cây (RF) hoặc số slots (Bandit)
- d: Độ sâu cây hoặc embedding dimension

---

## 6. References

### Academic Papers
- [Haversine Formula](https://en.wikipedia.org/wiki/Haversine_formula)
- [Heap Data Structure](https://en.wikipedia.org/wiki/Heap_(data_structure))
- [Jaccard Index](https://en.wikipedia.org/wiki/Jaccard_index)
- [Exponential Decay](https://en.wikipedia.org/wiki/Exponential_decay)
- [Thompson Sampling](https://en.wikipedia.org/wiki/Thompson_sampling)
- [Contraction Hierarchies](https://en.wikipedia.org/wiki/Contraction_hierarchies)

### ML Libraries
- [XGBoost](https://xgboost.readthedocs.io/)
- [Scikit-learn Random Forest](https://scikit-learn.org/)
- [Sentence Transformers](https://www.sbert.net/)

### Implementation Guides
- [OSRM API Documentation](http://project-osrm.org/docs/)
- [Flutter Performance Best Practices](https://docs.flutter.dev/perf)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)

---

**Cập nhật**: Tháng 01/2026  
**Version**: 2.0.0  
**Tác giả**: Team AppThienTai
