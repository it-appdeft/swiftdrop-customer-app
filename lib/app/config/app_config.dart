import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';
  static String get imageBaseUrl {
    final envVal = dotenv.env['IMAGE_BASE_URL'];
    if (envVal != null && envVal.trim().isNotEmpty) {
      try {
        final uri = Uri.parse(envVal.trim());
        if (uri.hasAuthority && uri.scheme.isNotEmpty) {
          return '${uri.scheme}://${uri.authority}';
        }
      } catch (_) {}
      return envVal.trim();
    }
    final bUrl = baseUrl;
    if (bUrl.isNotEmpty) {
      try {
        final uri = Uri.parse(bUrl);
        return '${uri.scheme}://${uri.authority}';
      } catch (_) {
        return bUrl;
      }
    }
    return '';
  }
  static String get googleMapsApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  static String get firebaseWebApiKey => dotenv.env['FIREBASE_WEB_API_KEY'] ?? '';
  static String get appName => dotenv.env['APP_NAME'] ?? 'SwiftDrop';
  static bool get isDebug => dotenv.env['IS_DEBUG'] == 'true';
  static int get apiTimeout => int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30') ?? 30;
  static String get accessTokenKey => dotenv.env['ACCESS_TOKEN_KEY'] ?? 'sd_access_token';
  static String get refreshTokenKey => dotenv.env['REFRESH_TOKEN_KEY'] ?? 'sd_refresh_token';
  static bool get isNgrok => baseUrl.contains('ngrok');

  // --- Reverb (WebSocket) --------------------------------------------------
  static String get reverbAppId => dotenv.env['REVERB_APP_ID'] ?? '';
  static String get reverbAppKey => dotenv.env['REVERB_APP_KEY'] ?? '';
  static String get reverbAppSecret => dotenv.env['REVERB_APP_SECRET'] ?? '';
  static String get reverbHost => dotenv.env['REVERB_HOST'] ?? '';
  static int get reverbPort =>
      int.tryParse(dotenv.env['REVERB_PORT'] ?? '8080') ?? 8080;
  static String get reverbScheme => dotenv.env['REVERB_SCHEME'] ?? 'http';
}
