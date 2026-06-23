import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_express/models/app_notification.dart';

class NotificationRepository {
  NotificationRepository({
    FirebaseFirestore? firestore,
    bool firebaseEnabled = true,
  })  : _firestore = firestore,
        _firebaseEnabled = firebaseEnabled;

  final FirebaseFirestore? _firestore;
  final bool _firebaseEnabled;

  FirebaseFirestore get _db {
    if (!_firebaseEnabled) {
      throw StateError('Firebase is not configured for notifications.');
    }
    return _firestore ?? FirebaseFirestore.instance;
  }

  Stream<List<AppNotification>> watchUserNotifications(String userId) {
    if (!_firebaseEnabled) return Stream.value(const []);
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final notifications = snapshot.docs
          .map((doc) => AppNotification.fromFirestore(doc))
          .toList();
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notifications;
    });
  }

  Future<void> markAsRead(String id) {
    if (!_firebaseEnabled) return Future<void>.value();
    return _db.collection('notifications').doc(id).update({
      'isRead': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markAllAsRead(List<AppNotification> notifications) {
    if (!_firebaseEnabled) return Future<void>.value();
    final batch = _db.batch();
    for (final notification in notifications.where((item) => !item.isRead)) {
      batch.update(_db.collection('notifications').doc(notification.id), {
        'isRead': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    return batch.commit();
  }

  Future<void> deleteNotification(String id) {
    if (!_firebaseEnabled) return Future<void>.value();
    return _db.collection('notifications').doc(id).delete();
  }

  Future<void> clearNotifications(List<AppNotification> notifications) {
    if (!_firebaseEnabled) return Future<void>.value();
    final batch = _db.batch();
    for (final notification in notifications) {
      batch.delete(_db.collection('notifications').doc(notification.id));
    }
    return batch.commit();
  }
}
