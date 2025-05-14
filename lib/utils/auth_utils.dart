import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waiter_app/cartprovider.dart';
import 'package:waiter_app/login.dart';
import 'package:waiter_app/providers/notification_provider.dart';
import 'package:waiter_app/utils/apphelper.dart';

class AuthUtils {
  static Future<void> logout(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      //  DO NOT use prefs.clear(); it wipes read notifications too.
      //  Instead, remove only session/login-related keys.
      await prefs.remove('userToken');
      await prefs.remove('userId');
      await prefs.remove('shopId');
      await prefs.remove('waiterName');
      await prefs.remove('someKey'); // Add other login/session keys if any

      print("Login-related SharedPreferences cleared");

      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.clearCart();
      print("Cart cleared");

      final notificationProvider =
          Provider.of<NotificationProvider>(context, listen: false);

      //  Only clear in-memory notifications, not read history
      notificationProvider.clearInMemoryNotifications();

      if (!context.mounted) return;

      try {
        Apphelper.connectedDevice?.disconnect();
      } catch (e) {
        print("Apphelper error: $e");
      }

      await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      print("Logout error: $e");
    }
  }
}
