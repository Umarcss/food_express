import 'package:flutter/material.dart';
import 'package:food_express/models/cart_item.dart';
import 'package:food_express/models/order.dart';
import 'package:food_express/repositories/order_repository.dart';
import 'package:food_express/services/payment_service.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider({
    OrderRepository? orderRepository,
    PaymentService? paymentService,
    bool firebaseEnabled = true,
  })  : _orderRepository = orderRepository ??
            OrderRepository(firebaseEnabled: firebaseEnabled),
        _paymentService =
            paymentService ?? PaymentService(firebaseEnabled: firebaseEnabled);

  final OrderRepository _orderRepository;
  final PaymentService _paymentService;
  FoodOrder? _currentOrder;
  final List<FoodOrder> _orderHistory = [];
  bool _isProcessing = false;
  String? _errorMessage;

  FoodOrder? get currentOrder => _currentOrder;
  List<FoodOrder> get orderHistory => List.unmodifiable(_orderHistory);
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;

  Future<bool> checkout({
    required String userId,
    required List<CartItem> items,
    required String deliveryAddress,
  }) async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final order = await _orderRepository.createOrder(
        userId: userId,
        cartItems: items,
        deliveryAddress: deliveryAddress,
      );
      final initialized = await _paymentService.initialize(order.id);
      final result = await _paymentService.launch(initialized.accessCode);
      if (!result.isSuccess) {
        _errorMessage =
            result.wasCancelled ? 'Payment was cancelled.' : result.message;
        return false;
      }
      final verified = await _paymentService.verify(
        result.reference.isEmpty ? initialized.reference : result.reference,
      );
      if (!verified) {
        _errorMessage = 'Payment could not be verified.';
        return false;
      }
      _setCurrentOrder(order);
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void useDemoOrder({
    required String userId,
    required List<CartItem> items,
    required String deliveryAddress,
  }) {
    final subtotal =
        items.fold<int>(0, (sum, item) => sum + item.lineTotalKobo);
    final deliveryFee = subtotal == 0 ? 0 : (subtotal * 0.1).round();
    final now = DateTime.now();
    final order = FoodOrder(
      id: 'demo-${now.microsecondsSinceEpoch}',
      userId: userId,
      items: items.map((item) => item.toOrderMap()).toList(),
      subtotalKobo: subtotal,
      deliveryFeeKobo: deliveryFee,
      totalKobo: subtotal + deliveryFee,
      status: OrderStatus.confirmed,
      paymentStatus: PaymentStatus.paid,
      deliveryAddress: deliveryAddress,
      createdAt: now,
      updatedAt: now,
      driver: const {
        'name': 'Abba Umar',
        'phone': '+2349162836212',
        'rating': '4.8',
      },
    );
    _setCurrentOrder(order);
  }

  void selectOrder(FoodOrder order) {
    _currentOrder = order;
    notifyListeners();
  }

  void updateCurrentOrderStatus(OrderStatus status) {
    final order = _currentOrder;
    if (order == null || order.status == status) return;
    _setCurrentOrder(order.copyWith(status: status, updatedAt: DateTime.now()));
  }

  void _setCurrentOrder(FoodOrder order) {
    _currentOrder = order;
    final index = _orderHistory.indexWhere((item) => item.id == order.id);
    if (index == -1) {
      _orderHistory.insert(0, order);
    } else {
      _orderHistory[index] = order;
      _orderHistory.sort((a, b) {
        final aDate = a.updatedAt ?? a.createdAt ?? DateTime(0);
        final bDate = b.updatedAt ?? b.createdAt ?? DateTime(0);
        return bDate.compareTo(aDate);
      });
    }
    notifyListeners();
  }
}
