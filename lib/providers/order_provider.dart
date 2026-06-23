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
  bool _isProcessing = false;
  String? _errorMessage;

  FoodOrder? get currentOrder => _currentOrder;
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
      _currentOrder = order;
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
    _currentOrder = FoodOrder(
      id: 'demo-order',
      userId: userId,
      items: items.map((item) => item.toOrderMap()).toList(),
      subtotalKobo: subtotal,
      deliveryFeeKobo: deliveryFee,
      totalKobo: subtotal + deliveryFee,
      status: OrderStatus.onTheWay,
      paymentStatus: PaymentStatus.paid,
      deliveryAddress: deliveryAddress,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      driver: const {
        'name': 'Abba Umar',
        'phone': '+2349162836212',
        'rating': '4.8',
      },
    );
    notifyListeners();
  }
}
