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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: FoodCategory.values.length, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      // Animate to the selected tab
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // sort out  and return a list of items that belong to a specific category
  List<Food> _filterMenuByCategory(FoodCategory category, List<Food> fullMenu) {
    return fullMenu.where((food) => food.category == category).toList();
  }

  List<Food> _filterBySearch(List<Food> menu) {
    if (_searchQuery.isEmpty) return menu;
    return menu
        .where((food) =>
            food.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            food.describtion.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  // return the list of food in the given Category
  List<Widget> getFoodInThisCategory(List<Food> fullMenu) {
    return FoodCategory.values.map((category) {
      // get category menu
      List<Food> categoryMenu = _filterMenuByCategory(category, fullMenu);
      categoryMenu = _filterBySearch(categoryMenu);

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: categoryMenu.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 64,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No items found',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                key: ValueKey(category),
                itemCount: categoryMenu.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  // get individual food
                  final food = categoryMenu[index];

                  // return food tile UI
                  return Hero(
                    tag: 'food-${food.name}',
                    child: FoodTile(
                      food: food,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FoodPage(food: food),
                        ),
                      ),
                    ),
                  );
                },
              ),
      );
    }).toList();
  }

  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isSearching ? 60 : 0,
      child: _isSearching
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search food...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            )
          : null,
    );
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
                  _buildSearchBar(),
                  const CurrentLocation(),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isSearching = !_isSearching;
            if (!_isSearching) {
              _searchController.clear();
              _searchQuery = '';
            }
          });
        },
        child: Icon(_isSearching ? Icons.close : Icons.search),
      ),
    );
  }
}
