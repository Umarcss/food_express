import 'package:flutter/material.dart';
import 'package:food_express/design/app_theme.dart';
import 'package:food_express/main.dart';
import 'package:food_express/providers/auth_provider.dart';
import 'package:food_express/providers/order_provider.dart';
import 'package:provider/provider.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orderCount = context.watch<OrderProvider>().orderHistory.length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: _profileCardDecoration(),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: AppColors.gold,
                  child: Text(
                    auth.displayName.characters.first.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.charcoal,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(auth.displayName,
                          style: Theme.of(context).textTheme.titleLarge),
                      Text(auth.email),
                      if (auth.phone.isNotEmpty) Text(auth.phone),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _Tile(
            icon: Icons.history,
            title: 'Order history',
            subtitle: orderCount == 0
                ? 'Track demo and paid order activity'
                : '$orderCount session order${orderCount == 1 ? '' : 's'}',
            onTap: () => Navigator.pushNamed(context, AppRoutes.orderHistory),
          ),
          _Tile(
            icon: Icons.location_on_outlined,
            title: 'Delivery address',
            subtitle: auth.defaultAddress,
            onTap: () {},
          ),
          _Tile(
            icon: Icons.payment,
            title: 'Payment methods',
            subtitle: 'Demo mode until live payments are enabled',
            onTap: () {},
          ),
          _Tile(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'End this session',
            onTap: () async {
              await context.read<AuthProvider>().signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (_) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: _profileCardDecoration(),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.cream,
                child: Icon(icon, color: AppColors.charcoal),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

BoxDecoration _profileCardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(AppRadii.lg),
    border: Border.all(color: AppColors.line),
  );
}
