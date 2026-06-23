import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_express/data/seed_menu.dart';
import 'package:food_express/pages/login_page.dart';
import 'package:food_express/models/order.dart';
import 'package:food_express/providers/auth_provider.dart';
import 'package:food_express/providers/cart_provider.dart';
import 'package:food_express/providers/notification_provider.dart';
import 'package:food_express/providers/order_provider.dart';
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

  test('demo checkout creates session order history and updates status', () {
    final orders = OrderProvider(firebaseEnabled: false);
    final food = seedMenu.first;
    final cart = CartProvider()..addFood(food, const [], quantity: 2);

    orders.useDemoOrder(
      userId: 'demo-user',
      items: cart.items,
      deliveryAddress: '25 Abuja Road',
    );

    expect(orders.currentOrder, isNotNull);
    expect(orders.orderHistory, hasLength(1));
    expect(orders.currentOrder!.status, OrderStatus.confirmed);
    expect(orders.currentOrder!.totalItemCount, 2);

    orders.updateCurrentOrderStatus(OrderStatus.delivered);

    expect(orders.currentOrder!.status, OrderStatus.delivered);
    expect(orders.orderHistory.first.status, OrderStatus.delivered);
  });

  test('local demo notifications can be read and cleared', () async {
    final notifications = NotificationProvider(firebaseEnabled: false);

    notifications.addDemoNotification(
      title: 'Order confirmed',
      body: 'Your order is confirmed.',
    );

    expect(notifications.notifications, hasLength(1));
    expect(notifications.hasUnreadNotifications, isTrue);

    await notifications.markAsRead(notifications.notifications.first.id);

    expect(notifications.hasUnreadNotifications, isFalse);

    await notifications.clearNotifications();

    expect(notifications.notifications, isEmpty);
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
