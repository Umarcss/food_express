import 'dart:async';

import 'package:flutter/material.dart';
import 'package:food_express/models/app_notification.dart';
import 'package:food_express/repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationProvider({
    NotificationRepository? repository,
    bool firebaseEnabled = true,
  }) : _repository = repository ??
            NotificationRepository(firebaseEnabled: firebaseEnabled);

  final NotificationRepository _repository;
  StreamSubscription<List<AppNotification>>? _subscription;
  List<AppNotification> _notifications = const [];

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  bool get hasUnreadNotifications =>
      _notifications.any((notification) => !notification.isRead);

  void watchForUser(String? userId) {
    _subscription?.cancel();
    if (userId == null) {
      _notifications = const [];
      notifyListeners();
      return;
    }
    _subscription = _repository.watchUserNotifications(userId).listen(
      (notifications) {
        _notifications = notifications;
        notifyListeners();
      },
      onError: (Object error) {
        debugPrint('Notification stream error: $error');
      },
    );
  }

  Future<void> markAsRead(String id) => _repository.markAsRead(id);
  Future<void> markAllAsRead() => _repository.markAllAsRead(_notifications);
  Future<void> deleteNotification(String id) =>
      _repository.deleteNotification(id);
  Future<void> clearNotifications() =>
      _repository.clearNotifications(_notifications);

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
