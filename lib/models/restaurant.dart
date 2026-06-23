import 'package:flutter/material.dart';
import 'package:food_express/core/money.dart';
import 'package:food_express/data/seed_menu.dart';
import 'package:food_express/models/cart_item.dart';
import 'package:food_express/models/food.dart';

@Deprecated('Use MenuProvider and CartProvider instead.')
class Restaurant extends ChangeNotifier {
  final List<CartItem> _cart = [];

  List<Food> get menu => seedMenu;
  List<CartItem> get cart => List.unmodifiable(_cart);

  void addToCart(Food food, List<Addon> selectedAddons, [int quantity = 1]) {
    final item = CartItem.fromFood(
      food,
      selectedAddons,
      quantity: quantity,
    );
    final index = _cart.indexWhere((entry) => entry.id == item.id);
    if (index == -1) {
      _cart.add(item);
    } else {
      _cart[index].quantity += quantity;
    }
    notifyListeners();
  }

  void removeFromCart(CartItem cartItem) {
    final index = _cart.indexWhere((entry) => entry.id == cartItem.id);
    if (index == -1) return;
    if (_cart[index].quantity <= 1) {
      _cart.removeAt(index);
    } else {
      _cart[index].quantity--;
    }
    notifyListeners();
  }

  void updateCartItemAddons(CartItem cartItem, List<Addon> newAddons) {
    final index = _cart.indexWhere((entry) => entry.id == cartItem.id);
    if (index == -1) return;
    _cart[index] = _cart[index].copyWith(selectedAddons: newAddons);
    notifyListeners();
  }

  int get totalPriceKobo =>
      _cart.fold<int>(0, (sum, item) => sum + item.lineTotalKobo);
  double get totalPrice => totalPriceKobo / 100;

  int getTotalItemCount() {
    return _cart.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  String displayCartReciept() {
    final receipt = StringBuffer()
      ..writeln("Here's your receipt.")
      ..writeln()
      ..writeln(DateTime.now())
      ..writeln('---------');
    for (final item in _cart) {
      receipt.writeln(
        '${item.quantity} x ${item.foodName} - ${formatKobo(item.lineTotalKobo)}',
      );
    }
    receipt
      ..writeln('---------')
      ..writeln('Subtotal: ${formatKobo(totalPriceKobo)}')
      ..writeln(
          'Delivery Fee: ${formatKobo(deliveryFeeForSubtotal(totalPriceKobo))}')
      ..writeln(
          'Total: ${formatKobo(totalPriceKobo + deliveryFeeForSubtotal(totalPriceKobo))}')
      ..writeln('Total Items: ${getTotalItemCount()}');
    return receipt.toString();
  }
}
