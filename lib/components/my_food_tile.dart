import 'package:flutter/material.dart';
import 'package:food_express/components/food_card.dart';
import 'package:food_express/models/food.dart';

class FoodTile extends StatelessWidget {
  final Food food;
  final void Function()? onTap;

  const FoodTile({
    super.key,
    required this.food,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FoodCard(food: food, onTap: onTap ?? () {});
  }
}
