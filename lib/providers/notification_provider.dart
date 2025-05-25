import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  final List<Map<String, dynamic>> _notifications = [];
  bool _hasUnreadNotifications = false;

  List<Map<String, dynamic>> get notifications => _notifications;
  bool get hasUnreadNotifications => _hasUnreadNotifications;

  Future<void> initialize() async {
    await _notificationService.initialize();
  }

  void addNotification({
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) {
    _notifications.insert(
      0,
      {
        'title': title,
        'body': body,
        'type': type,
        'data': data,
        'timestamp': DateTime.now(),
        'isRead': false,
      },
    );
    _hasUnreadNotifications = true;
    notifyListeners();

    // Show system notification
    _notificationService.showOrderStatusNotification(
      title: title,
      body: body,
      status: type,
    );
  }

  void markAsRead(int index) {
    if (index >= 0 && index < _notifications.length) {
      _notifications[index]['isRead'] = true;
      _hasUnreadNotifications = _notifications.any((n) => !n['isRead']);
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var notification in _notifications) {
      notification['isRead'] = true;
    }
    _hasUnreadNotifications = false;
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    _hasUnreadNotifications = false;
    notifyListeners();
  }
} 