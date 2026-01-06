# 🤖 AI Service Documentation

## Tài liệu hệ thống AI dự báo thiên tai và cảnh báo thông minh

---

## 📋 Mục lục

1. [Tổng quan](#1-tổng-quan)
2. [Kiến trúc hệ thống](#2-kiến-trúc-hệ-thống)
3. [Cài đặt & Chạy](#3-cài-đặt--chạy)
4. [API Endpoints](#4-api-endpoints)
5. [Models & Algorithms](#5-models--algorithms)
6. [Training](#6-training)
7. [Deployment](#7-deployment)

---

## 1. Tổng quan

### 1.1. Giới thiệu

**Smart Alert AI Service** là hệ thống AI backend cung cấp các tính năng thông minh cho ứng dụng cứu trợ thiên tai:

| Tính năng | Mô tả | Thuật toán |
|-----------|-------|------------|
| **Hazard Prediction** | Dự báo mức độ rủi ro thiên tai theo vị trí | XGBoost / Gradient Boosting |
| **Alert Scoring** | Đánh giá độ ưu tiên cảnh báo | Random Forest |
| **Duplicate Detection** | Phát hiện cảnh báo trùng lặp | Sentence Transformers (Semantic Similarity) |
| **Notification Timing** | Gợi ý thời điểm gửi thông báo tối ưu | Thompson Sampling (Contextual Bandit) |

### 1.2. Công nghệ sử dụng

```
Python 3.9+
├── FastAPI          # Web Framework
├── Uvicorn          # ASGI Server
├── Scikit-learn     # Machine Learning
├── XGBoost          # Gradient Boosting
├── Sentence-Transformers  # NLP Embeddings
├── Pandas / NumPy   # Data Processing
└── Docker           # Containerization
```

---

## 2. Kiến trúc hệ thống

### 2.1. Cấu trúc thư mục

```
ai_service/
├── main.py                 # FastAPI application entry point
├── config.py               # Configuration settings
├── train_hazard_model.py   # Model training script
├── training_utils.py       # Training utilities
├── requirements.txt        # Python dependencies
├── Dockerfile              # Docker build file
├── docker-compose.yml      # Docker compose configuration
│
├── models/                 # ML Models
│   ├── alert_scorer.py         # Alert priority scoring
│   ├── duplicate_detector.py   # Semantic duplicate detection
│   ├── hazard_predictor.py     # Hazard zone prediction
│   └── notification_timing.py  # Smart notification timing
│
├── services/               # Business logic services
│   ├── data_collector.py       # Data collection for training
│   └── model_trainer.py        # Model retraining logic
│
├── utils/                  # Utilities
│   ├── features.py             # Feature extraction
│   └── metrics.py              # Metrics calculation
│
├── data/                   # Data storage
│   ├── models/                 # Trained model files (.pkl)
│   ├── training/               # Training data
│   └── cache/                  # Cache files
│
└── tests/                  # Unit tests
```

### 2.2. Sơ đồ luồng dữ liệu

```
┌─────────────────────────────────────────────────────────────────┐
│                     FLUTTER MOBILE APP                          │
│  (Gửi request dự báo thiên tai, scoring cảnh báo...)           │
└─────────────────────────────────────────────────────────────────┘
                              │ HTTP/REST
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                   FASTAPI APPLICATION                           │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────────────┐│
│  │   /score    │ │  /predict   │ │      /duplicate/check       ││
│  │   /zones    │ │  /health    │ │      /timing/recommend      ││
│  └─────────────┘ └─────────────┘ └─────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      ML MODELS LAYER                            │
│  ┌───────────────┐ ┌───────────────┐ ┌───────────────────────┐ │
│  │ HazardPredictor│ │  AlertScorer  │ │  DuplicateDetector    │ │
│  │ (XGBoost)      │ │ (RandomForest)│ │  (SentenceTransformer)│ │
│  └───────────────┘ └───────────────┘ └───────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3. Cài đặt & Chạy

### 3.1. Yêu cầu hệ thống

- Python 3.9 trở lên
- 4GB RAM (khuyến nghị 8GB cho training)
- 2GB disk space

### 3.2. Cài đặt môi trường

```bash
# Di chuyển vào thư mục ai_service
cd ai_service

# Tạo virtual environment
python -m venv venv

# Kích hoạt virtual environment
# Windows:
venv\Scripts\activate
# Linux/Mac:
source venv/bin/activate

# Cài đặt dependencies
pip install -r requirements.txt
```

### 3.3. Huấn luyện model (lần đầu)

```bash
# Chạy script huấn luyện
python train_hazard_model.py
```

Output mẫu:
```
============================================================
  🌊 VIETNAM HAZARD ZONE PREDICTION - MODEL TRAINING
============================================================
🔄 Generating 50,000 training samples...
📊 Splitting data...
  Training: 40,000 samples
  Testing:  10,000 samples
🚀 Training GradientBoosting model...
✅ Model Accuracy: 0.8542 (85.42%)
💾 Saving model...
✅ Model saved to: data/models/hazard_predictor.pkl
```

### 3.4. Chạy API Server

```bash
# Chạy server development
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# Hoặc chạy trực tiếp
python main.py
```

Server sẽ chạy tại: `http://localhost:8000`
- API Docs (Swagger): `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

### 3.5. Chạy với Docker

```bash
# Build image
docker build -t ai-service .

# Chạy container
docker run -d -p 8000:8000 ai-service

# Hoặc dùng docker-compose
docker-compose up -d
```

---

## 4. API Endpoints

### 4.1. Health Check

```http
GET /api/v1/health
```

**Response:**
```json
{
  "status": "healthy",
  "models": {
    "scorer": "loaded",
    "duplicate_detector": "loaded",
    "timing_model": "loaded"
  },
  "database": "connected"
}
```

---

### 4.2. Dự báo rủi ro thiên tai

```http
POST /api/v1/hazard/predict
```

**Request Body:**
```json
{
  "lat": 16.0544,
  "lng": 108.2022,
  "month": 10,
  "hazard_type": "flood"
}
```

**Response:**
```json
{
  "lat": 16.0544,
  "lng": 108.2022,
  "risk_level": 4,
  "risk_label": "Cao",
  "confidence": 0.85,
  "hazard_type": "flood",
  "month": 10,
  "province": "Đà Nẵng",
  "explanation": "Mức rủi ro lũ lụt CAO do vị trí thuộc miền Trung và đang trong mùa mưa bão (tháng 10)"
}
```

**Mức độ rủi ro:**
| Level | Label | Mô tả |
|-------|-------|-------|
| 1 | Rất thấp | An toàn, ít có nguy cơ |
| 2 | Thấp | Cần theo dõi |
| 3 | Trung bình | Chuẩn bị sẵn sàng |
| 4 | Cao | Nguy cơ cao, cần cảnh giác |
| 5 | Rất cao | Nguy hiểm, cần di dời |

---

### 4.3. Lấy danh sách vùng nguy hiểm

```http
GET /api/v1/hazard/zones?province=Đà Nẵng&month=10&hazard_type=flood&min_risk=3
```

**Parameters:**
| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| province | string | Lọc theo tỉnh/thành |
| month | int | Lọc theo tháng (1-12) |
| hazard_type | string | flood, landslide, storm |
| min_risk | int | Mức rủi ro tối thiểu (1-5) |

**Response:**
```json
{
  "total": 5,
  "month": 10,
  "zones": [
    {
      "id": "zone-1",
      "lat": 16.0544,
      "lng": 108.2022,
      "radius_km": 15.0,
      "hazard_type": "flood",
      "risk_level": 4,
      "description": "Vùng ngập lụt cao tại Đà Nẵng"
    }
  ]
}
```

---

### 4.4. Đánh giá độ ưu tiên cảnh báo

```http
POST /api/v1/score
```

**Request Body:**
```json
{
  "alert_id": "alert-123",
  "severity": "high",
  "alert_type": "weather",
  "content": "Mưa lớn trong 3 giờ tới, nguy cơ ngập lụt",
  "province": "TP.HCM",
  "district": "Quận 1",
  "lat": 10.762622,
  "lng": 106.660172,
  "created_at": "2024-01-15T10:00:00Z",
  "user_lat": 10.762622,
  "user_lng": 106.660172,
  "user_role": "victim"
}
```

**Response:**
```json
{
  "alert_id": "alert-123",
  "priority_score": 85.5,
  "confidence": 0.92,
  "explanation": {
    "severity_impact": 30,
    "distance_impact": 25,
    "time_decay": 0.95,
    "type_weight": 1.2
  }
}
```

---

### 4.5. Kiểm tra cảnh báo trùng lặp

```http
POST /api/v1/duplicate/check
```

**Request Body:**
```json
{
  "new_alert": {
    "id": "new-alert-1",
    "content": "Cảnh báo lũ lụt tại Quảng Nam",
    "province": "Quảng Nam"
  },
  "existing_alerts": [
    {
      "id": "alert-existing-1",
      "content": "Lũ lụt nghiêm trọng ở Quảng Nam",
      "province": "Quảng Nam"
    }
  ],
  "threshold": 0.85
}
```

**Response:**
```json
{
  "is_duplicate": true,
  "duplicates": [
    {
      "alert": {"id": "alert-existing-1", "...": "..."},
      "similarity": 0.92
    }
  ],
  "best_match": {
    "alert": {"id": "alert-existing-1"},
    "similarity": 0.92
  }
}
```

---

## 5. Models & Algorithms

### 5.1. Hazard Zone Predictor

**Thuật toán:** Gradient Boosting Classifier (tương tự XGBoost)

**Đầu vào (Features):**
| Feature | Mô tả |
|---------|-------|
| lat, lng | Tọa độ GPS |
| province_id | ID tỉnh/thành (0-24) |
| region_id | Vùng miền (Bắc=0, Trung=1, Tây Nguyên=2, Nam=3) |
| month | Tháng trong năm (1-12) |
| season | Mùa (Khô=0, Chuyển tiếp=1, Mưa bão=2) |
| hazard_type_id | Loại thiên tai (flood=0, landslide=1, storm=2) |
| base_flood_risk | Rủi ro lũ lụt cơ sở của tỉnh (1-5) |
| base_landslide_risk | Rủi ro sạt lở cơ sở (1-5) |
| base_storm_risk | Rủi ro bão cơ sở (1-5) |
| seasonal_multiplier | Hệ số mùa (0.1-1.0) |

**Đầu ra:** Risk Level (1-5)

**Dữ liệu huấn luyện:** 50,000 samples từ 25 tỉnh/thành Việt Nam

### 5.2. Alert Scoring Model

**Thuật toán:** Random Forest Classifier

**Yếu tố đánh giá:**
- Mức độ nghiêm trọng (severity)
- Khoảng cách từ người dùng
- Thời gian kể từ khi tạo cảnh báo
- Loại cảnh báo
- Vai trò người dùng

### 5.3. Duplicate Detector

**Thuật toán:** Sentence Transformers

**Model:** `paraphrase-multilingual-MiniLM-L12-v2`

**Cách hoạt động:**
1. Chuyển đổi text thành vector embedding
2. Tính cosine similarity giữa các embeddings
3. Đánh dấu trùng lặp nếu similarity > threshold (0.85)

### 5.4. Notification Timing

**Thuật toán:** Thompson Sampling (Contextual Bandit)

**Cách hoạt động:**
- Học từ phản hồi người dùng (click, dismiss)
- Cân bằng exploration/exploitation
- Gợi ý thời điểm tối ưu (0-23h)

---

## 6. Training

### 6.1. Huấn luyện Hazard Predictor

```bash
python train_hazard_model.py
```

**Tham số điều chỉnh trong `train_hazard_model.py`:**
```python
# Số lượng samples
num_samples = 50000

# Gradient Boosting params
model = GradientBoostingClassifier(
    n_estimators=150,    # Số cây
    max_depth=6,         # Độ sâu tối đa
    learning_rate=0.1,   # Tốc độ học
    subsample=0.8,       # Tỷ lệ sampling
)
```

### 6.2. Dữ liệu tỉnh/thành

Dữ liệu 25 tỉnh/thành với các thông tin:
- Tọa độ trung tâm (lat, lng)
- Vùng miền (Bắc, Trung, Tây Nguyên, Nam)
- Mức rủi ro cơ sở cho từng loại thiên tai

### 6.3. Hệ số mùa vụ

```python
SEASONAL_MULTIPLIERS = {
    # Tháng: (flood, storm, landslide)
    1: (0.3, 0.2, 0.3),   # Mùa khô
    ...
    9: (1.0, 0.9, 1.0),   # Đỉnh mùa mưa bão
    10: (1.0, 1.0, 1.0),  # Đỉnh mùa mưa bão
    ...
}
```

---

## 7. Deployment

### 7.1. Docker Deployment

**Dockerfile:**
```dockerfile
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### 7.2. Cloud Deployment

**Railway/Render/Heroku:**
1. Push code lên GitHub
2. Kết nối repository
3. Set environment variables:
   ```
   API_HOST=0.0.0.0
   API_PORT=8000
   ```
4. Deploy

### 7.3. Cấu hình Production

```python
# config.py
API_HOST = os.getenv("API_HOST", "0.0.0.0")
API_PORT = int(os.getenv("API_PORT", "8000"))

# Trong main.py - giới hạn CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://your-app.com"],  # Specific origins
    allow_credentials=True,
    allow_methods=["GET", "POST"],
    allow_headers=["*"],
)
```

---

## 📞 Liên hệ

- **Repository:** [GitHub - AppThienTai](https://github.com/PhamMinhKha0710/AppThienTai)
- **API Docs:** http://localhost:8000/docs

---

> 📝 **Ghi chú:** Tài liệu này được cập nhật lần cuối vào tháng 1/2026.
