import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:food_express/models/cart_item.dart';
import 'package:food_express/models/food.dart';
import 'package:intl/intl.dart';

class Restaurant extends ChangeNotifier {
  // list of food menu
  final List<Food> _Menu = [
    // burgers
    Food(
        name: "classic chesse burger",
        describtion:
            "A juice beef patty with melted chedder, lettuce , tomato, and hint onions and pickle .",
        imagePath: "lib/images/burgers/double.jpg",
        price: 0.99,
        category: FoodCategory.burgers,
        availableAddons: [
          Addon(name: "Extra cheese", price: 300),
          Addon(name: "Becon", price: 500),
          Addon(name: "Avacado", price: 800)
        ]),
    Food(
        name: "classic chesse burger",
        describtion:
            "A juice beef patty with melted chedder, lettuce , tomato, and hint onions and pickle .",
        imagePath: "lib/images/burgers/double.jpg",
        price: 0.99,
        category: FoodCategory.burgers,
        availableAddons: [
          Addon(name: "Extra cheese", price: 300),
          Addon(name: "Becon", price: 500),
          Addon(name: "Avacado", price: 800)
        ]),
    Food(
        name: "classic chesse burger",
        describtion:
            "A juice beef patty with melted chedder, lettuce , tomato, and hint onions and pickle .",
        imagePath: "lib/images/burgers/double.jpg",
        price: 0.99,
        category: FoodCategory.burgers,
        availableAddons: [
          Addon(name: "Extra cheese", price: 300),
          Addon(name: "Becon", price: 500),
          Addon(name: "Avacado", price: 800)
        ]),
    Food(
        name: "classic chesse burger",
        describtion:
            "A juice beef patty with melted chedder, lettuce , tomato, and hint onions and pickle .",
        imagePath: "lib/images/burgers/double.jpg",
        price: 0.99,
        category: FoodCategory.burgers,
        availableAddons: [
          Addon(name: "Extra cheese", price: 300),
          Addon(name: "Becon", price: 500),
          Addon(name: "Avacado", price: 800)
        ]),
    Food(
        name: "classic chesse burger",
        describtion:
            "A juice beef patty with melted chedder, lettuce , tomato, and hint onions and pickle .",
        imagePath: "lib/images/burgers/double.jpg",
        price: 0.99,
        category: FoodCategory.burgers,
        availableAddons: [
          Addon(name: "Extra cheese", price: 300),
          Addon(name: "Becon", price: 500),
          Addon(name: "Avacado", price: 800)
        ]),
    // salads
    Food(
        name: "classic chesse salad",
        describtion:
            "A juice beef patty with melted chedder, lettuce , tomato, and hint onions and pickle .",
        imagePath: "lib/images/burgers/double.jpg",
        price: 0.99,
        category: FoodCategory.salads,
        availableAddons: [
          Addon(name: "Extra cheese", price: 300),
          Addon(name: "Becon", price: 500),
          Addon(name: "Avacado", price: 800)
        ]),
    Food(
        name: "classic chesse salad",
        describtion:
            "A juice beef patty with melted chedder, lettuce , tomato, and hint onions and pickle .",
        imagePath: "lib/images/burgers/double.jpg",
        price: 0.99,
        category: FoodCategory.salads,
        availableAddons: [
          Addon(name: "Extra cheese", price: 300),
          Addon(name: "Becon", price: 500),
          Addon(name: "Avacado", price: 800)
        ]),
    Food(
        name: "classic chesse salad",
        describtion:
            "A juice beef patty with melted chedder, lettuce , tomato, and hint onions and pickle .",
        imagePath: "lib/images/burgers/double.jpg",
        price: 0.99,
        category: FoodCategory.salads,
        availableAddons: [
          Addon(name: "Extra cheese", price: 300),
          Addon(name: "Becon", price: 500),
          Addon(name: "Avacado", price: 800)
        ]),
    Food(
        name: "classic chesse salad",
        describtion:
            "A juice beef patty with melted chedder, lettuce , tomato, and hint onions and pickle .",
        imagePath: "lib/images/burgers/double.jpg",
        price: 0.99,
        category: FoodCategory.salads,
        availableAddons: [
          Addon(name: "Extra cheese", price: 300),
          Addon(name: "Becon", price: 500),
          Addon(name: "Avacado", price: 800)
        ]),
    Food(
        name: "classic chesse salad",
        describtion:
            "A juice beef patty with melted chedder, lettuce , tomato, and hint onions and pickle .",
        imagePath: "lib/images/burgers/double.jpg",
        price: 0.99,
        category: FoodCategory.salads,
        availableAddons: [
          Addon(name: "Extra cheese", price: 300),
          Addon(name: "Becon", price: 500),
          Addon(name: "Avacado", price: 800)
        ]),

    //sides
    Food(
        name: "classic chesse burger",
        describtion:
            "A juice beef patty with melted chedder, lettuce , tomato, and hint onions and pickle .",
        imagePath: "lib/images/burgers/double.jpg",
        price: 0.99,
        category: FoodCategory.sides,
        availableAddons: [
          Addon(name: "Extra cheese", price: 300),
          Addon(name: "Becon", price: 500),
          Addon(name: "Avacado", price: 800)
        ]),
    Food(
        name: "classic chesse burger",
        describtion:
            "A juice beef patty with melted chedder, lettuce , tomato, and hint onions and pickle .",
        imagePath: "lib/images/burgers/double.jpg",
        price: 0.99,
        category: FoodCategory.sides,
        availableAddons: [
          Addon(name: "Extra cheese", price: 300),
          Addon(name: "Becon", price: 500),
          Addon(name: "Avacado", price: 800)
        ]),
    Food(
        name: "classic chesse burger",
        describtion:
            "A juice beef patty with melted chedder, lettuce , tomato, and hint onions and pickle .",
        imagePath: "lib/images/burgers/double.jpg",
        price: 0.99,
        category: FoodCategory.sides,
        availableAddons: [
          Addon(name: "Extra cheese", price: 300),
          Addon(name: "Becon", price: 500),
          Addon(name: "Avacado", price: 800)
        ]),
    Food(
        name: "classic chesse burger",
        describtion:
            "A juice beef patty with melted chedder, lettuce , tomato, and hint onions and pickle .",
        imagePath: "lib/images/burgers/double.jpg",
        price: 0.99,
        category: FoodCategory.sides,
        availableAddons: [
          Addon(name: "Extra cheese", price: 300),
          Addon(name: "Becon", price: 500),
          Addon(name: "Avacado", price: 800)
        ]),
    Food(
        name: "classic chesse burger",
        describtion:
            "A juice beef patty with melted chedder, lettuce , tomato, and hint onions and pickle .",
        imagePath: "lib/images/burgers/double.jpg",
        price: 0.99,
        category: FoodCategory.sides,
        availableAddons: [
          Addon(name: "Extra cheese", price: 300),
          Addon(name: "Becon", price: 500),
          Addon(name: "Avacado", price: 800)
        ]),

    // desserts
    Food(
        name: "classic chesse burger",
        describtion:
            "A juice beef patty with melted chedder, lettuce , tomato, and hint onions and pickle .",
        imagePath: "lib/images/burgers/double.jpg",
        price: 0.99,
        category: FoodCategory.desserts,
        availableAddons: [
          Addon(name: "Extra cheese", price: 300),
          Addon(name: "Becon", price: 500),
          Addon(name: "Avacado", price: 800)
        ]),
    Food(
        name: "classic chesse burger",
        describtion:
            "A juice beef patty with melted chedder, lettuce , tomato, and hint onions and pickle .",
        imagePath: "lib/images/burgers/double.jpg",
        price: 0.99,
        category: FoodCategory.desserts,
        availableAddons: [
          Addon(name: "Extra cheese", price: 300),
          Addon(name: "Becon", price: 500),
          Addon(name: "Avacado", price: 800)
        ]),
    Food(
        name: "classic chesse burger",
        describtion:
            "A juice beef patty with melted chedder, lettuce , tomato, and hint onions and pickle .",
        imagePath: "lib/images/burgers/double.jpg",
        price: 0.99,
        category: FoodCategory.desserts,
        availableAddons: [
          Addon(name: "Extra cheese", price: 300),
          Addon(name: "Becon", price: 500),
          Addon(name: "Avacado", price: 800)
        ]),
    Food(
        name: "classic chesse burger",
        describtion:
            "A juice beef patty with melted chedder, lettuce , tomato, and hint onions and pickle .",
        imagePath: "lib/images/burgers/double.jpg",
        price: 0.99,
        category: FoodCategory.desserts,
        availableAddons: [
          Addon(name: "Extra cheese", price: 300),
          Addon(name: "Becon", price: 500),
          Addon(name: "Avacado", price: 800)
        ]),
    Food(
        name: "classic chesse burger",
        describtion:
            "A juice beef patty with melted chedder, lettuce , tomato, and hint onions and pickle .",
        imagePath: "lib/images/burgers/double.jpg",
        price: 0.99,
        category: FoodCategory.desserts,
        availableAddons: [
          Addon(name: "Extra cheese", price: 300),
          Addon(name: "Becon", price: 500),
          Addon(name: "Avacado", price: 800)
        ]),

    // drinks
    Food(
        name: "classic chesse burger",
        describtion:
            "A juice beef patty with melted chedder, lettuce , tomato, and hint onions and pickle .",
        imagePath: "lib/images/burgers/double.jpg",
        price: 0.99,
        category: FoodCategory.drinks,
        availableAddons: [
          Addon(name: "Extra cheese", price: 300),
          Addon(name: "Becon", price: 500),
          Addon(name: "Avacado", price: 800)
        ]),
    Food(
        name: "classic chesse burger",
        describtion:
            "A juice beef patty with melted chedder, lettuce , tomato, and hint onions and pickle .",
        imagePath: "lib/images/burgers/double.jpg",
        price: 0.99,
        category: FoodCategory.drinks,
        availableAddons: [
          Addon(name: "Extra cheese", price: 300),
          Addon(name: "Becon", price: 500),
          Addon(name: "Avacado", price: 800)
        ]),
    Food(
        name: "classic chesse burger",
        describtion:
            "A juice beef patty with melted chedder, lettuce , tomato, and hint onions and pickle .",
        imagePath: "lib/images/burgers/double.jpg",
        price: 0.99,
        category: FoodCategory.drinks,
        availableAddons: [
          Addon(name: "Extra cheese", price: 300),
          Addon(name: "Becon", price: 500),
          Addon(name: "Avacado", price: 800)
        ]),
    Food(
        name: "classic chesse burger",
        describtion:
            "A juice beef patty with melted chedder, lettuce , tomato, and hint onions and pickle .",
        imagePath: "lib/images/burgers/double.jpg",
        price: 0.99,
        category: FoodCategory.drinks,
        availableAddons: [
          Addon(name: "Extra cheese", price: 300),
          Addon(name: "Becon", price: 500),
          Addon(name: "Avacado", price: 800)
        ]),
    Food(
        name: "classic chesse burger",
        describtion:
            "A juice beef patty with melted chedder, lettuce , tomato, and hint onions and pickle .",
        imagePath: "lib/images/burgers/double.jpg",
        price: 0.99,
        category: FoodCategory.drinks,
        availableAddons: [
          Addon(name: "Extra cheese", price: 300),
          Addon(name: "Becon", price: 500),
          Addon(name: "Avacado", price: 800)
        ]),
  ];
/*
  GETTERS 
*/

  List<Food> get menu => _Menu;
  List<CartItem> get cart => _cart;
/*  
  OPERATIONS 

*/

// user cart
  final List<CartItem> _cart = [];

  // add to cart
  void addToCart(Food food, List<Addon> selectedAddons, [int quantity = 1]) {
    // see if the item is already in cart
    CartItem? cartItem = _cart.firstWhereOrNull((item) {
      // check if the food items are the same
      bool isSameFood = item.food == food;

      // check if the list of selected addons are the same
      bool isSameAddons =
          const ListEquality().equals(item.selectedAddons, selectedAddons);

      return isSameFood && isSameAddons;
    });

    if (cartItem != null) {
      // if the item is already in cart, increase the quantity
      cartItem.quantity += quantity;
    } else {
      // if the item is not in cart, add it
      _cart.add(CartItem(
          food: food, selectedAddons: selectedAddons, quantity: quantity));
    }

    notifyListeners();
  }

  // remove to cart
  void removeFromCart(CartItem cartItem) {
    int cartIndex = _cart.indexOf(cartItem);

    if (cartIndex != -1) {
      if (_cart[cartIndex].quantity > 1) {
        _cart[cartIndex].quantity--;
      } else {
        _cart.removeAt(cartIndex);
      }
    }

    notifyListeners();
  }

  // get total price of cart
  double get totalPrice {
    double total = 0;
    for (CartItem item in _cart) {
      total += item.totalPrice;
    }
    return total;
  }

  // get total numbers of item in the cart

  int getTotalItemCount() {
    int totalItemCount = 0;

    for (CartItem cartItem in _cart) {
      totalItemCount += cartItem.quantity;
    }

    return totalItemCount;
  }

  // clear the cart
  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

/*
HELPERS

*/

// generate reciept
  String displayCartReciept() {
    final reciept = StringBuffer();
    reciept.writeln("Here's your reciept.");
    reciept.writeln();

    // format the date to include  up  to  seconds only
    String formattedDate =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    reciept.writeln(formattedDate);
    reciept.writeln();
    reciept.writeln("---------");

    for (final cartItem in _cart) {
      reciept.writeln(
          "${cartItem.quantity} x ${cartItem.food.name} - ${_formatPrice(cartItem.food.price)}");
      if (cartItem.selectedAddons.isEmpty) {
        reciept.writeln(" Add-ons: ${_formatAddons(cartItem.selectedAddons)}");
      }
      reciept.writeln();
    }

    reciept.writeln("---------");
    reciept.writeln();
    reciept.writeln("Total Items: ${getTotalItemCount()}");
    reciept.writeln("price Items: ${_formatPrice(totalPrice)}");

    return reciept.toString();
  }

// format double into money
  String _formatPrice(double price) {
    return "\N${price.toStringAsFixed(2)}";
  }

// format list of addons into a string summary
  String _formatAddons(List<Addon> addons) {
    return addons
        .map((addon) => "${addon.name} (${_formatPrice(addon.price)})")
        .join(", ");
  }
}
