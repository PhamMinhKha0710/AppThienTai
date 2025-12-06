# ⚠️ CÁC TASK CÒN THIẾU - CLEAN ARCHITECTURE MIGRATION

## 📋 TỔNG QUAN

**Tỷ lệ hoàn thành: ~85%** (thay vì 95% như đã nghĩ)

Còn **3 controllers** và **2 repositories** chưa được migrate sang Clean Architecture.

---

## ❌ CÒN THIẾU (15%)

### 1. **BannerRepository** - Chưa có Clean Architecture

#### Controllers đang dùng trực tiếp:
- ✅ `lib/presentation/features/shop/controllers/banner_controller.dart`
  - Dùng `BannerRepository` trực tiếp
  - Methods: `getAllBanner()`, `uploadDummyDataCloudinary()`

#### Cần làm:
1. ✅ Tạo Domain Interface: `domain/repositories/banner_repository.dart`
2. ✅ Tạo Use Cases:
   - `GetAllBannersUseCase`
   - `UploadBannerUseCase`
3. ✅ Refactor `BannerController` để dùng Use Cases
4. ✅ Update `AppBindings` với Banner Use Cases

---

### 2. **HelpRequestRepository** - Chưa có Clean Architecture

#### Controllers đang dùng trực tiếp:
- ✅ `lib/presentation/features/shop/controllers/create_request_controller.dart`
  - Dùng `HelpRequestRepository` trực tiếp
  - Method: `createHelpRequest()`

#### Cần làm:
1. ✅ Tạo Domain Interface: `domain/repositories/help_request_repository.dart`
2. ✅ Tạo Use Cases:
   - `CreateHelpRequestUseCase`
   - `GetHelpRequestsUseCase`
   - `UpdateHelpRequestStatusUseCase`
3. ✅ Refactor `CreateRequestController` để dùng Use Cases
4. ✅ Update `AppBindings` với HelpRequest Use Cases

---

### 3. **InMemoryHelpRepository** - Chưa có Clean Architecture

#### Controllers đang dùng trực tiếp:
- ✅ `lib/presentation/features/admin/controllers/help_controller.dart`
  - Dùng `InMemoryHelpRepository` trực tiếp
  - Methods: `fetchHelpRequest()`, `fetchHelpRequestForCurrentUser()`, `reserveSupporter()`, `updateHelpStatus()`, `streamHelpRequests()`, `streamSupporters()`

#### Cần làm:
1. ✅ Tạo Domain Interface cho Help Repository (có thể dùng chung với HelpRequestRepository)
2. ✅ Tạo Use Cases:
   - `GetAllHelpRequestsUseCase`
   - `GetHelpRequestsForCurrentUserUseCase`
   - `ReserveSupporterUseCase`
   - `UpdateHelpRequestStatusUseCase`
   - `StreamHelpRequestsUseCase`
   - `StreamSupportersUseCase`
3. ✅ Refactor `HelpController` để dùng Use Cases
4. ✅ Update `AppBindings` với Help Use Cases

---

### 4. **Main.dart** - Vẫn dùng Adapter

#### File:
- ✅ `lib/main.dart`
  - Vẫn tạo `AuthenticationRepositoryAdapter` để tương thích
  - Có thể xóa sau khi đảm bảo không còn code nào dùng adapter

#### Cần làm:
1. ✅ Kiểm tra xem còn code nào dùng `AuthenticationRepositoryAdapter` không
2. ✅ Nếu không còn, xóa adapter khỏi `main.dart`
3. ✅ Xóa file `authentication_repository_adapter.dart` nếu không còn dùng

---

### 5. **Legacy Repositories** - Có thể xóa sau khi migrate xong

#### Files:
- ⚠️ `lib/data/repositories/authentication/authentication_repository.dart` - Legacy GetX Controller
- ⚠️ `lib/data/repositories/user/user_repository.dart` - Legacy GetX Controller
- ⚠️ `lib/data/repositories/authentication/authentication_repository_adapter.dart` - Adapter (nếu không còn dùng)

#### Cần làm:
1. ✅ Đảm bảo không còn code nào dùng legacy repositories
2. ✅ Xóa các file legacy sau khi test kỹ

---

## 📊 THỐNG KÊ

### Controllers đã migrate (7/10 = 70%):
- ✅ LoginController
- ✅ SignupController
- ✅ VerifyEmailController
- ✅ ForgetPasswordController
- ✅ UserController
- ✅ UpdateNameController
- ✅ AuthRedirectController

### Controllers chưa migrate (3/10 = 30%):
- ❌ BannerController
- ❌ CreateRequestController
- ❌ HelpController

### Repositories đã có Clean Architecture (2/5 = 40%):
- ✅ AuthenticationRepository
- ✅ UserRepository

### Repositories chưa có Clean Architecture (3/5 = 60%):
- ❌ BannerRepository
- ❌ HelpRequestRepository
- ❌ InMemoryHelpRepository

---

## 🎯 KẾ HOẠCH HOÀN THÀNH

### Bước 1: BannerRepository Migration
1. Tạo `domain/repositories/banner_repository.dart`
2. Tạo `domain/usecases/get_all_banners_usecase.dart`
3. Tạo `domain/usecases/upload_banner_usecase.dart`
4. Refactor `BannerController`
5. Update `AppBindings`

### Bước 2: HelpRequestRepository Migration
1. Tạo `domain/repositories/help_request_repository.dart`
2. Tạo các Use Cases cần thiết
3. Refactor `CreateRequestController`
4. Update `AppBindings`

### Bước 3: InMemoryHelpRepository Migration
1. Tạo Domain Interface (hoặc extend HelpRequestRepository)
2. Tạo các Use Cases cần thiết
3. Refactor `HelpController`
4. Update `AppBindings`

### Bước 4: Cleanup
1. Kiểm tra và xóa adapter trong `main.dart`
2. Xóa legacy repositories
3. Test toàn bộ ứng dụng

---

## ⏱️ ƯỚC TÍNH THỜI GIAN

- **BannerRepository**: ~30 phút
- **HelpRequestRepository**: ~45 phút
- **InMemoryHelpRepository**: ~45 phút
- **Cleanup**: ~15 phút

**Tổng cộng: ~2-3 giờ** để hoàn thành 100% migration.

---

## ✅ SAU KHI HOÀN THÀNH

Khi hoàn thành tất cả các task trên, codebase sẽ:
- ✅ 100% tuân theo Clean Architecture
- ✅ Tất cả controllers dùng Use Cases
- ✅ Không còn legacy code
- ✅ Dễ dàng test và maintain
- ✅ Sẵn sàng cho production

