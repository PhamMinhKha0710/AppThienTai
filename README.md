# Ứng Dụng Cứu Trợ Thiên Tai (AppThienTai)

Ứng dụng kết nối nạn nhân và tình nguyện viên trong các tình huống thiên tai khẩn cấp, hỗ trợ cứu hộ, quyên góp và cảnh báo sớm.

## ✨ Tính Năng Đã Triển Khai

### 1. 🚨 Cứu Hộ & SOS
- **Nút SOS Khẩn Cấp**:
    - Gửi tín hiệu cầu cứu kèm vị trí GPS.
    - Nút bấm nổi (Floating Button), có thể thu gọn/mở rộng.
- **Bản Đồ Nạn Nhân (Victim Map)**:
    - Hiển thị vùng nguy hiểm (Lũ lụt, Sạt lở) được dự báo bởi AI.
    - Bộ lọc: Chỉ hiện điểm trú ẩn an toàn hoặc vùng nguy hiểm.
    - Tìm kiếm địa điểm và loại thiên tai.
- **Chat Thời Gian Thực**: Kết nối trực tiếp giữa Nạn nhân và Tình nguyện viên/Đội cứu hộ.

### 2. 🤝 Quyên Góp (Volunteer)
- **Quyên Góp Tiền Mặt**:
    - Chọn nhanh mệnh giá (Chips: 50k, 100k, ...).
    - Thẻ Chiến dịch nổi bật (Campaign Cards).
    - Quét mã QR (Mock) chuyển khoản trực tiếp về MTTQ.
- **Quyên Góp Nhu Yếu Phẩm**:
    - Lưới danh mục hiện đại (Thực phẩm, Y tế, Nước uống...).
    - Form nhập liệu chi tiết.
- **Đăng Ký Tình Nguyện Viên**:
    - Đăng ký góp công sức theo kỹ năng (Vận chuyển, Y tế, Dọn dẹp...).
    - Chọn ngày sẵn sàng tham gia.

### 3. 🤖 AI Dự Báo Thiên Tai
- **Mô hình XGBoost** dự đoán mức độ rủi ro (1-5) dựa trên vị trí và tháng.
- **API Endpoint** (FastAPI) phục vụ dự đoán thời gian thực.
- **Dữ liệu**: Đã được huấn luyện với dataset giả lập các tỉnh thành Việt Nam.

### 4. 📶 Chế Độ Offline & Hướng Dẫn
- **Cẩm Nang Sinh Tồn**: Truy cập hướng dẫn ứng phó bão lũ ngay cả khi mất mạng.
- **Lưu Trữ Cục Bộ**: Lưu lịch sử SOS và danh bạ khẩn cấp.

### 5. 🔔 Thông Báo
- Tích hợp **Firebase Cloud Messaging (FCM)**.
- Gửi cảnh báo theo chủ đề (Topic Subscription).

## 🛠️ Công Nghệ Sử Dụng

- **Frontend**: Flutter (GetX State Management).
- **Backend Services**: Firebase (Auth, Firestore, Storage, Messaging).
- **AI Service**: Python, FastAPI, Scikit-learn, XGBoost.
- **Maps**: Flutter Map (OpenStreetMap).

## 🚀 Hướng Dẫn Cài Đặt

### 1. Chạy Ứng Dụng Flutter
```bash
flutter pub get
flutter run
```

### 2. Chạy AI Service (Local)
```bash
cd ai_service
# Cài đặt thư viện
pip install -r requirements.txt
# Huấn luyện model (nếu cần)
python train_hazard_model.py
# Chạy server
uvicorn main:app --reload
```
