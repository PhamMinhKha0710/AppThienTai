# 05. HƯỚNG DẪN TRIỂN KHAI (DEPLOYMENT)

---

## MỤC LỤC

- [5.1. Yêu cầu Môi trường](#51-yêu-cầu-môi-trường)
- [5.2. Cài đặt Development](#52-cài-đặt-development)
- [5.3. Cài đặt Production](#53-cài-đặt-production)
- [5.4. CI/CD Pipeline](#54-cicd-pipeline)
- [5.5. Troubleshooting Deployment](#55-troubleshooting-deployment)

---

## 5.1. YÊU CẦU MÔI TRƯỜNG

### 5.1.1. Development Environment

**Máy tính phát triển:**

| Component | Requirement | Recommended |
|-----------|-------------|-------------|
| **OS** | Windows 10+, macOS 10.15+, Ubuntu 20.04+ | macOS/Linux |
| **RAM** | 8GB minimum | 16GB+ |
| **Storage** | 20GB free | SSD 50GB+ |
| **Network** | Stable internet | Fiber/4G |

**Software Requirements:**

```bash
# Flutter SDK
Flutter 3.24.0 or higher
Dart SDK 3.5.0 or higher

# IDE (chọn 1)
- Android Studio 2023.1+ (recommended)
- Visual Studio Code 1.80+ với Flutter extension
- IntelliJ IDEA

# Mobile Development
- Android SDK 30+
- Xcode 15+ (for iOS, macOS only)

# Version Control
Git 2.30+

# AI Service (Optional)
Python 3.9+
pip 23+
```

### 5.1.2. Production Environment

**Mobile App:**
- Google Play Store account (Android)
- Apple Developer account (iOS)
- Firebase Blaze plan (Pay-as-you-go)

**AI Service:**
- Cloud platform: Railway/Render/Heroku/GCP
- Memory: 2GB minimum
- CPU: 1 vCPU minimum
- Storage: 5GB

---

## 5.2. CÀI ĐẶT DEVELOPMENT

### 5.2.1. Bước 1: Cài đặt Flutter SDK

**Windows:**

```powershell
# Download Flutter SDK
# https://docs.flutter.dev/get-started/install/windows

# Giải nén vào C:\src\flutter
# Thêm vào PATH: C:\src\flutter\bin

# Verify
flutter doctor
```

**macOS/Linux:**

```bash
# Download
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable

# Add to PATH
export PATH="$PATH:$HOME/development/flutter/bin"

# Add to ~/.bashrc or ~/.zshrc
echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.bashrc

# Verify
flutter doctor
```

**Fix issues từ `flutter doctor`:**

```bash
# Android licenses
flutter doctor --android-licenses

# Install missing components
# Follow prompts from flutter doctor
```

---

### 5.2.2. Bước 2: Clone Repository

```bash
# Clone via HTTPS
git clone https://github.com/PhamMinhKha0710/AppThienTai.git
cd AppThienTai

# Hoặc via SSH (nếu đã setup SSH key)
git clone git@github.com:PhamMinhKha0710/AppThienTai.git
cd AppThienTai

# Checkout branch development (nếu có)
git checkout develop
```

---

### 5.2.3. Bước 3: Cấu hình Firebase

**3.1. Android Configuration:**

```bash
# Download google-services.json từ Firebase Console
# Firebase Console > Project Settings > Your apps > Android app

# Copy file vào:
android/app/google-services.json
```

**Xác nhận `android/app/build.gradle`:**

```gradle
dependencies {
    // Firebase
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-analytics'
    ...
}

apply plugin: 'com.google.gms.google-services'
```

**3.2. iOS Configuration (macOS only):**

```bash
# Download GoogleService-Info.plist từ Firebase Console

# Copy file vào:
ios/Runner/GoogleService-Info.plist

# Open Xcode
open ios/Runner.xcworkspace

# Trong Xcode: Add GoogleService-Info.plist to Runner target
```

---

###5.2.4. Bước 4: Install Dependencies

```bash
# Flutter dependencies
flutter pub get

# Verify no errors
flutter pub upgrade
flutter pub outdated
```

**File `pubspec.yaml` chính:**

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  get: ^4.6.6
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  firebase_storage: ^11.6.0
  firebase_messaging: ^14.7.10
  
  # Map
  flutter_map: ^6.1.0
  latlong2: ^0.9.0
  
  # Location
  geolocator: ^10.1.0
  geocoding: ^2.1.1
  
  # UI
  iconsax: ^0.0.8
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  
  # HTTP
  dio: ^5.4.0
  
  # Others
  image_picker: ^1.0.7
  intl: ^0.18.1
  url_launcher: ^6.2.2
```

---

### 5.2.5. Bước 5: Chạy App

**Kiểm tra devices:**

```bash
flutter devices
```

**Chạy trên emulator/device:**

```bash
#Android
flutter run

# iOS (macOS only)
flutter run

# Chọn device nếu có nhiều
flutter run -d <device-id>

# Run với flavor (nếu có)
flutter run --flavor dev -t lib/main_dev.dart
```

**Hot Reload & Hot Restart:**

```bash
# Trong terminal đang chạy app:
r   # Hot reload (giữ state)
R   # Hot restart (reset state)
q   # Quit
```

---

### 5.2.6. Bước 6: Setup AI Service (Optional)

```bash
cd ai_service

# Create virtual environment
python -m venv venv

# Activate
# Windows:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Train model (first time only)
python train_hazard_model.py

# Run server
python main.py

# Test
curl http://localhost:8000/api/v1/health
```

**Update AI service URL trong app:**

```dart
// lib/data/services/ai_service.dart
class AIService {
  static const baseUrl = 'http://localhost:8000';  // Dev
  // static const baseUrl = 'https://your-ai-service.railway.app';  // Prod
}
```

---

### 5.2.7. Bước 7: Verify Setup

**Checklist:**

- [ ] `flutter doctor` không có lỗi nghiêm trọng
- [ ] App build thành công
- [ ] Firebase connected (check logs)
- [ ] Google Sign-in hoạt động
- [ ] Firestore read/write OK
- [ ] Map hiển thị
- [ ] GPS hoạt động
- [ ] AI service response (nếu đã setup)

**Test app:**

1. Đăng ký tài khoản mới
2. Đăng nhập
3. Gửi SOS test
4. Xem bản đồ
5. Kiểm tra notifications

---

## 5.3. CÀI ĐẶT PRODUCTION

### 5.3.1. Build Android APK/AAB

**Build APK (for testing):**

```bash
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

**Build AAB (App Bundle - for Play Store):**

```bash
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

**Signing Config:**

Tạo `android/key.properties`:

```properties
storePassword=<your-keystore-password>
keyPassword=<your-key-password>
keyAlias=upload
storeFile=<path-to-keystore-file>
```

Update `android/app/build.gradle`:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

---

### 5.3.2. Build iOS IPA (macOS only)

```bash
# Build
flutter build ios --release

# Open Xcode
open ios/Runner.xcworkspace

# In Xcode:
# 1. Select "Any iOS Device (arm64)"
# 2. Product > Archive
# 3. Distribute App > App Store Connect
# 4. Upload
```

**Signing:**

- Cần Apple Developer account ($99/year)
- Configure signing trong Xcode
- Upload to App Store Connect
- Submit for review

---

### 5.3.3. Deploy AI Service

#### Option 1: Railway (Recommended)

**Bước 1: Tạo `railway.toml`**

```toml
[build]
builder = "nixpacks"
buildCommand = "pip install -r requirements.txt && python train_hazard_model.py"

[deploy]
startCommand = "uvicorn main:app --host 0.0.0.0 --port $PORT"
healthcheckPath = "/api/v1/health"
healthcheckTimeout = 30
restartPolicyType = "on_failure"
```

**Bước 2: Deploy**

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# Initialize
cd ai_service
railway init

# Deploy
railway up

# Get URL
railway domain
# Example: https://apptthientai-ai-production.up.railway.app
```

**Bước 3: Set Environment Variables**

```bash
railway variables set API_HOST=0.0.0.0
railway variables set API_PORT=$PORT
```

#### Option 2: Docker + Any Cloud

**Dockerfile đã có sẵn:**

```dockerfile
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Train model
RUN python train_hazard_model.py

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

**Build & Deploy:**

```bash
# Build image
docker build -t apptthientai-ai .

# Run locally
docker run -p 8000:8000 apptthientai-ai

# Push to Docker Hub
docker tag apptthientai-ai your-dockerhub/apptthientai-ai
docker push your-dockerhub/apptthientai-ai

# Deploy to cloud (GCP/AWS/Azure)
# Follow cloud-specific docs
```

---

### 5.3.4. Update Production Firebase Config

**Firestore Security Rules:**

```bash
# Deploy rules
firebase deploy --only firestore:rules

# Test rules
firebase emulators:start --only firestore
```

**Storage Rules:**

```bash
firebase deploy --only storage
```

**Indexes:**

Indexes được tạo tự động khi query lỗi. Hoặc deploy thủ công:

```bash
firebase deploy --only firestore:indexes
```

---

### 5.3.5. Environment-specific Config

**Tạo flavors (optional):**

**`lib/main_dev.dart`:**

```dart
import 'package:flutter/material.dart';
import 'main.dart';

void main() {
  const environment = Environment.dev;
  runApp(MyApp(environment: environment));
}

enum Environment { dev, staging, prod }

class Config {
  static String get aiServiceUrl {
    switch (environment) {
      case Environment.dev:
        return 'http://localhost:8000';
      case Environment.staging:
        return 'https://staging-ai.railway.app';
      case Environment.prod:
        return 'https://ai.apptthientai.com';
    }
  }
}
```

**Run with flavor:**

```bash
flutter run --flavor dev -t lib/main_dev.dart
flutter run --flavor prod -t lib/main_prod.dart
```

---

## 5.4. CI/CD PIPELINE

### 5.4.1. GitHub Actions (Suggested)

**`.github/workflows/flutter-ci.yml`:**

```yaml
name: Flutter CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.24.0'
        channel: 'stable'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Analyze code
      run: flutter analyze
    
    - name: Run tests
      run: flutter test
  
  build-android:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.24.0'
    
    - name: Build APK
      run: flutter build apk --release
    
    - name: Upload APK
      uses: actions/upload-artifact@v3
      with:
        name: app-release
        path: build/app/outputs/flutter-apk/app-release.apk
```

**`.github/workflows/ai-service-deploy.yml`:**

```yaml
name: Deploy AI Service

on:
  push:
    branches: [ main ]
    paths:
      - 'ai_service/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Deploy to Railway
      uses: bervProject/railway-deploy@v1
      with:
        railway_token: ${{ secrets.RAILWAY_TOKEN }}
        service: ai-service
```

---

### 5.4.2. Automated Testing

**Unit Tests:**

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/shelter_repository_test.dart

# Coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

**Widget Tests:**

```bash
flutter test test/widget/
```

**Integration Tests:**

```bash
flutter test integration_test/app_test.dart
```

---

## 5.5. TROUBLESHOOTING DEPLOYMENT

### 5.5.1. Common Build Issues

**❌ Issue: `Gradle build failed`**

```bash
# Solution 1: Clean build
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk

# Solution 2: Update Gradle
# Update android/gradle/wrapper/gradle-wrapper.properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.0-all.zip
```

**❌ Issue: `iOS build failed - Signing`**

```
# Open Xcode
open ios/Runner.xcworkspace

# Fix signing trong:
# Runner > Signing & Capabilities
# - Select team
# - Enable "Automatically manage signing"
```

**❌ Issue: `Firebase not initialized`**

```dart
// Ensure this in main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();  // ← Must be here
  runApp(MyApp());
}
```

**❌ Issue: `AI Service connection refused`**

```bash
# Check if service is running
curl http://localhost:8000/api/v1/health

# Check firewall
# Allow port 8000

# Check app config
# Ensure correct baseUrl in AIService
```

---

### 5.5.2. Performance Issues

**❌ Issue: App quá chậm khi build release**

```bash
# Enable Proguard (Android)
# android/app/build.gradle
buildTypes {
    release {
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
}

# Optimize images
# Use smaller image sizes
# Compress với TinyPNG
```

**❌ Issue: APK quá lớn**

```bash
# Build with split-per-abi
flutter build apk --release --split-per-abi

# Output 3 APKs:
# - app-armeabi-v7a-release.apk
# - app-arm64-v8a-release.apk  ← Most common
# - app-x86_64-release.apk
```

---

### 5.5.3. Deployment Checklist

**Pre-deployment:**

- [ ] All tests passing
- [ ] No lint errors
- [ ] Updated version number (`pubspec.yaml`)
- [ ] Updated changelog
- [ ] Firebase config for production
- [ ] AI service URL updated to production
- [ ] Signing configured
- [ ] Privacy policy updated
- [ ] Screenshots prepared (for stores)

**Post-deployment:**

- [ ] Test on real devices
- [ ] Monitor crash reports (Firebase Crashlytics)
- [ ] Check analytics (Firebase Analytics)
- [ ] Monitor AI service logs
- [ ] Backup database
- [ ] Update documentation

---

**[Tiếp tục ở file 06_OPERATIONS.md]**
