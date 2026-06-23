import 'package:flutter/material.dart';
import 'package:food_express/components/app_image.dart';
import 'package:food_express/components/glass_surface.dart';
import 'package:food_express/components/my_button.dart';
import 'package:food_express/components/price_text.dart';
import 'package:food_express/design/app_theme.dart';
import 'package:food_express/models/food.dart';
import 'package:food_express/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class FoodPage extends StatefulWidget {
  final Food food;

  const FoodPage({
    super.key,
    required this.food,
  });

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  final Set<Addon> _selectedAddons = {};
  int _quantity = 1;

  int get _unitTotal {
    return widget.food.priceKobo +
        _selectedAddons.fold<int>(0, (sum, addon) => sum + addon.priceKobo);
  }

  void _addToCart() {
    context.read<CartProvider>().addFood(
          widget.food,
          _selectedAddons.toList(),
          quantity: _quantity,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.food.name} added to cart')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton.filledTonal(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton.filledTonal(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Favorites coming soon')),
              );
            },
            icon: const Icon(Icons.favorite_border),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    AppImage(
                      path: widget.food.imageUrl,
                      height: 360,
                      width: double.infinity,
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.cream.withValues(alpha: 0.98),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      bottom: AppSpacing.lg,
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                          border: Border.all(color: AppColors.line),
                          boxShadow: AppShadows.soft(AppColors.charcoal),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.food.name,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(widget.food.description),
                            const SizedBox(height: AppSpacing.md),
                            const Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.sm,
                              children: [
                                _InfoPill(
                                  icon: Icons.star_rounded,
                                  label: '4.8 rated',
                                ),
                                _InfoPill(
                                  icon: Icons.schedule_rounded,
                                  label: '20-30 min',
                                ),
                                _InfoPill(
                                  icon: Icons.delivery_dining_rounded,
                                  label: 'Fast delivery',
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            PriceText(
                                amountKobo: widget.food.priceKobo,
                                fontSize: 22),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  120,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Quantity',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Spacer(),
                          _Stepper(
                            value: _quantity,
                            onDecrement: _quantity == 1
                                ? null
                                : () => setState(() => _quantity--),
                            onIncrement: () => setState(() => _quantity++),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Add-ons',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: widget.food.availableAddons.map((addon) {
                        final selected = _selectedAddons.contains(addon);
                        return FilterChip(
                          selected: selected,
                          label: Text(
                              '${addon.name} • ₦${addon.priceKobo ~/ 100}'),
                          onSelected: (value) {
                            setState(() {
                              if (value) {
                                _selectedAddons.add(addon);
                              } else {
                                _selectedAddons.remove(addon);
                              }
                            });
                          },
                          selectedColor: AppColors.charcoal,
                          backgroundColor: Colors.white,
                          checkmarkColor: AppColors.gold,
                          side: BorderSide(
                            color:
                                selected ? AppColors.charcoal : AppColors.line,
                          ),
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : AppColors.charcoal,
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      }).toList(),
                    ),
                  ]),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: AppShadows.soft(AppColors.charcoal),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Total'),
                          PriceText(amountKobo: _unitTotal * _quantity),
                        ],
                      ),
                    ),
                    Expanded(
                      child: PrimaryButton(
                        text: 'Add to cart',
                        icon: Icons.shopping_bag_outlined,
                        onPressed: _addToCart,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.success),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final int value;
  final VoidCallback? onDecrement;
  final VoidCallback onIncrement;

  const _Stepper({
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      radius: AppRadii.pill,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onDecrement,
            icon: const Icon(Icons.remove),
          ),
          Text('$value', style: Theme.of(context).textTheme.titleMedium),
          IconButton(
            onPressed: onIncrement,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
