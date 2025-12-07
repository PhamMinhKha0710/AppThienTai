# Data Layer

Layer này chịu trách nhiệm lấy dữ liệu từ các nguồn (Firebase, API, Local Storage) và implement repository interfaces từ domain layer.

## Cấu trúc:

- **datasources/** - Data sources (remote, local)
  - **remote/** - Firebase, API calls
  - **local/** - Local storage, cache
- **models/** - DTOs (Data Transfer Objects) với toJson/fromJson
- **repositories/** - Repository implementations
- **mappers/** - Mappers giữa DTOs và Entities

## Nguyên tắc:
- Implement repository interfaces từ domain layer
- Models ở đây là DTOs, có thể khác với entities
- Xử lý exception mapping (từ Firebase/API exceptions sang domain failures)



