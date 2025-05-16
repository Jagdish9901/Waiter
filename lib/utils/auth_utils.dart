import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waiter_app/login.dart';
import 'package:waiter_app/providers/cartprovider.dart';
import 'package:waiter_app/providers/notification_provider.dart';
import 'package:waiter_app/utils/apphelper.dart';

// class AuthUtils {
//   static Future<void> logout(BuildContext context) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();

//       //  DO NOT use prefs.clear(); it wipes read notifications too.
//       //  Instead, remove only session/login-related keys.
//       await prefs.remove('userToken');
//       await prefs.remove('userId');
//       await prefs.remove('shopId');
//       await prefs.remove('waiterName');
//       await prefs.remove('someKey'); // Add other login/session keys if any

//       print("Login-related SharedPreferences cleared");

//       final cartProvider = Provider.of<CartProvider>(context, listen: false);
//       cartProvider.clearCart();
//       print("Cart cleared");

//       final notificationProvider =
//           Provider.of<NotificationProvider>(context, listen: false);

//       //  Only clear in-memory notifications, not read history
//       notificationProvider.clearInMemoryNotifications();

//       if (!context.mounted) return;

//       try {
//         Apphelper.connectedDevice?.disconnect();
//       } catch (e) {
//         print("Apphelper error: $e");
//       }

//       await Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(builder: (context) => LoginScreen()),
//         (route) => false,
//       );
//     } catch (e) {
//       print("Logout error: $e");
//     }
//   }
// }

// class AuthUtils {
//   static Future<void> logout(BuildContext context) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();

//       // Clear login-related keys AND printer preference
//       await prefs.remove('userToken');
//       await prefs.remove('userId');
//       await prefs.remove('shopId');
//       await prefs.remove('waiterName');
//       await prefs.remove('printerType'); // Add this line to clear printer pref
//       await prefs.remove('someKey');

//       print(
//           "Login-related SharedPreferences cleared including printer preference");

//       final cartProvider = Provider.of<CartProvider>(context, listen: false);
//       cartProvider.clearCart();
//       print("Cart cleared");

//       final notificationProvider =
//           Provider.of<NotificationProvider>(context, listen: false);
//       notificationProvider.clearInMemoryNotifications();

//       // Disconnect printer if connected
//       try {
//         await Apphelper.connectedDevice?.disconnect();
//         Apphelper.connectedDevice = null;
//         Apphelper.printerType = null;
//       } catch (e) {
//         print("Error disconnecting printer: $e");
//       }

//       if (!context.mounted) return;

//       await Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(builder: (context) => LoginScreen()),
//         (route) => false,
//       );
//     } catch (e) {
//       print("Logout error: $e");
//     }
//   }
// }

// notification not showing after logout

class AuthUtils {
  static Future<void> logout(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Clear login-related keys AND printer preference
      await prefs.remove('userToken');
      await prefs.remove('userId');
      await prefs.remove('shopId');
      await prefs.remove('waiterName');
      await prefs.remove('printerType');
      await prefs.remove('someKey');
      await prefs.setBool('isLoggedIn', false);

      print(
          "Login-related SharedPreferences cleared including printer preference");

      // Clear cart
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.clearCart();
      print("Cart cleared");

      // Clear notification in-memory state but preserve read status
      final notificationProvider =
          Provider.of<NotificationProvider>(context, listen: false);
      notificationProvider.clearInMemoryNotifications();
      print("Notifications cleared from memory (read status preserved)");

      // Disconnect printer if connected
      try {
        await Apphelper.connectedDevice?.disconnect();
        Apphelper.connectedDevice = null;
        Apphelper.printerType = null;
        print("Printer disconnected");
      } catch (e) {
        print("Error disconnecting printer: $e");
      }

      if (!context.mounted) return;

      // Navigate to login screen and remove all routes
      await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
      print("Navigation to login screen complete");
    } catch (e) {
      print("Logout error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: ${e.toString()}')),
        );
      }
    }
  }
}
