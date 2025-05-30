import 'package:flutter/material.dart';
import 'package:food_express/auth/login_or_signup.dart';
import 'package:food_express/models/restaurant.dart';
import 'package:food_express/themes/theme_provider.dart';
import 'package:food_express/providers/notification_provider.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        // theme provider
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        // Restaurant provider
        ChangeNotifierProvider(create: (context) => Restaurant()),
        // Notification provider
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginOrSignup(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
