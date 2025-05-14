import 'package:flutter/material.dart';
import 'package:waiter_app/api_services/notification_service.dart';
import 'package:waiter_app/models/notification_item.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationItem> _notifications = [];
  final Set<String> _processedOrders = {};
  final Set<String> _readOrderNos = {};

  List<NotificationItem> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  String get badgeText {
    if (unreadCount <= 0) return '';
    return unreadCount > 9 ? '9+' : '$unreadCount';
  }

  Future<void> initializeNotifications() async {
    await _loadReadNotifications();
    for (var notification in _notifications) {
      if (_readOrderNos.contains(notification.orderNo)) {
        notification.isRead = true;
      }
    }
    notifyListeners();
  }

  ///  Add new notification and trigger local notification with sound
  void addNotification(NotificationItem notification) {
    if (!_processedOrders.contains(notification.orderNo)) {
      notification.isRead = _readOrderNos.contains(notification.orderNo);
      _notifications.insert(0, notification);
      _processedOrders.add(notification.orderNo);
      notifyListeners();

      //  Trigger local notification sound
      NotificationService.showNotification(
        title: 'New Order Ready',
        body: 'Order #${notification.orderNo} is ready!',
      );
    }
  }

  void markAsRead(int index) async {
    if (index >= 0 && index < _notifications.length) {
      _notifications[index].isRead = true;
      _readOrderNos.add(_notifications[index].orderNo);
      await _saveReadNotifications();
      notifyListeners();
    }
  }

  void markAllAsRead() async {
    for (var notification in _notifications) {
      notification.isRead = true;
      _readOrderNos.add(notification.orderNo);
    }
    await _saveReadNotifications();
    notifyListeners();
  }

  void removeNotification(int index) {
    if (index >= 0 && index < _notifications.length) {
      final removedOrder = _notifications[index].orderNo;
      _processedOrders.remove(removedOrder);
      _notifications.removeAt(index);
      notifyListeners();
    }
  }

  void clearInMemoryNotifications() {
    _notifications.clear();
    _processedOrders.clear();
    notifyListeners();
  }

  void clearNotifications() async {
    _notifications.clear();
    _processedOrders.clear();
    _readOrderNos.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('readOrderNos');
    notifyListeners();
  }

  Future<void> _loadReadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('readOrderNos') ?? [];
    _readOrderNos.addAll(saved);
  }

  Future<void> _saveReadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('readOrderNos', _readOrderNos.toList());
  }
}
