import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/repositories/auth_repository.dart';
import '../../firebase_options.dart';
import '../constants/storage_keys.dart';
import '../utils/app_logger.dart';
import 'storage_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  AppLogger.d('Handling background message: ${message.messageId}');
}

class NotificationService extends GetxService {
  static NotificationService get to => Get.find();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedAppSub;
  StreamSubscription<String>? _tokenRefreshSub;

  final RxnString fcmToken = RxnString();

  /// Gets current stored or reactive FCM token
  String? get token => fcmToken.value ?? StorageService.to.read<String>(StorageKeys.fcmToken);

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    try {
      if (Firebase.apps.isEmpty) {
        AppLogger.w('NotificationService init skipped: Firebase not initialized');
        return;
      }

      await _setupLocalNotifications();
      await _setupFirebaseMessaging();
    } catch (e) {
      AppLogger.w('NotificationService init failed', e);
    }
  }

  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _localNotifications.initialize(settings);
  }

  Future<void> _setupFirebaseMessaging() async {
    final messaging = FirebaseMessaging.instance;

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await messaging.setAutoInitEnabled(true);

    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    AppLogger.i('Notification permissions status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      final status = await Permission.notification.status;
      if (status.isPermanentlyDenied) {
        Future.delayed(const Duration(milliseconds: 1500), _showPermissionDialog);
      }
    }

    // Fetch initial FCM token with retry mechanism
    final currentToken = await _fetchTokenWithRetry();
    if (currentToken != null) {
      fcmToken.value = currentToken;
      await StorageService.to.write(StorageKeys.fcmToken, currentToken);
      AppLogger.i('FCM DEVICE TOKEN: $currentToken');
      syncFcmTokenWithServer(currentToken);
    } else {
      AppLogger.w('FCM token could not be retrieved after retries.');
    }

    // Listen for FCM token refresh
    _tokenRefreshSub = messaging.onTokenRefresh.listen((newToken) async {
      fcmToken.value = newToken;
      await StorageService.to.write(StorageKeys.fcmToken, newToken);
      AppLogger.i('NEW FCM DEVICE TOKEN: $newToken');
      syncFcmTokenWithServer(newToken);
    });

    _foregroundSub = FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    _openedAppSub = FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  /// Sync FCM token to server via /auth/update-fcm-token
  Future<void> syncFcmTokenWithServer([String? specificToken]) async {
    final tokenToSync = specificToken ?? token;
    if (tokenToSync == null || tokenToSync.isEmpty) return;
    if (!StorageService.to.isLoggedIn) return;

    try {
      final authRepo = AuthRepository();
      final response = await authRepo.updateFcmToken(tokenToSync);
      if (response.success) {
        AppLogger.i('FCM token synced with server successfully');
      }
    } catch (e) {
      AppLogger.w('FCM token server sync skipped: $e');
    }
  }

  /// Request notification permissions and show settings dialog if denied
  Future<void> checkAndRequestPermission() async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      final result = await Permission.notification.request();
      if (result.isGranted) {
        AppLogger.i('Notification permission granted');
        await getOrFetchToken();
      } else if (result.isPermanentlyDenied) {
        _showPermissionDialog();
      }
    } else if (status.isPermanentlyDenied) {
      _showPermissionDialog();
    }
  }

  /// Shows custom dialog when notification permission is permanently denied
  void _showPermissionDialog() {
    if (Get.isDialogOpen ?? false) return;
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.notifications_active_outlined, color: Color(0xFFFF6B00)),
            SizedBox(width: 10),
            Text(
              'Notification Permission',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: const Text(
          'Please enable notifications in settings to receive instant order tracking and delivery status alerts.',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Later', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B00),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Get.back();
              await openAppSettings();
            },
            child: const Text('Open Settings', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  /// Helper to fetch FCM token with automatic retry
  Future<String?> _fetchTokenWithRetry({int maxRetries = 4}) async {
    final messaging = FirebaseMessaging.instance;
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final token = await messaging.getToken();
        if (token != null && token.isNotEmpty) {
          return token;
        }
      } catch (e) {
        AppLogger.w('FCM token fetch attempt $attempt/$maxRetries failed ($e)');
        if (attempt < maxRetries) {
          await Future.delayed(Duration(seconds: 2 * attempt));
        }
      }
    }
    return null;
  }

  /// Explicitly retrieve or refresh the device FCM token on-demand
  Future<String?> getOrFetchToken() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        final newToken = await _fetchTokenWithRetry(maxRetries: 3);
        if (newToken != null) {
          fcmToken.value = newToken;
          await StorageService.to.write(StorageKeys.fcmToken, newToken);
          syncFcmTokenWithServer(newToken);
          return newToken;
        }
      }
    } catch (e) {
      AppLogger.e('Error manually fetching FCM token', e);
    }
    return token;
  }

  void _handleForegroundMessage(RemoteMessage message) {
    try {
      _showLocalNotification(message);
    } catch (e) {
      AppLogger.w('Failed to show local notification', e);
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    AppLogger.d('Notification opened app: ${message.data}');
  }

  @override
  void onClose() {
    _foregroundSub?.cancel();
    _openedAppSub?.cancel();
    _tokenRefreshSub?.cancel();
    super.onClose();
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'swiftdrop_channel',
      'SwiftDrop Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
    );
  }
}