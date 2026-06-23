import 'package:food_express/models/food.dart';

const List<Food> seedMenu = [
  Food(
    id: 'classic-cheese-burger',
    name: 'Classic Cheese Burger',
    description:
        'Juicy beef patty, cheddar, lettuce, tomato, pickles, and house sauce.',
    imageUrl: 'lib/images/burgers/double.jpg',
    priceKobo: 420000,
    category: FoodCategory.burgers,
    sortOrder: 1,
    availableAddons: [
      Addon(id: 'extra-cheese', name: 'Extra cheese', priceKobo: 60000),
      Addon(id: 'crispy-bacon', name: 'Crispy bacon', priceKobo: 90000),
      Addon(id: 'avocado', name: 'Avocado', priceKobo: 120000),
    ],
  ),
  Food(
    id: 'double-stack-burger',
    name: 'Double Stack Burger',
    description:
        'Two smashed patties, caramelized onions, pickles, and smoky aioli.',
    imageUrl: 'lib/images/burgers/double.jpg',
    priceKobo: 620000,
    category: FoodCategory.burgers,
    sortOrder: 2,
    availableAddons: [
      Addon(id: 'extra-cheese', name: 'Extra cheese', priceKobo: 60000),
      Addon(id: 'spicy-mayo', name: 'Spicy mayo', priceKobo: 35000),
    ],
  ),
  Food(
    id: 'garden-crunch-salad',
    name: 'Garden Crunch Salad',
    description:
        'Crisp greens, cucumber, sweet corn, cherry tomatoes, and lemon dressing.',
    imageUrl: 'lib/images/sides/pizza.jpeg',
    priceKobo: 310000,
    category: FoodCategory.salads,
    sortOrder: 3,
    availableAddons: [
      Addon(id: 'grilled-chicken', name: 'Grilled chicken', priceKobo: 120000),
      Addon(id: 'boiled-egg', name: 'Boiled egg', priceKobo: 50000),
    ],
  ),
  Food(
    id: 'loaded-fries',
    name: 'Loaded Fries',
    description:
        'Golden fries topped with cheese sauce, herbs, and spicy ketchup.',
    imageUrl: 'lib/images/sides/pizza.jpeg',
    priceKobo: 260000,
    category: FoodCategory.sides,
    sortOrder: 4,
    availableAddons: [
      Addon(id: 'extra-sauce', name: 'Extra sauce', priceKobo: 30000),
      Addon(id: 'chicken-bites', name: 'Chicken bites', priceKobo: 100000),
    ],
  ),
  Food(
    id: 'chocolate-parfait',
    name: 'Chocolate Parfait',
    description:
        'Layered chocolate cream, biscuit crumble, and a chilled caramel finish.',
    imageUrl: 'lib/images/burgers/double.jpg',
    priceKobo: 280000,
    category: FoodCategory.desserts,
    sortOrder: 5,
    availableAddons: [
      Addon(id: 'whipped-cream', name: 'Whipped cream', priceKobo: 40000),
    ],
  ),
  Food(
    id: 'zobo-spritz',
    name: 'Zobo Spritz',
    description: 'Hibiscus, citrus, ginger, and sparkling water over ice.',
    imageUrl: 'lib/images/sides/pizza.jpeg',
    priceKobo: 180000,
    category: FoodCategory.drinks,
    sortOrder: 6,
    availableAddons: [
      Addon(id: 'extra-ginger', name: 'Extra ginger', priceKobo: 20000),
    ],
  ),
];
