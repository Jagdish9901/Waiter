// import 'package:flutter/material.dart';
// import 'package:waiter_app/api_services/notification_service.dart';
// import 'package:waiter_app/models/notification_item.dart';
// import 'package:flutter/foundation.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class NotificationProvider with ChangeNotifier {
//   List<NotificationItem> _notifications = [];
//   final Set<String> _processedOrders = {}; // Tracks orders we've seen
//   final Set<String> _readOrderNos = {}; // Tracks read notifications
//   final Set<String> _bannerShownOrders = {}; // Tracks banner-shown orders

//   List<NotificationItem> get notifications => _notifications;
//   int get unreadCount => _notifications.where((n) => !n.isRead).length;

//   String get badgeText =>
//       unreadCount <= 0 ? '' : (unreadCount > 9 ? '9+' : '$unreadCount');

//   Future<void> initializeNotifications() async {
//     await _loadPersistedData();
//     notifyListeners();
//   }

//   void addNotification(NotificationItem notification) {
//     if (!_processedOrders.contains(notification.orderNo)) {
//       // set read status from persistence
//       notification.isRead = _readOrderNos.contains(notification.orderNo);

//       // Add to notifications list
//       _notifications.insert(0, notification);
//       _processedOrders.add(notification.orderNo);

//       // Show banner if never shown before
//       if (!_bannerShownOrders.contains(notification.orderNo)) {
//         _showBannerNotification(notification);
//         _bannerShownOrders.add(notification.orderNo);
//         _saveBannerShownOrders();
//       }

//       notifyListeners();
//     }
//   }

//   void _showBannerNotification(NotificationItem notification) {
//     NotificationService.showNotification(
//       title: 'New Order Ready',
//       body: 'Order #${notification.orderNo} is ready!',
//     );
//   }

//   void markAsRead(int index) async {
//     if (index >= 0 && index < _notifications.length) {
//       _notifications[index].isRead = true;
//       _readOrderNos.add(_notifications[index].orderNo);
//       await _saveReadOrders();
//       notifyListeners();
//     }
//   }

//   void markAllAsRead() async {
//     for (var notification in _notifications) {
//       notification.isRead = true;
//       _readOrderNos.add(notification.orderNo);
//     }
//     await _saveReadOrders();
//     notifyListeners();
//   }

//   void removeNotification(int index) {
//     if (index >= 0 && index < _notifications.length) {
//       _processedOrders.remove(_notifications[index].orderNo);
//       _notifications.removeAt(index);
//       notifyListeners();
//     }
//   }

//   void clearInMemoryNotifications() {
//     _notifications.clear();
//     _processedOrders.clear();
//     notifyListeners();
//   }

//   void clearAllNotifications() async {
//     _notifications.clear();
//     _processedOrders.clear();
//     _readOrderNos.clear();
//     _bannerShownOrders.clear();
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('readOrderNos');
//     await prefs.remove('bannerShownOrders');
//     notifyListeners();
//   }

//   // Persistence methods
//   Future<void> _loadPersistedData() async {
//     final prefs = await SharedPreferences.getInstance();

//     // Load read notifications
//     final readOrders = prefs.getStringList('readOrderNos') ?? [];
//     _readOrderNos.addAll(readOrders);

//     // Load banner-shown notifications
//     final bannerShown = prefs.getStringList('bannerShownOrders') ?? [];
//     _bannerShownOrders.addAll(bannerShown);
//   }

//   Future<void> _saveReadOrders() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setStringList('readOrderNos', _readOrderNos.toList());
//   }

//   Future<void> _saveBannerShownOrders() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setStringList('bannerShownOrders', _bannerShownOrders.toList());
//   }
// }

//firebase related

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waiter_app/api_services/notification_service.dart';
import 'package:waiter_app/models/notification_item.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationItem> _notifications = [];
  final Set<String> _processedOrders = {};
  final Set<String> _readOrderNos = {};
  final Set<String> _bannerShownOrders = {};

  List<NotificationItem> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  String get badgeText =>
      unreadCount <= 0 ? '' : (unreadCount > 9 ? '9+' : '$unreadCount');

  Future<void> initializeNotifications() async {
    await _loadPersistedData();
    notifyListeners();
  }

  void addNotification(NotificationItem notification) {
    if (!_processedOrders.contains(notification.orderNo)) {
      notification.isRead = _readOrderNos.contains(notification.orderNo);
      _notifications.insert(0, notification);
      _processedOrders.add(notification.orderNo);

      if (!_bannerShownOrders.contains(notification.orderNo)) {
        _showBannerNotification(notification);
        _bannerShownOrders.add(notification.orderNo);
        _saveBannerShownOrders();
      }

      notifyListeners();
    }
  }

  void _showBannerNotification(NotificationItem notification) {
    NotificationService.showLocalNotification(
      title: 'New Order Ready',
      body:
          'Order #${notification.orderNo} is ready for Table ${notification.tableName}',
      payload: notification.orderNo, // Add payload for navigation
    );
  }

  // ... rest of your existing methods remain unchanged ...
  void markAsRead(int index) async {
    if (index >= 0 && index < _notifications.length) {
      _notifications[index].isRead = true;
      _readOrderNos.add(_notifications[index].orderNo);
      await _saveReadOrders();
      notifyListeners();
    }
  }

  void markAllAsRead() async {
    for (var notification in _notifications) {
      notification.isRead = true;
      _readOrderNos.add(notification.orderNo);
    }
    await _saveReadOrders();
    notifyListeners();
  }

  void removeNotification(int index) {
    if (index >= 0 && index < _notifications.length) {
      _processedOrders.remove(_notifications[index].orderNo);
      _notifications.removeAt(index);
      notifyListeners();
    }
  }

  void clearInMemoryNotifications() {
    _notifications.clear();
    _processedOrders.clear();
    notifyListeners();
  }

  void clearAllNotifications() async {
    _notifications.clear();
    _processedOrders.clear();
    _readOrderNos.clear();
    _bannerShownOrders.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('readOrderNos');
    await prefs.remove('bannerShownOrders');
    notifyListeners();
  }

  // Persistence methods
  Future<void> _loadPersistedData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load read notifications
    final readOrders = prefs.getStringList('readOrderNos') ?? [];
    _readOrderNos.addAll(readOrders);

    // Load banner-shown notifications
    final bannerShown = prefs.getStringList('bannerShownOrders') ?? [];
    _bannerShownOrders.addAll(bannerShown);
  }

  Future<void> _saveReadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('readOrderNos', _readOrderNos.toList());
  }

  Future<void> _saveBannerShownOrders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('bannerShownOrders', _bannerShownOrders.toList());
  }
}
