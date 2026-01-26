# DeltaCompressor Application

แอปพลิเคชัน DeltaCompressor สำหรับการจัดการบริการของ Delta Compressor รองรับ Android, iOS และ Web (ในอนาคต)

## เทคโนโลยีที่ใช้

### State Management
- **Provider** - จัดการ State ของแอปพลิเคชันด้วย ChangeNotifier pattern

### HTTP & Networking
- **Dio** - HTTP Client สำหรับเชื่อมต่อกับ Backend
- **Retrofit** - Type-safe HTTP client generator
- **json_annotation & json_serializable** - Serialization/Deserialization ของ JSON models

### Local Storage
- **Hive** - NoSQL database สำหรับ local caching และเก็บข้อมูลออฟไลน์

### Localization (L10n)
- **flutter_localizations** - รองรับหลายภาษา
- **intl** - Format และ parse date, number, currency
- รองรับ 2 ภาษา: ไทย (th), อังกฤษ (en)

### อื่นๆ
- **go_router** - Navigation และ Routing
- **google_fonts** - Custom fonts จาก Google Fonts

## สถาปัตยกรรม (Architecture)

โปรเจคใช้ **Clean Architecture + MVVM Pattern** แบบ Android

```
lib/
├── core/                          # Core modules ที่ใช้ร่วมกันทั้งแอป
│   ├── const/                     # Constants
│   ├── data/                      # Data Layer
│   │   ├── cache/                 # Local Storage (Hive)
│   │   │   ├── app_local_storage.dart
│   │   │   └── hive/              # Hive adapters & registrar
│   │   ├── remote/                # Remote API
│   │   │   ├── app_client.dart    # Retrofit client
│   │   │   └── models/            # Request/Response models
│   │   │       ├── api_configs.dart
│   │   │       ├── request/
│   │   │       │   └── customer_credential.dart
│   │   │       └── response/
│   │   │           ├── base_response.dart
│   │   │           └── login_customer_response.dart
│   │   └── repo/                  # Repository (Business Logic)
│   │       └── app_repository.dart
│   ├── env/                       # Environment configurations
│   │   ├── dev_environment.dart   # Development
│   │   └── prd_environment.dart   # Production
│   ├── l10n/                      # Localization utilities
│   │   └── l10n.dart
│   ├── res/                       # Resources
│   │   ├── colors/                # Color palette
│   │   ├── strings/               # Generated localization files
│   │   │   └── l10n/              # ARB files (en, th, zh)
│   │   ├── styles/                # Text styles & themes
│   │   └── theme/                 # App theme configurations
│   └── viewmodels/                # ViewModels (ใช้กับ Provider)
│       └── app_viewmodel.dart
├── feature/                       # Feature modules (ตาม feature)
│   └── [แต่ละ feature จะมี view, viewmodel, และ repository ของตัวเอง]
└── main.dart                      # Entry point
```

## Layers ของ Clean Architecture

### 1. Data Layer (`lib/core/data/`)
- **Cache**: จัดการ local storage ด้วย Hive
- **Remote**: จัดการ API calls ด้วย Retrofit + Dio
- **Repository**: เป็น interface ระหว่าง Data Layer และ ViewModel

### 2. Domain Layer (Business Logic)
- อยู่ใน **Repository** - ประมวลผล business logic
- รวม use cases และ validation

### 3. Presentation Layer
- **View**: UI components (Flutter Widgets)
- **ViewModel**: จัดการ state ด้วย Provider (ChangeNotifier)

## การทำงานของ Data Flow

```
View (Widget)
    ↓ (user action)
ViewModel (Provider/ChangeNotifier)
    ↓ (business logic)
Repository
    ↓ (เลือก data source)
Remote API (Retrofit) ← → Local Cache (Hive)
    ↓ (response)
ViewModel (update state)
    ↓ (notify listeners)
View (rebuild UI)
```

## ตัวอย่าง Implementation ที่มีอยู่

### 1. API Client Configuration
- `AppClient` - Retrofit client สำหรับ HTTP requests
- รองรับ Authentication ด้วย Bearer token
- Timeout: Connect 1 min, Send 1 min, Receive 2 min

### 2. Login Feature
- Request: `CustomerCredential`
- Response: `LoginCustomerResponse` พร้อม customer data
- Endpoint: `POST /customer/login`

### 3. Local Storage
- `AppLocalStorage` - จัดการ Hive box
- ฟังก์ชัน: `getLanguage()` - ดึงภาษาที่เลือก (default: 'th')

### 4. Localization
- ARB files: `app_en.arb`, `app_th.arb`, `app_zh.arb`
- Auto-generated: `AppLocalizations` class
- L10n utilities: ธงประเทศและชื่อภาษา

## 🚀 Getting Started

### 1. ติดตั้ง Dependencies
```bash
flutter pub get
```

### 2. Generate Code (สำคัญ!)
ต้องรันคำสั่งนี้เพื่อ generate code สำหรับ Retrofit และ JSON serialization:
```bash
dart run build_runner build --delete-conflicting-outputs
```

**หมายเหตุ**: หากมี error เกี่ยวกับ generated files (.g.dart) ให้รันคำสั่งนี้ก่อน

### 3. รัน Development
```bash
flutter run
```

## คำสั่งสำคัญ

### Code Generation
เมื่อแก้ไข Retrofit client หรือ JSON models ให้รัน:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Watch Mode (Auto-generate)
```bash
dart run build_runner watch --delete-conflicting-outputs
```

### Localization Generation
เมื่อแก้ไข ARB files ให้รัน:
```bash
flutter gen-l10n
```

## Environment Configuration

- **Development**: `dev_environment.dart`
- **Production**: `prd_environment.dart`

## Base Models

### BaseModelResponse
ทุก API response จะ extend จาก `BaseModelResponse` ที่มี:
- `success`: สถานะความสำเร็จ
- `message`: ข้อความตอบกลับ
- `errorType`: ประเภทของ error (ถ้ามี)

## การเพิ่ม Feature ใหม่

1. สร้างโฟลเดอร์ใน `lib/feature/[feature_name]/`
2. แบ่งเป็น:
   - `view/` - UI widgets
   - `viewmodel/` - Provider viewmodels
   - `repository/` - Business logic (extends `AppRepository`)
3. ใช้ `AppClient` และ `AppLocalStorage` ผ่าน Repository

## Version

- **Version**: 3.0.0+1
- **SDK**: Dart ^3.9.0
- **Platform**: Android, iOS, Web (coming soon)

## หมายเหตุ

- ใช้ `hive_ce` (Community Edition) แทน hive package เดิม
- Retrofit generator version 10.1.3 ต้อง compatible กับ Hive generator
- ทุก JSON model ต้อง generate code ด้วย build_runner
