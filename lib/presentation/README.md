# Presentation Layer

Layer này chứa UI và logic trình bày, phụ thuộc vào domain layer.

## Cấu trúc:

- **features/** - Các feature modules
  - **{feature_name}/**
    - **controllers/** - GetX controllers
    - **screens/** - UI screens
    - **widgets/** - Feature-specific widgets
    - **bindings/** - GetX bindings
- **routes/** - Navigation routes
- **theme/** - Theme overrides (nếu cần)

## Nguyên tắc:
- Controllers gọi use cases từ domain layer
- Không gọi trực tiếp repositories
- Screens chỉ phụ thuộc vào controllers
- Widgets có thể reusable hoặc feature-specific







