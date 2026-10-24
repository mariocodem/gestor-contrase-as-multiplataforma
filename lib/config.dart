import 'package:flutter/foundation.dart';

/// Where the Bóveda Worker lives, fixed at build time:
///
///     flutter run --dart-define-from-file=config/prod.json
///
/// Without it, debug builds talk to `npm run dev` in backend/ (wrangler on port 8787); the Android
/// emulator reaches the host machine at 10.0.2.2.
class AppConfig {
  const AppConfig._(this.apiUrl);

  static const _apiUrl = String.fromEnvironment('BOVEDA_API_URL');

  /// Null in a release build that wasn't given a server: the app says so instead of failing later.
  static AppConfig? resolve() {
    if (_apiUrl.isNotEmpty) return AppConfig._(Uri.parse(_apiUrl));
    if (kReleaseMode) return null;
    final android = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    return AppConfig._(Uri.parse(android ? 'http://10.0.2.2:8787' : 'http://localhost:8787'));
  }

  final Uri apiUrl;
}
