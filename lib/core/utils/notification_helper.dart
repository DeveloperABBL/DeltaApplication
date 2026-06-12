import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
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
/// // Listen การ tap notification (FCM / เปิดจาก terminated) — message อาจ null ถ้าแตะ local notif
/// NotificationHelper.onNotificationTap((message) {
///   context.go(NotificationPage.pagePath);
/// });
///
/// // Get FCM token
/// final token = await NotificationHelper.getToken();
/// ```
class NotificationHelper {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Callback เมื่อ user เปิดจาก push (RemoteMessage) หรือแตะ local notification ตอน foreground (null)
  static void Function(RemoteMessage? message)? _onMessageTapped;

  /// ข้อความล่าสุดที่โชว์เป็น local notification ตอน foreground (ใช้เมื่อแตะ local notif)
  static RemoteMessage? _lastForegroundMessageForTap;

  /// เปิดแอปจาก terminated ด้วย notification ก่อนลงทะเบียน callback — เก็บไว้แล้วส่งตอน [onNotificationTap]
  static RemoteMessage? _pendingInitialOpenMessage;

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
      // 1. Request permission
      final permissionGranted = await _requestPermissions();
      if (!permissionGranted) {
        debugPrint(
          '⚠️ Notification permission denied — foreground push may not show',
        );
      }

      // 2. Initialize local notifications (ใช้แสดงตอน foreground บน Android)
      await _initializeLocalNotifications();

      // 3. iOS: ให้ระบบแสดง banner ตอนแอปเปิดอยู่ (FCM ไม่โชว์เองใน foreground)
      if (platform_check.isIOS) {
        await setForegroundNotificationPresentationOptions();
      }

      // 4. Android 13+: ขอ POST_NOTIFICATIONS (FCM requestPermission บน Android อาจไม่พอ)
      if (platform_check.isAndroid) {
        await PermissionHelper.requestNotificationPermission();
      }

      // 5. Listen Token ของ FirebaseMessaging
      _messaging.onTokenRefresh.listen(onTokenRefresh ?? (_) {});

      // 6. Setup Firebase Messaging handlers (ต้องลงทะเบียนเสมอ แม้ permission ถูกปฏิเสธ)
      await _setupMessageHandlers();

      // 7. Setup background message handler
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
        _onMessageTapped?.call(_lastForegroundMessageForTap);
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
    // iOS: ใช้ setForegroundNotificationPresentationOptions แสดง banner ระบบ
    // Android: ต้องสร้าง local notification เอง (ระบบไม่โชว์ใน tray ตอน foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📩 Foreground Message: ${message.messageId}');
      debugPrint('📩 Title: ${message.notification?.title}');
      debugPrint('📩 Body: ${message.notification?.body}');
      debugPrint('📩 Data: ${message.data}');

      if (platform_check.isAndroid) {
        unawaited(
          _showLocalNotification(message).catchError((Object e, StackTrace st) {
            debugPrint('❌ Foreground local notification failed: $e');
            debugPrint('$st');
          }),
        );
      }
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

      if (_onMessageTapped != null) {
        _onMessageTapped!(initialMessage);
      } else {
        _pendingInitialOpenMessage = initialMessage;
      }
    }
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final titleBody = _extractTitleAndBody(message);
    if (titleBody == null) {
      debugPrint(
        '⚠️ Foreground message has no title/body — use notification payload '
        'or data keys: title, body',
      );
      return;
    }

    _lastForegroundMessageForTap = message;

    final imagePath = await _downloadNotificationImage(_extractImageUrl(message));

    await _localNotifications.show(
      message.messageId?.hashCode ??
          DateTime.now().millisecondsSinceEpoch ~/ 1000,
      titleBody.$1,
      titleBody.$2,
      _buildNotificationDetails(
        message: message,
        title: titleBody.$1,
        body: titleBody.$2,
        imagePath: imagePath,
      ),
      payload: message.data.toString(),
    );
  }

  /// คืน (title, body) จาก notification payload หรือ data
  static (String, String)? _extractTitleAndBody(RemoteMessage message) {
    final n = message.notification;
    if (n?.title != null && n!.title!.isNotEmpty) {
      return (n.title!, n.body ?? '');
    }

    final data = message.data;
    final title = data['title'] ?? data['notification_title'];
    final body = data['body'] ?? data['notification_body'] ?? data['message'];
    if (title != null && title.isNotEmpty) {
      return (title, body ?? '');
    }
    return null;
  }

  /// ดึง URL รูปจาก FCM (notification payload หรือ data)
  static String? _extractImageUrl(RemoteMessage message) {
    final notification = message.notification;
    final androidImage = notification?.android?.imageUrl;
    if (androidImage != null && androidImage.isNotEmpty) return androidImage;

    final appleImage = notification?.apple?.imageUrl;
    if (appleImage != null && appleImage.isNotEmpty) return appleImage;

    final data = message.data;
    for (final key in ['image', 'imageUrl', 'image_url']) {
      final value = data[key];
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  static Future<String?> _downloadNotificationImage(String? url) async {
    if (url == null || url.isEmpty) return null;

    try {
      final uri = Uri.tryParse(url);
      if (uri == null || !uri.hasScheme) return null;

      final dir = await getTemporaryDirectory();
      final ext = uri.path.toLowerCase().endsWith('.png') ? '.png' : '.jpg';
      final filePath =
          '${dir.path}/fcm_img_${DateTime.now().millisecondsSinceEpoch}$ext';

      await Dio().download(url, filePath);
      return filePath;
    } catch (e) {
      debugPrint('❌ Failed to download notification image: $e');
      return null;
    }
  }

  static NotificationDetails _buildNotificationDetails({
    required RemoteMessage message,
    required String title,
    required String body,
    String? imagePath,
  }) {
    final android = message.notification?.android;

    AndroidNotificationDetails androidDetails;
    DarwinNotificationDetails iosDetails;

    if (imagePath != null && platform_check.isAndroid) {
      final bitmap = FilePathAndroidBitmap(imagePath);
      androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription:
            'This channel is used for Delta Compressor app notifications',
        importance: Importance.high,
        priority: Priority.high,
        icon: android?.smallIcon ?? '@mipmap/ic_launcher',
        styleInformation: BigPictureStyleInformation(
          bitmap,
          largeIcon: bitmap,
          contentTitle: title,
          summaryText: body,
        ),
      );
    } else {
      androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription:
            'This channel is used for Delta Compressor app notifications',
        importance: Importance.high,
        priority: Priority.high,
        icon: android?.smallIcon ?? '@mipmap/ic_launcher',
      );
    }

    if (imagePath != null && platform_check.isIOS) {
      iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        attachments: [DarwinNotificationAttachment(imagePath)],
      );
    } else {
      iosDetails = const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
    }

    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  /// ==================== Public API ====================

  /// ตั้งค่า callback เมื่อ user เปิดจาก FCM (มี [RemoteMessage]) หรือแตะ local notification ตอน foreground ([message] เป็น null)
  ///
  /// เรียกหลัง GoRouter พร้อม — ถ้าเปิดแอปจาก terminated ด้วย notification จะส่งข้อความค้างเมื่อลงทะเบียนครั้งแรก
  static void onNotificationTap(void Function(RemoteMessage? message) callback) {
    _onMessageTapped = callback;
    final pending = _pendingInitialOpenMessage;
    if (pending != null) {
      _pendingInitialOpenMessage = null;
      callback(pending);
    }
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
