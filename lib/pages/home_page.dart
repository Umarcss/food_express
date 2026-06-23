import 'package:flutter/material.dart';
import 'package:food_express/components/app_image.dart';
import 'package:food_express/components/empty_state.dart';
import 'package:food_express/components/food_card.dart';
import 'package:food_express/components/icon_glass_button.dart';
import 'package:food_express/components/price_text.dart';
import 'package:food_express/core/money.dart';
import 'package:food_express/design/app_theme.dart';
import 'package:food_express/main.dart';
import 'package:food_express/models/food.dart';
import 'package:food_express/pages/food_page.dart';
import 'package:food_express/providers/auth_provider.dart';
import 'package:food_express/providers/cart_provider.dart';
import 'package:food_express/providers/menu_provider.dart';
import 'package:food_express/providers/notification_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();
  FoodCategory _selectedCategory = FoodCategory.burgers;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFood(Food food) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FoodPage(food: food)),
    );
  }

  void _quickAdd(Food food) {
    context.read<CartProvider>().addFood(food, const []);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${food.name} added to cart')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final menu = context.watch<MenuProvider>();
    final cart = context.watch<CartProvider>();
    final notifications = context.watch<NotificationProvider>();
    final allItems = menu.items;
    final items = menu.byCategory(_selectedCategory, _query);
    final featured = allItems.take(5).toList();
    final heroFood = featured.isNotEmpty ? featured.first : null;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.sm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HomeTopBar(
                          name: auth.displayName,
                          address: auth.defaultAddress,
                          hasNotifications:
                              notifications.hasUnreadNotifications,
                          cartCount: cart.totalItemCount,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _SearchBox(
                          controller: _searchController,
                          query: _query,
                          onChanged: (value) => setState(() => _query = value),
                          onClear: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _PromoHero(food: heroFood),
                        const SizedBox(height: AppSpacing.lg),
                        _CategoryRail(
                          selectedCategory: _selectedCategory,
                          onSelected: (category) =>
                              setState(() => _selectedCategory = category),
                        ),
                        if (featured.isNotEmpty && _query.isEmpty) ...[
                          const SizedBox(height: AppSpacing.xl),
                          _SectionHeader(
                            title: 'Top picks today',
                            action: 'See all',
                            onAction: () => setState(
                              () => _selectedCategory = featured.first.category,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _TopPicks(
                            foods: featured,
                            onTap: _openFood,
                            onAdd: _quickAdd,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.xl),
                        _SectionHeader(
                          title: '${_selectedCategory.label} near you',
                          action: '${items.length} places',
                        ),
                      ],
                    ),
                  ),
                ),
                if (menu.isLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (items.isEmpty)
                  const SliverFillRemaining(
                    child: EmptyState(
                      icon: Icons.search_off,
                      title: 'No meals found',
                      message: 'Try another search term or category.',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      132,
                    ),
                    sliver: SliverList.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final food = items[index];
                        return FoodCard(
                          food: food,
                          onTap: () => _openFood(food),
                          onAdd: () => _quickAdd(food),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) Navigator.pushNamed(context, AppRoutes.cart);
          if (index == 2) Navigator.pushNamed(context, AppRoutes.profile);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.shopping_bag_outlined), label: 'Cart'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Me'),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:
          cart.isEmpty ? null : _CartPill(total: cart.totalKobo),
    );
  }
}

class _HomeTopBar extends StatelessWidget {
  final String name;
  final String address;
  final bool hasNotifications;
  final int cartCount;

  const _HomeTopBar({
    required this.name,
    required this.address,
    required this.hasNotifications,
    required this.cartCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Food Express',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  const Icon(Icons.near_me_rounded,
                      size: 18, color: AppColors.success),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      '$name • $address',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconGlassButton(
          icon: Icons.notifications_none_rounded,
          tooltip: 'Notifications',
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.notifications),
          badge: hasNotifications ? const _Badge(label: '!') : null,
        ),
        const SizedBox(width: AppSpacing.sm),
        IconGlassButton(
          icon: Icons.shopping_bag_outlined,
          tooltip: 'Cart',
          onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
          badge: cartCount > 0 ? _Badge(label: '$cartCount') : null,
        ),
      ],
    );
  }
}

class _SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBox({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: 'Search burgers, drinks, sides',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: query.isEmpty
            ? IconButton(
                tooltip: 'Filters',
                onPressed: () {},
                icon: const Icon(Icons.tune_rounded),
              )
            : IconButton(
                tooltip: 'Clear search',
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded),
              ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          borderSide: const BorderSide(color: AppColors.line),
        ),
      ),
    );
  }
}

class _PromoHero extends StatelessWidget {
  final Food? food;

  const _PromoHero({required this.food});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 176,
      decoration: BoxDecoration(
        color: AppColors.gold,
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppShadows.soft(AppColors.gold),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -22,
            bottom: -34,
            child: Transform.rotate(
              angle: -0.12,
              child: food == null
                  ? const Icon(Icons.lunch_dining_rounded,
                      size: 170, color: Colors.white)
                  : AppImage(
                      path: food!.imageUrl,
                      width: 190,
                      height: 150,
                      borderRadius: BorderRadius.circular(30),
                    ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                    child: const Text(
                      'Free delivery today',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Your cravings,\nin minutes',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          height: 1,
                          color: AppColors.charcoal,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    food == null ? 'Fresh meals around you' : food!.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRail extends StatelessWidget {
  final FoodCategory selectedCategory;
  final ValueChanged<FoodCategory> onSelected;

  const _CategoryRail({
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: FoodCategory.values.map((category) {
          final selected = category == selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: _CategoryChip(
              category: category,
              selected: selected,
              onTap: () => onSelected(category),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final FoodCategory category;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  IconData get icon {
    switch (category) {
      case FoodCategory.burgers:
        return Icons.lunch_dining_rounded;
      case FoodCategory.salads:
        return Icons.eco_rounded;
      case FoodCategory.sides:
        return Icons.local_fire_department_rounded;
      case FoodCategory.desserts:
        return Icons.icecream_rounded;
      case FoodCategory.drinks:
        return Icons.local_cafe_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      avatar: Icon(
        icon,
        size: 18,
        color: selected ? Colors.white : AppColors.charcoal,
      ),
      label: Text(category.label),
      backgroundColor: selected ? AppColors.charcoal : Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.charcoal,
        fontWeight: FontWeight.w900,
      ),
      side: BorderSide(color: selected ? AppColors.charcoal : AppColors.line),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.title,
    required this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        TextButton(
          onPressed: onAction,
          child: Text(action),
        ),
      ],
    );
  }
}

class _TopPicks extends StatelessWidget {
  final List<Food> foods;
  final ValueChanged<Food> onTap;
  final ValueChanged<Food> onAdd;

  const _TopPicks({
    required this.foods,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 208,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: foods.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final food = foods[index];
          return _PickCard(
            food: food,
            onTap: () => onTap(food),
            onAdd: () => onAdd(food),
          );
        },
      ),
    );
  }
}

class _PickCard extends StatelessWidget {
  final Food food;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  const _PickCard({
    required this.food,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 164,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AppImage(path: food.imageUrl, height: 104, width: 164),
                Positioned(
                  right: AppSpacing.sm,
                  top: AppSpacing.sm,
                  child: IconButton.filled(
                    tooltip: 'Quick add',
                    onPressed: onAdd,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.charcoal,
                      fixedSize: const Size(36, 36),
                    ),
                    icon: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const Row(
                    children: [
                      Icon(Icons.star_rounded, size: 16, color: AppColors.gold),
                      SizedBox(width: 2),
                      Text('4.8 • 20 min'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  PriceText(amountKobo: food.priceKobo),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartPill extends StatelessWidget {
  final int total;

  const _CartPill({required this.total});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: FilledButton.icon(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
          ),
          icon: const Icon(Icons.shopping_bag_rounded),
          label: Text('View cart • ${formatKobo(total)}'),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;

  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: const BoxDecoration(
        color: AppColors.gold,
        shape: BoxShape.circle,
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.charcoal,
          fontWeight: FontWeight.w900,
          fontSize: 11,
        ),
      ),
    );
  }
}
