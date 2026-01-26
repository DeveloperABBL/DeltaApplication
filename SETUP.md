# Setup Instructions

## Initial Setup

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Generate Code Files**
   This is **REQUIRED** before running the app. The project uses code generation for:
   - Retrofit API client (`app_client.g.dart`)
   - JSON serialization (`first_loading_response.g.dart`)
   
   Run:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **Run the App**
   ```bash
   flutter run
   ```

## Project Structure

The project follows **MVVM + Clean Architecture** pattern:

```
lib/
├── core/                    # Core modules
│   ├── const/              # Constants
│   ├── data/               # Data layer
│   │   ├── cache/          # Local storage (Hive)
│   │   ├── remote/         # API client (Retrofit)
│   │   └── repo/           # Repository base
│   ├── env/                # Environment configs
│   ├── providers/          # Global providers
│   ├── utils/              # Utilities (RepoResult, UiResult)
│   ├── viewmodels/         # Base ViewModels
│   └── widgets/            # Reusable widgets
├── feature/                # Feature modules
│   └── first_loading/      # First loading feature
│       ├── models/
│       ├── repository/
│       ├── screen/
│       └── viewmodel/
└── main.dart
```

## First Loading Feature

The app starts with a first loading screen that:
- Fetches image from `GET /first_loading` endpoint
- Displays the image from the API response
- Handles loading, error, and empty states

API Endpoint: `https://services.delta-compressor.co.th/api/first_loading`

## Troubleshooting

### Error: Target of URI hasn't been generated
**Solution**: Run `dart run build_runner build --delete-conflicting-outputs`

### Error: Undefined class '_AppClient'
**Solution**: Run code generation (see above)

### Hive errors
**Solution**: Make sure `AppLocalStorage.instance().init()` is called in `DevEnvironment.loadEnv()`
