import 'package:flutter/material.dart';
import 'package:food_express/components/app_image.dart';
import 'package:food_express/components/price_text.dart';
import 'package:food_express/design/app_theme.dart';
import 'package:food_express/models/cart_item.dart';
import 'package:food_express/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class MyCartTile extends StatelessWidget {
  final CartItem cartItem;

  const MyCartTile({super.key, required this.cartItem});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppImage(
              path: cartItem.imageUrl,
              width: 92,
              height: 92,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.foodName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    cartItem.selectedAddons.isEmpty
                        ? 'No extras'
                        : cartItem.selectedAddons
                            .map((addon) => addon.name)
                            .join(', '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  PriceText(amountKobo: cartItem.lineTotalKobo),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _CartStepper(
              quantity: cartItem.quantity,
              onDecrement: () => cart.decrement(cartItem),
              onIncrement: () => cart.increment(cartItem),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _CartStepper({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Column(
        children: [
          IconButton(
            tooltip: 'Add one',
            onPressed: onIncrement,
            icon: const Icon(Icons.add_rounded),
          ),
          Text(
            '$quantity',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          IconButton(
            tooltip: 'Remove one',
            onPressed: onDecrement,
            icon: const Icon(Icons.remove_rounded),
          ),
        ],
      ),
    );
  }
}
