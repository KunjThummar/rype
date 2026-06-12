# Rype Frontend

Flutter app for the Rype investment tracker.

## Getting Started

Run the backend on port `4000`, then start the frontend on any free Flutter port:

```bash
flutter run -d chrome --web-port 3000
```

The app uses the API URL specified in `lib/core/constants/api_constants.dart` by default.

## Development

To point the app at a local or different API while developing, use:

```bash
# For Chrome web
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:4000

# For Android device/emulator
flutter run -d android --dart-define=API_BASE_URL=http://10.0.2.2:4000
```

Note: For Android emulator, use `http://10.0.2.2:4000` instead of `localhost` or `127.0.0.1`.

## Building for Release

### Android APK

```bash
# Build release APK with production API URL
flutter build apk --release --dart-define=API_BASE_URL=https://rype-5kkv.onrender.com

# Or for local backend (if accessible)
flutter build apk --release --dart-define=API_BASE_URL=http://your-backend-url:4000
```

### Web

```bash
flutter build web --release --dart-define=API_BASE_URL=https://rype-5kkv.onrender.com
```

## Prerequisites

- Flutter SDK: ^3.12.1
- Android SDK (for APK builds)
- Xcode (for iOS builds)

## Important Notes

- The app requires internet permission on Android (already added to AndroidManifest.xml)
- API tokens are securely stored using `flutter_secure_storage`
- Auth persistence: App checks for stored token on startup and navigates accordingly
- For emulator testing, use `http://10.0.2.2:4000` for backend access
