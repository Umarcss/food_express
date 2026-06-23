import 'package:flutter/material.dart';
import 'package:food_express/components/empty_state.dart';
import 'package:food_express/components/my_button.dart';
import 'package:food_express/components/my_cart_tile.dart';
import 'package:food_express/core/money.dart';
import 'package:food_express/design/app_theme.dart';
import 'package:food_express/main.dart';
import 'package:food_express/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          if (!cart.isEmpty)
            IconButton(
              tooltip: 'Clear cart',
              onPressed: cart.clear,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: cart.isEmpty
          ? EmptyState(
              icon: Icons.shopping_bag_outlined,
              title: 'Your cart is empty',
              message: 'Add a meal you love and it will appear here.',
              action: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Browse menu'),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                180,
              ),
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return Dismissible(
                  key: ValueKey(item.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => context.read<CartProvider>().remove(item),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: AppSpacing.lg),
                    color: AppColors.danger,
                    child:
                        const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  child: MyCartTile(cartItem: item),
                );
              },
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.86),
                  boxShadow: AppShadows.soft(AppColors.espresso),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadii.lg),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SummaryRow(
                      label: 'Subtotal',
                      value: formatKobo(cart.subtotalKobo),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _SummaryRow(
                      label: 'Delivery',
                      value: formatKobo(cart.deliveryFeeKobo),
                    ),
                    const Divider(height: 28),
                    _SummaryRow(
                      label: 'Total',
                      value: formatKobo(cart.totalKobo),
                      isTotal: true,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    PrimaryButton(
                      text: 'Proceed to checkout',
                      icon: Icons.payment,
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.checkout),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    final valueStyle = TextStyle(
      fontWeight: FontWeight.w900,
      fontSize: isTotal ? 20 : 15,
      color: isTotal ? AppColors.tomato : AppColors.charcoal,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 180) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: isTotal ? Theme.of(context).textTheme.titleMedium : null,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(value, style: valueStyle),
              ),
            ],
          );
        }
        return Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: isTotal ? Theme.of(context).textTheme.titleMedium : null,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Align(
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(value, style: valueStyle),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
