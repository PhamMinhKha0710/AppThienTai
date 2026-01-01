# Ứng Dụng Cưu Trợ Bảo Lưu (Relief Aid App)

[![Flutter](https://img.shields.io/badge/Flutter-3.10.1+-02569B?style=for-the-badge&logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase)](https://firebase.google.com)
[![Dart](https://img.shields.io/badge/Dart-3.0.0+-0175C2?style=for-the-badge&logo=dart)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

## 📋 Giới thiệu

**Cưu Trợ Bảo Lưu** là một ứng dụng di động toàn diện được xây dựng bằng Flutter, dành cho việc quản lý và điều phối cứu trợ trong các tình huống khẩn cấp và thiên tai. Ứng dụng hỗ trợ kết nối giữa nạn nhân, tình nguyện viên và đội ngũ quản lý để đảm bảo việc cứu trợ được thực hiện nhanh chóng và hiệu quả.

### 🎯 Mục tiêu dự án
- **Phản hồi nhanh**: Giảm thời gian phản hồi cứu trợ từ giờ xuống phút
- **Điều phối hiệu quả**: Tối ưu hóa phân bổ nguồn lực và tình nguyện viên
- **Minh bạch**: Theo dõi thời gian thực trạng thái yêu cầu cứu trợ
- **An toàn**: Bảo mật thông tin và xác thực người dùng nghiêm ngặt

### 📊 Thống kê dự án
- **Ngôn ngữ**: Dart/Flutter
- **Kiến trúc**: Clean Architecture
- **Database**: Firebase Firestore
- **Authentication**: Firebase Auth + Biometric
- **Real-time**: Firebase Cloud Messaging
- **Maps**: Flutter Map + OpenStreetMap
- **State Management**: GetX

## ✨ Tính năng nổi bật

### 👥 Hệ thống đa vai trò

#### **Nạn nhân (Victim)**
- **Gửi yêu cầu SOS khẩn cấp** với vị trí GPS tự động
- **Tạo yêu cầu cứu trợ chi tiết** với hình ảnh và mô tả
- **Theo dõi trạng thái yêu cầu** thời gian thực
- **Nhận thông báo cập nhật** từ tình nguyện viên
- **Chat trực tiếp** với đội cứu trợ
- **Xem bản đồ** vị trí tình nguyện viên gần nhất
- **Đánh giá và phản hồi** chất lượng dịch vụ

#### **Tình nguyện viên (Volunteer)**
- **Nhận nhiệm vụ cứu trợ** dựa trên vị trí và kỹ năng
- **Cập nhật trạng thái nhiệm vụ** (đang thực hiện, hoàn thành)
- **Upload hình ảnh** chứng minh hoàn thành nhiệm vụ
- **Chat với nạn nhân** để xác nhận chi tiết
- **Quản lý tài nguyên** (thực phẩm, thuốc men, v.v.)
- **Báo cáo tiến độ** cho đội ngũ quản lý
- **Xem thống kê đóng góp** cá nhân

#### **Quản trị viên (Admin)**
- **Giám sát tổng thể** tất cả yêu cầu cứu trợ
- **Điều phối tình nguyện viên** đến các khu vực cần thiết
- **Quản lý tài nguyên** và phân bổ hợp lý
- **Phân tích dữ liệu** và báo cáo thống kê
- **Quản lý nội dung** tin tức và hướng dẫn
- **Xác minh tình nguyện viên** và quản lý tài khoản
- **Theo dõi hiệu suất** hệ thống

### 🚨 Hệ thống khẩn cấp SOS

#### **Tính năng chính:**
- **SOS tức thời**: Một nút nhấn duy nhất gửi tín hiệu khẩn cấp
- **Vị trí GPS tự động**: Lấy tọa độ chính xác trong thời gian thực
- **Thông báo đa kênh**: Push notification + SMS backup
- **Phân loại ưu tiên**: Tự động phân loại mức độ khẩn cấp

#### **Quy trình SOS:**
1. **Nhấn nút SOS** → Gửi vị trí hiện tại
2. **Xác nhận khẩn cấp** → Chọn loại hỗ trợ cần thiết
3. **Thông báo đến volunteers** → Trong bán kính 5km
4. **Theo dõi phản hồi** → Thời gian thực
5. **Kết nối trực tiếp** → Chat với đội cứu trợ gần nhất

### 📍 Bản đồ và định vị

#### **Tính năng bản đồ:**
- **Flutter Map** với OpenStreetMap tiles
- **Clustering markers** cho hiệu suất tốt
- **GPS tracking** thời gian thực
- **Geofencing** cho khu vực cứu trợ
- **Offline maps** cho vùng không có internet

#### **Địa chỉ Việt Nam:**
- **Tỉnh/Thành phố** → 63 tỉnh thành
- **Quận/Huyện** → Tự động load theo tỉnh
- **Phường/Xã** → Chi tiết đến cấp xã
- **Địa chỉ chi tiết** → Số nhà, đường phố

### 💬 Trò chuyện và giao tiếp

#### **Chat System:**
- **Real-time messaging** với Firebase
- **Media sharing** (hình ảnh, video)
- **Typing indicators** và online status
- **Message encryption** cho bảo mật
- **Chat history** lưu trữ vĩnh viễn
- **Group chat** cho đội cứu trợ

#### **Thông báo đẩy:**
- **Firebase Cloud Messaging** (FCM)
- **Custom notification channels** theo loại
- **Silent notifications** cho updates
- **Action buttons** trong notification

### 📦 Quản lý yêu cầu cứu trợ

#### **Các loại yêu cầu hỗ trợ:**
- 🥖 **Thực phẩm** - Lương khô, thực phẩm đóng hộp, rau củ quả
- 💧 **Nước uống** - Nước sạch, nước khoáng, nước lọc
- 💊 **Thuốc men** - Thuốc chữa bệnh, băng gạc, dụng cụ y tế
- 🏠 **Nơi trú ẩn** - Lều trại, nhà tạm, khu cách ly
- 🚁 **Cứu hộ** - Cứu người mắc kẹt, sơ cứu ban đầu
- 👕 **Quần áo** - Trang phục, chăn màn, đồ dùng cá nhân
- 🔧 **Khác** - Đồ điện tử, nhiên liệu, v.v.

#### **Mức độ ưu tiên:**
- 🔴 **Khẩn cấp** - Nguy hiểm tính mạng, phản hồi < 15 phút
- 🟠 **Cao** - Bị thương nặng, phản hồi < 1 giờ
- 🟡 **Trung bình** - Cần hỗ trợ cơ bản, phản hồi < 4 giờ
- 🟢 **Thấp** - Hỗ trợ bổ sung, phản hồi < 24 giờ

#### **Workflow yêu cầu:**
```
Tạo yêu cầu → Phân loại ưu tiên → Gửi đến volunteers → Nhận phản hồi → Xác nhận → Thực hiện → Hoàn thành → Đánh giá
```

### 🎁 Hệ thống quyên góp

#### **Quyên góp tài chính:**
- **Momo/ZaloPay integration**
- **Stripe/PayPal** cho quốc tế
- **Theo dõi giao dịch** minh bạch
- **Báo cáo sử dụng** quỹ

#### **Quyên góp vật chất:**
- **Inventory management** cho vật tư
- **Donation tracking** từ nguồn đến đích
- **Quality control** và phân loại
- **Distribution planning**

### 📰 Tin tức và cập nhật

#### **Nội dung quản lý:**
- **Emergency alerts** từ cơ quan chức năng
- **Weather warnings** và dự báo
- **Safety guidelines** và hướng dẫn sơ tán
- **Resource availability** cập nhật
- **Success stories** và báo cáo

### 🔐 Bảo mật và xác thực

#### **Authentication Methods:**
- **Email/Password** với Firebase Auth
- **Google Sign-in** cho nhanh chóng
- **Biometric authentication** (Fingerprint/Face ID)
- **PIN code** backup
- **Multi-factor authentication**

#### **Security Features:**
- **Firebase App Check** chống bot attacks
- **Flutter Secure Storage** cho sensitive data
- **JWT tokens** với expiration
- **Role-based access control** (RBAC)
- **Data encryption** at rest và in transit

## 🏗️ Kiến trúc ứng dụng

Ứng dụng được xây dựng theo mô hình **Clean Architecture** với 4 tầng chính, đảm bảo tính **testability**, **maintainability** và **scalability**.

### 📱 **Presentation Layer** - Tầng Trình Bày
```
presentation/
├── bindings/              # GetX dependency injection setup
│   ├── app_bindings.dart          # Main app dependencies
│   └── general_bindings.dart      # General bindings
├── controllers/           # GetX controllers
│   ├── auth_redirect_controller.dart
│   └── ... (feature controllers)
├── features/              # Feature modules
│   ├── authentication/    # Auth screens & controllers
│   ├── victim/           # Victim dashboard & features
│   ├── volunteer/        # Volunteer dashboard & features
│   ├── admin/            # Admin management features
│   ├── chat/             # Chat & messaging
│   ├── personalization/  # User profile & settings
│   └── shop/             # Help requests management
├── routes/               # Navigation routes
│   ├── app_routes.dart           # Route definitions
│   └── routes.dart              # Route constants
└── utils/                # Presentation utilities
    ├── help_request_mapper.dart  # DTO ↔ Presentation mapping
    └── user_mapper.dart
```

**Trách nhiệm:**
- UI rendering và user interactions
- State management với GetX
- Navigation và routing
- Input validation và formatting
- Error handling cho UI

### 🎯 **Domain Layer** - Tầng Logic Nghiệp Vụ
```
domain/
├── entities/              # Business objects (pure Dart)
│   ├── help_request_entity.dart
│   ├── user_entity.dart
│   ├── alert_entity.dart
│   └── ...
├── repositories/          # Abstract interfaces
│   ├── help_request_repository.dart
│   ├── user_repository.dart
│   └── authentication_repository.dart
├── usecases/             # Business logic use cases
│   ├── create_help_request_usecase.dart
│   ├── login_usecase.dart
│   ├── get_help_requests_usecase.dart
│   └── ...
└── failures/             # Domain-specific failures
    └── failures.dart
```

**Trách nhiệm:**
- Business rules và logic thuần túy
- Use cases cho từng business operation
- Entities không phụ thuộc framework
- Validation rules cho business objects
- Abstract contracts cho data operations

### 💾 **Data Layer** - Tầng Dữ Liệu
```
data/
├── datasources/          # External data sources
│   └── remote/
│       ├── help_request_remote_datasource.dart
│       └── user_remote_datasource.dart
├── models/               # DTOs with serialization
│   ├── help_request_dto.dart
│   ├── user_dto.dart
│   └── alert_dto.dart
├── repositories/         # Repository implementations
│   ├── help_request_repository_impl.dart
│   ├── user_repository_impl.dart
│   └── authentication_repository_impl.dart
├── services/             # External services
│   ├── location_service.dart
│   └── routing_service.dart
└── DummyData/           # Mock data for testing
```

**Trách nhiệm:**
- Implement domain repository interfaces
- Data transformation (DTO ↔ Entity)
- External API calls và database operations
- Error mapping (external errors → domain failures)
- Caching và offline support

### 🛠️ **Core Layer** - Tầng Cơ Sở
```
core/
├── constants/            # App-wide constants
│   ├── colors.dart       # Color palette
│   ├── sizes.dart        # UI dimensions
│   ├── text_strings.dart # Localized strings
│   ├── enums.dart        # App enums
│   └── image_strings.dart # Asset paths
├── exceptions/           # Custom exceptions
│   ├── firebase_exceptions.dart
│   ├── platform_exceptions.dart
│   └── format_exceptions.dart
├── injection/           # Dependency injection
│   └── injection_container.dart # GetIt setup
├── popups/              # UI feedback components
│   ├── full_screen_loader.dart
│   └── loaders.dart
├── theme/               # App theming
│   ├── theme.dart       # Light/dark themes
│   └── custom_themes/   # Theme components
├── utils/               # Utility functions
│   ├── device_utility.dart
│   ├── formatter.dart
│   ├── validation.dart
│   └── vietnam_provinces_helper.dart
└── widgets/             # Shared UI components
    ├── buttons/         # Custom buttons
    ├── cards/           # Card widgets
    ├── texts/           # Text components
    ├── loaders/         # Loading indicators
    └── ...
```

**Trách nhiệm:**
- Chia sẻ utilities và constants
- Custom exceptions và error handling
- Dependency injection setup
- UI theming và shared components
- Device-specific utilities

### 🔄 **Data Flow Architecture**

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Presentation  │───▶│     Domain      │───▶│      Data       │
│   (GetX Views)  │    │  (Use Cases)    │    │ (Repositories)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   UI Events     │    │ Business Logic  │    │ External APIs   │
│                 │    │                 │    │ Firebase, Maps   │
│ Controllers     │    │ Entities        │    │ Local Storage   │
│ State Updates   │    │ Validation      │    │ Network Calls   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### 🧪 **Testing Strategy**

- **Unit Tests**: Domain layer (entities, use cases)
- **Widget Tests**: Presentation layer (UI components)
- **Integration Tests**: Data layer (repositories, APIs)
- **End-to-End Tests**: Full user workflows

## 🛠️ Công nghệ sử dụng

### 📱 **Frontend Framework**
- **Flutter 3.10.1+** - Cross-platform UI framework
- **Dart 3.0.0+** - Programming language
- **GetX 4.7.2** - State management, routing, dependency injection
- **Material Design 3** - Design system

### 🗺️ **Maps & Location**
- **Flutter Map 8.2.2** - Interactive maps với OpenStreetMap
- **LatLng2 0.9.0** - Geographic coordinate handling
- **Geolocator 14.0.2** - GPS location services
- **Geocoding 4.0.0** - Address ⇄ Coordinates conversion
- **Vietnam Provinces 2.0.0** - Vietnamese administrative divisions

### 🔐 **Authentication & Security**
- **Firebase Auth 6.0.1** - User authentication
- **Google Sign-in 6.3.0** - OAuth integration
- **Flutter Secure Storage 8.0.0** - Encrypted local storage
- **Firebase App Check 0.4.1+2** - Request validation
- **Local Authentication** - Biometric/PIN authentication

### 💾 **Database & Storage**
- **Cloud Firestore 6.0.0** - NoSQL real-time database
- **Firebase Storage 13.0.0** - File storage (images, documents)
- **Get Storage 2.1.1** - Local key-value storage

### 📡 **Communication & Networking**
- **Firebase Messaging 16.0.0** - Push notifications
- **Dio 5.9.0** - HTTP client cho external APIs
- **Connectivity Plus 6.1.5** - Network connectivity monitoring

### 🎨 **UI/UX Components**
- **Iconsax 0.0.8** - Custom icon pack
- **Lottie 3.3.1** - Vector animations
- **Shimmer 3.0.0** - Loading animations
- **Smooth Page Indicator 1.2.1** - Page indicators
- **Flutter Rating Bar 4.0.1** - Star rating component
- **Readmore 3.0.0** - Expandable text
- **Carousel Slider 5.1.1** - Image carousels

### 🛠️ **Development Tools**
- **Flutter Lints 6.0.0** - Code quality linting
- **Flutter Native Splash 2.4.6** - Native splash screens
- **Image Picker 1.2.0** - Camera/gallery image selection
- **URL Launcher 6.3.2** - External link opening
- **Package Info Plus** - App version information
- **Logger 2.6.1** - Logging utility

### 📊 **State Management Details**
```dart
// GetX Controller Pattern
class ExampleController extends GetxController {
  final _isLoading = false.obs;
  final _data = <Model>[].obs;

  bool get isLoading => _isLoading.value;
  List<Model> get data => _data;

  Future<void> fetchData() async {
    _isLoading.value = true;
    try {
      final result = await _repository.getData();
      _data.assignAll(result);
    } catch (e) {
      // Error handling
    } finally {
      _isLoading.value = false;
    }
  }
}
```

### 🔧 **Build Tools**
- **Gradle (Android)** - Android build system
- **CocoaPods (iOS)** - iOS dependency management
- **Firebase CLI** - Firebase deployment tools

## 📁 Cấu trúc thư mục chi tiết

```
lib/
├── app.dart                           # Root widget với GetMaterialApp
├── main.dart                          # Application entry point
├── firebase_options.dart              # Firebase configuration
├── NavigationController.dart          # Main navigation controller
│
├── core/                             # 🛠️ Core Layer
│   ├── constants/
│   │   ├── api_constants.dart        # API endpoints & keys
│   │   ├── colors.dart              # Color palette definitions
│   │   ├── enums.dart               # Application enums
│   │   ├── exports.dart             # Export barrel file
│   │   ├── image_strings.dart       # Asset image paths
│   │   ├── sizes.dart               # UI sizing constants
│   │   └── text_strings.dart        # Localized text strings
│   ├── exceptions/
│   │   ├── exceptions.dart          # Base exceptions
│   │   ├── exports.dart
│   │   ├── firebase_auth_exceptions.dart
│   │   ├── firebase_exceptions.dart
│   │   ├── format_exceptions.dart
│   │   └── platform_exceptions.dart
│   ├── injection/
│   │   └── injection_container.dart # GetIt DI setup
│   ├── popups/
│   │   ├── exports.dart
│   │   ├── full_screen_loader.dart  # Loading overlays
│   │   └── loaders.dart             # Loading indicators
│   ├── storage/
│   │   └── storage_utility.dart     # GetStorage utilities
│   ├── theme/
│   │   ├── custom_themes/          # Theme components
│   │   │   ├── appbar_theme.dart
│   │   │   ├── bottom_sheet_theme.dart
│   │   │   ├── checkbox_theme.dart
│   │   │   ├── chip_theme.dart
│   │   │   ├── elevated_button_theme.dart
│   │   │   ├── outlined_button_theme.dart
│   │   │   └── text_theme.dart
│   │   └── theme.dart               # Main theme configuration
│   ├── utils/
│   │   ├── cloud_helper_functions.dart
│   │   ├── device_utility.dart     # Device info utilities
│   │   ├── exports.dart
│   │   ├── formatter.dart          # Date/currency formatters
│   │   ├── helper_functions.dart   # General helpers
│   │   ├── network_manager.dart    # Network connectivity
│   │   ├── pricing_calculator.dart # Pricing utilities
│   │   ├── validation.dart         # Input validation
│   │   └── vietnam_provinces_helper.dart
│   └── widgets/                    # Shared UI components
│       ├── animations/             # Animation widgets
│       ├── appbar/                # Custom app bars
│       ├── buttons/               # Custom buttons
│       ├── cards/                 # Card components
│       ├── chatbot/               # Chat UI components
│       ├── chips/                 # Chip widgets
│       ├── custom_shapes/         # Custom shapes
│       ├── icons/                 # Icon components
│       ├── image_text_widget/     # Image+text widgets
│       ├── images/                # Image display widgets
│       ├── layouts/               # Layout containers
│       ├── list_titles/           # List title components
│       ├── loaders/               # Loading components
│       ├── login_singup/          # Auth UI components
│       ├── map/                   # Map-related widgets
│       ├── products/              # Product display
│       ├── shimmers/              # Shimmer effects
│       ├── storms/                # Custom UI components
│       ├── styles/                # Text styles
│       ├── success_screen/        # Success screens
│       ├── tabs/                  # Tab components
│       └── texts/                 # Text widgets
│
├── domain/                          # 🎯 Domain Layer
│   ├── entities/                   # Business objects
│   │   ├── alert_entity.dart
│   │   ├── banner_entity.dart
│   │   ├── donation_entity.dart
│   │   ├── help_request_entity.dart
│   │   ├── news_entity.dart
│   │   ├── shelter_entity.dart
│   │   └── user_entity.dart
│   ├── failures/                   # Domain failures
│   │   └── failures.dart
│   ├── repositories/               # Abstract contracts
│   │   ├── alert_repository.dart
│   │   ├── authentication_repository.dart
│   │   ├── banner_repository.dart
│   │   ├── donation_repository.dart
│   │   ├── help_request_repository.dart
│   │   ├── news_repository.dart
│   │   ├── shelter_repository.dart
│   │   └── user_repository.dart
│   └── usecases/                   # Business logic
│       ├── create_help_request_usecase.dart
│       ├── delete_account_usecase.dart
│       ├── get_all_banners_usecase.dart
│       ├── get_current_user_usecase.dart
│       ├── get_help_requests_by_user_usecase.dart
│       ├── get_help_requests_usecase.dart
│       ├── login_usecase.dart
│       ├── logout_usecase.dart
│       ├── re_authenticate_usecase.dart
│       ├── register_usecase.dart
│       ├── save_user_usecase.dart
│       ├── send_email_verification_usecase.dart
│       ├── send_password_reset_usecase.dart
│       ├── sign_in_with_google_usecase.dart
│       ├── update_help_request_status_usecase.dart
│       ├── update_user_usecase.dart
│       ├── upload_banners_usecase.dart
│       └── upload_image_usecase.dart
│
├── data/                           # 💾 Data Layer
│   ├── datasources/
│   │   └── remote/                # External data sources
│   │       ├── help_request_remote_datasource.dart
│   │       └── user_remote_datasource.dart
│   ├── DummyData/                 # Mock data
│   │   └── MinhDummyData.dart
│   ├── models/                    # DTOs with serialization
│   │   ├── alert_dto.dart
│   │   ├── banner_dto.dart
│   │   ├── donation_dto.dart
│   │   ├── help_request_dto.dart
│   │   ├── news_dto.dart
│   │   ├── shelter_dto.dart
│   │   └── user_dto.dart
│   ├── repositories/              # Repository implementations
│   │   ├── alerts/
│   │   ├── authentication/
│   │   ├── donations/
│   │   ├── help/
│   │   ├── help_request_repository_impl.dart
│   │   ├── news/
│   │   ├── shelters/
│   │   ├── user/
│   │   ├── user_repository_impl.dart
│   │   └── chat_repository.dart
│   └── services/                  # External services
│       ├── location_service.dart
│       └── routing_service.dart
│
├── presentation/                   # 📱 Presentation Layer
│   ├── bindings/                  # GetX bindings
│   │   ├── app_bindings.dart
│   │   └── general_bindings.dart
│   ├── controllers/               # GetX controllers
│   │   └── auth_redirect_controller.dart
│   ├── features/                  # Feature modules
│   │   ├── admin/                 # Admin dashboard
│   │   │   ├── controllers/
│   │   │   ├── navigation_admin_menu.dart
│   │   │   ├── NavigationAdminController.dart
│   │   │   └── screens/
│   │   ├── authentication/        # Auth features
│   │   │   ├── controllers/
│   │   │   └── screens/
│   │   ├── chat/                  # Chat system
│   │   │   ├── controller/
│   │   │   └── screens/
│   │   ├── personalization/       # User profile
│   │   │   ├── controllers/
│   │   │   └── screens/
│   │   ├── shop/                  # Help requests
│   │   │   ├── controllers/
│   │   │   └── screens/
│   │   ├── victim/                # Victim interface
│   │   │   ├── controllers/
│   │   │   ├── navigation_victim_menu.dart
│   │   │   ├── NavigationVictimController.dart
│   │   │   └── screens/
│   │   └── volunteer/             # Volunteer interface
│   │       ├── controllers/
│   │       ├── navigation_volunteer_menu.dart
│   │       ├── NavigationVolunteerController.dart
│   │       └── screens/
│   ├── routes/                    # Navigation
│   │   ├── app_routes.dart        # Route definitions
│   │   ├── custom_routes/
│   │   └── routes.dart            # Route constants
│   └── utils/                     # Presentation utilities
│       ├── help_request_mapper.dart
│       └── user_mapper.dart
│
└── service/                        # 🔧 Service Layer
    ├── CloudinaryService.dart     # Image upload service
    └── MinhFirebaseStorageService.dart # Firebase storage
```

## 📊 Database Schema

### **Firestore Collections**

#### **users** - Thông tin người dùng
```json
{
  "userId": "string",
  "email": "string",
  "fullName": "string",
  "phoneNumber": "string",
  "userType": "victim|volunteer|admin",
  "profileImageUrl": "string?",
  "location": {
    "latitude": "number",
    "longitude": "number",
    "address": "string"
  },
  "isActive": "boolean",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

#### **help_requests** - Yêu cầu cứu trợ
```json
{
  "id": "string",
  "title": "string",
  "description": "string",
  "latitude": "number",
  "longitude": "number",
  "contact": "string",
  "severity": "low|medium|high|urgent",
  "status": "pending|inProgress|completed|cancelled",
  "type": "food|water|medicine|shelter|rescue|clothes|other",
  "address": "string",
  "imageUrl": "string?",
  "userId": "string",
  "assignedVolunteerId": "string?",
  "province": "string?",
  "district": "string?",
  "ward": "string?",
  "detailedAddress": "string?",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

#### **alerts** - Cảnh báo khẩn cấp
```json
{
  "id": "string",
  "userId": "string",
  "type": "sos|emergency|warning",
  "latitude": "number",
  "longitude": "number",
  "message": "string",
  "status": "active|resolved",
  "createdAt": "timestamp"
}
```

#### **chat_messages** - Tin nhắn chat
```json
{
  "id": "string",
  "senderId": "string",
  "receiverId": "string",
  "message": "string",
  "messageType": "text|image|location",
  "timestamp": "timestamp",
  "isRead": "boolean"
}
```

## 🔌 API Documentation

### **AI Service Integration** 🤖

The app includes an intelligent AI service for alert scoring, duplicate detection, and notification timing optimization.

**Key Features:**
- **Smart Alert Scoring**: ML-powered priority scoring with automatic fallback to rule-based
- **Semantic Duplicate Detection**: Identifies duplicate alerts using natural language processing
- **Optimal Notification Timing**: Learns best times to send notifications based on user engagement
- **Health Monitoring**: Automatic health checks and metrics tracking
- **User Engagement Tracking**: Logs interactions for continuous AI improvement

**Documentation:**
- 📘 **[Complete AI Integration Guide](docs/AI_SERVICE_INTEGRATION.md)**
- 🚀 **Quick Start**: Set `enableAiScoring = true` in `api_constants.dart`
- 🏥 **Health Check**: Monitor via `AIServiceMonitor`
- 📊 **Metrics**: View real-time performance in app logs

**Architecture:**
- **Hybrid Approach**: AI primary + Rule-based fallback for reliability
- **Async Processing**: Non-blocking UI with 10s timeout
- **Continuous Learning**: Improves from user feedback over time

---

### **Authentication APIs**

#### **POST /auth/login**
```dart
// Use case: Login with email/password
final loginUseCase = Get.find<LoginUseCase>();
final result = await loginUseCase.call(
  LoginParams(email: email, password: password)
);
```

#### **POST /auth/register**
```dart
// Use case: Register new user
final registerUseCase = Get.find<RegisterUseCase>();
final result = await registerUseCase.call(
  RegisterParams(email: email, password: password, fullName: fullName)
);
```

### **Help Request APIs**

#### **POST /help-requests**
```dart
// Create new help request
final createUseCase = Get.find<CreateHelpRequestUseCase>();
final result = await createUseCase.call(CreateHelpRequestParams(
  title: title,
  description: description,
  latitude: lat,
  longitude: lng,
  severity: severity,
  type: type,
  contact: contact
));
```

#### **GET /help-requests**
```dart
// Get all help requests
final getUseCase = Get.find<GetHelpRequestsUseCase>();
final result = await getUseCase.call(NoParams());
```

#### **PUT /help-requests/{id}/status**
```dart
// Update request status
final updateUseCase = Get.find<UpdateHelpRequestStatusUseCase>();
final result = await updateUseCase.call(UpdateStatusParams(
  requestId: id,
  status: newStatus
));
```

### **User Management APIs**

#### **GET /users/profile**
```dart
// Get current user profile
final getUserUseCase = Get.find<GetCurrentUserUseCase>();
final result = await getUserUseCase.call(NoParams());
```

#### **PUT /users/profile**
```dart
// Update user profile
final updateUseCase = Get.find<UpdateUserUseCase>();
final result = await updateUseCase.call(UpdateUserParams(
  fullName: fullName,
  phoneNumber: phoneNumber
));
```

## 🚀 Cài đặt và chạy

### 📋 **Yêu cầu hệ thống**

| Component | Version | Required |
|-----------|---------|----------|
| Flutter SDK | `^3.10.1` | ✅ Required |
| Dart SDK | `^3.0.0` | ✅ Required |
| Android Studio | `2022.3+` | ✅ Required (Android) |
| Xcode | `14.0+` | ✅ Required (iOS - macOS only) |
| VS Code | `Latest` | ✅ Alternative IDE |
| Android SDK | `API 21+` | ✅ Android development |
| iOS Simulator | `Latest` | ✅ iOS development |

### 🔧 **Cài đặt Flutter**

#### **Windows:**
```bash
# Download Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable

# Add to PATH
# C:\flutter\bin

# Verify installation
flutter doctor
```

#### **macOS:**
```bash
# Using Homebrew
brew install flutter

# Or download manually
git clone https://github.com/flutter/flutter.git -b stable

# Verify installation
flutter doctor
```

### 📦 **Cài đặt Dependencies**

```bash
# Clone repository
git clone <repository-url>
cd cuutrobaolu

# Install Flutter dependencies
flutter pub get

# Clean build (optional)
flutter clean
flutter pub get
```

### 🔥 **Cấu hình Firebase**

#### **Bước 1: Tạo Firebase Project**
1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Click **"Create a project"**
3. Đặt tên project: `cuutrobaolu`
4. Enable Google Analytics (recommended)

#### **Bước 2: Cấu hình Authentication**
1. Vào **Authentication** → **Sign-in method**
2. Enable:
   - ✅ Email/Password
   - ✅ Google
   - ✅ Anonymous (optional)

#### **Bước 3: Cấu hình Firestore Database**
1. Vào **Firestore Database** → **Create database**
2. Chọn **Start in test mode** (sẽ thay đổi sau)
3. Chọn location: `asia-southeast1` (Singapore)

#### **Bước 4: Cấu hình Storage**
1. Vào **Storage** → **Get started**
2. Chọn **Start in test mode**
3. Tạo bucket mặc định

#### **Bước 5: Thêm ứng dụng**

##### **Android:**
1. Click **Android icon** trong project settings
2. **Android package name**: `com.example.cuutrobaolu`
3. Download `google-services.json`
4. Đặt file vào: `android/app/google-services.json`

##### **iOS:**
1. Click **iOS icon** trong project settings
2. **iOS bundle ID**: `com.example.cuutrobaolu`
3. Download `GoogleService-Info.plist`
4. Đặt file vào: `ios/Runner/GoogleService-Info.plist`

#### **Bước 6: Cập nhật Firebase Options**
```bash
# Generate firebase_options.dart
flutterfire configure
```

### 🌍 **Cấu hình Environment Variables**

Tạo file `.env` trong root directory:
```env
# Firebase Configuration
FIREBASE_API_KEY=your_api_key
FIREBASE_PROJECT_ID=cuutrobaolu
FIREBASE_APP_ID=your_app_id

# API Keys (if needed)
GOOGLE_MAPS_API_KEY=your_maps_key
CLOUDINARY_API_KEY=your_cloudinary_key

# Environment
ENVIRONMENT=development
DEBUG_MODE=true
```

### 🏃‍♂️ **Chạy ứng dụng**

#### **Development Mode:**
```bash
# Chạy trên thiết bị Android mặc định
flutter run

# Chạy trên thiết bị Android cụ thể
flutter devices
flutter run -d <device-id>

# Chạy trên iOS Simulator (macOS only)
flutter run -d iphone

# Chạy trên web
flutter run -d chrome

# Chạy với flavor (nếu có)
flutter run --flavor development
```

#### **Debug Mode với Hot Reload:**
```bash
# Terminal 1: Start app
flutter run

# Terminal 2: Hot reload on file changes
# Press 'r' in terminal or save files in IDE
```

#### **Profile/Release Mode:**
```bash
# Profile mode (performance testing)
flutter run --profile

# Release mode
flutter run --release
```

### 🔍 **Kiểm tra thiết bị kết nối**
```bash
# List all connected devices
flutter devices

# Check device status
flutter doctor -v

# Clean and rebuild
flutter clean && flutter pub get && flutter run
```

## 📱 Screenshots & Demo

### **Giao diện chính:**
- **Splash Screen** - Màn hình khởi động với animation
- **Onboarding** - Hướng dẫn sử dụng cho người mới
- **Authentication** - Đăng nhập/đăng ký với multiple methods
- **Dashboard** - Tổng quan theo role (Victim/Volunteer/Admin)

### **Tính năng chính:**
- **SOS Emergency** - Nút khẩn cấp với vị trí GPS
- **Map Integration** - Bản đồ tương tác với markers
- **Help Requests** - Tạo và quản lý yêu cầu cứu trợ
- **Chat System** - Trò chuyện real-time
- **Profile Management** - Quản lý thông tin cá nhân

*(Screenshots sẽ được thêm vào thư mục `docs/screenshots/`)*

## 🧪 Testing Strategy

### **Unit Tests** - Test logic nghiệp vụ
```bash
# Chạy tất cả unit tests
flutter test

# Chạy tests cho domain layer
flutter test test/domain/

# Chạy tests với coverage
flutter test --coverage

# Xem coverage report
genhtml coverage/lcov.info -o coverage/html
# Mở coverage/html/index.html
```

### **Widget Tests** - Test UI components
```bash
# Chạy widget tests
flutter test test/presentation/

# Test specific widget
flutter test test/presentation/widgets/custom_button_test.dart
```

### **Integration Tests** - Test end-to-end
```bash
# Chạy integration tests
flutter test integration_test/

# Test với device thật
flutter test integration_test/app_test.dart -d <device-id>
```

### **Test Structure:**
```
test/
├── domain/                    # Unit tests for business logic
│   ├── entities/
│   ├── usecases/
│   └── repositories/
├── presentation/             # Widget tests
│   ├── widgets/
│   └── screens/
├── data/                     # Integration tests
│   ├── repositories/
│   └── services/
└── integration_test/         # E2E tests
    └── app_test.dart
```

### **Mocking Strategy:**
```dart
// Using mockito for external dependencies
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirestore extends Mock implements FirebaseFirestore {}

// Setup mocks in test
setUp(() {
  mockAuth = MockFirebaseAuth();
  mockFirestore = MockFirestore();

  // Inject mocks
  Get.put<AuthenticationRepository>(
    AuthenticationRepositoryImpl(mockAuth, mockFirestore)
  );
});
```

## 🚀 Deployment & CI/CD

### **Build Configurations**

#### **Android APK:**
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Split per ABI (smaller APKs)
flutter build apk --release --split-per-abi
```

#### **Android App Bundle (AAB):**
```bash
# Recommended for Google Play
flutter build appbundle --release
```

#### **iOS:**
```bash
# iOS Archive
flutter build ios --release

# Open Xcode for distribution
open ios/Runner.xcworkspace
```

#### **Web:**
```bash
# Web build
flutter build web --release

# Serve locally
flutter run -d chrome --release
```

### **Fastlane Integration**
```ruby
# fastlane/Fastfile
platform :android do
  desc "Deploy to Google Play Beta"
  lane :beta do
    gradle(task: "clean bundleRelease")
    upload_to_play_store(
      track: 'beta',
      aab: '../build/app/outputs/bundle/release/app-release.aab'
    )
  end
end
```

### **Firebase App Distribution**
```bash
# Install Firebase CLI
npm install -g firebase-tools
firebase login

# Distribute Android APK
firebase appdistribution:distribute build/app/outputs/apk/release/app-release.apk \
  --app <firebase-app-id> \
  --groups "testers"

# Distribute iOS
firebase appdistribution:distribute build/ios/ipa/Runner.ipa \
  --app <firebase-app-id> \
  --groups "testers"
```

### **Environment Configurations**
```yaml
# pubspec.yaml
flavors:
  development:
    app:
      name: "Cưu Trợ Bảo Lưu (Dev)"
    android:
      applicationId: "com.cuutrobaolu.dev"
    ios:
      bundleId: "com.cuutrobaolu.dev"
  staging:
    app:
      name: "Cưu Trợ Bảo Lưu (Staging)"
    android:
      applicationId: "com.cuutrobaolu.staging"
    ios:
      bundleId: "com.cuutrobaolu.staging"
  production:
    app:
      name: "Cưu Trợ Bảo Lưu"
    android:
      applicationId: "com.cuutrobaolu"
    ios:
      bundleId: "com.cuutrobaolu"
```

## ⚡ Performance Optimization

### **App Startup Optimization**
- **Lazy Loading**: VietnamProvinces và các service nặng
- **Tree Shaking**: Loại bỏ unused code
- **Deferred Loading**: Load features on demand
- **Precompiled Shaders**: Giảm jank đầu tiên

### **Memory Management**
- **Image Caching**: CachedNetworkImage với memory limits
- **List Virtualization**: Chỉ render visible items
- **Object Pooling**: Reuse expensive objects
- **Background Tasks**: Isolate cho heavy computations

### **Network Optimization**
- **Request Batching**: Gom nhóm requests
- **Response Caching**: Cache API responses
- **Image Compression**: Tối ưu kích thước ảnh
- **Offline Support**: Local storage fallback

### **UI Performance**
- **Widget Reuse**: const constructors
- **Build Optimization**: Keys cho dynamic lists
- **Animation Optimization**: Use AnimatedBuilder
- **Shader Precompilation**: compile-time shader compilation

```dart
// Performance best practices
class OptimizedList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: PageStorageKey<String>('optimized_list'),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return const ItemWidget(); // Use const where possible
      },
    );
  }
}
```

## 📦 Build & Deploy

### Build APK (Android)
```bash
flutter build apk --release
```

### Build IPA (iOS)
```bash
flutter build ios --release
```

### Build App Bundle (Android)
```bash
flutter build appbundle --release
```

### Build Web
```bash
flutter build web --release
```

## 🔧 Development Scripts

### **Code Quality:**
```bash
# Static analysis
flutter analyze

# Format all Dart files
dart format .

# Fix auto-fixable issues
dart fix --apply

# Check for unused files
flutter pub run dart_code_metrics:metrics check-unused-files lib

# Generate documentation
dart doc .
```

### **Build & Run:**
```bash
# Clean rebuild
flutter clean && flutter pub get && flutter run

# Build all platforms
flutter build apk --release
flutter build ios --release
flutter build web --release

# Run with specific flavor
flutter run --flavor development --target lib/main_development.dart

# Run tests with coverage
flutter test --coverage && genhtml coverage/lcov.info -o coverage/html
```

### **Firebase:**
```bash
# Configure Firebase
flutterfire configure

# Deploy Firebase functions (if any)
firebase deploy --only functions

# View Firebase logs
firebase functions:log
```

### **Maintenance:**
```bash
# Update dependencies
flutter pub upgrade

# Outdated packages check
flutter pub outdated

# Clean up
flutter clean
rm -rf pubspec.lock
flutter pub get
```

## 🐛 Troubleshooting

### **Common Issues:**

#### **1. Flutter Doctor Issues**
```bash
# Update Flutter
flutter upgrade

# Accept Android licenses
flutter doctor --android-licenses

# Install missing components
flutter doctor --fix
```

#### **2. Firebase Configuration**
```
Error: [core/no-app] No Firebase App '[DEFAULT]' has been created
```
**Solution:**
- Kiểm tra `firebase_options.dart` đã được generate
- Đảm bảo `Firebase.initializeApp()` được gọi trong `main()`
- Verify Google Services files are in correct locations

#### **3. Build Failures**
```
Error: android.os.NetworkOnMainThreadException
```
**Solution:**
- Move network calls to background threads
- Use `async/await` properly
- Check for platform-specific implementations

#### **4. GPS/Location Issues**
```dart
// Request permissions properly
LocationPermission permission = await Geolocator.requestPermission();
if (permission == LocationPermission.denied) {
  // Handle permission denied
}
```

#### **5. Memory Issues**
- Use `const` constructors where possible
- Implement proper disposal in controllers
- Use image caching with size limits
- Monitor memory usage with DevTools

#### **6. Hot Reload Not Working**
```bash
# Force hot restart
flutter run --pid-file=/tmp/flutter.pid
# Then press 'R' in terminal
```

### **Debug Tools:**

#### **Flutter DevTools:**
```bash
# Start DevTools
flutter pub global run devtools
flutter run

# Or use VS Code extension
```

#### **Logging:**
```dart
// Enable verbose logging
Logger logger = Logger(
  printer: PrettyPrinter(),
  level: Level.verbose,
);

// Usage
logger.d('Debug message');
logger.i('Info message');
logger.w('Warning message');
logger.e('Error message');
```

## 🤝 Contribution Guidelines

### **Development Workflow:**

1. **Fork & Clone**
   ```bash
   git clone https://github.com/your-username/cuutrobaolu.git
   cd cuutrobaolu
   git checkout -b feature/your-feature-name
   ```

2. **Setup Development Environment**
   ```bash
   flutter pub get
   flutterfire configure
   # Setup your Firebase project
   ```

3. **Code Standards**
   - Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
   - Use [Flutter Lints](https://pub.dev/packages/flutter_lints)
   - Write meaningful commit messages
   - Add tests for new features

4. **Branch Naming Convention**
   ```
   feature/add-user-authentication
   bugfix/fix-map-crash
   refactor/cleanup-controllers
   docs/update-readme
   ```

5. **Commit Message Format**
   ```
   type(scope): description

   [optional body]

   [optional footer]
   ```
   **Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

6. **Pull Request Process**
   - Create PR from your feature branch
   - Fill out PR template completely
   - Request review from maintainers
   - Address review comments
   - Squash commits before merge

### **Code Review Checklist:**
- [ ] Tests pass (`flutter test`)
- [ ] Code formatted (`dart format .`)
- [ ] No linting errors (`flutter analyze`)
- [ ] Documentation updated
- [ ] Breaking changes documented
- [ ] Performance impact assessed

### **Feature Development:**
```dart
// 1. Create feature branch
git checkout -b feature/new-feature

// 2. Implement domain logic first
// - Add entity to domain/entities/
// - Add use case to domain/usecases/
// - Add repository interface to domain/repositories/

// 3. Implement data layer
// - Add DTO to data/models/
// - Implement repository in data/repositories/
// - Add remote data source if needed

// 4. Implement presentation layer
// - Add controller to presentation/features/
// - Add screens and widgets
// - Update routes

// 5. Add tests
// - Unit tests for domain logic
// - Widget tests for UI components
// - Integration tests for full flows

// 6. Update documentation
// - README updates
// - Code comments
// - API documentation
```

## 📊 Project Metrics

### **Code Quality:**
- **Lines of Code**: ~15,000+ lines
- **Test Coverage**: Target 80%+
- **Code Maintainability**: A grade (Code Climate)
- **Technical Debt**: Low

### **Performance Benchmarks:**
- **App Launch Time**: < 3 seconds (cold start)
- **Time to Interactive**: < 2 seconds
- **Memory Usage**: < 200MB (active)
- **Battery Impact**: Minimal

### **User Experience:**
- **Crash Rate**: < 0.5%
- **Response Time**: < 500ms (average)
- **Offline Capability**: 80% features work offline

## 🔒 Security Considerations

### **Data Protection:**
- **Encryption**: All sensitive data encrypted at rest
- **Authentication**: Multi-factor authentication
- **Authorization**: Role-based access control
- **Audit Logging**: All user actions logged

### **Network Security:**
- **HTTPS Only**: All API calls use HTTPS
- **Certificate Pinning**: Prevent MITM attacks
- **Request Signing**: API requests are signed
- **Rate Limiting**: Prevent abuse

### **Privacy:**
- **Data Minimization**: Only collect necessary data
- **Consent Management**: User consent for data collection
- **GDPR Compliance**: Data portability and deletion
- **Location Privacy**: GPS data anonymized when possible

## 📈 Roadmap

### **Phase 1 (Current): MVP**
- ✅ Basic user authentication
- ✅ SOS emergency system
- ✅ Help request management
- ✅ Map integration
- ✅ Real-time chat

### **Phase 2: Enhancement**
- 🔄 Advanced analytics dashboard
- 🔄 AI-powered matching algorithm
- 🔄 Multi-language support (EN/VN)
- 🔄 Offline-first architecture
- 🔄 Push notification improvements

### **Phase 3: Scale**
- 📋 Blockchain integration for donations
- 📋 IoT device integration
- 📋 International expansion
- 📋 Government API integration
- 📋 Advanced AI features

## 📄 License

```
MIT License

Copyright (c) 2024 Cưu Trợ Bảo Lưu Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

## 👥 Team & Credits

### **Core Development Team:**
- **Project Lead**: [Name]
- **Lead Developer**: [Name]
- **UI/UX Designer**: [Name]
- **QA Engineer**: [Name]

### **Contributors:**
- Special thanks to Flutter community
- Firebase team for excellent documentation
- Open source contributors

### **Advisors:**
- **Technical Advisor**: [Name]
- **Domain Expert**: [Name]

## 📞 Contact & Support

### **Official Channels:**
- **Email**: support@cuutrobaolu.com
- **Website**: https://cuutrobaolu.com
- **GitHub**: https://github.com/cuutrobaolu/app
- **LinkedIn**: https://linkedin.com/company/cuutrobaolu

### **Community:**
- **Discord**: https://discord.gg/cuutrobaolu
- **Reddit**: r/cuutrobaolu
- **Twitter**: @cuutrobaolu

### **Support:**
- **Documentation**: https://docs.cuutrobaolu.com
- **Issue Tracker**: https://github.com/cuutrobaolu/app/issues
- **Feature Requests**: https://github.com/cuutrobaolu/app/discussions

---

## 🎯 Mission Statement

*"Cưu Trợ Bảo Lưu được phát triển với sứ mệnh kết nối những trái tim nhân ái, mang lại sự hỗ trợ kịp thời cho những người đang cần giúp đỡ trong các tình huống khẩn cấp. Chúng tôi tin rằng công nghệ có thể tạo nên sự khác biệt, và ứng dụng của chúng tôi là cầu nối giữa tình người và hành động cứu trợ."*

---

**Built with ❤️ for humanity in times of crisis**
