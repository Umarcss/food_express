import 'package:flutter/material.dart';
import 'package:food_express/design/app_theme.dart';
import 'package:food_express/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: AppColors.line),
            ),
            child: SwitchListTile(
              activeThumbColor: AppColors.charcoal,
              activeTrackColor: AppColors.gold,
              contentPadding: EdgeInsets.zero,
              value: theme.isDarkMode,
              title: const Text('Dark mode'),
              subtitle: const Text('Use the deeper night palette'),
              onChanged: (_) => theme.toggleTheme(),
            ),
          ),
        ],
      ),
    );
  }
}
