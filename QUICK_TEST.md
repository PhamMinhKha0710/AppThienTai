# 🚀 Hướng Dẫn Test Nhanh

## Bước 1: Kiểm Tra Compile

```bash
# Chạy trong terminal
cd C:\Users\ADMIN\Desktop\AppThienTai
flutter pub get
flutter analyze
```

**Kỳ vọng**: Không có lỗi compile (có thể có warnings)

## Bước 2: Chạy App

```bash
flutter run
```

## Bước 3: Test Các Tính Năng

### ✅ Test 1: Đăng nhập với vai trò Nạn nhân

1. Đăng nhập với tài khoản có `userType = "victim"` hoặc `"nạn nhân"`
2. **Kỳ vọng**: App tự động vào `NavigationVictimMenu` với 5 tabs

### ✅ Test 2: Màn hình Home

1. Kiểm tra:
   - [ ] Mini-map hiển thị (có thể mất vài giây để lấy GPS)
   - [ ] List cảnh báo scroll được
   - [ ] Shortcut buttons "Điểm trú ẩn" và "Hướng dẫn" hoạt động
   - [ ] Nút SOS (màu đỏ) ở góc dưới phải

### ✅ Test 3: Màn hình Map

1. Tap vào tab "Bản đồ" hoặc button "Xem bản đồ đầy đủ"
2. Kiểm tra:
   - [ ] Bản đồ hiển thị
   - [ ] Search bar ở trên
   - [ ] Legend ở dưới bên trái
   - [ ] Long-press mở dialog báo cáo

### ✅ Test 4: Màn hình Alerts

1. Tap tab "Cảnh báo"
2. Kiểm tra:
   - [ ] Tabs "Đang hoạt động" và "Lịch sử" chuyển đổi được
   - [ ] Tap vào alert card mở dialog chi tiết

### ✅ Test 5: Màn hình SOS

1. Tap nút SOS (từ bất kỳ đâu)
2. Kiểm tra:
   - [ ] Wizard form 3 bước hiển thị
   - [ ] Bước 1: Nhập mô tả, GPS tự động
   - [ ] Bước 2: Chụp/chọn ảnh
   - [ ] Bước 3: Xác nhận và gửi

### ✅ Test 6: Màn hình News

1. Tap tab "Tin tức"
2. Kiểm tra:
   - [ ] List bài viết hiển thị
   - [ ] Categories filter hoạt động
   - [ ] Tap FAB mở chatbot bottom sheet

## 🐛 Nếu Gặp Lỗi

### Lỗi: "LocationService not found"
**Đã sửa**: LocationService đã được thêm vào `AppBindings`

### Lỗi: "Navigation không chuyển đúng"
**Kiểm tra**: 
- UserType trong Firestore có đúng không?
- File `navigation_helper.dart` có import `NavigationVictimMenu` chưa?

### Lỗi: "Map không hiển thị"
**Kiểm tra**:
- Quyền GPS đã được cấp chưa?
- Internet connection (cần để load map tiles)

## 📝 Debug Tips

1. **Xem logs**: Console sẽ hiển thị lỗi nếu có
2. **Hot reload**: Nhấn `r` trong terminal khi app đang chạy
3. **Hot restart**: Nhấn `R` để restart app
4. **DevTools**: Mở DevTools để xem Widget Tree

## ✅ Checklist Hoàn Chỉnh

Sau khi test, đánh dấu:
- [ ] App compile không lỗi
- [ ] Tất cả 5 tabs hiển thị
- [ ] Home screen hoạt động
- [ ] Map screen hoạt động
- [ ] Alerts screen hoạt động
- [ ] SOS screen hoạt động
- [ ] News screen hoạt động
- [ ] Widgets dùng chung hoạt động
- [ ] Không có lỗi runtime










