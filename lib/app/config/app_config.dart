import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';
  static String get imageBaseUrl => dotenv.env['IMAGE_BASE_URL'] ?? '';
  static String get socketUrl => dotenv.env['SOCKET_URL'] ?? '';
  static String get googleMapsApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  static String get firebaseWebApiKey => dotenv.env['FIREBASE_WEB_API_KEY'] ?? '';
  static String get appName => dotenv.env['APP_NAME'] ?? 'SwiftDrop';
  static bool get isDebug => dotenv.env['IS_DEBUG'] == 'true';
  static int get apiTimeout => int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30') ?? 30;
  static String get accessTokenKey => dotenv.env['ACCESS_TOKEN_KEY'] ?? 'sd_access_token';
  static String get refreshTokenKey => dotenv.env['REFRESH_TOKEN_KEY'] ?? 'sd_refresh_token';
  static bool get isNgrok => baseUrl.contains('ngrok');
}
