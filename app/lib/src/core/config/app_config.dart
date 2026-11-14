import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'SharedPreferences must be overridden in main()',
  ),
);

const _configuredApiBaseUrl = String.fromEnvironment('API_BASE_URL');
const _configuredApiKey = String.fromEnvironment('API_KEY');

/// API key compiled into the app build. It is public to app users and only
/// supports key rotation, identification, and server-side rate limiting.
Map<String, String> get apiKeyHeaders => _configuredApiKey.isEmpty
    ? const <String, String>{}
    : <String, String>{'X-API-Key': _configuredApiKey};

/// Build-time API URL. Override with:
/// `flutter run --dart-define-from-file=.env.json`
String get apiBaseUrl {
  if (_configuredApiBaseUrl.isEmpty) {
    throw StateError(
      'API_BASE_URL is required. Run Flutter with --dart-define-from-file=.env.json.',
    );
  }

  return _configuredApiBaseUrl;
}
