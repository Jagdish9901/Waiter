// import 'dart:io';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:permission_handler/permission_handler.dart';

// class NotificationService {
//   static final FlutterLocalNotificationsPlugin
//       _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

//   static Future<void> initialize() async {
//     // Request notification permissions for Android 13+
//     if (Platform.isAndroid) {
//       final androidInfo = await _flutterLocalNotificationsPlugin
//           .resolvePlatformSpecificImplementation<
//               AndroidFlutterLocalNotificationsPlugin>();

//       if (await Permission.notification.isDenied) {
//         await Permission.notification.request();
//       }

//       // Create notification channel
//       const AndroidNotificationChannel channel = AndroidNotificationChannel(
//         'custom_sound_channel_v2', // Same as used below
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
//     const AndroidNotificationDetails androidDetails =
//         AndroidNotificationDetails(
//       'custom_sound_channel_v2', // Must match the created channel ID
//       'Custom Sound Notifications',
//       channelDescription: 'Channel for order alerts',
//       importance: Importance.max,
//       priority: Priority.high,
//       playSound: true,
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

// notification icon below

// import 'dart:io';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:permission_handler/permission_handler.dart';

// class NotificationService {
//   static final FlutterLocalNotificationsPlugin
//       _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

//   static Future<void> initialize() async {
//     // Request notification permissions for Android 13+
//     if (Platform.isAndroid) {
//       final androidInfo = await _flutterLocalNotificationsPlugin
//           .resolvePlatformSpecificImplementation<
//               AndroidFlutterLocalNotificationsPlugin>();

//       if (await Permission.notification.isDenied) {
//         await Permission.notification.request();
//       }

//       // Create notification channel
//       const AndroidNotificationChannel channel = AndroidNotificationChannel(
//         'custom_sound_channel_v2', // Same as used below
//         'Custom Sound Notifications',
//         description: 'Channel for order alerts',
//         importance: Importance.high,
//         playSound: true,
//         sound: RawResourceAndroidNotificationSound('new_notification'),
//       );

//       await androidInfo?.createNotificationChannel(channel);
//     }

//     const AndroidInitializationSettings androidSettings =
//         AndroidInitializationSettings(
//             'ic_stat_icon_192'); //  Use custom color icon (no .png)

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
//     const AndroidNotificationDetails androidDetails =
//         AndroidNotificationDetails(
//       'custom_sound_channel_v2', // Must match the created channel ID
//       'Custom Sound Notifications',
//       channelDescription: 'Channel for order alerts',
//       importance: Importance.max,
//       priority: Priority.high,
//       playSound: true,
//       icon: 'ic_stat_icon_192', //  Set custom notification icon here too
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

// new code for web

import 'dart:io' show Platform; // Platform works only outside web
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    if (kIsWeb) {
      // Web platform notice
      print(
          "Running on Web, local notifications with custom sounds are not supported.");
      print(
          "Consider using browser notification APIs or Firebase Cloud Messaging (FCM) for web.");
      return;
    }

    if (Platform.isAndroid) {
      final androidInfo = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }

      // Create custom sound channel
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'custom_sound_channel_v2',
        'Custom Sound Notifications',
        description: 'Channel for order alerts',
        importance: Importance.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('new_notification'),
      );

      await androidInfo?.createNotificationChannel(channel);
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    if (kIsWeb) {
      print(
          "Notifications not supported via flutter_local_notifications on Web.");
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'custom_sound_channel_v2',
      'Custom Sound Notifications',
      channelDescription: 'Channel for order alerts',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      icon: '@mipmap/ic_launcher',
      sound: RawResourceAndroidNotificationSound('new_notification'),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      sound: 'new_notification.mp3',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }
}
