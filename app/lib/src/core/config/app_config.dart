import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('SharedPreferences must be overridden in main()'),
);

const _configuredApiBaseUrl = String.fromEnvironment('API_BASE_URL');

/// Build-time API URL. Override with:
/// `flutter run --dart-define=API_BASE_URL=https://api.example.com/api/v1`
String get apiBaseUrl {
  if (_configuredApiBaseUrl.isNotEmpty) {
    return _configuredApiBaseUrl;
  }

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:8000/api/v1';
  }

  return 'http://localhost:8000/api/v1';
}
