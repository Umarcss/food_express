import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_express/core/money.dart';
import 'package:food_express/models/cart_item.dart';
import 'package:food_express/models/order.dart';

class OrderRepository {
  OrderRepository({
    FirebaseFirestore? firestore,
    bool firebaseEnabled = true,
  })  : _firestore = firestore,
        _firebaseEnabled = firebaseEnabled;

  final FirebaseFirestore? _firestore;
  final bool _firebaseEnabled;

  FirebaseFirestore get _db {
    if (!_firebaseEnabled) {
      throw StateError('Firebase is not configured for orders.');
    }
    return _firestore ?? FirebaseFirestore.instance;
  }

  Future<FoodOrder> createOrder({
    required String userId,
    required List<CartItem> cartItems,
    required String deliveryAddress,
  }) async {
    if (!_firebaseEnabled) {
      throw StateError(
        'Firebase is not configured. Use demo delivery or configure Firebase for this platform.',
      );
    }
    final subtotal = cartItems.fold<int>(
      0,
      (total, item) => total + item.lineTotalKobo,
    );
    final deliveryFee = deliveryFeeForSubtotal(subtotal);
    final payload = {
      'userId': userId,
      'items': cartItems.map((item) => item.toOrderMap()).toList(),
      'subtotalKobo': subtotal,
      'deliveryFeeKobo': deliveryFee,
      'totalKobo': subtotal + deliveryFee,
      'status': OrderStatus.pending.name,
      'paymentStatus': PaymentStatus.unpaid.name,
      'deliveryAddress': deliveryAddress,
      'driver': {
        'name': 'Abba Umar',
        'phone': '+2349162836212',
        'rating': '4.8',
      },
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final doc = await _db.collection('orders').add(payload);
    final snapshot = await doc.get();
    return FoodOrder.fromFirestore(snapshot);
  }

  Stream<FoodOrder?> watchOrder(String orderId) {
    if (!_firebaseEnabled) return Stream.value(null);
    return _db.collection('orders').doc(orderId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return FoodOrder.fromFirestore(doc);
    });
  }
}
