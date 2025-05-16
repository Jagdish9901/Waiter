import 'dart:io' show Platform; // Platform works only outside web
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

// notification not showing after logout

class NotificationService {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    if (kIsWeb) {
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
