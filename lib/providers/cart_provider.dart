import 'package:flutter/material.dart';
import 'package:food_express/core/money.dart';
import 'package:food_express/models/cart_item.dart';
import 'package:food_express/models/food.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  int get totalItemCount =>
      _items.fold<int>(0, (sum, item) => sum + item.quantity);
  int get subtotalKobo =>
      _items.fold<int>(0, (sum, item) => sum + item.lineTotalKobo);
  int get deliveryFeeKobo => deliveryFeeForSubtotal(subtotalKobo);
  int get totalKobo => subtotalKobo + deliveryFeeKobo;

  void addFood(Food food, List<Addon> selectedAddons, {int quantity = 1}) {
    final candidate = CartItem.fromFood(
      food,
      selectedAddons,
      quantity: quantity,
    );
    final index = _items.indexWhere((item) => item.id == candidate.id);
    if (index == -1) {
      _items.add(candidate);
    } else {
      _items[index].quantity += quantity;
    }
    notifyListeners();
  }

  void increment(CartItem item) {
    item.quantity += 1;
    notifyListeners();
  }

  void decrement(CartItem item) {
    final index = _items.indexWhere((entry) => entry.id == item.id);
    if (index == -1) return;
    if (_items[index].quantity <= 1) {
      _items.removeAt(index);
    } else {
      _items[index].quantity -= 1;
    }
    notifyListeners();
  }

  void remove(CartItem item) {
    _items.removeWhere((entry) => entry.id == item.id);
    notifyListeners();
  }

  void updateAddons(CartItem item, List<Addon> addons) {
    final index = _items.indexWhere((entry) => entry.id == item.id);
    if (index == -1) return;
    final updated = _items[index].copyWith(selectedAddons: addons);
    _items.removeAt(index);
    final existing = _items.indexWhere((entry) => entry.id == updated.id);
    if (existing == -1) {
      _items.insert(index.clamp(0, _items.length), updated);
    } else {
      _items[existing].quantity += updated.quantity;
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
