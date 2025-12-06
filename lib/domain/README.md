# Domain Layer

Layer này chứa business logic thuần túy, không phụ thuộc vào framework hay external libraries.

## Cấu trúc:

- **entities/** - Business entities (pure Dart classes)
- **repositories/** - Repository interfaces (abstract classes)
- **usecases/** - Use cases (business logic)
- **failures/** - Domain-specific failures

## Nguyên tắc:
- Không import Flutter, Firebase, GetX, hoặc bất kỳ external package nào
- Chỉ chứa business logic thuần túy
- Entities không có methods toJson/fromJson (chuyển sang DTO ở data layer)

