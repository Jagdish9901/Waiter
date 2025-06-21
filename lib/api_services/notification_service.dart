// import 'dart:io' show Platform; // Platform works only outside web
// import 'package:flutter/foundation.dart'; // for kIsWeb
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:permission_handler/permission_handler.dart';

// // notification not showing after logout

// class NotificationService {
//   static final FlutterLocalNotificationsPlugin
//       _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

//   static Future<void> initialize() async {
//     if (kIsWeb) {
//       print(
//           "Running on Web, local notifications with custom sounds are not supported.");
//       print(
//           "Consider using browser notification APIs or Firebase Cloud Messaging (FCM) for web.");
//       return;
//     }

//     if (Platform.isAndroid) {
//       final androidInfo = await _flutterLocalNotificationsPlugin
//           .resolvePlatformSpecificImplementation<
//               AndroidFlutterLocalNotificationsPlugin>();

//       if (await Permission.notification.isDenied) {
//         await Permission.notification.request();
//       }

//       const AndroidNotificationChannel channel = AndroidNotificationChannel(
//         'custom_sound_channel_v2',
//         'Custom Sound Notifications',
//         description: 'Channel for order alerts',
//         importance: Importance.high,
//         playSound: true,
//         sound: RawResourceAndroidNotificationSound('new_notification'),
//       );

//       await androidInfo?.createNotificationChannel(channel);
//     }

//     const AndroidInitializationSettings androidSettings =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const DarwinInitializationSettings iosSettings =
//         DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );

//     const InitializationSettings initSettings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );

//     await _flutterLocalNotificationsPlugin.initialize(initSettings);
//   }

//   static Future<void> showNotification({
//     required String title,
//     required String body,
//   }) async {
//     if (kIsWeb) {
//       print(
//           "Notifications not supported via flutter_local_notifications on Web.");
//       return;
//     }

//     const AndroidNotificationDetails androidDetails =
//         AndroidNotificationDetails(
//       'custom_sound_channel_v2',
//       'Custom Sound Notifications',
//       channelDescription: 'Channel for order alerts',
//       importance: Importance.max,
//       priority: Priority.high,
//       playSound: true,
//       icon: '@mipmap/ic_launcher',
//       sound: RawResourceAndroidNotificationSound('new_notification'),
//     );

//     const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
//       sound: 'new_notification.mp3',
//     );

//     const NotificationDetails notificationDetails = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );

//     await _flutterLocalNotificationsPlugin.show(
//       DateTime.now().millisecondsSinceEpoch ~/ 1000,
//       title,
//       body,
//       notificationDetails,
//     );
//   }
// }

//firebase related

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static bool _initialized = false;

  // Public method to get token (call this after initialization)
  static Future<String?> getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $token');
      return token;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // Initialize FCM first
    await _setupFCM();

    // Then initialize local notifications
    if (kIsWeb) {
      debugPrint("Web platform: Limited notification support");
      return;
    }

    // Android-specific setup
    if (Platform.isAndroid) {
      final androidPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      // Request notification permission
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }

      // Create notification channel
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'order_notifications', // Same as before
        'Order Notifications', // Same as before
        description: 'Notifications for ready orders', // Same as before
        importance: Importance.max, // Same as before
        playSound: true, // Same as before
        sound: RawResourceAndroidNotificationSound(
            'new_notification'), // Same as before
        enableVibration: true, // Same as before
        showBadge: true, // Same as before
        // Removed 'priority' parameter as it's now handled differently
      );

      await androidPlugin?.createNotificationChannel(channel);
    }

    // Initialize local notifications plugin
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
    //   requestAlertPermission: true,
    //   requestBadgePermission: true,
    //   requestSoundPermission: true,
    //   onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    // );

    await _flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        // iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
  }

  static Future<void> _setupFCM() async {
    try {
      // Request notification permissions
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint(
          'Notification permission status: ${settings.authorizationStatus}');

      // Get and print the FCM token
      String? token = await _firebaseMessaging.getToken();
      debugPrint('Initial FCM Token: $token');

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        debugPrint('FCM Token Refreshed: $newToken');
        // Send to your server here
      });

      // Set up foreground message handler
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Received foreground message: ${message.messageId}');
        _showNotificationFromMessage(message);
      });

      // Handle when app is in background but not terminated
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('Opened app from background message');
        _handleNotificationClick(message);
      });

      // Handle when app is terminated
      FirebaseMessaging.instance
          .getInitialMessage()
          .then((RemoteMessage? message) {
        if (message != null) {
          debugPrint('Opened app from terminated state');
          _handleNotificationClick(message);
        }
      });
    } catch (e) {
      debugPrint('Error setting up FCM: $e');
    }
  }

  static void _onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    debugPrint('Received local notification: $title - $body');
  }

  static void _onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) {
    debugPrint('Notification clicked: ${notificationResponse.payload}');
  }

  static Future<void> _showNotificationFromMessage(
      RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'order_notifications',
        'Order Notifications',
        channelDescription: 'Notifications for ready orders',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('new_notification'),
        enableVibration: true,
        visibility: NotificationVisibility.public,
        fullScreenIntent: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      await _flutterLocalNotificationsPlugin.show(
        message.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        ),
        payload: message.data['orderId'],
      );
    }
  }

  static void _handleNotificationClick(RemoteMessage message) {
    // Handle navigation when notification is clicked
    debugPrint('Notification data: ${message.data}');
    // You can use Navigator here with a GlobalKey
  }

  static Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'order_notifications',
      'Order Notifications',
      channelDescription: 'Notifications for ready orders',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('new_notification'),
      enableVibration: true,
      visibility: NotificationVisibility.public,
      fullScreenIntent: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: payload,
    );
  }
}
