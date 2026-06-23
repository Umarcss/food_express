import 'package:flutter/material.dart';
import 'package:food_express/core/money.dart';
import 'package:food_express/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class MyReceipt extends StatelessWidget {
  const MyReceipt({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in cart.items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(child: Text('${item.quantity} x ${item.foodName}')),
                const SizedBox(width: 8),
                Flexible(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(formatKobo(item.lineTotalKobo)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        const Divider(),
        Row(
          children: [
            const Text('Total'),
            const SizedBox(width: 8),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(formatKobo(cart.totalKobo)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class MyReciept extends MyReceipt {
  const MyReciept({super.key});
}
