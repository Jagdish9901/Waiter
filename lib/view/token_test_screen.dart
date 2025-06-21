import 'package:flutter/material.dart';
import 'package:waiter_app/api_services/notification_service.dart';

class TokenTestScreen extends StatelessWidget {
  const TokenTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FCM Token Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                String? token = await NotificationService.getFCMToken();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('FCM Token: $token')),
                );
                debugPrint('FCM Token: $token');
              },
              child: const Text('Get FCM Token'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                NotificationService.showLocalNotification(
                  title: 'Test Notification',
                  body: 'This is a test notification',
                );
              },
              child: const Text('Test Local Notification'),
            ),
          ],
        ),
      ),
    );
  }
}
