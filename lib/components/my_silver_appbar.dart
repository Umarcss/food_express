import 'package:flutter/material.dart';
import 'package:food_express/main.dart';
import 'package:food_express/providers/cart_provider.dart';
import 'package:food_express/providers/notification_provider.dart';
import 'package:provider/provider.dart';

class MySilverAppBar extends StatelessWidget {
  final Widget child;
  final Widget title;

  const MySilverAppBar({super.key, required this.child, required this.title});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final notifications = context.watch<NotificationProvider>();
    return SliverAppBar(
      expandedHeight: 320,
      collapsedHeight: 112,
      pinned: true,
      actions: [
        IconButton(
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.notifications),
          icon: Badge(
            isLabelVisible: notifications.hasUnreadNotifications,
            child: const Icon(Icons.notifications_outlined),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
          icon: Badge(
            isLabelVisible: cart.totalItemCount > 0,
            label: Text('${cart.totalItemCount}'),
            child: const Icon(Icons.shopping_cart_outlined),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          icon: const Icon(Icons.person_outline),
        ),
      ],
      title: const Text('Food Express'),
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.only(bottom: 48),
          child: child,
        ),
        title: title,
        centerTitle: true,
        expandedTitleScale: 1,
      ),
    );
  }
}
