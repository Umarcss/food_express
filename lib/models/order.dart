import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  onTheWay,
  delivered,
  cancelled;

  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.onTheWay:
        return 'On the way';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  static OrderStatus fromName(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => OrderStatus.pending,
    );
  }
}

enum PaymentStatus {
  unpaid,
  initializing,
  pending,
  paid,
  failed,
  cancelled;

  static PaymentStatus fromName(String value) {
    return PaymentStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => PaymentStatus.unpaid,
    );
  }
}

class FoodOrder {
  final String id;
  final String userId;
  final List<Map<String, dynamic>> items;
  final int subtotalKobo;
  final int deliveryFeeKobo;
  final int totalKobo;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final String? paystackReference;
  final String deliveryAddress;
  final Map<String, dynamic>? driver;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const FoodOrder({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotalKobo,
    required this.deliveryFeeKobo,
    required this.totalKobo,
    required this.status,
    required this.paymentStatus,
    required this.deliveryAddress,
    this.paystackReference,
    this.driver,
    this.createdAt,
    this.updatedAt,
  });

  factory FoodOrder.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    final items = data['items'];
    return FoodOrder(
      id: snapshot.id,
      userId: data['userId'] as String? ?? '',
      items: items is List
          ? items
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList()
          : const [],
      subtotalKobo: (data['subtotalKobo'] as num?)?.toInt() ?? 0,
      deliveryFeeKobo: (data['deliveryFeeKobo'] as num?)?.toInt() ?? 0,
      totalKobo: (data['totalKobo'] as num?)?.toInt() ?? 0,
      status: OrderStatus.fromName(data['status'] as String? ?? ''),
      paymentStatus:
          PaymentStatus.fromName(data['paymentStatus'] as String? ?? ''),
      paystackReference: data['paystackReference'] as String?,
      deliveryAddress: data['deliveryAddress'] as String? ?? '',
      driver: data['driver'] is Map
          ? Map<String, dynamic>.from(data['driver'] as Map)
          : null,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
