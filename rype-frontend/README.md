# Rype Frontend

Flutter app for the Rype investment tracker.

## Getting Started

Run the backend on port `4000`, then start the frontend on any free Flutter port:

```bash
flutter run -d chrome --web-port 3000
```

The app uses `http://127.0.0.1:4000` as the API by default, so it will not fight
with a Flutter web server running on `3000`.

To point the app at another API while developing or publishing, pass:

```bash
flutter run --dart-define=API_BASE_URL=https://your-api-domain.com
flutter build apk --dart-define=API_BASE_URL=https://your-api-domain.com
flutter build web --dart-define=API_BASE_URL=https://your-api-domain.com
```
