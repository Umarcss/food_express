import 'package:flutter/material.dart';
import 'package:food_express/components/my_quantity_selector.dart';
import 'package:food_express/models/cart_item.dart';
import 'package:food_express/models/restaurant.dart';
import 'package:food_express/models/food.dart';
import 'package:provider/provider.dart';

class MyCartTile extends StatefulWidget {
  final CartItem cartItem;

  const MyCartTile({super.key, required this.cartItem});

  @override
  State<MyCartTile> createState() => _MyCartTileState();
}

class _MyCartTileState extends State<MyCartTile> {
  late Map<Addon, bool> selectedAddons;

  @override
  void initState() {
    super.initState();
    selectedAddons = {};
    // Initialize selected addons map
    for (Addon addon in widget.cartItem.food.availableAddons) {
      selectedAddons[addon] = widget.cartItem.selectedAddons.contains(addon);
    }
  }

  void _updateAddons() {
    List<Addon> newSelectedAddons = selectedAddons.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    context
        .read<Restaurant>()
        .updateCartItemAddons(widget.cartItem, newSelectedAddons);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Restaurant>(
      builder: (context, restaurant, child) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // food image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      widget.cartItem.food.imagePath,
                      height: 100,
                      width: 100,
                    ),
                  ),

                  const SizedBox(width: 10),

                  // name and price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // food name
                      Text(widget.cartItem.food.name),

                      // food price
                      Text(
                        'N${widget.cartItem.food.price.toString()}',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // increment or decrement quantity
                  QuantitySelectos(
                    quantity: widget.cartItem.quantity,
                    food: widget.cartItem.food,
                    onDecrement: () {
                      restaurant.removeFromCart(widget.cartItem);
                    },
                    onIncrement: () {
                      restaurant.addToCart(
                          widget.cartItem.food, widget.cartItem.selectedAddons);
                    },
                  )
                ],
              ),
            ),

            // addons
            if (widget.cartItem.food.availableAddons.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Add-ons",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          widget.cartItem.food.availableAddons.map((addon) {
                        return FilterChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(addon.name),
                              Text(' (N${addon.price})'),
                            ],
                          ),
                          selected: selectedAddons[addon] ?? false,
                          onSelected: (bool selected) {
                            setState(() {
                              selectedAddons[addon] = selected;
                            });
                            _updateAddons();
                          },
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          selectedColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.2),
                          checkmarkColor: Theme.of(context).colorScheme.primary,
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                            fontSize: 12,
                          ),
                          shape: StadiumBorder(
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
