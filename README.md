<p align="center">
  <img src="assets/images/logo.png" alt="AppThienTai Logo" width="120"/>
</p>

<h1 align="center">🌊 AppThienTai - Ứng Dụng Cứu Trợ Thiên Tai</h1>

<p align="center">
  <strong>Kết nối nạn nhân và tình nguyện viên trong các tình huống thiên tai khẩn cấp</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.24.x-02569B?logo=flutter" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.5.x-0175C2?logo=dart" alt="Dart"/>
  <img src="https://img.shields.io/badge/Python-3.9+-3776AB?logo=python" alt="Python"/>
  <img src="https://img.shields.io/badge/AI-XGBoost-FF6F00" alt="AI"/>
  <img src="https://img.shields.io/badge/Firebase-Backend-FFCA28?logo=firebase" alt="Firebase"/>
</p>

<p align="center">
  <a href="#-tính-năng-chính">Tính năng</a> •
  <a href="#-kiến-trúc">Kiến trúc</a> •
  <a href="#-cài-đặt">Cài đặt</a> •
  <a href="#-ai-service">AI Service</a> •
  <a href="#-đóng-góp">Đóng góp</a>
</p>

---

## 📱 Giới Thiệu

**AppThienTai** là ứng dụng di động cứu trợ thiên tai được phát triển bằng Flutter, tích hợp AI để dự báo rủi ro và hỗ trợ người dùng trong các tình huống khẩn cấp như bão, lũ lụt, sạt lở đất tại Việt Nam.

### 🎯 Mục tiêu
- **Cảnh báo sớm**: Dự báo rủi ro thiên tai bằng AI/ML
- **Cứu hộ nhanh**: Kết nối nạn nhân với đội cứu hộ qua GPS
- **Quyên góp dễ dàng**: Tiền mặt, nhu yếu phẩm, công sức
- **Hoạt động offline**: Sử dụng được khi mất mạng

---

## ✨ Tính Năng Chính

### 1. 🚨 Module SOS & Cứu Hộ

| Tính năng | Mô tả |
|-----------|-------|
| **Nút SOS Khẩn Cấp** | Floating button, gửi vị trí GPS tức thì |
| **Offline Queue** | Lưu yêu cầu SOS khi mất mạng, tự động gửi khi có kết nối |
| **Gọi Nhanh** | Nút gọi 113, 114, 115 trực tiếp |
| **Bản đồ Nạn nhân** | Hiển thị vùng nguy hiểm và điểm trú ẩn |
| **Chat Thời gian thực** | Liên lạc với đội cứu hộ |

```
┌─────────────────────────────────────────┐
│  🆘  Gửi yêu cầu SOS                    │
│                                         │
│  📍 Vị trí: 10.762, 106.660            │
│  📝 Mô tả: [Nhập tình huống...]        │
│                                         │
│  ┌─────┐  ┌─────┐  ┌─────┐            │
│  │ 113 │  │ 114 │  │ 115 │            │
│  └─────┘  └─────┘  └─────┘            │
│                                         │
│         [ GỬI SOS NGAY ]               │
└─────────────────────────────────────────┘
```

### 2. 🗺️ Bản Đồ Thông Minh

- **Vùng nguy hiểm**: Hiển thị các khu vực có rủi ro cao (đỏ/cam/vàng)
- **Điểm trú ẩn**: Shelter, bệnh viện, trường học
- **Geofencing**: Tự động cảnh báo khi vào vùng nguy hiểm
- **Routing**: Tìm đường đi ngắn nhất đến nơi an toàn (OSRM)

### 3. 🤝 Module Quyên Góp

#### 💵 Quyên góp Tiền mặt
- Chip nhanh: 50K, 100K, 200K, 500K, 1M
- Campaign Cards: Chiến dịch cứu trợ nổi bật
- QR Code: Chuyển khoản trực tiếp MTTQ

#### 📦 Quyên góp Nhu yếu phẩm
| Danh mục | Icon |
|----------|------|
| Thực phẩm | 🍚 |
| Nước uống | 💧 |
| Quần áo | 👕 |
| Y tế | 💊 |
| Thiết bị | 🔦 |
| Khác | 📦 |

#### 🙋 Đăng ký Tình nguyện viên
- Kỹ năng: Vận chuyển, Y tế, Dọn dẹp, Nấu ăn, Logistics
- Lịch sẵn sàng: Chọn ngày có thể tham gia
- SMS/Call thông báo

### 4. 🤖 AI Dự Báo Thiên Tai

#### Mô hình ML
| Model | Algorithm | Use case |
|-------|-----------|----------|
| **Hazard Predictor** | XGBoost | Dự báo rủi ro (1-5 sao) |
| **Alert Scorer** | Random Forest | Điểm ưu tiên cảnh báo |
| **Duplicate Detector** | Sentence BERT | Phát hiện tin trùng lặp |
| **Notification Timing** | Thompson Sampling | Tối ưu thời điểm gửi |

#### Dữ liệu Training
- **63 tỉnh/thành** Việt Nam với hazard profile
- **Open-Meteo API**: Dữ liệu thời tiết real-time
- **NCHMF/DDMFC**: Nguồn chính phủ (100% reliability)
- **50,000+ samples** cho training

### 5. 🔔 Thông Báo Thông Minh

- **Smart Batching**: Gộp 3-5 notification để tránh spam
- **Cooldown**: 2 phút giữa mỗi lần gửi
- **Priority-based**: Critical → gửi ngay, Low → batch
- **FCM Integration**: Firebase Cloud Messaging

### 6. 📶 Chế Độ Offline

- **Cẩm nang sinh tồn**: Hướng dẫn ứng phó thiên tai
- **SOS Queue**: Lưu và gửi khi có mạng
- **Local Storage**: Danh bạ khẩn cấp, lịch sử

---

## 🏗️ Kiến Trúc

### Clean Architecture

```
lib/
├── core/                   # Constants, theme, utilities
├── data/                   # Repositories, Services, DTOs
│   ├── repositories/       # Firebase implementations
│   └── services/           # Business logic services
├── domain/                 # Entities, Use cases
│   ├── entities/           # Data models
│   └── services/           # Domain services (Scoring, Dedup)
└── presentation/           # UI Layer
    ├── bindings/           # GetX bindings
    ├── controllers/        # GetX controllers
    └── features/           # Screens by feature
        ├── admin/
        ├── auth/
        ├── donation/
        ├── victim/
        └── volunteer/
```

### Công nghệ

| Layer | Technology |
|-------|------------|
| **Frontend** | Flutter 3.24.x, Dart 3.5.x |
| **State Management** | GetX |
| **Backend** | Firebase (Auth, Firestore, Storage, FCM) |
| **AI Service** | Python, FastAPI, Scikit-learn, XGBoost |
| **Maps** | flutter_map + OpenStreetMap |
| **Routing** | OSRM (Open Source Routing Machine) |

---

## 🚀 Cài Đặt

### Yêu cầu
- Flutter SDK 3.24.x+
- Dart 3.5.x+
- Python 3.9+ (cho AI Service)
- Firebase project

### 1. Clone Repository

```bash
git clone https://github.com/PhamMinhKha0710/AppThienTai.git
cd AppThienTai
```

### 2. Chạy Flutter App

```bash
# Cài đặt dependencies
flutter pub get

# Chạy ứng dụng
flutter run

# Build APK
flutter build apk --release
```

### 3. Chạy AI Service

```bash
cd ai_service

# Tạo virtual environment
python -m venv venv
source venv/bin/activate  # Linux/Mac
# hoặc: venv\Scripts\activate  # Windows

# Cài đặt dependencies
pip install -r requirements.txt

# Train model (lần đầu)
python train_hazard_model.py

# Chạy server
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

**API Docs**: http://localhost:8000/docs

---

## 🤖 AI Service

### API Endpoints

| Endpoint | Method | Mô tả |
|----------|--------|-------|
| `/api/v1/health` | GET | Health check |
| `/api/v1/hazard/predict` | POST | Dự báo rủi ro thiên tai |
| `/api/v1/hazard/zones` | GET | Lấy danh sách vùng nguy hiểm |
| `/api/v1/score` | POST | Tính điểm ưu tiên cảnh báo |
| `/api/v1/duplicate/check` | POST | Kiểm tra tin trùng lặp |
| `/api/v1/timing/recommend` | POST | Gợi ý thời điểm gửi notification |

### Ví dụ Request

```bash
# Dự báo rủi ro
curl -X POST "http://localhost:8000/api/v1/hazard/predict" \
  -H "Content-Type: application/json" \
  -d '{
    "lat": 16.0544,
    "lng": 108.2022,
    "month": 10,
    "hazard_type": "flood"
  }'

# Response:
{
  "risk_level": 4,
  "risk_label": "high",
  "confidence": 0.85,
  "province": "Đà Nẵng",
  "explanation": "Nguy cơ ngập lụt mức Cao tại Đà Nẵng"
}
```

---

## 📊 Thuật Toán

| Thuật toán | File | Mục đích |
|------------|------|----------|
| Multi-factor Scoring | `alert_scoring_service.dart` | Điểm ưu tiên cảnh báo |
| Exponential Decay | `alert_scoring_service.dart` | Suy giảm theo thời gian |
| Haversine Distance | `geofencing_service.dart` | Tính khoảng cách GPS |
| OSRM Routing | `routing_service.dart` | Tìm đường đi ngắn nhất |
| XGBoost | `hazard_predictor.py` | Dự báo thiên tai |
| Thompson Sampling | `notification_timing.py` | Tối ưu notification |

📚 Chi tiết: [docs/algorithms/README.md](docs/algorithms/README.md)

---

## 📁 Cấu Trúc Thư Mục

```
AppThienTai/
├── lib/                    # Flutter source code
├── assets/                 # Images, fonts, JSON
├── ai_service/            # Python AI backend
│   ├── models/            # ML models
│   ├── data_collectors/   # Data collection scripts
│   └── data/              # Training data & model files
├── docs/                  # Documentation
│   ├── algorithms/        # Thuật toán chi tiết
│   └── handover_document/ # Bàn giao kỹ thuật
├── test/                  # Unit & Widget tests
└── android/ios/          # Platform-specific code
```

---

## 🗓️ Roadmap

### ✅ Đã hoàn thành
- [x] SOS Module với GPS & Offline queue
- [x] Bản đồ vùng nguy hiểm
- [x] Quyên góp tiền/nhu yếu phẩm
- [x] AI Hazard Prediction (XGBoost)
- [x] Smart Notification Batching
- [x] Geofencing Service

### 🚧 Đang phát triển
- [ ] Video call với đội cứu hộ
- [ ] Tích hợp VNPay/Momo
- [ ] Push notification nâng cao

### 📋 Kế hoạch tương lai
- [ ] IoT Sensors integration
- [ ] Blockchain donation tracking
- [ ] Multi-language support
- [ ] Satellite data for flood prediction

---

## 🤝 Đóng Góp

Chúng tôi hoan nghênh mọi đóng góp! Vui lòng:

1. Fork repository
2. Tạo feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Tạo Pull Request

---

## 📄 License

Dự án này được phát hành dưới giấy phép **MIT License**.

---

## 👥 Team

| Role | Name |
|------|------|
| **Developer** | Phạm Minh Kha |
| **AI/ML** | AppThienTai Team |

---

## 📞 Liên Hệ

- **GitHub**: [PhamMinhKha0710/AppThienTai](https://github.com/PhamMinhKha0710/AppThienTai)
- **Email**: support@appthientai.vn

---

<p align="center">
  Made with ❤️ for Vietnam Disaster Relief
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Version-1.0.0-blue" alt="Version"/>
  <img src="https://img.shields.io/badge/Status-Active-green" alt="Status"/>
</p>
