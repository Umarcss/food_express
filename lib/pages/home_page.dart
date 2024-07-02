import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:food_express/components/current_location.dart';
import 'package:food_express/components/descrition_box.dart';
import 'package:food_express/components/my_drawer.dart';
import 'package:food_express/components/my_food_tile.dart';
import 'package:food_express/components/my_silver_appbar.dart';
import 'package:food_express/components/tab_bar.dart';
import 'package:food_express/models/food.dart';
import 'package:food_express/models/restaurant.dart';
import 'package:food_express/pages/food_page.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // tab controller
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: FoodCategory.values.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // sort out  and return a list of items that belong to a specific category
  List<Food> _filterMenuByCategory(FoodCategory category, List<Food> fullMemu) {
    return fullMemu.where((Food) => Food.category == category).toList();
  }

  // return the list of food in the given Category
  List<Widget> getFoodInThisCategory(List<Food> fullMemu) {
    return FoodCategory.values.map((category) {
      // get category menu
      List<Food> categoryMenu = _filterMenuByCategory(category, fullMemu);

      return ListView.builder(
        itemCount: categoryMenu.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          // get individual food
          final food = categoryMenu[index];

          // return food tile UI
          return FoodTile(
            food: food,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FoodPage(food: food),
              ),
            ),
          );
        },
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          MySilverAppBar(
              title: MyTabBar(tabController: _tabController),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    indent: 25,
                    endIndent: 25,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  //  switch

                  const CurrentLocation(),

                  // describtion box
                  const DescribtionBox(),
                ],
              )),
        ],
        body: Consumer<Restaurant>(
          builder: (context, restaurant, child) => TabBarView(
              controller: _tabController,
              children: getFoodInThisCategory(restaurant.menu)),
        ),
      ),
    );
  }
}
