import 'package:food_express/models/food.dart';

class CartItem {
  final String id;
  final String foodId;
  final String foodName;
  final String imageUrl;
  final int unitPriceKobo;
  final List<Addon> selectedAddons;
  int quantity;

  CartItem({
    required this.id,
    required this.foodId,
    required this.foodName,
    required this.imageUrl,
    required this.unitPriceKobo,
    required this.selectedAddons,
    this.quantity = 1,
  });

  factory CartItem.fromFood(
    Food food,
    List<Addon> selectedAddons, {
    int quantity = 1,
  }) {
    final addonKey = selectedAddons.map((addon) => addon.id).toList()..sort();
    return CartItem(
      id: '${food.id}:${addonKey.join(',')}',
      foodId: food.id,
      foodName: food.name,
      imageUrl: food.imageUrl,
      unitPriceKobo: food.priceKobo,
      selectedAddons: List.unmodifiable(selectedAddons),
      quantity: quantity,
    );
  }

  int get addonsPriceKobo {
    return selectedAddons.fold<int>(
      0,
      (sum, addon) => sum + addon.priceKobo,
    );
  }

  int get lineTotalKobo => (unitPriceKobo + addonsPriceKobo) * quantity;

  double get totalPrice => lineTotalKobo / 100;

  CartItem copyWith({
    List<Addon>? selectedAddons,
    int? quantity,
  }) {
    final addons = selectedAddons ?? this.selectedAddons;
    final addonKey = addons.map((addon) => addon.id).toList()..sort();
    return CartItem(
      id: '$foodId:${addonKey.join(',')}',
      foodId: foodId,
      foodName: foodName,
      imageUrl: imageUrl,
      unitPriceKobo: unitPriceKobo,
      selectedAddons: List.unmodifiable(addons),
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toOrderMap() {
    return {
      'id': id,
      'foodId': foodId,
      'foodName': foodName,
      'imageUrl': imageUrl,
      'unitPriceKobo': unitPriceKobo,
      'quantity': quantity,
      'selectedAddons': selectedAddons.map((addon) => addon.toMap()).toList(),
      'lineTotalKobo': lineTotalKobo,
    };
  }
}
