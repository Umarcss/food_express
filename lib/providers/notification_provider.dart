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
  List<AppNotification> _remoteNotifications = const [];
  final List<AppNotification> _localNotifications = [];

  List<AppNotification> get notifications {
    final items = [..._localNotifications, ..._remoteNotifications];
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(items);
  }

  bool get hasUnreadNotifications =>
      notifications.any((notification) => !notification.isRead);

  void watchForUser(String? userId) {
    _subscription?.cancel();
    if (userId == null) {
      _remoteNotifications = const [];
      _localNotifications.clear();
      notifyListeners();
      return;
    }
    _subscription = _repository.watchUserNotifications(userId).listen(
      (notifications) {
        _remoteNotifications = notifications;
        notifyListeners();
      },
      onError: (Object error) {
        debugPrint('Notification stream error: $error');
      },
    );
  }

  void addDemoNotification({
    required String title,
    required String body,
    String type = 'order',
    Map<String, dynamic>? data,
  }) {
    _localNotifications.insert(
      0,
      AppNotification(
        id: 'local-${DateTime.now().microsecondsSinceEpoch}',
        title: title,
        body: body,
        type: type,
        isRead: false,
        createdAt: DateTime.now(),
        data: data,
      ),
    );
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    final localIndex =
        _localNotifications.indexWhere((notification) => notification.id == id);
    if (localIndex != -1) {
      _localNotifications[localIndex] =
          _localNotifications[localIndex].copyWith(isRead: true);
      notifyListeners();
      return;
    }
    return _repository.markAsRead(id);
  }

  Future<void> markAllAsRead() async {
    for (var i = 0; i < _localNotifications.length; i++) {
      _localNotifications[i] = _localNotifications[i].copyWith(isRead: true);
    }
    notifyListeners();
    return _repository.markAllAsRead(_remoteNotifications);
  }

  Future<void> deleteNotification(String id) async {
    final removed =
        _localNotifications.any((notification) => notification.id == id);
    _localNotifications.removeWhere((notification) => notification.id == id);
    if (removed) {
      notifyListeners();
      return;
    }
    return _repository.deleteNotification(id);
  }

  Future<void> clearNotifications() async {
    _localNotifications.clear();
    notifyListeners();
    return _repository.clearNotifications(_remoteNotifications);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
