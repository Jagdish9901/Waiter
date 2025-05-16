import 'package:flutter/material.dart';
import 'package:waiter_app/api_services/notification_service.dart';
import 'package:waiter_app/models/notification_item.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// class NotificationProvider with ChangeNotifier {
//   List<NotificationItem> _notifications = [];
//   final Set<String> _processedOrders = {};
//   final Set<String> _readOrderNos = {};

//   List<NotificationItem> get notifications => _notifications;
//   int get unreadCount => _notifications.where((n) => !n.isRead).length;

//   String get badgeText {
//     if (unreadCount <= 0) return '';
//     return unreadCount > 9 ? '9+' : '$unreadCount';
//   }

//   Future<void> initializeNotifications() async {
//     await _loadReadNotifications();
//     for (var notification in _notifications) {
//       if (_readOrderNos.contains(notification.orderNo)) {
//         notification.isRead = true;
//       }
//     }
//     notifyListeners();
//   }

//   ///  Add new notification and trigger local notification with sound
//   void addNotification(NotificationItem notification) {
//     if (!_processedOrders.contains(notification.orderNo)) {
//       notification.isRead = _readOrderNos.contains(notification.orderNo);
//       _notifications.insert(0, notification);
//       _processedOrders.add(notification.orderNo);
//       notifyListeners();

//       //  Trigger local notification sound
//       NotificationService.showNotification(
//         title: 'New Order Ready',
//         body: 'Order #${notification.orderNo} is ready!',
//       );
//     }
//   }

//   void markAsRead(int index) async {
//     if (index >= 0 && index < _notifications.length) {
//       _notifications[index].isRead = true;
//       _readOrderNos.add(_notifications[index].orderNo);
//       await _saveReadNotifications();
//       notifyListeners();
//     }
//   }

//   void markAllAsRead() async {
//     for (var notification in _notifications) {
//       notification.isRead = true;
//       _readOrderNos.add(notification.orderNo);
//     }
//     await _saveReadNotifications();
//     notifyListeners();
//   }

//   void removeNotification(int index) {
//     if (index >= 0 && index < _notifications.length) {
//       final removedOrder = _notifications[index].orderNo;
//       _processedOrders.remove(removedOrder);
//       _notifications.removeAt(index);
//       notifyListeners();
//     }
//   }

//   void clearInMemoryNotifications() {
//     _notifications.clear();
//     _processedOrders.clear();
//     notifyListeners();
//   }

//   void clearNotifications() async {
//     _notifications.clear();
//     _processedOrders.clear();
//     _readOrderNos.clear();
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('readOrderNos');
//     notifyListeners();
//   }

//   Future<void> _loadReadNotifications() async {
//     final prefs = await SharedPreferences.getInstance();
//     final saved = prefs.getStringList('readOrderNos') ?? [];
//     _readOrderNos.addAll(saved);
//   }

//   Future<void> _saveReadNotifications() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setStringList('readOrderNos', _readOrderNos.toList());
//   }
// }

// notification not showing after logout

// class NotificationProvider with ChangeNotifier {
//   List<NotificationItem> _notifications = [];
//   final Set<String> _processedOrders = {};
//   final Set<String> _readOrderNos = {};

//   List<NotificationItem> get notifications => _notifications;
//   Set<String> get readOrderNos => _readOrderNos;
//   int get unreadCount => _notifications.where((n) => !n.isRead).length;

//   String get badgeText {
//     if (unreadCount <= 0) return '';
//     return unreadCount > 9 ? '9+' : '$unreadCount';
//   }

//   Future<void> initializeNotifications() async {
//     await _loadReadNotifications();
//     notifyListeners();
//   }

//   void addNotification(NotificationItem notification) {
//     final isNewOrder = !_processedOrders.contains(notification.orderNo);

//     if (isNewOrder) {
//       // Check if this was previously read
//       final wasPreviouslyRead = _readOrderNos.contains(notification.orderNo);

//       notification.isRead = wasPreviouslyRead;
//       _notifications.insert(0, notification);
//       _processedOrders.add(notification.orderNo);
//       notifyListeners();

//       // Only show notification if it wasn't previously read
//       if (!wasPreviouslyRead) {
//         NotificationService.showNotification(
//           title: 'New Order Ready',
//           body: 'Order #${notification.orderNo} is ready!',
//         );
//       }
//     }
//   }

//   void markAsRead(int index) async {
//     if (index >= 0 && index < _notifications.length) {
//       _notifications[index].isRead = true;
//       _readOrderNos.add(_notifications[index].orderNo);
//       await _saveReadNotifications();
//       notifyListeners();
//     }
//   }

//   void markAllAsRead() async {
//     for (var notification in _notifications) {
//       notification.isRead = true;
//       _readOrderNos.add(notification.orderNo);
//     }
//     await _saveReadNotifications();
//     notifyListeners();
//   }

//   void removeNotification(int index) {
//     if (index >= 0 && index < _notifications.length) {
//       final removedOrder = _notifications[index].orderNo;
//       _processedOrders.remove(removedOrder);
//       _notifications.removeAt(index);
//       notifyListeners();
//     }
//   }

//   void clearInMemoryNotifications() {
//     _notifications.clear();
//     _processedOrders.clear();
//     notifyListeners();
//   }

//   void clearNotifications() async {
//     _notifications.clear();
//     _processedOrders.clear();
//     _readOrderNos.clear();
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('readOrderNos');
//     notifyListeners();
//   }

//   Future<void> _loadReadNotifications() async {
//     final prefs = await SharedPreferences.getInstance();
//     final saved = prefs.getStringList('readOrderNos') ?? [];
//     _readOrderNos.addAll(saved);
//   }

//   Future<void> _saveReadNotifications() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setStringList('readOrderNos', _readOrderNos.toList());
//   }
// }

class NotificationProvider with ChangeNotifier {
  List<NotificationItem> _notifications = [];
  final Set<String> _processedOrders = {}; // Tracks orders we've seen
  final Set<String> _readOrderNos = {}; // Tracks read notifications
  final Set<String> _bannerShownOrders = {}; // Tracks banner-shown orders

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
      // set read status from persistence
      notification.isRead = _readOrderNos.contains(notification.orderNo);

      // Add to notifications list
      _notifications.insert(0, notification);
      _processedOrders.add(notification.orderNo);

      // Show banner if never shown before
      if (!_bannerShownOrders.contains(notification.orderNo)) {
        _showBannerNotification(notification);
        _bannerShownOrders.add(notification.orderNo);
        _saveBannerShownOrders();
      }

      notifyListeners();
    }
  }

  void _showBannerNotification(NotificationItem notification) {
    NotificationService.showNotification(
      title: 'New Order Ready',
      body: 'Order #${notification.orderNo} is ready!',
    );
  }

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
