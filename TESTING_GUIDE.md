# Hướng Dẫn Kiểm Tra Các Tính Năng Vai Trò Nạn Nhân

## 📋 Checklist Kiểm Tra

### 1. Kiểm Tra Compile và Dependencies

#### Bước 1: Chạy lệnh để kiểm tra lỗi compile
```bash
flutter pub get
flutter analyze
```

#### Bước 2: Kiểm tra các dependencies cần thiết
Đảm bảo các package sau đã được thêm vào `pubspec.yaml`:
- ✅ `flutter_map` - cho bản đồ
- ✅ `latlong2` - cho tọa độ
- ✅ `geolocator` - cho GPS
- ✅ `geocoding` - cho địa chỉ
- ✅ `image_picker` - cho chụp ảnh
- ✅ `get` - cho state management
- ✅ `iconsax` - cho icons

### 2. Kiểm Tra LocationService

#### Vấn đề có thể gặp:
LocationService cần được register trong AppBindings hoặc khởi tạo trước khi sử dụng.

#### Cách sửa:
Thêm vào `lib/presentation/bindings/app_bindings.dart`:
```dart
import '../../data/services/location_service.dart';

// Trong dependencies():
Get.put(LocationService(), permanent: true);
```

### 3. Kiểm Tra Navigation

#### Test Case 1: Đăng nhập với vai trò Nạn nhân
1. Chạy app: `flutter run`
2. Đăng nhập với tài khoản có `userType = "victim"` hoặc `"nạn nhân"`
3. **Kỳ vọng**: App tự động chuyển đến `NavigationVictimMenu` với 5 tabs:
   - Trang chủ
   - Bản đồ
   - Cảnh báo
   - Tin tức
   - Cá nhân

#### Test Case 2: Chuyển đổi giữa các tabs
1. Tap vào từng tab trong bottom navigation
2. **Kỳ vọng**: Màn hình tương ứng hiển thị đúng

### 4. Kiểm Tra Màn Hình Home

#### Test Case 3: Mini-map hiển thị
1. Vào tab "Trang chủ"
2. **Kỳ vọng**: 
   - Mini-map hiển thị (chiếm ~40% màn hình)
   - Marker vị trí hiện tại (màu xanh)
   - Button "Xem bản đồ đầy đủ" ở góc dưới phải

#### Test Case 4: Cảnh báo gần đây
1. Scroll xuống phần "Cảnh báo gần đây"
2. **Kỳ vọng**: 
   - List cảnh báo hiển thị (có thể scroll ngang)
   - Card cảnh báo có icon, tiêu đề, mô tả, thời gian
   - Màu sắc khác nhau theo severity (đỏ = high, cam = medium)

#### Test Case 5: Shortcut buttons
1. Scroll xuống phần "Hỗ trợ nhanh"
2. Tap vào "Điểm trú ẩn"
3. **Kỳ vọng**: Chuyển đến màn hình Map
4. Quay lại, tap vào "Hướng dẫn"
5. **Kỳ vọng**: Chuyển đến tab "Tin tức"

#### Test Case 6: Nút SOS
1. Tap vào nút SOS (màu đỏ) ở góc dưới phải
2. **Kỳ vọng**: Mở màn hình SOS Request với wizard form

### 5. Kiểm Tra Màn Hình Map

#### Test Case 7: Bản đồ đầy đủ
1. Vào tab "Bản đồ" hoặc tap "Xem bản đồ đầy đủ"
2. **Kỳ vọng**:
   - Bản đồ hiển thị với vị trí hiện tại
   - Có search bar ở trên
   - Có filter button
   - Có legend ở dưới bên trái

#### Test Case 8: Long-press để báo cáo
1. Long-press vào một điểm trên bản đồ
2. **Kỳ vọng**: Dialog "Báo cáo thiên tai" xuất hiện

### 6. Kiểm Tra Màn Hình Alerts

#### Test Case 9: Tabs Alerts
1. Vào tab "Cảnh báo"
2. Tap vào tab "Đang hoạt động" và "Lịch sử"
3. **Kỳ vọng**: 
   - Tab được highlight khi selected
   - Nội dung thay đổi theo tab

#### Test Case 10: Alert Card
1. Tap vào một alert card
2. **Kỳ vọng**: 
   - Dialog hiển thị chi tiết alert
   - Có các button: "Đóng", "Xem trên bản đồ", "Hướng dẫn xử lý"

### 7. Kiểm Tra Màn Hình SOS

#### Test Case 11: Wizard Form
1. Tap nút SOS từ bất kỳ màn hình nào
2. **Bước 1**: Nhập mô tả vấn đề
   - **Kỳ vọng**: GPS tự động lấy vị trí và hiển thị
3. Tap "Tiếp tục"
4. **Bước 2**: Chụp ảnh hoặc chọn từ thư viện
   - **Kỳ vọng**: Ảnh được thêm vào danh sách
5. Tap "Tiếp tục"
6. **Bước 3**: Xem lại thông tin
   - **Kỳ vọng**: Hiển thị mô tả và số lượng ảnh
7. Tap "Gửi SOS"
   - **Kỳ vọng**: 
     - Loading indicator hiển thị
     - Snackbar "Thành công" sau khi gửi
     - Quay về màn hình trước

### 8. Kiểm Tra Màn Hình News

#### Test Case 12: Tin tức và hướng dẫn
1. Vào tab "Tin tức"
2. **Kỳ vọng**:
   - Search bar ở trên
   - Categories filter (Tất cả, Sơ tán, Y tế cơ bản, ...)
   - List các bài viết với hình ảnh, tiêu đề, summary

#### Test Case 13: Chatbot
1. Tap vào nút chatbot (FAB)
2. **Kỳ vọng**: 
   - Bottom sheet mở ra
   - Có các suggestion buttons
   - Có input field để nhập câu hỏi

### 9. Kiểm Tra Widgets Dùng Chung

#### Test Case 14: MinhTabButton
- Sử dụng trong: Alerts, Donation
- **Kỳ vọng**: Tab được highlight khi selected

#### Test Case 15: MinhAlertCard
- Sử dụng trong: Home, Alerts
- **Kỳ vọng**: 
  - Màu sắc đúng theo severity
  - Tap vào hiển thị dialog chi tiết

#### Test Case 16: MinhShortcutButton
- Sử dụng trong: Home
- **Kỳ vọng**: 
  - Icon và label hiển thị đúng
  - Tap vào thực hiện action tương ứng

## 🐛 Các Lỗi Thường Gặp và Cách Sửa

### Lỗi 1: LocationService not found
**Lỗi**: `Get.find<LocationService>()` throws exception
**Cách sửa**: Thêm LocationService vào AppBindings (xem mục 2)

### Lỗi 2: Navigation không chuyển đúng
**Lỗi**: Vẫn vào NavigationMenu thay vì NavigationVictimMenu
**Cách sửa**: 
- Kiểm tra `userType` trong Firestore có đúng không
- Kiểm tra `NavigationHelper.redirectAfterAuth()` có import `NavigationVictimMenu` chưa

### Lỗi 3: Map không hiển thị
**Lỗi**: Màn hình trắng hoặc lỗi
**Cách sửa**: 
- Kiểm tra quyền GPS đã được cấp chưa
- Kiểm tra internet connection (cần để load map tiles)

### Lỗi 4: Widget không tìm thấy
**Lỗi**: `MinhTabButton` not found
**Cách sửa**: 
- Chạy `flutter pub get`
- Kiểm tra import path có đúng không

## 📱 Cách Test Nhanh

### Option 1: Test từng màn hình riêng lẻ
Tạo một màn hình test tạm thời:

```dart
// lib/test_victim_screens.dart
import 'package:cuutrobaolu/presentation/features/victim/navigation_victim_menu.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: NavigationVictimMenu(),
  ));
}
```

### Option 2: Sử dụng Flutter DevTools
1. Chạy app với `flutter run`
2. Mở DevTools: `flutter pub global activate devtools` rồi `flutter pub global run devtools`
3. Kiểm tra Widget Tree để xem các widget có render đúng không

### Option 3: Debug Console
1. Chạy app với `flutter run`
2. Xem console logs để phát hiện lỗi
3. Sử dụng `print()` hoặc `debugPrint()` trong controllers để debug

## ✅ Checklist Hoàn Chỉnh

- [ ] App compile không lỗi (`flutter analyze` pass)
- [ ] LocationService được register
- [ ] Navigation chuyển đúng khi đăng nhập với role victim
- [ ] Tất cả 5 tabs hiển thị đúng
- [ ] Home screen: mini-map, alerts, shortcuts, SOS button
- [ ] Map screen: bản đồ, search, filter, legend
- [ ] Alerts screen: tabs, search, alert cards
- [ ] SOS screen: wizard form 3 bước hoạt động
- [ ] News screen: list, search, categories, chatbot
- [ ] Widgets dùng chung hoạt động đúng
- [ ] Không có lỗi runtime trong console

## 🚀 Bước Tiếp Theo

Sau khi test xong, cần:
1. Tích hợp với Firestore để load dữ liệu thực
2. Tích hợp payment gateway cho Donation
3. Tích hợp chatbot API
4. Tích hợp ML prediction API
5. Thêm unit tests cho controllers
6. Thêm integration tests cho các luồng chính


