import 'dart:async';

import 'package:flutter/material.dart';
import 'package:food_express/models/food.dart';
import 'package:food_express/repositories/menu_repository.dart';

class MenuProvider extends ChangeNotifier {
  MenuProvider({
    MenuRepository? repository,
    bool firebaseEnabled = true,
  }) : _repository =
            repository ?? MenuRepository(firebaseEnabled: firebaseEnabled);

  final MenuRepository _repository;
  StreamSubscription<List<Food>>? _subscription;
  List<Food> _items = const [];
  bool _isLoading = true;
  String? _errorMessage;

  List<Food> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    await _subscription?.cancel();
    _isLoading = true;
    notifyListeners();
    _subscription = _repository.watchMenu().listen(
      (items) {
        _items = items;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (Object error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  List<Food> byCategory(FoodCategory category, String query) {
    final normalized = query.trim().toLowerCase();
    return _items.where((food) {
      final matchesCategory = food.category == category;
      final matchesQuery = normalized.isEmpty ||
          food.name.toLowerCase().contains(normalized) ||
          food.description.toLowerCase().contains(normalized);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
