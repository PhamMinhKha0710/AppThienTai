# TÀI LIỆU BÀN GIAO DỰ ÁN
# ỨNG DỤNG CỨU TRỢ THIÊN TAI (AppThienTai)

**Phiên bản:** 1.0.0  
**Ngày bàn giao:** Tháng 01/2026  
**Đơn vị phát triển:** Team Development  

---

## 📑 MỤC LỤC

1. [Giới thiệu tổng quan](#1-giới-thiệu-tổng-quan)
2. [Kiến trúc hệ thống](#2-kiến-trúc-hệ-thống)
3. [Công nghệ sử dụng](#3-công-nghệ-sử-dụng)
4. [Cấu trúc dự án](#4-cấu-trúc-dự-án)
5. [Hướng dẫn triển khai](#5-hướng-dẫn-triển-khai)
6. [Tài liệu kỹ thuật chi tiết](#6-tài-liệu-kỹ-thuật-chi-tiết)

---

## 1. GIỚI THIỆU TỔNG QUAN

### 1.1. Mục đích dự án

**AppThienTai** là ứng dụng di động hỗ trợ hoạt động cứu trợ thiên tai, kết nối giữa:
- **Nạn nhân:** Người dân cần hỗ trợ trong tình huống khẩn cấp
- **Tình nguyện viên:** Người muốn đóng góp hỗ trợ cứu trợ
- **Quản trị viên:** Điều phối và quản lý hoạt động cứu trợ

### 1.2. Phạm vi triển khai

- **Nền tảng:** Mobile (Android, iOS)
- **Người dùng mục tiêu:** Người dân Việt Nam, tình nguyện viên, tổ chức cứu trợ
- **Vùng địa lý:** Toàn quốc

### 1.3. Tính năng chính

| Module | Chức năng | Mô tả |
|--------|-----------|-------|
| **SOS** | Gửi tín hiệu cứu hộ | Gửi yêu cầu khẩn cấp kèm GPS, hình ảnh |
| **Bản đồ** | Hiển thị vùng nguy hiểm | Xem điểm cứu trợ, vùng ngập lụt, sạt lở |
| **Quyên góp** | Đóng góp tiền/vật phẩm | Quyên góp tiền mặt, nhu yếu phẩm, thời gian |
| **Tình nguyện** | Đăng ký hỗ trợ | Đăng ký làm tình nguyện viên cứu trợ |
| **AI Dự báo** | Cảnh báo thiên tai | Dự đoán mức độ rủi ro theo vị trí |
| **Chat** | Giao tiếp thời gian thực | Kết nối nạn nhân - cứu hộ |
| **Admin** | Quản lý hệ thống | Dashboard, quản lý SOS, cảnh báo, điểm phân phối |

---

## 2. KIẾN TRÚC HỆ THỐNG

### 2.1. Sơ đồ tổng quan

```
┌─────────────────────────────────────────────────────────────┐
│                   MOBILE APPLICATION                        │
│                      (Flutter)                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────────┐  │
│  │  Victim  │  │Volunteer │  │  Admin   │  │   Common   │  │
│  │  Module  │  │  Module  │  │  Module  │  │   Module   │  │
│  └──────────┘  └──────────┘  └──────────┘  └────────────┘  │
└─────────────────────────────────────────────────────────────┘
                         ↓ API Calls
┌─────────────────────────────────────────────────────────────┐
│                   FIREBASE BACKEND                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │   Firestore  │  │ Authentication│  │  Cloud Storage  │  │
│  │   Database   │  │               │  │  (Media Files)  │  │
│  └──────────────┘  └──────────────┘  └──────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         Cloud Messaging (Push Notifications)         │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                         ↓ HTTP API
┌─────────────────────────────────────────────────────────────┐
│                   AI SERVICE (FastAPI)                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │ Hazard Pred │  │ Alert Scoring│  │ Duplicate Detect │  │
│  │  (XGBoost)   │  │(RandomForest)│  │  (Transformers)  │  │
│  └──────────────┘  └──────────────┘  └──────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### 2.2. Luồng dữ liệu chính

1. **Luồng SOS:**
   - User → App → Firestore (sos_requests) → Admin Dashboard
   - Admin → Assign volunteer → Notification → Volunteer

2. **Luồng Quyên góp:**
   - User → Donation form → Firestore (donations) → MTTQ Account

3. **Luồng AI Dự báo:**
   - User location → AI Service API → XGBoost Model → Risk prediction → App

---

## 3. CÔNG NGHỆ SỬ DỤNG

### 3.1. Frontend (Mobile App)

| Công nghệ | Phiên bản | Mục đích |
|-----------|-----------|----------|
| Flutter | 3.24.x | Framework phát triển đa nền tảng |
| Dart | 3.5.x | Ngôn ngữ lập trình |
| GetX | Latest | State management, routing, DI |
| flutter_map | Latest | Hiển thị bản đồ OpenStreetMap |
| geolocator | Latest | Định vị GPS |
| image_picker | Latest | Chụp/chọn ảnh |

### 3.2. Backend Services

| Service | Công nghệ | Mục đích |
|---------|-----------|----------|
| Authentication | Firebase Auth | Đăng nhập email/password, Google |
| Database | Cloud Firestore | NoSQL realtime database |
| Storage | Firebase Storage | Lưu ảnh/video SOS |
| Messaging | FCM | Push notifications |
| AI Service | Python FastAPI | API dự báo thiên tai |

### 3.3. AI/Machine Learning

| Component | Algorithm | Dataset |
|-----------|-----------|---------|
| Hazard Prediction | XGBoost/Gradient Boosting | 50,000 samples, 25 tỉnh VN |
| Alert Scoring | Random Forest | Synthetic + real feedback |
| Duplicate Detection | Sentence Transformers | Multilingual MiniLM |

### 3.4. DevOps & Tools

- **Version Control:** Git, GitHub
- **CI/CD:** GitHub Actions (suggested)
- **Testing:** Flutter test, Widget tests
- **Documentation:** Markdown

---

## 4. CẤU TRÚC DỰ ÁN

### 4.1. Cấu trúc thư mục Mobile App

```
lib/
├── core/                        # Shared utilities
│   ├── constants/              # Colors, sizes, strings
│   ├── widgets/                # Reusable widgets
│   ├── utils/                  # Helper functions
│   └── injection/              # Dependency injection
├── data/                        # Data layer
│   ├── models/                 # DTOs
│   ├── repositories/           # Repository implementations
│   └── services/               # External services
├── domain/                      # Business logic
│   ├── entities/               # Domain models
│   └── repositories/           # Repository interfaces
└── presentation/                # UI layer
    └── features/
        ├── authentication/     # Login, signup
        ├── victim/            # SOS, map, receive
        ├── volunteer/         # Donation, tasks
        ├── admin/             # Dashboard, management
        ├── chat/              # Real-time chat
        └── common/            # Shared screens
```

### 4.2. Cấu trúc AI Service

```
ai_service/
├── main.py                     # FastAPI entry point
├── config.py                   # Configuration
├── requirements.txt            # Python dependencies
├── models/                     # ML models
│   ├── hazard_predictor.py    # Dự báo thiên tai
│   ├── alert_scorer.py        # Scoring cảnh báo
│   └── duplicate_detector.py  # Phát hiện trùng
├── services/                   # Business logic
├── utils/                      # Utilities
└── data/                       # Data & trained models
    └── models/                 # .pkl files
```

---

## 5. HƯỚNG DẪN TRIỂN KHAI

### 5.1. Yêu cầu hệ thống

**Máy phát triển:**
- Flutter SDK 3.24+
- Dart SDK 3.5+
- Android Studio / VS Code
- Git

**AI Service:**
- Python 3.9+
- 4GB RAM minimum
- 2GB disk space

### 5.2. Cài đặt Mobile App

```bash
# 1. Clone repository
git clone https://github.com/PhamMinhKha0710/AppThienTai.git
cd AppThienTai

# 2. Install dependencies
flutter pub get

# 3. Configure Firebase
# - Download google-services.json (Android)
# - Download GoogleService-Info.plist (iOS)
# - Place in android/app/ and ios/Runner/

# 4. Run app
flutter run
```

### 5.3. Cài đặt AI Service

```bash
cd ai_service

# 1. Create virtual environment
python -m venv venv
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows

# 2. Install dependencies
pip install -r requirements.txt

# 3. Train model (first time)
python train_hazard_model.py

# 4. Run server
python main.py
# Server at http://localhost:8000
```

### 5.4. Deploy Production

**Mobile App:**
- Build APK: `flutter build apk --release`
- Build iOS: `flutter build ios --release`
- Upload to Play Store / App Store

**AI Service:**
- Deploy to Railway/Render/Heroku
- Set environment variables:
  ```
  API_HOST=0.0.0.0
  API_PORT=8000
  ```

---

## 6. TÀI LIỆU KỸ THUẬT CHI TIẾT

Tham khảo các tài liệu bổ sung:

| Tài liệu | File | Nội dung |
|----------|------|----------|
| **Hướng dẫn người dùng** | [USER_GUIDE.md](./USER_GUIDE.md) | Cách sử dụng app cho end-user |
| **Cơ sở lý thuyết** | [CHAPTER_2_THEORETICAL_FOUNDATION.md](./CHAPTER_2_THEORETICAL_FOUNDATION.md) | Lý thuyết công nghệ sử dụng |
| **AI Service** | [ai_service/README.md](../ai_service/README.md) | Chi tiết AI service, API, training |
| **Architecture** | [ARCHITECTURE_SUMMARY.md](./ARCHITECTURE_SUMMARY.md) | Kiến trúc tổng quan |

---

## 7. BẢO MẬT & PHÂN QUYỀN

### 7.1. Phân quyền người dùng

| Role | Quyền hạn |
|------|-----------|
| **Victim** | Gửi SOS, xem bản đồ, đăng ký nhận hỗ trợ, chat |
| **Volunteer** | Quyên góp, đăng ký tình nguyện, nhận nhiệm vụ |
| **Admin** | Toàn quyền: quản lý SOS, cảnh báo, điểm phân phối, users |

### 7.2. Bảo mật

- **Authentication:** Firebase Authentication với JWT tokens
- **Database Rules:** Firestore Security Rules giới hạn truy cập theo role
- **Storage Rules:** Chỉ owner upload được file
- **API Security:** CORS được cấu hình cho phép origins cụ thể
- **Sensitive Data:** Không lưu password plaintext

### 7.3. Firestore Security Rules (Mẫu)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // SOS requests: victim tạo, admin đọc/sửa
    match /sos_requests/{sosId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if isAdmin();
    }
    
    // Shelters: public đọc, admin sửa
    match /shelters/{shelterId} {
      allow read: if true;
      allow write: if isAdmin();
    }
    
    function isAdmin() {
      return request.auth != null && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.Role == 'admin';
    }
  }
}
```

---

## 8. VẬN HÀNH & BẢO TRÌ

### 8.1. Monitoring

**Firebase Console:**
- Theo dõi số lượng users
- Crash reports
- Performance metrics

**AI Service Monitoring:**
- Health check endpoint: `/api/v1/health`
- Logs trong console
- Monitor CPU/RAM usage

### 8.2. Backup & Recovery

**Firestore:**
- Tự động backup bởi Firebase
- Export data định kỳ (khuyến nghị hàng tuần)

**AI Models:**
- Lưu trữ file `.pkl` trong `ai_service/data/models/`
- Backup sau mỗi lần retrain

### 8.3. Bảo trì định kỳ

**Hàng tuần:**
- Kiểm tra crash reports
- Review user feedback

**Hàng tháng:**
- Update dependencies: `flutter pub upgrade`
- Retrain AI model với data mới
- Review Firestore usage và tối ưu queries

### 8.4. Troubleshooting

| Vấn đề | Giải pháp |
|---------|-----------|
| App crash khi gửi SOS | Check Firestore rules, xem logs |
| Không load được điểm phân phối | Admin cần tạo dữ liệu trong "Quản lý điểm phân phối" |
| AI service timeout | Tăng `connectTimeout` trong Dio hoặc deploy AI service gần hơn |
| Map không hiển thị | Check internet, OpenStreetMap API |

---

## 9. MỞ RỘNG & PHÁT TRIỂN

### 9.1. Tính năng đề xuất

1. **Thanh toán online** cho quyên góp (VNPay, Momo)
2. **Video call** giữa nạn nhân - cứu hộ
3. **IoT sensors** cảnh báo mực nước tự động
4. **Blockchain** để minh bạch quyên góp
5. **Multi-language** support (English, etc.)

### 9.2. Cải tiến AI

- Tích hợp dữ liệu thực từ khí tượng thủy văn
- Sử dụng satellite imagery cho dự báo lũ
- Real-time alert với WebSocket

### 9.3. Performance Optimization

- Implement pagination cho lists
- Lazy loading images
- Cache bản đồ offline
- Optimize Firestore indexes

---

## 10. LIÊN HỆ & HỖ TRỢ

**Team Development:**
- **Repository:** https://github.com/PhamMinhKha0710/AppThienTai
- **Email:** [Điền email support]
- **Hotline:** [Điền hotline]

**Tài liệu bổ sung:**
- API Documentation: http://localhost:8000/docs (khi chạy AI service)
- Firebase Console: https://console.firebase.google.com

---

## 11. CHANGELOG

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 01/2026 | Initial release với đầy đủ tính năng SOS, quyên góp, AI |

---

## PHỤ LỤC

### A. Environment Variables

```bash
# Mobile App (.env nếu dùng)
FIREBASE_PROJECT_ID=cuutrobaolu
AI_SERVICE_URL=http://localhost:8000

# AI Service
API_HOST=0.0.0.0
API_PORT=8000
```

### B. Firebase Collections Schema

**sos_requests:**
```json
{
  "UserId": "string",
  "Description": "string",
  "Lat": "number",
  "Lng": "number",
  "Status": "pending|inprogress|completed|cancelled",
  "Severity": "string",
  "NumberOfPeople": "number",
  "CreatedAt": "timestamp",
  "Images": ["url1", "url2"]
}
```

**shelters:**
```json
{
  "Name": "string",
  "Address": "string",
  "Lat": "number",
  "Lng": "number",
  "Capacity": "number",
  "CurrentOccupancy": "number",
  "IsActive": "boolean",
  "Amenities": ["item1", "item2"],
  "DistributionTime": "string"
}
```

---

**Kết thúc tài liệu bàn giao**

> 📌 **Lưu ý quan trọng:** Tài liệu này cần được cập nhật khi có thay đổi lớn về kiến trúc hoặc tính năng.
