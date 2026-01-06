# 04. API SPECIFICATIONS

---

## MỤC LỤC

- [4.1. Firebase APIs](#41-firebase-apis)
- [4.2. AI Service APIs](#42-ai-service-apis)
- [4.3. Error Handling](#43-error-handling)
- [4.4. Rate Limiting](#44-rate-limiting)
- [4.5. API Examples](#45-api-examples)

---

## 4.1. FIREBASE APIs

### 4.1.1. Firebase Authentication API

**Base URL:** Managed by Firebase SDK, không cần HTTP requests trực tiếp

**Methods Available:**

#### Sign Up with Email/Password

```dart
Future<UserCredential> signUp({
  required String email,
  required String password,
}) async {
  try {
    final credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
    
    // Send verification email
    await credential.user?.sendEmailVerification();
    
    return credential;
  } on FirebaseAuthException catch (e) {
    throw _handleAuthException(e);
  }
}
```

**Common Error Codes:**
- `email-already-in-use` - Email đã được sử dụng
- `invalid-email` - Email không hợp lệ
- `weak-password` - Mật khẩu yếu (< 6 ký tự)

#### Sign In with Email/Password

```dart
Future<UserCredential> signIn({
  required String email,
  required String password,
}) async {
  try {
    return await FirebaseAuth.instance
        .signInWithEmailAndPassword(
          email: email,
          password: password,
        );
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      throw Exception('Không tìm thấy tài khoản');
    } else if (e.code == 'wrong-password') {
      throw Exception('Mật khẩu không đúng');
    }
    rethrow;
  }
}
```

#### Sign In with Google

```dart
Future<UserCredential> signInWithGoogle() async {
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  final GoogleSignInAuthentication? googleAuth = 
      await googleUser?.authentication;
  
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );
  
  return await FirebaseAuth.instance.signInWithCredential(credential);
}
```

#### Reset Password

```dart
Future<void> resetPassword(String email) async {
  await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
}
```

---

### 4.1.2. Firestore CRUD APIs

#### Create Document

```dart
// Add with auto-generated ID
Future<DocumentReference> createSOS(SosDto sos) async {
  return await FirebaseFirestore.instance
      .collection('sos_requests')
      .add(sos.toJson());
}

// Set with specific ID
Future<void> createUser(String userId, UserDto user) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .set(user.toJson());
}
```

#### Read Document(s)

```dart
// Get single document
Future<ShelterEntity?> getShelterById(String shelterId) async {
  final doc = await FirebaseFirestore.instance
      .collection('shelters')
      .doc(shelterId)
      .get();
  
  if (doc.exists && doc.data() != null) {
    return ShelterDto.fromSnapshot(doc).toEntity();
  }
  return null;
}

// Query multiple documents
Future<List<SosEntity>> getPendingSOS() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('sos_requests')
      .where('Status', isEqualTo: 'pending')
      .orderBy('CreatedAt', descending: true)
      .limit(50)
      .get();
  
  return snapshot.docs
      .map((doc) => SosDto.fromSnapshot(doc).toEntity())
      .toList();
}

// Realtime stream
Stream<List<ShelterEntity>> getAllShelters() {
  return FirebaseFirestore.instance
      .collection('shelters')
      .where('IsActive', isEqualTo: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ShelterDto.fromSnapshot(doc).toEntity())
          .toList());
}
```

#### Update Document

```dart
// Update specific fields
Future<void> updateSOSStatus(String sosId, String status) async {
  await FirebaseFirestore.instance
      .collection('sos_requests')
      .doc(sosId)
      .update({
        'Status': status,
        'UpdatedAt': FieldValue.serverTimestamp(),
      });
}

// Update entire document
Future<void> updateShelter(ShelterEntity shelter) async {
  final dto = ShelterDto.fromEntity(shelter);
  await FirebaseFirestore.instance
      .collection('shelters')
      .doc(shelter.id)
      .update({
        ...dto.toJson(),
        'UpdatedAt': FieldValue.serverTimestamp(),
      });
}
```

#### Delete Document

```dart
Future<void> deleteShelter(String shelterId) async {
  await FirebaseFirestore.instance
      .collection('shelters')
      .doc(shelterId)
      .delete();
}
```

---

### 4.1.3. Firebase Storage API

#### Upload Image

```dart
Future<String> uploadImage({
  required File imageFile,
  required String path,
}) async {
  try {
    // Create reference
    final storageRef = FirebaseStorage.instance.ref().child(path);
    
    // Upload
    final uploadTask = await storageRef.putFile(imageFile);
    
    // Get download URL
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    
    return downloadUrl;
  } catch (e) {
    throw Exception('Upload failed: $e');
  }
}

// Usage for SOS images
Future<List<String>> uploadSOSImages(List<File> images) async {
  final urls = <String>[];
  
  for (int i = 0; i < images.length; i++) {
    final path = 'sos/${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
    final url = await uploadImage(imageFile: images[i], path: path);
    urls.add(url);
  }
  
  return urls;
}
```

#### Delete Image

```dart
Future<void> deleteImage(String downloadUrl) async {
  try {
    final ref = FirebaseStorage.instance.refFromURL(downloadUrl);
    await ref.delete();
  } catch (e) {
    print('Delete image failed: $e');
  }
}
```

---

### 4.1.4. Firebase Cloud Messaging (FCM)

#### Send Notification (Server-side via Cloud Functions)

```javascript
// Firebase Cloud Function
const admin = require('firebase-admin');

exports.sendSOSNotification = functions.firestore
  .document('sos_requests/{sosId}')
  .onCreate(async (snap, context) => {
    const sos = snap.data();
    
    // Get all admins
    const adminsSnapshot = await admin.firestore()
      .collection('users')
      .where('Role', '==', 'admin')
      .get();
    
    const tokens = adminsSnapshot.docs
      .map(doc => doc.data().fcmToken)
      .filter(token => token);
    
    if (tokens.length === 0) return;
    
    const message = {
      notification: {
        title: '🚨 SOS Khẩn cấp!',
        body: `${sos.Description.substring(0, 100)}...`,
      },
      data: {
        type: 'sos',
        sosId: context.params.sosId,
        severity: sos.Severity,
      },
      tokens: tokens,
    };
    
    await admin.messaging().sendMulticast(message);
  });
```

#### Subscribe to Topic (Client-side)

```dart
Future<void> subscribeToAlerts(String province) async {
  await FirebaseMessaging.instance.subscribeToTopic('alert_$province');
}

Future<void> unsubscribeFromAlerts(String province) async {
  await FirebaseMessaging.instance.unsubscribeFromTopic('alert_$province');
}
```

#### Handle Foreground Notifications

```dart
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  print('Got a message whilst in the foreground!');
  print('Message data: ${message.data}');

  if (message.notification != null) {
    // Show local notification
    showLocalNotification(
      title: message.notification!.title,
      body: message.notification!.body,
    );
  }
});
```

---

## 4.2. AI SERVICE APIs

**Base URL:** `http://localhost:8000` (dev) hoặc `https://your-ai-service.railway.app` (prod)

### 4.2.1. Health Check

**Endpoint:** `GET /api/v1/health`

**Description:** Kiểm tra service có hoạt động không

**Request:** None

**Response:**

```json
{
  "status": "healthy",
  "timestamp": "2026-01-06T08:50:00Z",
  "version": "1.0.0",
  "models_loaded": {
    "hazard_predictor": true,
    "alert_scorer": true,
    "duplicate_detector": true
  }
}
```

**Example:**

```dart
Future<bool> checkAIServiceHealth() async {
  try {
    final response = await dio.get('$baseUrl/api/v1/health');
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}
```

---

### 4.2.2. Hazard Prediction

**Endpoint:** `POST /api/v1/hazard/predict`

**Description:** Dự đoán mức độ rủi ro thiên tai theo vị trí

**Request Body:**

```json
{
  "province": "string (tên tỉnh)",
  "hazard_type": "string (flood|landslide|storm)",
  "season": "integer (1-4, optional)",
  "month": "integer (1-12, optional)"
}
```

**Response:**

```json
{
  "prediction": {
    "risk_level": 4,
    "probability": 0.85,
    "hazard_type": "flood",
    "province": "Quảng Nam"
  },
  "recommendations": [
    "Chuẩn bị lương thực dự trữ 3-5 ngày",
    "Kiểm tra đường thoát hiểm",
    "Theo dõi cảnh báo từ cơ quan chức năng"
  ],
  "timestamp": "2026-01-06T08:50:00Z"
}
```

**Example:**

```dart
Future<HazardPrediction> predictHazard({
  required String province,
  required String hazardType,
}) async {
  try {
    final response = await dio.post(
      '$baseUrl/api/v1/hazard/predict',
      data: {
        'province': province,
        'hazard_type': hazardType,
        'month': DateTime.now().month,
      },
    );
    
    return HazardPrediction.fromJson(response.data['prediction']);
  } catch (e) {
    throw Exception('Prediction failed: $e');
  }
}
```

**Error Responses:**

```json
// 400 Bad Request
{
  "detail": "Invalid province name"
}

// 500 Internal Server Error
{
  "detail": "Model prediction failed"
}
```

---

### 4.2.3. Get Hazard Zones

**Endpoint:** `GET /api/v1/hazard/zones?hazard_type={type}&risk_threshold={threshold}`

**Description:** Lấy danh sách vùng có nguy cơ cao

**Query Parameters:**
- `hazard_type` (optional): `flood|landslide|storm`
- `risk_threshold` (optional): `1-5`, default = 3

**Response:**

```json
{
  "zones": [
    {
      "province": "Quảng Nam",
      "risk_level": 5,
      "hazard_type": "flood",
      "probability": 0.92,
      "affected_districts": ["Núi Thành", "Tam Kỳ"],
      "last_updated": "2026-01-06T08:00:00Z"
    },
    {
      "province": "Quảng Ngãi",
      "risk_level": 4,
      "hazard_type": "flood",
      "probability": 0.78,
      "affected_districts": ["Bình Sơn", "Sơn Tịnh"],
      "last_updated": "2026-01-06T08:00:00Z"
    }
  ],
  "total": 2,
  "timestamp": "2026-01-06T08:50:00Z"
}
```

**Example:**

```dart
Future<List<HazardZone>> getHighRiskZones() async {
  final response = await dio.get(
    '$baseUrl/api/v1/hazard/zones',
    queryParameters: {
      'hazard_type': 'flood',
      'risk_threshold': 4,
    },
  );
  
  return (response.data['zones'] as List)
      .map((json) => HazardZone.fromJson(json))
      .toList();
}
```

---

### 4.2.4. Alert Scoring

**Endpoint:** `POST /api/v1/score`

**Description:** Đánh giá mức độ nghiêm trọng của cảnh báo

**Request Body:**

```json
{
  "title": "string",
  "description": "string",
  "hazard_type": "string (flood|landslide|storm)",
  "affected_areas": ["string"],
  "source": "string (official|user|ai)"
}
```

**Response:**

```json
{
  "severity_score": 88.5,
  "severity_label": "Khẩn cấp",
  "factors": {
    "title_severity": 90.0,
    "description_urgency": 85.0,
    "affected_population": 92.0,
    "hazard_danger": 100.0,
    "source_reliability": 75.0
  },
  "recommended_actions": [
    "Gửi thông báo đẩy ngay lập tức",
    "Kích hoạt đội cứu hộ",
    "Liên hệ cơ quan chức năng"
  ]
}
```

**Example:**

```dart
Future<AlertScore> scoreAlert(AlertDto alert) async {
  final response = await dio.post(
    '$baseUrl/api/v1/score',
    data: {
      'title': alert.title,
      'description': alert.description,
      'hazard_type': alert.type,
      'affected_areas': alert.affectedAreas,
      'source': 'official',
    },
  );
  
  return AlertScore.fromJson(response.data);
}
```

---

### 4.2.5. Duplicate Detection

**Endpoint:** `POST /api/v1/duplicate/check`

**Description:** Kiểm tra xem SOS/Alert có bị trùng lặp không

**Request Body:**

```json
{
  "text": "string (description to check)",
  "collection": "string (sos|alert)",
  "threshold": "float (0.0-1.0, optional, default=0.85)"
}
```

**Response:**

```json
{
  "is_duplicate": true,
  "matches": [
    {
      "id": "sos_123",
      "text": "Gia đình 5 người đang bị ngập lụt nặng...",
      "similarity": 0.92,
      "created_at": "2026-01-06T07:30:00Z"
    }
  ],
  "highest_similarity": 0.92
}
```

**Example:**

```dart
Future<bool> checkDuplicateSOS(String description) async {
  final response = await dio.post(
    '$baseUrl/api/v1/duplicate/check',
    data: {
      'text': description,
      'collection': 'sos',
      'threshold': 0.85,
    },
  );
  
  return response.data['is_duplicate'] as bool;
}
```

---

## 4.3. ERROR HANDLING

### 4.3.1. Firebase Errors

**Common Firebase Error Codes:**

| Code | Description | User Message |
|------|-------------|--------------|
| `permission-denied` | Security rules denied | "Bạn không có quyền thực hiện thao tác này" |
| `not-found` | Document không tồn tại | "Không tìm thấy dữ liệu" |
| `already-exists` | Document đã tồn tại | "Dữ liệu này đã tồn tại" |
| `unavailable` | Service tạm thời không khả dụng | "Dịch vụ đang bảo trì, vui lòng thử lại sau" |
| `deadline-exceeded` | Timeout | "Kết nối quá chậm, vui lòng thử lại" |

**Error Handling Pattern:**

```dart
try {
  await _firestore.collection('sos_requests').doc(sosId).get();
} on FirebaseException catch (e) {
  switch (e.code) {
    case 'permission-denied':
      throw Exception('Bạn không có quyền truy cập');
    case 'not-found':
      throw Exception('SOS không tồn tại');
    case 'unavailable':
      throw Exception('Dịch vụ tạm thời không khả dụng');
    default:
      throw Exception('Lỗi không xác định: ${e.message}');
  }
}
```

### 4.3.2. AI Service Errors

**HTTP Status Codes:**

| Code | Meaning | Action |
|------|---------|--------|
| 200 | Success | Process response |
| 400 | Bad Request | Validate input |
| 404 | Not Found | Check endpoint |
| 500 | Server Error | Retry or fallback |
| 503 | Service Unavailable | Service down, show offline message |

**Error Handling with Dio:**

```dart
try {
  final response = await dio.post('$baseUrl/api/v1/hazard/predict', ...);
  return response.data;
} on DioException catch (e) {
  if (e.type == DioExceptionType.connectionTimeout) {
    throw Exception('Kết nối AI service timeout');
  } else if (e.type == DioExceptionType.receiveTimeout) {
    throw Exception('Nhận dữ liệu quá lâu');
  } else if (e.response != null) {
    final statusCode = e.response!.statusCode;
    if (statusCode == 400) {
      throw Exception('Dữ liệu đầu vào không hợp lệ');
    } else if (statusCode == 500) {
      throw Exception('Lỗi AI service, vui lòng thử lại');
    }
  }
  throw Exception('Không thể kết nối AI service');
}
```

---

## 4.4. RATE LIMITING

### 4.4.1. Firebase Limits

| Resource | Limit | Notes |
|----------|-------|-------|
| **Firestore Reads** | 50,000/day (Free tier) | 1M/day (Paid) |
| **Firestore Writes** | 20,000/day (Free tier) | 500K/day (Paid) |
| **Storage Uploads** | 5GB total (Free) | Unlimited (Paid) |
| **FCM Messages** | Unlimited | But has quota per second |
| **Auth Sign-ins** | No hard limit | Throttled if suspicious |

**Best Practices:**
- Cache data locally với GetX
- Sử dụng pagination
- Batch operations khi có thể

### 4.4.2. AI Service Rate Limiting

**Current Implementation:**

```python
# main.py
from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)

@app.post("/api/v1/hazard/predict")
@limiter.limit("100/minute")  # 100 requests per minute per IP
async def predict_hazard(...):
    ...
```

**Rate Limit Response:**

```json
{
  "error": "Rate limit exceeded",
  "message": "Too many requests. Please try again in 60 seconds.",
  "retry_after": 60
}
```

**Client-side Handling:**

```dart
try {
  final response = await dio.post(...);
} on DioException catch (e) {
  if (e.response?.statusCode == 429) {
    final retryAfter = e.response?.headers['Retry-After']?.first;
    throw Exception('Đã vượt quá giới hạn requests. Thử lại sau $retryAfter giây');
  }
}
```

---

## 4.5. API EXAMPLES

### 4.5.1. Complete SOS Flow

```dart
class SOSService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storage = StorageService();
  final LocationService _location = LocationService();
  
  Future<String> submitSOS({
    required String description,
    required String phoneNumber,
    required int numberOfPeople,
    required List<File> images,
  }) async {
    try {
      // 1. Get current location
      final position = await _location.getCurrentLocation();
      
      // 2. Upload images to Storage
      final imageUrls = await _storage.uploadSOSImages(images);
      
      // 3. Create SOS document in Firestore
      final docRef = await _firestore.collection('sos_requests').add({
        'UserId': FirebaseAuth.instance.currentUser!.uid,
        'Description': description,
        'PhoneNumber': phoneNumber,
        'NumberOfPeople': numberOfPeople,
        'Lat': position.latitude,
        'Lng': position.longitude,
        'Images': imageUrls,
        'Status': 'pending',
        'Severity': _calculateSeverity(description),
        'CreatedAt': FieldValue.serverTimestamp(),
        'UpdatedAt': FieldValue.serverTimestamp(),
      });
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to submit SOS: $e');
    }
  }
  
  String _calculateSeverity(String description) {
    final urgentKeywords = ['khẩn cấp', 'nguy hiểm', 'cứu'];
    if (urgentKeywords.any((k) => description.toLowerCase().contains(k))) {
      return 'Khẩn cấp';
    }
    return 'Cao';
  }
}
```

### 4.5.2. Complete Donation Flow

```dart
class DonationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<String> donateCash({
    required double amount,
    required String transactionId,
  }) async {
    final docRef = await _firestore.collection('donations').add({
      'UserId': FirebaseAuth.instance.currentUser!.uid,
      'Type': 'cash',
      'Amount': amount,
      'PaymentMethod': 'bank_transfer',
      'TransactionId': transactionId,
      'Status': 'pending',  // Admin will confirm
      'CreatedAt': FieldValue.serverTimestamp(),
    });
    
    return docRef.id;
  }
  
  Future<String> donateSupplies({
    required List<SupplyItem> items,
    required String deliveryMethod,
    String? deliveryAddress,
  }) async {
    final docRef = await _firestore.collection('donations').add({
      'UserId': FirebaseAuth.instance.currentUser!.uid,
      'Type': 'supplies',
      'Items': items.map((item) => item.toJson()).toList(),
      'DeliveryMethod': deliveryMethod,
      'DeliveryAddress': deliveryAddress,
      'Status': 'pending',
      'CreatedAt': FieldValue.serverTimestamp(),
    });
    
    return docRef.id;
  }
}
```

---

**[Tiếp tục ở file 05_DEPLOYMENT.md]**
