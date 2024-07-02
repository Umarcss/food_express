// food item 
class Food {
  final String name;              // cheese burger
  final String describtion;       // burgerfull of cheese
  final String imagePath;         // lib/images/cheese_burger.png
  final double price;             //4.99
  final FoodCategory category;    // [extra cheese , sauce, extra patty]
  List<Addon> availableAddons;

  Food({
    required this.name,
    required this.describtion,
    required this.imagePath,
    required this.price,
    required this.category,
    required this.availableAddons,
    });
}


// food categories 

enum FoodCategory {
  burgers,
  salads,
  sides,
  desserts,
  drinks,
}


// food addons 

class Addon {
  String name;
  double price;

  Addon({
    required this.name, 
    required this.price,
    });
}