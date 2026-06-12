class ApiConstants {
  static const String _defaultBaseUrl = 'https://rype-5kkv.onrender.com';
  
  // Read from build-time define, fall back to default
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultBaseUrl,
  );
}

