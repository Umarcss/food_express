import 'package:flutter/material.dart';
import 'package:food_express/models/food.dart';

class MyTabBar extends StatelessWidget {
  final TabController tabController;

  const MyTabBar({
    super.key,
    required this.tabController,
  });

  List<Tab> _builderCategoryTabs() {
    return FoodCategory.values.map((category) {
      return Tab(
        text: category.label,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: tabController,
      tabs: _builderCategoryTabs(),
    );
  }
}
