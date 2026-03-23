import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart' as handler;

import 'package:delta_compressor_202501017/core/utils/permission_helper.dart';
import 'package:delta_compressor_202501017/core/utils/platform_check_stub.dart'
    if (dart.library.io) 'package:delta_compressor_202501017/core/utils/platform_check_io.dart'
    as platform_check;

/// Handler สำหรับ background notifications
/// ต้องเป็น top-level function เพื่อให้ Firebase เรียกใช้ได้
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📩 Background Message: ${message.messageId}');
  debugPrint('📩 Title: ${message.notification?.title}');
  debugPrint('📩 Body: ${message.notification?.body}');
  debugPrint('📩 Data: ${message.data}');

  // สามารถเพิ่ม logic เพิ่มเติมได้ เช่น update local database
}

/// Helper class สำหรับจัดการ Firebase Cloud Messaging และ Local Notifications
///
/// รองรับ:
/// - Background notifications (เมื่อ app ปิดหรือ minimize)
/// - Foreground notifications (เมื่อ app เปิดอยู่)
/// - การเปิด app จาก notification tap
/// - การขอ permission สำหรับ iOS
///
/// Example:
/// ```dart
/// // Initialize ใน main.dart
/// await NotificationHelper.initialize();
///
/// // Listen การ tap notification
/// NotificationHelper.onNotificationTap((message) {
///   // Handle navigation
/// });
///
/// // Get FCM token
/// final token = await NotificationHelper.getToken();
/// ```
class NotificationHelper {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Callback เมื่อ user tap notification
  static Function(RemoteMessage)? _onMessageTapped;

  /// สถานะการ initialize
  static bool _initialized = false;

  static const String _channelId = 'delta_compressor_channel';
  static const String _channelName = 'Delta Compressor Notifications';

  /// ==================== Main Initialization ====================

  /// Initialize Firebase Messaging และ Local Notifications
  ///
  /// ควรเรียกใน main() หลัง Firebase.initializeApp()
  ///
  /// Returns: true ถ้า initialize สำเร็จ, false ถ้ามีปัญหา
  static Future<bool> initialize({Function(String)? onTokenRefresh}) async {
    if (_initialized) {
      debugPrint('⚠️ NotificationHelper already initialized');
      return true;
    }

    try {
      // 1. Request permission (iOS)
      final permissionGranted = await _requestPermissions();
      if (!permissionGranted) {
        debugPrint('⚠️ Notification permission denied');
        return false;
      }

      // 2. Initialize local notifications
      await _initializeLocalNotifications();

      // 3. Listen Token ของ FirebaseMessaging
      _messaging.onTokenRefresh.listen(onTokenRefresh ?? (_) {});

      // 4. Setup Firebase Messaging handlers
      await _setupMessageHandlers();

      // 5. Setup background message handler
      FirebaseMessaging.onBackgroundMessage(
        firebaseMessagingBackgroundHandler,
      );

      _initialized = true;
      debugPrint('✅ NotificationHelper initialized successfully');

      // 6. Get and log FCM token
      final token = await getToken();
      debugPrint('🔑 FCM Token: $token');

      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to initialize NotificationHelper: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  /// ==================== Permission Management ====================

  /// ขอ permission สำหรับ notifications
  /// ใช้ FirebaseMessaging.requestPermission() โดยตรงเพื่อให้ iOS แสดง dialog ได้ถูกต้อง
  static Future<bool> _requestPermissions() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint(
        '📱 Notification Permission Status: ${settings.authorizationStatus}',
      );

      return settings.authorizationStatus ==
              AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      debugPrint('❌ Error requesting notification permission: $e');
      return false;
    }
  }

  /// ตรวจสอบสถานะ notification permission ปัจจุบัน
  static Future<bool> hasPermission() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// ขอ permission สำหรับ Exact Alarms (Android 14+)
  static Future<bool> requestExactAlarmPermission() async {
    try {
      if (!platform_check.isAndroid) {
        debugPrint('ℹ️ Exact alarm permission is only for Android');
        return true;
      }

      final status = await PermissionHelper.requestExactAlarmPermission();
      debugPrint('⏰ Exact Alarm Permission Status: $status');

      return status == handler.PermissionStatus.granted;
    } catch (e) {
      debugPrint('❌ Error requesting exact alarm permission: $e');
      return false;
    }
  }

  /// ตรวจสอบว่ามี exact alarm permission หรือไม่
  static Future<bool> hasExactAlarmPermission() async {
    if (!platform_check.isAndroid) return true;
    return await PermissionHelper.hasExactAlarmPermission();
  }

  /// ==================== Local Notifications Setup ====================

  static Future<void> _initializeLocalNotifications() async {
    // Android settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('📱 Local notification tapped: ${details.payload}');
      },
    );

    if (platform_check.isAndroid) {
      await _createAndroidNotificationChannel();
    }
  }

  static Future<void> _createAndroidNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'This channel is used for Delta Compressor app notifications',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    debugPrint('📱 Android notification channel created');
  }

  /// ==================== Firebase Messaging Handlers ====================

  static Future<void> _setupMessageHandlers() async {
    // 1. Foreground messages (เมื่อ app เปิดอยู่)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📩 Foreground Message: ${message.messageId}');
      debugPrint('📩 Title: ${message.notification?.title}');
      debugPrint('📩 Body: ${message.notification?.body}');
      debugPrint('📩 Data: ${message.data}');

      _showLocalNotification(message);
    });

    // 2. Message opened app (user tap notification)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(
        '📲 Notification tapped (app in background): ${message.messageId}',
      );
      debugPrint('📲 Data: ${message.data}');

      _onMessageTapped?.call(message);
    });

    // 3. Check if app was opened from terminated state
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint(
        '📲 App opened from terminated state: ${initialMessage.messageId}',
      );
      debugPrint('📲 Data: ${initialMessage.data}');

      _onMessageTapped?.call(initialMessage);
    }
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription:
                'This channel is used for Delta Compressor app notifications',
            importance: Importance.high,
            priority: Priority.high,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  /// ==================== Public API ====================

  /// ตั้งค่า callback เมื่อ user tap notification
  static void onNotificationTap(Function(RemoteMessage) callback) {
    _onMessageTapped = callback;
  }

  /// ค่า platform สำหรับส่งไปยัง API device/token ('ios' | 'android' | 'web')
  static String get devicePlatform =>
      platform_check.isIOS ? 'ios' : (platform_check.isAndroid ? 'android' : 'web');

  /// ดึง FCM token สำหรับส่งไปยัง backend
  ///
  /// Returns: FCM token หรือ null ถ้าไม่สามารถดึงได้
  static Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      return token;
    } catch (e) {
      debugPrint('❌ Failed to get FCM token: $e');
      return null;
    }
  }

  /// Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('✅ Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('❌ Failed to subscribe to topic $topic: $e');
    }
  }

  /// Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('❌ Failed to unsubscribe from topic $topic: $e');
    }
  }

  /// ลบ FCM token (ใช้เมื่อ user logout)
  static Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      debugPrint('✅ FCM token deleted');
    } catch (e) {
      debugPrint('❌ Failed to delete FCM token: $e');
    }
  }

  /// ตั้งค่า foreground notification presentation options (iOS)
  static Future<void> setForegroundNotificationPresentationOptions({
    bool alert = true,
    bool badge = true,
    bool sound = true,
  }) async {
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: alert,
      badge: badge,
      sound: sound,
    );
  }

  /// แสดง notification ด้วยตนเอง (สำหรับ testing)
  static Future<void> showTestNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription:
              'This channel is used for Delta Compressor app notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: data?.toString(),
    );
  }
}
