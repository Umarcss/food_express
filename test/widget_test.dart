import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_express/data/seed_menu.dart';
import 'package:food_express/pages/login_page.dart';
import 'package:food_express/providers/auth_provider.dart';
import 'package:food_express/providers/cart_provider.dart';
import 'package:food_express/providers/notification_provider.dart';
import 'package:provider/provider.dart';

void main() {
  test('cart adds matching food and add-ons into one line item', () {
    final cart = CartProvider();
    final food = seedMenu.first;
    final addon = food.availableAddons.first;

    cart.addFood(food, [addon], quantity: 2);
    cart.addFood(food, [addon]);

    expect(cart.items, hasLength(1));
    expect(cart.items.first.quantity, 3);
    expect(cart.subtotalKobo, (food.priceKobo + addon.priceKobo) * 3);
    expect(cart.totalItemCount, 3);
  });

  test('cart removes items when quantity reaches zero', () {
    final cart = CartProvider();
    final food = seedMenu.first;

    cart.addFood(food, const []);
    cart.decrement(cart.items.first);

    expect(cart.items, isEmpty);
    expect(cart.subtotalKobo, 0);
  });

  testWidgets('login screen renders modern auth form', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ],
        child: const MaterialApp(home: LoginPage()),
      ),
    );

    expect(find.text('Food Express'), findsOneWidget);
    expect(find.text('Your cravings, delivered fast.'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}
